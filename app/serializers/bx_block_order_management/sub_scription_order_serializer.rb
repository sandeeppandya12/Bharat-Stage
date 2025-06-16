module BxBlockOrderManagement
  class SubScriptionOrderSerializer < BuilderBase::BaseSerializer
    attributes :id, :order_number, :status, :total, :gst, :sub_total, :valid_date, :active_plan, :order_date, :auto_renewal

    attribute :order_date do |order|
      order.order_date.in_time_zone("Asia/Kolkata").strftime("%d/%m/%Y (%I:%M %p)") if order.order_date.present?
    end

    attribute :valid_date do |order|
      order.valid_date.in_time_zone("Asia/Kolkata").strftime("%d/%m/%Y (%I:%M %p)") if order.valid_date.present?
    end

    attribute :subscription do |order|
      {
        id: order.subscription.id,
        name: order.subscription.name,
        price: order.subscription.price
      }
    end

    attribute :account do |order|
      {
        id: order.account.id,
        full_name: "#{order.account.first_name} #{order.account.last_name}",
        email: order.account.email
      }
    end
  end
end
