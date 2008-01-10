class BzflagController < ApplicationController
  before_filter :authorize, :except => [ :index, :servers ]

  def index
  end

  def servers
    @bz_servers = BzServer.find(:all, :order => "server_host_id, port", :include => ["last_chat_message", "last_filtered_message"])
  end

  def help
  end

  def reports
    msg_report_id = LogType.find_by_token("MSG-REPORT").id
    @reports = LogMessage.find(:all, :conditions => "log_type_id = #{msg_report_id}", :order => "logged_at desc")
  end

  def players
    @search_options = ['Callsign','IP','Hostname']

    @ips = nil
    if request.post?
      if params[:search][:search_for] =~ /^%*$/
        flash[:notice] = "Please enter some search criteria"
      elsif params[:search][:search_by] == 'Callsign'
        @ips = Callsign.find(:all, :conditions => "name like '#{params[:search][:search_for]}'").collect{|x| x.ips}.flatten
      elsif params[:search][:search_by] == 'IP'
        @ips = Ip.find(:all, :conditions => "ip like '#{params[:search][:search_for]}'")
      elsif params[:search][:search_by] == 'Hostname'
        @ips = Ip.find(:all, :conditions => "hostname like '#{params[:search][:search_for]}'")
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
