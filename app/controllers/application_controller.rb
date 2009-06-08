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

require 'fileutils'
require 'ostruct'
require 'yaml'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  config = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/config.yml"))
  env_config = config.send(RAILS_ENV)
  config.common.update(env_config) unless env_config.nil?
  ::AppConfig = OpenStruct.new(config.common)

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_bzflag.norang.ca_session_id'

  before_filter :get_user

  private

  def get_user
    @user = (session[:user_id] && User.find(session[:user_id])) || User.new
    permissions = @user.permissions
    @admin_menu_perm = permissions.index(Permission.find_by_name("admin menu"))
    cfg_menu_p = Permission.find_by_name("configuration menu")
    @configuration_menu_perm = permissions.index(cfg_menu_p)
    if cfg_menu_p.groups.count == 0
      @configuration_menu_perm = true
      flash[:notice] = "<strong>Configuration Menu unrestricted - anyone can edit permissions</strong>"
      flash[:notice] += "<br>Add the 'Configuration Menu' to at least one group"
    end
    @ban_perm = permissions.index(Permission.find_by_name("ban"))
    @logs_perm = permissions.index(Permission.find_by_name("logs"))
    @map_upload_perm = permissions.index(Permission.find_by_name("map upload"))
    @player_info_perm = permissions.index(Permission.find_by_name("player info"))
    @server_control_perm = permissions.index(Permission.find_by_name("server control"))
    @short_ban_perm = permissions.index(Permission.find_by_name("short ban"))
    @test_server_control_perm = permissions.index(Permission.find_by_name("test server control"))
    @view_private_chat_perm = permissions.index(Permission.find_by_name("view private chat"))
  end

  def read_html_and_strip_to_body_content(file)
    content = IO.read(file)
    # Strip off the header
    content = content.sub(/^.*<body[^>]*>/im, '')
    # Strip off the trailer
    content = content.sub(/<\/body>.*$/im, '')
  end

  def authorize(perm)
    unless perm
      if session[:user_id]
        flash[:notice] = "Access Denied."
        redirect_to(:controller => "bzflag", :action => "index")
      else
        flash[:notice] = "Access Restricted.  Please log in."
        session[:original_uri] = request.request_uri
        redirect_to(:controller => "login", :action => "login")
      end
    end
  end

  def authorize_admin_menu_perm
    authorize(@admin_menu_perm)
  end

  def authorize_configuration_menu_perm
    authorize(@configuration_menu_perm)
  end

  def authorize_player_info_perm
    authorize(@player_info_perm)
  end

  def db_date(date)
    date && date.gmtime.strftime("%Y-%m-%d %H:%M:%S")
  end
end
