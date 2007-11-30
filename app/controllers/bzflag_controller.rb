class BzflagController < ApplicationController
  before_filter :authorize, :except => [ :index, :servers ]

  def index
  end

  def servers
    case params[:sort]
    when 'host' then @bz_servers = BzServer.find(:all, :order => "server_host_id, port")
    when 'port' then @bz_servers = BzServer.find(:all, :order => "port, server_host_id")
    when 'map_name' then @bz_servers = BzServer.find(:all, :order => "map_name, server_host_id, port")
    when 'chat' then @bz_servers = BzServer.find(:all, :order => "last_chat_at, server_host_id, port")
    when 'filtered_chat' then @bz_servers = BzServer.find(:all, :order => "last_filtered_chat_at, server_host_id, port")
    else  @bz_servers = BzServer.find(:all, :order => "server_host_id, port")
    end
  end

  def help
  end

  def reports
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
