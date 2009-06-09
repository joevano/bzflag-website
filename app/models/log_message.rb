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

class LogMessage < ActiveRecord::Base
  belongs_to :log_type
  belongs_to :callsign
  belongs_to :to_callsign, :class_name => "Callsign", :foreign_key => "to_callsign_id"
  belongs_to :team
  belongs_to :message
  belongs_to :bz_server
  has_one :last_chat_log_server, :class_name => "BzServer", :foreign_key => "last_chat_message_id"
  has_one :last_filtered_log_server, :class_name => "BzServer", :foreign_key => "last_filtered_message_id"
  has_one :server_status_server, :class_name => "BzServer", :foreign_key => "server_status_message_id"

  @recent_ban_days = 3
  @recent_report_days = 3

  def self.recent_ban_days
    find(:all,
         :conditions => "log_type_id = #{LogType.find_by_token("MSG-COMMAND").id} and logged_at > '#{db_date(@recent_ban_days.days.ago)}' and (text like 'ban %' or text like 'unban %' or text like 'hostban %' or text like 'hostunban %' or text like 'idban %' or text like 'idunban %' or text like 'poll ban %')",
         :order => "logged_at",
         :joins => :message,
         :include => "message")
  end

  def self.recent_report_days
    find(:all, :conditions => "log_type_id = #{LogType.find_by_token("MSG-REPORT").id} and logged_at > '#{db_date(@recent_report_days.days.ago)}'", :order => "logged_at")
  end
  
end