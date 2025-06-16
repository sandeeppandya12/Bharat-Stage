module BxBlockStripeOrderManagement
  class PaymentIntentDelegate
    attr_reader :payable_reference

    class << self
      def create(payable_reference)
        new(payable_reference)
      end
    end

    def initialize(payable_reference)
      @payable_reference = payable_reference
    end

    def amount_in_cents
      (order.total * 100).to_i
    end

    # The only way to get currency of the order is this chain of relations.
    # We could use order.order_transaction.currency, but order_transaction is no being used/populated yet.
    def currency
      raise BxBlockStripeIntegration::PayablePreconditionsUnmet, diff_currencies_error unless same_currency_across_order_items?

      uniq_order_item_currencies.first
    end

    private

    def order
      @order ||= BxBlockOrderManagement::Order.find(payable_reference)
    end

    def same_currency_across_order_items?
      uniq_order_item_currencies.size == 1
    end

    def uniq_order_item_currencies
      @uniq_order_item_currencies ||= order.order_items.map do |order_item|
        order_item
          .catalogue
          .brand
          .currency
      end
        .uniq
    end

    def diff_currencies_error
      "Order items have different currencies: #{uniq_order_item_currencies.join(", ")}"
    end
  end
end
