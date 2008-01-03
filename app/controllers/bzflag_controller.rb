class BzflagController < ApplicationController
  before_filter :authorize, :except => [ :index, :servers ]

  def index
  end

  def servers
    case params[:sort]
    when 'host' then servers = BzServer.find(:all, :order => "server_host_id, port")
    when 'port' then servers = BzServer.find(:all, :order => "port, server_host_id")
    when 'map_name' then servers = BzServer.find(:all, :order => "map_name, server_host_id, port")
    else  servers = BzServer.find(:all, :order => "server_host_id, port")
    end

#    @bz_servers = servers.collect{ |b| [b, b.player_connections.find(:all, :order => "slot", :conditions => "part_at is null")] }      
    @bz_servers = servers.collect{ |b| [b, []] }

  end

  def help
  end

  def reports
    msg_report_id = LogType.find_by_token("MSG-REPORT").id
    @reports = LogMessage.find(:all, :conditions => "log_type_id = #{msg_report_id}", :order => "logged_at desc")
  end

  def players
    @num_callsigns = Callsign.count
    @num_ips = Ip.count
    @num_player_connections = PlayerConnection.count
    @num_log_messages = LogMessage.count
    @search_options = ['Callsign','IP','Hostname']
    @lastlog = LogMessage.find(:first, :order => "id desc")

    if request.post?
      
    end
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
