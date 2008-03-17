class BzflagController < ApplicationController
  before_filter :authorize_admin_menu_perm, :except => [ :index ]

  def index
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
                                   :order => "logged_at desc",
                                   :include => "message")

    report_type_id = LogType.find_by_token("MSG-REPORT").id
    @recent_report_days = 3
    @recent_reports = LogMessage.find(:all, :conditions => "log_type_id = #{report_type_id} and logged_at > '#{db_date(@recent_report_days.days.ago)}'", :order => "logged_at desc")
  end

  def logs
    @bz_server = BzServer.find(params[:id])
    @log_messages = @bz_server.log_messages.find(:all, :conditions => "logged_at > '#{db_date(24.hours.ago)}'")
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
