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
class IpsAddFirstJoinLastPart < ActiveRecord::Migration
  def self.up
    add_column :ips, :first_join_at, :datetime
    add_column :ips, :last_part_at, :datetime

    execute "update ips set first_join_at = (select join_at from player_connections where player_connections.ip_id = ips.id order by join_at limit 1),
                            last_part_at = (select part_at from player_connections where player_connections.ip_id = ips.id order by part_at desc limit 1);"
      
  end

  def self.down
    remove_column :ips, :first_join_at
    remove_column :ips, :last_part_at
  end
end
