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
class DropLogs < ActiveRecord::Migration
  def self.up
    drop_table :logs
  end

  def self.down
    create_table "logs", :force => true do |t|
      t.integer  "log_type_id"
      t.integer  "callsign_id"
      t.integer  "to_callsign_id"
      t.datetime "logged_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "bzid"
      t.integer  "team_id"
      t.integer  "message_id"
      t.integer  "bz_server_id"
    end
  end
end
