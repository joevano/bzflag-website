class BzflagController < ApplicationController
  before_filter :authorize, :except => [ :index, :servers ]

  def index
  end

  def servers
    servers = BzServer.find(:all, :order => "server_host_id, port")
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

    @results = nil
    if request.post?
      if params[:search][:search_by] == 'Callsign'
        @results = Callsign.find(:all, :conditions => "name like '#{params[:search][:search_for]}'").collect{|x| x.name}.uniq
      elsif params[:search][:search_by] == 'IP'
        @results = Ip.find(:all, :conditions => "ip like '#{params[:search][:search_for]}'").collect{|x| "#{x.ip} #{x.hostname}"}.uniq
      elsif params[:search][:search_by] == 'Hostname'
        @results = Ip.find(:all, :conditions => "hostname like '#{params[:search][:search_for]}'").collect{|x| "#{x.ip} #{x.hostname}"}.uniq
      end
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
