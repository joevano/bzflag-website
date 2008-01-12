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

    @ips = []
    @matches = nil
    if request.post?
      @matches = 0
      @player_search = PlayerSearch.new()
      @player_search.search_by = params[:player_search][:search_by]
      @player_search.search_for = params[:player_search][:search_for]
      ips = []
      if params[:player_search][:search_for] =~ /^%*$/
        flash.now[:notice] = "Please enter some search criteria"
      elsif params[:player_search][:search_by] == 'Callsign'
        ips = Callsign.find(:all, :conditions => [ "name like ?", params[:player_search][:search_for]]).collect{|x| x.ips}
      elsif params[:player_search][:search_by] == 'IP'
        if params[:player_search][:search_for] =~ /^%*(\.%){0,3}$/
          flash.now[:notice] = "IP Search criteria will return too many matches - try something else."
        else
          ips = Ip.find(:all, :conditions => [ "ip like ?", params[:player_search][:search_for]])
        end
      elsif params[:player_search][:search_by] == 'Hostname'
        if params[:player_search][:search_for] =~ /^[%\.]+[^.]*$/
          flash.now[:notice] = "Hostname search criteria will return too many matches - try something else."
        else
          ips = Ip.find(:all, :conditions => [ "hostname like ?", params[:player_search][:search_for]])
        end
      end

      ips.flatten! if ips
      ips.sort! if ips

      ips.each do |ip|
        connections = []
        ip.callsigns.each do |callsign|
          callsign_details = PlayerConnection.find_by_sql("select callsign_id, is_verified, is_admin, is_operator, is_globaluser from player_connections where callsign_id = #{callsign.id} and ip_id = #{ip.id} group by callsign_id, is_verified, is_admin, is_operator, is_globaluser") 
          callsign_details.each do |cdet|
            cdet.bzid = nil
            pc_first = ip.player_connections.find(:first, :conditions => "callsign_id = #{callsign.id} and is_verified = #{cdet.is_verified} and is_admin = #{cdet.is_admin} and is_operator = #{cdet.is_operator} and is_globaluser = #{cdet.is_globaluser}", :order => "join_at")
            pc_last = ip.player_connections.find(:first, :conditions => "callsign_id = #{callsign.id} and is_verified = #{cdet.is_verified} and is_admin = #{cdet.is_admin} and is_operator = #{cdet.is_operator} and is_globaluser = #{cdet.is_globaluser}", :order => "part_at desc")
            cdet.join_at = pc_first.join_at if pc_first
            cdet.bzid = pc_first.bzid if pc_first && pc_first.bzid
            cdet.part_at = pc_last.part_at if pc_last
            cdet.bzid = pc_last.bzid if pc_last && pc_last.bzid
            connections.push(cdet)

            # Update the ip join and part times
            ip.first_join_at = cdet.join_at if ip.first_join_at.nil? || cdet.join_at < ip.first_join_at
            ip.last_part_at = cdet.part_at if ip.last_part_at.nil? || cdet.part_at > ip.last_part_at
          end
          @matches += callsign_details.size
        end
        @ips.push([ip, connections])
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
      session[:original_uri] = request.request_uri
      redirect_to(:controller => "login", :action => "login")
    end
  end
end
