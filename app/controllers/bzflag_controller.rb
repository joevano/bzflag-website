class BzflagController < ApplicationController

  def index
  end

  def servers
    @bz_servers = BzServer.find(:all, :order => "server_host_id, port")
  end

  def help
  end

  def reports
  end

  def players
  end

  def bans
  end

  def recordings
  end

  def admins
    @jradmins = Group.find_by_name("NORANG.JRADMIN").users.collect { |u| u.callsign }
    @sradmins = Group.find_by_name("NORANG.SRADMIN").users.collect { |u| u.callsign }
    @tradmins = Group.find_by_name("NORANG.TRADMIN").users.collect { |u| u.callsign }
    @developers = Group.find_by_name("Developers").users.collect { |u| u.callsign }
  end

  def mailing_list
  end
end
