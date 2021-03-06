class SendReportPushJob < ActiveJob::Base
  queue_as :default

  def perform()
	# Create new RailsPushNotifications app for I devices
  	app = RailsPushNotifications::APNSApp.new
	app.apns_dev_cert = File.read('path/to/your/development/certificate.pem')
	app.apns_prod_cert = File.read('path/to/your/production/certificate.pem')
	app.sandbox_mode = true
	app.save
  	# Find all notifications that need to be sent
  	Api::V1::Notification.where('event_type = ?', Api::V1::Notification::TYPE_NEW_REPORT).order('created_at asc').find_each do |notify|

      	report = Api::V1::Report.find(notify.event_object_id)
      	# devices tokens
  		tokens = []
      	# Find user's device token
      	Api::V1::Device.where('user_id = ?', notify.user_id).find_each do |device|
      		# Add user's token to tokens array
      		tokens << device.token	
      	end

      	unless tokens.empty?
      		# Add new notification
	      	app.notifications.create(
				destinations: tokens,
				data: { aps: { alert: 'New report: ' + report.place, sound: 'true', badge: 1 } }
			)
			# Delete notification from notifications table - it will be delivered by push notification
      		notify.destroy	
      	end  
	end
	# Send push notifications
	app.push_notifications
  end
end