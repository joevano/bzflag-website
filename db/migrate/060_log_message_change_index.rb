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
class LogMessageChangeIndex < ActiveRecord::Migration
  def self.up
    remove_index :log_messages, :name => "index_log_messages"
    add_index :log_messages, [:bz_server_id, :id, :log_type_id, :logged_at], :name => "index_log_messages"
  end

  def self.down
    remove_index :log_messages, :name => "index_log_messages"
    add_index :log_messages, [:bz_server_id, :log_type_id, :logged_at], :name => "index_log_messages"
  end
end
