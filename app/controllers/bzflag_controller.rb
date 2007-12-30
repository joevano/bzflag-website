class BzflagController < ApplicationController
  before_filter :authorize, :except => [ :index, :servers ]

  def index
  end

  def servers
    case params[:sort]
    when 'host' then @bz_servers = BzServer.find(:all, :order => "server_host_id, port")
    when 'port' then @bz_servers = BzServer.find(:all, :order => "port, server_host_id")
    when 'map_name' then @bz_servers = BzServer.find(:all, :order => "map_name, server_host_id, port")
    else  @bz_servers = BzServer.find(:all, :order => "server_host_id, port")
    end
  end

  def help
  end

  def reports
    msg_report_id = LogType.find_by_token("MSG-REPORT").id
    @reports = LogMessage.find(:all, :conditions => "log_type_id = #{msg_report_id}", :order => "logged_at desc")
  end

  def players
    @players = User.find(:all).collect { |p| p.callsign }
  end

  def bans
  end

  def recordings
  end

  def mailing_list
  end

  private

  def authorize
    unless @admin_menu_perm
      flash[:notice] = "Access Denied."
      redirect_to(:controller => "bzflag", :action => "index")
    end
  end
end
