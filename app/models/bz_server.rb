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
class BzServer < ActiveRecord::Base
  belongs_to :server_host
  has_many :player_connections
  has_many :log_messages
  has_many :current_players
  belongs_to :last_chat_message,
             :class_name => "LogMessage",
             :foreign_key => "last_chat_message_id"
  belongs_to :last_filtered_message,
             :class_name => "LogMessage",
             :foreign_key => "last_filtered_message_id"
  belongs_to :server_status_message,
             :class_name => "LogMessage",
             :foreign_key => "server_status_message_id"

  validates_uniqueness_of :port, :scope => :server_host_id

  def is_idle
    !last_chat_message || last_chat_message.logged_at < 24.hours.ago
  end

  def is_stopped
    server_status_message &&
    server_status_message.message &&
    server_status_message.message.text.downcase == 'stopped'
  end
end
