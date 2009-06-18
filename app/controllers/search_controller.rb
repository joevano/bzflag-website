#-------------------------------------------------------------------------------
# The BZFlag Website Project - administration and monitoring of BZFlag servers
# Copyright (C) 2009  Bernt T. Hansen
#
# This website project is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This website project is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this website project; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#-------------------------------------------------------------------------------

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
        ip_id = []
       ips = Ip.callsign_like(@player_search.search_for.gsub(/\*/, '%'), IP_LIMIT)

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

      flash.now[:notice] = "Results limited to #{IP_LIMIT} IPs" if ips.size == IP_LIMIT

      # Loop through the callsign_details once and build a new list with an Ip object and list of PlayerConnections for the view to use
      @ips = []
      @matches = 0

      ips.each do |ip|
        connections = ip.player_connections.get_player_join_min_max
        @matches = @matches + connections.length
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
                                                     :order => "log_messages.id",
                                                     :include => [ "message", "callsign", "to_callsign" ],
                                                     :limit => 100)
        if @log_messages.empty?
            flash.now[:notice] = "Displaying most recent records"
        end
    elsif prev_page
        @log_messages = @bz_server.log_messages.find(:all,
                                                     :conditions => "log_messages.id <= #{prev_page} and log_type_id in (1,2,3,4,5,6,7,8,9,10,11,12,13)", 
                                                     :order =>  "log_messages.id desc",
                                                     :include => [ "message", "callsign", "to_callsign" ],
                                                     :limit => 100).reverse
    end

    if @log_messages.empty?
        @log_messages = @bz_server.log_messages.find(:all,
                                                     :conditions => "log_type_id in (1,2,3,4,5,6,7,8,9,10,11,12,13)", 
                                                     :order => "log_messages.id desc",
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
