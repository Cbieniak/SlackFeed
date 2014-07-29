class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	require 'open-uri'
 def index
 	channel_data = JSON.load(open("https://slack.com/api/channels.list?token=#{ENV['TOKEN']}&pretty=1"))
	@channel_data = channel_data["channels"].map{|summary_data| Channel.new(summary_data) }
	@user_channel_ids = []
	@channel_identifiers = {}
	@channel_data.each do |c_data|
		unless !c_data.is_member
			@channel_identifiers[c_data.id] = c_data.name
			@user_channel_ids << c_data.id
		end
	end
	#render json: @user_channel_ids
	messages = []
	@user_channel_ids.each do |channel_id|
		time = Time.now.to_i
		#https://slack.com/api/channels.history?token=xoxp-2182263167-2213146441-2494958940-5d527f&channel=C025C7R53&oldest=1406507678.000003&count=10&pretty=1
		message_data = JSON.load(open("https://slack.com/api/channels.history?token=#{ENV['TOKEN']}&channel=#{channel_id}&oldest=#{time-3600}&count=10"))
		puts message_data
		@message_data = message_data["messages"].map{|summary_data| Message.new(summary_data) }
		messages << {@channel_identifiers[channel_id] => @message_data} 
	end
	render json: messages
 	#render json: @channel_data, each_serializer: ChannelSerializer
 	
 end
end
