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

class PlayerConnection < ActiveRecord::Base
  belongs_to :email
  belongs_to :bz_server
  belongs_to :callsign
  belongs_to :ip
  belongs_to :team
  has_many :log_messages
  has_one :player_join_connection,
          :class_name => "log_messages",
          :conditions => "log_type_id = #{LogType.find_by_token('PLAYER-JOIN')}"
  has_one :player_part_connection,
          :class_name => "log_messages",
          :conditions => "log_type_id = #{LogType.find_by_token('PLAYER-PART')}"

  named_scope  :get_player_join_min_max,
               :select => "callsign_id,
                           callsigns.name as name,
                           max(bzid) as bzid,
                           min(join_at) as join_at,
                           max(part_at) as part_at,
                           is_globaluser,
                           is_operator,
                           is_verified,
                           is_admin",
               :joins => :callsign,
               :group => "callsign_id,
                          callsigns.name,
                          is_globaluser,
                          is_operator,
                          is_verified,
                          is_admin",
               :order => "part_at desc"
end
