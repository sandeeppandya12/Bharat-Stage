module BxBlockEmergency
  class EmergenciesController < ApplicationController
    before_action :set_emergency, only: %i[show update destroy]
    before_action :current_user

    def index
      emergencies = BxBlockEmergency::Emergency.all
      render json: emergencies, status: :ok
    end

    def show
      if @emergency
        render json: {
          data: ActiveModelSerializers::SerializableResource.new(@emergency, serializer: EmergencySerializer)
        }, status: :ok
      else
        render json: { message: 'Record not found' }, status: :not_found
      end
    end

    def create
      @emergency = BxBlockEmergency::Emergency.new(emergency_params)
      if @emergency.save
        render json: { emergency_details: BxBlockEmergency::EmergencySerializer.new(@emergency) },
               status: :created
      else
        render json: BxBlockEmergency::ErrorSerializer.new(@emergency), status: :unprocessable_entity
      end
    end

    def update
      emergency = @emergency.update(emergency_params)

      if emergency
        render json: { data: ActiveModelSerializers::SerializableResource.new(@emergency, serializer: EmergencySerializer) },
               status: :ok
      else
        render json: BxBlockEmergency::ErrorSerializer.new(@emergency), status: :unprocessable_entity
      end
    end

    def destroy
      if @emergency
        @emergency.update(is_active: false)
        render json: {
          message: 'Emergency details deleted successfully'
        }, status: :ok
      else
        render json: { message: 'Record not found' }, status: :not_found
      end
    end

    private

    def set_emergency
      @emergency = BxBlockEmergency::Emergency.find(params[:id])
    end

    def emergency_params
      params.require(:emergencies).permit(:name, :description, :type, :phone_number, :is_active,
                                                          :created_by, :updated_by)
      if params[:action] == 'create'
        permit_params.merge(created_by: @current_user.id)
      else
        permit_params.merge(updated_by: @current_user.id)
      end
    end
  end
end
