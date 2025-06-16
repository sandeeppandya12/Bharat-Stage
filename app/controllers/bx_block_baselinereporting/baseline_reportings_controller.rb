module BxBlockBaselinereporting
  class BaselineReportingsController < ApplicationController
  	before_action :set_baseline_reporting_params, only: [:show, :update, :destroy]

  	def index
  		baseline_reportings = BxBlockBaselinereporting::BaselineReporting.all
  		render json: BxBlockBaselinereporting::BaselineReportingSerializer.new(baseline_reportings).serializable_hash, status: :ok
  	end

  	def create
  		baseline_reporting = BxBlockBaselinereporting::BaselineReporting.new(baseline_reporting_params)
  		if baseline_reporting.save
  			render json: BxBlockBaselinereporting::BaselineReportingSerializer.new(baseline_reporting).serializable_hash, status: :created
  		else
  			render json: {errors: [ {message: "baseline reporting not created."}]}, status: :unprocessable_entity and return
  		end
  	end

  	def update
  		if @baseline_reporting.update(baseline_reporting_params)
  			render json: BxBlockBaselinereporting::BaselineReportingSerializer.new(@baseline_reporting).serializable_hash, status: :ok
  		else
  			render json: {errors: [ {message: "baseline reporting not updated."}]}, status: :unprocessable_entity and return
  		end
  	end

  	def show
  		render json: BxBlockBaselinereporting::BaselineReportingSerializer.new(@baseline_reporting).serializable_hash, status: :ok
  	end

  	def destroy
  		if @baseline_reporting
  			render json: {success: [
  								{message: "Baseline reporting deleted."}
  							]}, status: :ok
  		else
  			render json: {errors: [ {message: "baseline reporting can not be deleted."}]}, status: :unprocessable_entity and return
  		end
  	end

    def total_sos_count
		  start_date, end_date = parsed_range(params[:timeframe])

		  if params[:timeframe] == "month"
		    arr = count_sos_by_month(start_date, end_date)
		  elsif params[:timeframe] == "week"
		    arr = count_sos_by_week(start_date, end_date)
		  elsif !params[:timeframe].is_a?(String) && params[:timeframe].present?
		    arr = count_sos_by_custom_date(start_date, end_date)
		  else
		    arr = count_sos_by_day(start_date)
		  end

		  render json: { "data": arr }
		end

		private

		def parsed_date
		  Date.today
		end

		def parsed_range(range = 'day')
		  range = params[:timeframe] == "today" ? "day" : range

		  if params[:timeframe].is_a?(String)
		    [parsed_date.send("beginning_of_#{range}"), parsed_date.send("end_of_#{range}")]
		  else
		    [
		      params.dig(:timeframe, :start_date) || parsed_date.beginning_of_day,
		      params.dig(:timeframe, :end_date) || parsed_date.end_of_day
		    ]
		  end
		end

		def count_sos_by_month(start_date, end_date)
		  total_sos = BxBlockEmergency::Emergency.count_sos(start_date, end_date)
		  arr = Array.new(12, 0)
		  arr[Date.today.month - 1] = total_sos
		  arr
		end

		def count_sos_by_week(start_date, end_date)
		  arr = (start_date..end_date).map do |weekday|
				BxBlockEmergency::Emergency.count_sos(weekday.beginning_of_day, weekday.end_of_day)
		  end
		  arr
		end

		def count_sos_by_custom_date(start_date, end_date)
		  arr = Array.new(12, 0)
		  current_date = start_date.to_date.beginning_of_month
		  start_date = start_date.to_date

		  while current_date <= end_date.to_date
		    month_index = current_date.month - 1

		    if start_date.month == current_date.month
		      data_count = BxBlockEmergency::Emergency.count_sos(start_date.beginning_of_day, current_date.end_of_month)
		    elsif end_date.to_date.month == current_date.month
		      data_count = BxBlockEmergency::Emergency.count_sos(current_date.beginning_of_month, end_date.to_date.end_of_day)
		    else
		      data_count = BxBlockEmergency::Emergency.count_sos(current_date.beginning_of_month, current_date.end_of_month)
		    end

		    arr[month_index] = data_count
		    current_date = current_date.next_month
		  end

		  arr
		end

		def count_sos_by_day(start_date)
		  arr = (start_date.to_date.all_week).map do |weekday|
		  	if weekday == start_date
					BxBlockEmergency::Emergency.count_sos(weekday.beginning_of_day, weekday.end_of_day)
		    else
		    	0
		    end
		  end
		  arr
		end


  	def baseline_reporting_params
  		params.require(:baseline_reporting).permit(:sos_time)
  	end

  	def set_baseline_reporting_params
  		@baseline_reporting = BxBlockBaselinereporting::BaselineReporting.find_by!(id: params[:id])
  	end
  end
end
