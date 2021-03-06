class Api::V1::SpotEstimatesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_api_v1_spot_estimate, only: [:update, :destroy]

  # GET /api/v1/spot_estimates
  # GET /api/v1/spot_estimates.json
  def index
    head :not_found
    # @api_v1_spot_estimates = Api::V1::SpotEstimate.all

    # render json: @api_v1_spot_estimates
  end

  # GET /api/v1/spot_estimates/1
  # GET /api/v1/spot_estimates/1.json
  def show
    @api_v1_spot_estimate = Api::V1::SpotEstimate.where('spot_id = ? and user_id = ?', params[:id], @current_user.id).first

    unless @api_v1_spot_estimate.nil?
      render json: @api_v1_spot_estimate
    else
      head :not_found  
    end
  end

  # POST /api/v1/spot_estimates
  # POST /api/v1/spot_estimates.json
  def create
    unless Api::V1::SpotEstimate.where('spot_id = ? and user_id = ?', params[:spot_id], @current_user.id).first
      @api_v1_spot_estimate = Api::V1::SpotEstimate.new(api_v1_spot_estimate_params)
      @api_v1_spot_estimate.user_id = @current_user.id

      if @api_v1_spot_estimate.save
        render json: @api_v1_spot_estimate, status: :created, location: @api_v1_spot_estimate
      else
        render json: @api_v1_spot_estimate.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'you already voted!'}, status: 401        
    end
  end

  # PATCH/PUT /api/v1/spot_estimates/1
  # PATCH/PUT /api/v1/spot_estimates/1.json
  def update
    @api_v1_spot_estimate = Api::V1::SpotEstimate.where('spot_id = ? and user_id = ?', params[:id], @current_user.id).first

    if @api_v1_spot_estimate.update(api_v1_spot_estimate_params)
      head :no_content
    else
      render json: @api_v1_spot_estimate.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/spot_estimates/1
  # DELETE /api/v1/spot_estimates/1.json
  def destroy
    if @api_v1_spot_estimate.destroy
      head :no_content
    end
  end

  private

    def set_api_v1_spot_estimate
      @api_v1_spot_estimate = Api::V1::SpotEstimate.where('spot_id = ? and user_id = ?', params[:id], @current_user.id).first
    end

    def api_v1_spot_estimate_params
      params.permit(:spot_id, :rating, :best_month, :wave, :level, :sport)
    end
end
