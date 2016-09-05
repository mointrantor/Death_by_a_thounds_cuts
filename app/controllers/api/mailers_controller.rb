module Api
  class MailersController < ApplicationController
  	http_basic_authenticate_with name: "admin", password: "password"
    after_filter :send_thirdparty_mail
  	respond_to :json
    require 'json'

  	def send_mail
  		case request.format
    	when Mime::XML, Mime::ATOM, Mime::JSON
			 render json: {status: 'ok'}
    	end
  	end
    
    def send_thirdparty_mail
      json_body = JSON.parse(params.first[0])
      UserNotifier.send_mobile_notification_mail(json_body['header'], json_body['body']).deliver!
    end  

  end
end  