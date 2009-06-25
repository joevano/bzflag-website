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

class Callsign < ActiveRecord::Base
  has_many :player_connections
  has_many :ips, :through => :player_connections, :uniq => true
  has_many :teams, :through => :player_connections, :uniq => true
  has_many :log_messages

  named_scope :callsign_like,
              lambda {|callsign| { :conditions => ['name like ?', callsign] }}

  validates_presence_of :name

  @@callsigns = Hash.new

  def self.locate(name)
    if name =~ /^\s*$/
      name = 'UNKNOWN'
    end

    if !@@callsigns[name]
      @@callsigns.store(name, Callsign.find_or_create_by_name(name))
    end

    @@callsigns[name]
  end
end
