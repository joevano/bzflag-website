class BzflagController < ApplicationController

  def index
  end

  def servers
    @bz_servers = BzServer.find(:all, :order => "server_host_id, port")
    respond_to do |format|
      format.html
      format.xml { render :xml => @bz_servers.to_xml() }
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
end
