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
class MakeSelectedIndexesUnique < ActiveRecord::Migration
  def self.up
    remove_index :callsigns, :name
    remove_index :ips, :ip
    remove_index :messages, :text
    add_index :callsigns, :name, :unique => true
    add_index :emails, :email, :unique => true
    add_index :ips, :ip, :unique => true
    add_index :log_types, :token, :unique => true
    add_index :messages, :text, :unique => true
    add_index :server_hosts, :hostname, :unique => true
  end

  def self.down
    remove_index :callsigns, :name
    remove_index :emails, :email
    remove_index :ips, :ip
    remove_index :log_types, :token
    remove_index :messages, :text
    remove_index :server_hosts, :hostname
    add_index :callsigns, :name
    add_index :ips, :ip
    add_index :messages, :text
  end
end
