# frozen_string_literal: true

# == Schema Information
#
# Table name: order_items
#
#  id                      :bigint           not null, primary key
#  order_id                :bigint           not null
#  quantity                :integer
#  unit_price              :decimal(, )
#  total_price             :decimal(, )
#  old_unit_price          :decimal(, )
#  status                  :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  catalogue_id            :bigint           not null
#  catalogue_variant_id    :bigint           not null
#  order_status_id         :integer
#  placed_at               :datetime
#  confirmed_at            :datetime
#  in_transit_at           :datetime
#  delivered_at            :datetime
#  cancelled_at            :datetime
#  refunded_at             :datetime
#  manage_placed_status    :boolean          default(FALSE)
#  manage_cancelled_status :boolean          default(FALSE)
#
module BxBlockOrderManagement
  class OrderItem < BxBlockOrderManagement::ApplicationRecord
    self.table_name = :order_items

# Protected Area Start
    belongs_to :order, class_name: "BxBlockOrderManagement::Order", foreign_key: "order_management_order_id"
    belongs_to :catalogue, class_name: "BxBlockCatalogue::Catalogue"
    belongs_to :catalogue_variant,
      class_name: "BxBlockCatalogue::CatalogueVariant", optional: true

    belongs_to :order_status, optional: true

    has_many :order_trackings, class_name: "OrderTracking", as: :parent
    has_many :trackings, through: :order_trackings

# Protected Area End
    scope :get_records, ->(ids) { where(order_management_order_id: ids) }

    include AASM
    aasm column: "status" do
      state :in_cart, initial: true
      state :created, :placed, :confirmed, :in_transit, :delivered, :cancelled,
        :refunded, :payment_failed, :returned, :payment_pending

      event :in_cart do
        transitions to: :in_cart
      end

      event :created do
        transitions to: :created
      end

      event :pending_order do
        transitions from: %i[in_cart created payment_failed],
          to: :payment_pending,
          after: proc { |*_args| update_state_process }
      end

      event :place_order do
        transitions to: :placed,
          after: proc { |*_args| update_state_process }
      end

      event :confirm_order do
        transitions to: :confirmed,
          after: proc { |*_args| update_state_process }
      end

      event :to_transit do
        transitions to: :in_transit,
          after: proc { |*_args| update_state_process }
      end

      event :payment_failed do
        transitions to: :payment_failed,
          after: proc { |*_args| update_state_process }
      end

      event :deliver_order do
        transitions to: :delivered,
          after: proc { |*_args| update_state_process }
      end

      event :cancel_order do
        transitions to: :cancelled,
          after: proc { |*_args| update_state_process }
      end

      event :refund_order do
        transitions to: :refunded,
          after: proc { |*_args| update_state_process }
      end

      event :return_order do
        transitions to: :returned,
          after: proc { |*_args| update_state_process }
      end
    end

    before_save :update_prices
    before_save :set_item_status, if: :order_status_id_changed?
    after_save :update_product_stock, if: :order_status_id_changed?

    def update_prices
      if from_catalogue_warehouse
        self.unit_price = price
        self.total_price = order_item_total
      end
    end

    def set_item_status
      if status.present? && !order_status.present?
        self.order_status_id = OrderStatus.find_or_create_by(
          status: status
        ).id
      end
      event_name = order_status&.event_name
      send("#{event_name}!") unless order_status&.status == status
    end

    def is_order_paced
      !manage_placed_status && order_status.present? &&
        order_status.status == "placed"
    end

    def is_order_cancelled
      !manage_cancelled_status && order_status.present? &&
        order_status.status == "cancelled"
    end

    def update_product_stock
      product = catalogue_variant.present? ? catalogue_variant : catalogue
      if is_order_paced
        stock_qty = (product.stock_qty.to_i - quantity)
        block_qty = product.block_qty.to_i - quantity.to_i
        product.update!(stock_qty: stock_qty, block_qty: block_qty)
        if product.instance_of?(BxBlockCatalogue::CatalogueVariant)
          product.catalogue.update(
            stock_qty: product.catalogue.stock_qty - quantity,
            block_qty: product.catalogue.block_qty.to_i - quantity.to_i
          )
        end
        update(manage_placed_status: true)
      elsif is_order_cancelled
        # block_qty = product.block_qty.to_i - self.quantity.to_i
        product.update(stock_qty: product.stock_qty.to_i + quantity)
        if product.instance_of?(BxBlockCatalogue::CatalogueVariant)
          product.catalogue.update(stock_qty: product.catalogue.stock_qty + quantity)
        end
        update(manage_cancelled_status: true)
      end
    end

    def from_catalogue_warehouse
      catalogue_variant.present? ? catalogue_variant : catalogue
    end

    def price
      if catalogue_variant.present?
        if catalogue_variant.on_sale?
          catalogue_variant.sale_price
        else
          catalogue_variant.price
        end
      else
        catalogue&.on_sale? ? catalogue.sale_price : catalogue.price
      end
    end

    def order_item_total
      (quantity * price)
    end

    def update_state_process
      StateProcess.new(self, aasm).call
    end
  end
end
# rubocop:enable Metrics/MethodLength, Naming/PredicateName, Metrics/AbcSize, Metrics/BlockLength, Metrics/ClassLength
