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

class LogSearch
  attr_accessor :msg_player
  attr_accessor :msg_server
  attr_accessor :msg_broadcast
  attr_accessor :msg_filtered
  attr_accessor :msg_private
  attr_accessor :msg_team
  attr_accessor :msg_report
  attr_accessor :msg_command
  attr_accessor :msg_admin


  def self.and_conditions(condition1, condition2)
    condition1 = "" if condition1.nil?
    condition2 = "" if condition2.nil?
    condition = condition1.strip
    condition << " and " unless condition2.strip.empty? or condition1.strip.empty?
    condition << condition2.strip
  end

  def conditions
    condition = ""

    types = selected_log_types
    if types.empty?
      condition = "log_type_id is null"
    else
      condition = "log_type_id in (#{types.join(',')})"
    end
    #remove broadcast messages from the server if server messages are disabled
    condition = LogSearch.and_conditions(condition, "callsign_id <> #{Callsign.locate("SERVER").id}") if @msg_server == 0
  end

  private

  def selected_log_types
    log_types = []
    log_types << LogType.get_id("PLAYER-JOIN") if @msg_player == 1
    log_types << LogType.get_id("PLAYER-PART") if @msg_player == 1
    log_types << LogType.get_id("PLAYER-AUTH") if @msg_player == 1
    log_types << LogType.get_id("SERVER-STATUS") if @msg_server == 1
    log_types << LogType.get_id("SERVER-MAPNAME") if @msg_server == 1
    log_types << LogType.get_id("MSG-BROADCAST") if @msg_broadcast == 1
    log_types << LogType.get_id("MSG-FILTERED") if @msg_filtered == 1
    log_types << LogType.get_id("MSG-DIRECT") if @msg_direct == 1
    log_types << LogType.get_id("MSG-TEAM") if @msg_team == 1
    log_types << LogType.get_id("MSG-REPORT") if @msg_report == 1
    log_types << LogType.get_id("MSG-COMMAND") if @msg_command == 1
    log_types << LogType.get_id("MSG-ADMIN") if @msg_admin == 1
    return log_types
  end
end
