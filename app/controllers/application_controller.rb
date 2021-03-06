class ApplicationController < ActionController::API
	include ActionController::Serialization

	rescue_from ActiveRecord::RecordNotFound, with: :not_found!

	attr_accessor :current_user

	def unauthenticated!
	  response.headers['WWW-Authenticate'] = "Token realm=Application"
	  render json: { error: 'Bad credentials' }, status: 401
	end

	def unauthorized!
	  render json: { error: 'not authorized' }, status: 403
	end

	def invalid_resource!(errors = [])
	  api_error(status: 422, errors: errors)
	end

	def not_found!
	  return api_error(status: 404, errors: 'Not found')
	end

	def api_error(status: 500, errors: [])
	  unless Rails.env.production?
	    puts errors.full_messages if errors.respond_to? :full_messages
	  end
	  head status: status and return if errors.empty?

	  render json: { error: errors }, status: status
	end

	def authenticate_user!
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)

    unless token.nil?
    	user = Api::V1::User.validate_token(token)
    	if user
    		@current_user = user
    	else
    		return unauthenticated!
    	end
    else
    	return unauthenticated!
    end
  end

	def update_last_activity!
		user_activity = Api::V1::UserActivity.where(id: @current_user.id).first_or_initialize
		user_activity.user_id = @current_user.id
		user_activity.updated_at = DateTime.now
		user_activity.save
	end
end
