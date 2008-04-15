class BzflagController < ApplicationController
  before_filter :authorize_admin_menu_perm, :except => [ :index ]

  def index
    @server_list = ServerList.new()

    if params && params[:server_list]
      @server_list.hide_disabled = params[:server_list][:hide_disabled].to_i
      @server_list.hide_idle = params[:server_list][:hide_idle].to_i
      @server_list.hide_stopped = params[:server_list][:hide_stopped].to_i
    else
      @server_list.hide_disabled = 1
      @server_list.hide_idle = 1
      @server_list.hide_stopped = 1
    end

    @bz_servers = BzServer.find(:all,
                                :order => "current_players_count desc, log_messages.logged_at desc, server_host_id, port",
                                :include => ["last_chat_message", "last_filtered_message", "current_players"])
    @total_players = @total_running_servers = 0
    @bz_servers.each do |b|
      @total_players += b.current_players_count
      @total_running_servers += 1 if b.server_status_message && b.server_status_message.message.text.capitalize == 'Running'
    end

    @recent_ban_days = 3
    command_type_id = LogType.find_by_token("MSG-COMMAND").id
    @recent_bans = LogMessage.find(:all, 
                                   :conditions => "log_type_id = #{command_type_id} and logged_at > '#{db_date(@recent_ban_days.days.ago)}' and (text like 'ban %' or text like 'unban %' or text like 'hostban %' or text like 'hostunban %' or text like 'idban %' or text like 'idunban %' or text like 'poll ban %')", 
                                   :order => "logged_at",
                                   :include => "message")

    report_type_id = LogType.find_by_token("MSG-REPORT").id
    @recent_report_days = 3
    @recent_reports = LogMessage.find(:all, :conditions => "log_type_id = #{report_type_id} and logged_at > '#{db_date(@recent_report_days.days.ago)}'", :order => "logged_at")
  end

  def help
  end

  def reports
    msg_report_id = LogType.find_by_token("MSG-REPORT").id
    @reports = LogMessage.find(:all,
                               :conditions => "log_type_id = #{msg_report_id}",
                               :order => "logged_at desc", :limit => 100)
  end

  def bans
  end

  def recordings
  end

  def mailing_list
  end
end
