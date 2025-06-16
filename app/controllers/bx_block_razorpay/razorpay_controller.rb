# frozen_string_literal: true
module BxBlockRazorpay
  class RazorpayController < ApplicationController
    before_action :find_order, only: :create_order
    before_action :find_razorpay_order, except: :create_order

    def create_order
      unless order_params[:amount].present? && order_params[:currency].present?
        return render json: { error: "Params Amount or currency missing!" }, status: :unprocessable_entity
      end

      receipt = generate_receipt(@order.id)
      razorpay_order = RazorpayIntegration.create(order_params.merge(receipt: receipt))
      
      shopping_cart_razorpay_order = RazorpayOrder.create(
        amount: razorpay_order.amount,
        status: razorpay_order.status,
        razorpay_order_id: razorpay_order.id,
        receipt: razorpay_order.receipt,
        account_id: @order.customer.id,
        order_id: @order.id,
        entity: razorpay_order.entity,
        amount_paid: razorpay_order.amount_paid,
        amount_due: razorpay_order.amount_due,
        currency: razorpay_order.currency,
        attempts: razorpay_order.attempts,
        offer_id: razorpay_order.offer_id,
        notes: razorpay_order.notes
      )

      render json: RazorpayOrderSerializer.new(shopping_cart_razorpay_order).serializable_hash,
        status: :ok

    rescue StandardError
      render json: { error: "Some error occurred" }, status: :ok
    end
    
    def order_details
      return if @razorpay_order.nil?

      render json: {
        order_details: {
          razorpay_order: RazorpayOrderSerializer.new(@razorpay_order).serializable_hash,
          order: BxBlockShoppingCart::OrderSerializer.new(@razorpay_order.order).serializable_hash
        },
        status: :ok
      }
    end

    def verify_payment_signature
      return if @razorpay_order.nil?
      status = RazorpayIntegration.verify_payment(payment_signature_params.to_h)

      if status
        attrs = payment_signature_params.to_h.merge(rpay_order_id: payment_signature_params[:razorpay_order_id], status: status)
        attrs.delete "razorpay_order_id"
        vps = @razorpay_order.create_verify_payment_signature(attrs)

        render json: VerifyPaymentSignatureSerializer.new(vps).serializable_hash, status: :ok
      end

    rescue StandardError, SecurityError => e
      render json: { error: "Some error occured" }, status: :ok
    end

    private

    def order_params
      params.require(:data).permit(:amount, :currency, notes: {})
    end
    
    def generate_receipt(order_id)
      Digest::MD5.hexdigest("SCOD#{order_id}")
    end

    def find_order
      @order = BxBlockShoppingCart::Order.find_by(id: params[:id])
      return render json: {error: "Data not found"}, status: :unprocessable_entity unless @order
    end

    def find_razorpay_order
      @razorpay_order = RazorpayOrder.find_by(razorpay_order_id: params[:razorpay_order_id])
    end

    def payment_signature_params
      params.permit(:razorpay_order_id, :razorpay_payment_id, :razorpay_signature)
    end
  end
end