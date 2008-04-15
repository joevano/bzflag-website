class SearchController < ApplicationController
  before_filter :authorize_player_info_perm
  IP_LIMIT = 500

  def players
    @ips = []
    @matches = nil
    @player_search = PlayerSearch.new()
    @player_search.search_by = params[:player_search][:search_by] if params && params[:player_search]
    @player_search.search_for = params[:player_search][:search_for].lstrip.rstrip if params && params[:player_search]
    if @player_search.search_by && @player_search.search_for
      ips = []
      matches = 0
      if @player_search.search_for =~ /^[%*]*$/
        flash.now[:notice] = "Please enter some search criteria"
      elsif @player_search.search_by == 'Callsign'
        ips=Ip.find_by_sql(["select distinct ips.* from ips inner join player_connections on ips.id = player_connections.ip_id inner join callsigns on callsigns.id = player_connections.callsign_id where callsigns.name like ? order by ips.last_part_at desc, ips.id limit #{IP_LIMIT}", @player_search.search_for.gsub(/\*/, '%')])
      elsif @player_search.search_by == 'IP'
        ips = Ip.find(:all,
                      :conditions => [ "ip like ?", @player_search.search_for.gsub(/\*/, '%')],
                      :order => "last_part_at desc, ip",
                      :limit => IP_LIMIT)
      elsif @player_search.search_by == 'Hostname'
        ips = Ip.find(:all,
                      :conditions => [ "hostname like ?", @player_search.search_for.gsub(/\*/, '%')],
                      :order => "last_part_at desc, ip",
                      :limit => IP_LIMIT)
      end

      if ips.size > 0
        ip_ids = ips.collect{|i| i.id}.join(",")
        callsign_details = PlayerConnection.find_by_sql("select ip.id,pc.callsign_id,pc.is_verified, pc.is_admin, max(pc.bzid) as bzid, pc.ip_id, min(pc.join_at) as join_at, max(pc.part_at) as part_at, pc.is_globaluser, pc.is_operator from player_connections pc inner join ips ip on pc.ip_id = ip.id where pc.ip_id in (#{ip_ids}) group by ip.id, pc.callsign_id, pc.is_verified, pc.is_admin, pc.is_operator, pc.is_globaluser order by ip.last_part_at desc, ip.id, part_at desc")
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
    else
      @player_search.search_by = "Callsign"
    end
  end

  def logs
    @bz_server = BzServer.find(params[:id])
    next_page = params[:next_page]
    prev_page = params[:prev_page]

    @log_messages = []
    if next_page
        @log_messages = @bz_server.log_messages.find(:all,
                                                     :conditions => "log_messages.id >= #{next_page} and log_type_id in (1,2,3,4,5,6,7,8,9,10,11,12,13)", 
                                                     :order => "logged_at, log_messages.id",
                                                     :include => [ "message", "callsign", "to_callsign" ],
                                                     :limit => 100)
        if @log_messages.empty?
            flash.now[:notice] = "Displaying most recent records"
        end
    elsif prev_page
        @log_messages = @bz_server.log_messages.find(:all,
                                                     :conditions => "log_messages.id <= #{prev_page} and log_type_id in (1,2,3,4,5,6,7,8,9,10,11,12,13)", 
                                                     :order => "logged_at desc, log_messages.id desc",
                                                     :include => [ "message", "callsign", "to_callsign" ],
                                                     :limit => 100).reverse
    end

    if @log_messages.empty?
        @log_messages = @bz_server.log_messages.find(:all,
                                                     :conditions => "log_type_id in (1,2,3,4,5,6,7,8,9,10,11,12,13)", 
                                                     :order => "logged_at desc, log_messages.id desc",
                                                     :include => [ "message", "callsign", "to_callsign" ],
                                                     :limit => 100).reverse
    end

    @player_join_log_type_id = LogType.find_by_token("PLAYER-JOIN").id
    @player_part_log_type_id = LogType.find_by_token("PLAYER-PART").id
    @player_auth_log_type_id = LogType.find_by_token("PLAYER-AUTH").id
    @server_status_log_type_id = LogType.find_by_token("SERVER-STATUS").id
    @msg_broadcast_log_type_id = LogType.find_by_token("MSG-BROADCAST").id
    @msg_filtered_log_type_id = LogType.find_by_token("MSG-FILTERED").id
    @msg_direct_log_type_id = LogType.find_by_token("MSG-DIRECT").id
    @msg_team_log_type_id = LogType.find_by_token("MSG-TEAM").id
    @msg_report_log_type_id = LogType.find_by_token("MSG-REPORT").id
    @msg_command_log_type_id = LogType.find_by_token("MSG-COMMAND").id
    @msg_admin_log_type_id = LogType.find_by_token("MSG-ADMIN").id
    @server_mapname_log_type_id = LogType.find_by_token("SERVER-MAPNAME").id
    @server_status_log_type_id = LogType.find_by_token("SERVER-STATUS").id

    @server_callsign_id = Callsign.find_by_name("SERVER").id
  end
end
