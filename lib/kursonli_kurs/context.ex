defmodule KursonliKurs.Context do
  @moduledoc """
  Context macro
  """
  defmacro __using__(opts) do
    quote do
      import KursonliKurs.ContextFilters
      import Ecto.Query

      alias Ecto.Multi
      alias KursonliKurs.Repo

      @filters_module unquote(opts[:filters])

      @doc """
      Build composable query
      using filter pattern

      # Examples:
        iex> filter_by(from(u in "users"), %{name: "John"})
        #Ecto.Query<from u0 in \"users\", where: u0.name == ^"John">

      """
      def filter_by(query, filters) do
        Enum.reduce(filters, query, fn filter, query ->
          case filter do
            {:custom_filter, {filter, opts}} ->
              apply(@filters_module, :context_filter, [{filter, opts}, query])

            _ ->
              filter_next(filter, query)
          end
        end)
      end

      @doc """
      Return record wrapped in {:ok, struct()} tuple
      or {:error, :not_found} instead
      """
      @spec do_get(list()) :: {:ok, Ecto.Schema.t()} | {:error, :not_found}
      def do_get(opts), do: do_get(:get, opts)

      @spec do_get(Atom.t(), list()) :: {:ok, Ecto.Schema.t()} | {:error, :not_found}
      def do_get(fun, opts) do
        if __MODULE__.__info__(:functions)[fun] do
          case apply(__MODULE__, fun, [opts]) do
            nil -> {:error, :not_found}
            struct -> {:ok, struct}
          end
        else
          nil
        end
      end

      @doc false
      def transaction(operations, record, params, conn, result_hook \\ nil) do
        multi =
          Enum.reduce(
            [first_op | _] = operations,
            Multi.new(),
            &operation(&2, &1, record, params, conn)
          )

        case Repo.transaction(multi) do
          {:ok, res} ->
            success_key = multi_key_from_operation(first_op)
            transaction_result(res, success_key, result_hook)

          {:error, _key, changeset, _data} ->
            {:error, changeset}
        end
      end

      defp transaction_result(res, success_key, result_hook) do
        if is_function(result_hook),
          do: result_hook.(res),
          else: {:ok, res[success_key]}
      end

      defp operation(multi, operation, record, params, conn) do
        key = multi_key_from_operation(operation)

        Multi.run(multi, key, fn _, changes ->
          if is_function(operation),
            do: apply(operation, [changes, record, params, conn]),
            else: apply(__MODULE__, operation, [changes, record, params, conn])
        end)
      end

      defp multi_key_from_operation(operation) when is_function(operation) do
        fun_name = Function.info(operation)[:name]
        [_, name] = Regex.run(~r/-.+\.(.+)\//, Atom.to_string(fun_name))
        multi_key_from_operation(String.to_atom(name))
      end

      defp multi_key_from_operation(operation) do
        [prefix | keys] =
          operation
          |> Atom.to_string()
          |> String.split("_")

        string_key = Enum.join([prefix(prefix)] ++ keys, "_")
        String.to_atom(string_key)
      end

      defp prefix("create"), do: "created"
      defp prefix("update"), do: "updated"
      defp prefix("delete"), do: "deleted"
      defp prefix("add"), do: "added"
      defp prefix("reorder"), do: "reordered"
      defp prefix("assign"), do: "assigned"
      defp prefix(prefix), do: prefix

      @doc """
      Remove
      """
      def filtered_opts(opts, opts_to_remove) do
        Enum.reduce(opts_to_remove, opts, &Keyword.delete(&2, &1))
      end

      defp opts_to_map(opts) when is_map(opts), do: opts

      defp opts_to_map(opts) when is_list(opts) do
        Enum.reduce(opts, %{}, fn {key, value}, acc -> Map.put(acc, key, value) end)
      end

      # check if prodived id is uuid
      defguard uuid?(id) when is_binary(id) and byte_size(id) == 36
    end
  end
end
