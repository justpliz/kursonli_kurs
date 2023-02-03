import EctoEnum

defenum(OrderType, :order_type, Application.get_env(:kursonli_kurs, :order_type))

defenum(OrderTransfer, :order_transfer, Application.get_env(:kursonli_kurs, :order_transfer))

defenum(OrderStatus, :order_status, [:success, :fail, :active])

defenum(ActiveStatus, :active_status, [:active, :archive])
