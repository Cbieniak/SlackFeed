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

	group_data = JSON.load(open("https://slack.com/api/groups.list?token=#{ENV['TOKEN']}&pretty=1"))
	@group_data = group_data["groups"].map{|summary_data| Group.new(summary_data) }
	@user_group_ids = []
	@group_data.each do |g_data|
			@channel_identifiers[g_data.id] = g_data.name
			@user_group_ids << g_data.id
	end
	#render json: @user_channel_ids
	messages = []
	@user_channel_ids.each do |channel_id|
		time = Time.now.to_i
		message_data = JSON.load(open("https://slack.com/api/channels.history?token=#{ENV['TOKEN']}&channel=#{channel_id}&oldest=#{time-3600}&count=10"))
		@message_data = message_data["messages"].map{|summary_data| Message.new(summary_data) }
		messages << {@channel_identifiers[channel_id] => @message_data} 
	end

	@user_group_ids.each do |group_id|
		time = Time.now.to_i
		message_data = JSON.load(open("https://slack.com/api/groups.history?token=#{ENV['TOKEN']}&channel=#{group_id}&oldest=#{time-3600}&count=10"))
		@message_data = message_data["messages"].map{|summary_data| Message.new(summary_data) }
		messages << {@channel_identifiers[group_id] => @message_data} 
	end

	render json: messages
 	#render json: @channel_data, each_serializer: ChannelSerializer
 	
 end
end
