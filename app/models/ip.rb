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

class Ip < ActiveRecord::Base
  has_many :player_connections
  has_many :callsigns, :through => :player_connections, :uniq => true

  def self.callsign_like(name, limit=500)
     find_by_sql(['select distinct ip.*
                     from ips as ip
                     inner join player_connections as pc on ip.id = pc.ip_id
                     inner join callsigns as cs on cs.id = pc.callsign_id
                     where cs.name like ?
                     order by ip.last_part_at desc, ip.ip LIMIT ?', name, limit])
  end

  def self.locate(ip)
    newip = Ip.find_by_ip(ip)
    if newip.nil?
      newip = Ip.create!(:ip => ip)
      begin
        newip.hostname = Socket.gethostbyaddr(ip.split(".").collect{|y| y.to_i}.pack("CCCC"))[0]
      rescue
      end
      newip.save!
    end
    return newip
  end

  def <=>(other)
    # Sort two IPs by the latest player connection part_at time
    #

    # Get the last part_at time if we have one for this IP
    lastpart = self.player_connections.find(:first, :order => 'join_at desc')
    lastpart = lastpart.part_at if lastpart

    # Get the last part_at time for the other IP if it has one
    otherlastpart = other.player_connections.find(:first, :order => 'join_at desc')
    otherlastpart = otherlastpart.part_at if otherlastpart

    # If the other IP has no part_at sort it to the bottom
    # If we have not part_at sort it to the bottom
    # Otherwise compare the part_at times and sort accordingly
    if lastpart.nil?
      1
    elsif otherlastpart.nil?
      -1
    else
      otherlastpart <=> lastpart
    end
  end
end
