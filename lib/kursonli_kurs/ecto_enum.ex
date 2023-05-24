import EctoEnum

defenum(OrderType, :order_type, Application.get_env(:kursonli_kurs, :order_type))

defenum(OrderTransfer, :order_transfer, Application.get_env(:kursonli_kurs, :order_transfer))

defenum(OrderStatus, :order_status, [:success, :fail, :active])

defenum(ActiveStatus, :active_status, [:active, :archive])

defenum(FilialLink, :filial_link, [:slug, :url, :filial_id])

defenum(ScheduleType, :schedule_type, [:full, :nine_twenty, :nine_twenty_two])
