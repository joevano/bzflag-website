class SearchController < ApplicationController
  before_filter :authorize
  IP_LIMIT = 500

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
        ips=Ip.find_by_sql(["select distinct ips.* from ips inner join player_connections on ips.id = player_connections.ip_id inner join callsigns on callsigns.id = player_connections.callsign_id where callsigns.name like ? order by ips.last_part_at desc, ips.id limit #{IP_LIMIT}", params[:player_search][:search_for]])
      elsif params[:player_search][:search_by] == 'IP'
        ips = Ip.find(:all,
                      :conditions => [ "ip like ?", params[:player_search][:search_for]],
                      :order => "last_part_at desc, ip",
                      :limit => IP_LIMIT)
      elsif params[:player_search][:search_by] == 'Hostname'
        ips = Ip.find(:all,
                      :conditions => [ "hostname like ?", params[:player_search][:search_for]],
                      :order => "last_part_at desc, ip",
                      :limit => IP_LIMIT)
      end

      if ips.size > 0
        ip_ids = ips.collect{|i| i.id}.join(",")
        callsign_details = PlayerConnection.find_by_sql("select * from player_connections inner join ips on player_connections.ip_id = ips.id where ip_id in (#{ip_ids}) group by ip_id, callsign_id, is_verified, is_admin, is_operator, is_globaluser order by ips.last_part_at desc, ips.id")
      else
        callsign_details = []
      end
      @matches = callsign_details.size

      flash.now[:notice] = "Results limited to #{IP_LIMIT} IPs" if ips.size == IP_LIMIT

      # Loop through the callsign_details once and build a new list with an Ip object and list of PlayerConnections for the view to use
      @ips = []
      callsign_details_idx = 0
      ips.each do |ip|
        connections = []
        while callsign_details_idx < callsign_details.size && callsign_details[callsign_details_idx].ip_id == ip.id
          connections.push(callsign_details[callsign_details_idx])
          callsign_details_idx += 1
        end
        @ips.push([ip, connections])
      end
      flash.now[:notice] = "Oops - BUG: lost entries #{callsign_details_idx} - #{callsign_details.size}" if callsign_details_idx < callsign_details.size
    end
  end

  private

  def authorize
    unless @player_info_perm
      flash[:notice] = "Access Denied."
      session[:original_uri] = request.request_uri
      redirect_to(:controller => "login", :action => "login")
    end
  end
end
