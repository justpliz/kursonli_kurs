import EctoEnum

defenum(OrderType, :order_type, [:purchase, :sale])

defenum(OrderTransfer, :order_transfer, [:green, :red, :red_green])

defenum(OrderStatus, :order_status, [:success, :fail, :active])

defenum(PaymentStatus, :payment_status, [:paid, :not_paid])


