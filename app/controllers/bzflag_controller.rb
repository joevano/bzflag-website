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
require "banfile"

class BzflagController < ApplicationController
  before_filter :authorize_admin_menu_perm, :except => [ :index ]

  def index
    @server_list = ServerList.new()

    if params && params[:server_list]
      @server_list.hide_disabled = params[:server_list][:hide_disabled].to_i
      @server_list.hide_idle = params[:server_list][:hide_idle].to_i
      @server_list.hide_stopped = params[:server_list][:hide_stopped].to_i
    else
      @server_list.hide_disabled = 1
      @server_list.hide_idle = 1
      @server_list.hide_stopped = 1
    end

    @bz_servers = BzServer.find(:all,
                                :order => "current_players_count desc, log_messages.logged_at desc, server_host_id, port",
                                :include => ["last_chat_message", "last_filtered_message", "current_players"])
    @total_players = @total_running_servers = 0
    @bz_servers.each do |b|
      @total_players += b.current_players_count
      @total_running_servers += 1 if b.server_status_message && b.server_status_message.message.text.capitalize == 'Running'
    end

    @recent_bans = LogMessage.recent_ban_days
    @recent_reports = LogMessage.recent_report_days
  end

  def help
  end

  def reports
    msg_report_id = LogType.find_by_token("MSG-REPORT").id
    @reports = LogMessage.find(:all,
                               :conditions => "log_type_id = #{msg_report_id}",
                               :order => "log_type_id, logged_at desc", :limit => 100)
  end

  def bans
    @bans = Ban.new("public/masterban.txt").bans
  end

  def recordings
  end

  def mailing_list
  end
end
