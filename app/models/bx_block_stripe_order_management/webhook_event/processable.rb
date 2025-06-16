module BxBlockStripeOrderManagement
  class WebhookEvent
    module Processable
      extend ActiveSupport::Concern

      class_methods do
        def process_from_event(event)
          webhook_event = build_from_event(event.deep_symbolize_keys)
          webhook_event.process
        end

        private

        def build_from_event(event)
          new(
            event_id: event.fetch(:event_id),
            event_type: event.fetch(:event_type),
            object_id: event.fetch(:object_id),
            payable_reference: event.fetch(:payable_reference),
            payload: event.fetch(:payload)
          )
        end
      end

      def process
        case event_type
        when "payment_intent.succeeded"
          create_order_transaction!
          order.confirm_order!
        when "payment_intent.payment_failed"
          create_order_transaction!
          order.payment_failed!
        else
          Rails.logger.debug("BxBlockStripeOrderManagement: Processing unsupported webhook event #{event_type}:#{event_id}")
        end
      end

      private

      def order
        @order ||= BxBlockOrderManagement::Order.find(payable_reference)
      end

      def create_order_transaction!
        BxBlockOrderManagement::OrderTransaction.create!(
          order: order,
          account: order.account,
          charge_id: charge_id,
          amount: amount,
          currency: currency,
          charge_status: event_type
        )
      end

      def charge
        payload.dig(:data, :object, :charges, :data).first
      end

      def charge_id
        charge.fetch(:id)
      end

      def amount
        charge.fetch(:amount).to_i
      end

      def currency
        charge.fetch(:currency).upcase
      end
    end
  end
end
