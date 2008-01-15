class BzflagController < ApplicationController
  before_filter :authorize_admin_menu_perm, :except => [ :index, :servers ]

  def index
  end

  def servers
    @bz_servers = BzServer.find(:all, :order => "server_host_id, port", :include => ["last_chat_message", "last_filtered_message"])
  end

  def help
  end

  def reports
    msg_report_id = LogType.find_by_token("MSG-REPORT").id
    @reports = LogMessage.find(:all, :conditions => "log_type_id = #{msg_report_id}", :order => "logged_at desc", :limit => 100)
  end

  def bans
  end

  def recordings
  end

  def mailing_list
  end
end
