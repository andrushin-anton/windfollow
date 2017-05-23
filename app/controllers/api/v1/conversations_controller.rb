class Api::V1::ConversationsController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /api/v1/conversations
  # GET /api/v1/conversations
  def index
    conversations = Api::V1::Conversation.where('sender_id = ? OR recipient_id = ?', @current_user.id, @current_user.id).order('updated_at DESC').all
    
    paginate json: conversations
  end

  # POST /api/v1/conversations
  # POST /api/v1/conversations.json
  def create
    if Api::V1::Conversation.between(@current_user.id, params[:recipient_id]).present?
        conversation = Api::V1::Conversation.between(@current_user.id, params[:recipient_id]).first
    else
      conversation = Api::V1::Conversation.new(conversation_params)
      conversation.sender_id = @current_user.id
      conversation.save
    end
    render json: conversation
  end

  private
    def conversation_params
      params.permit(:recipient_id)
    end
end
