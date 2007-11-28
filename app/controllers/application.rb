# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'fileutils'

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_bzflag.norang.ca_session_id'
  ADMIN_MENU_PERM = "Admin Menu"
  CONFIGURATION_MENU_PERM = "Configuration Menu"
  BAN_PERM = "Ban"
  LOGS_PERM = "Logs"
  MAP_UPLOAD_PERM = "Map Upload"
  PLAYER_INFO_PERM = "Player Info"
  SERVER_CONTROL_PERM = "Server Control"
  SHORT_BAN_PERM = "Short Ban"
  TEST_SERVER_CONTROL_PERM = "Test Server Control"
  VIEW_PRIVATE_CHAT_PERM = "View Private Chat"

  before_filter :get_user

  private

  def get_user
    @user = (session[:user_id] && User.find(session[:user_id])) || User.new
    permissions = @user.permissions
    @admin_menu_perm = permissions.index(Permission.find_by_name(ADMIN_MENU_PERM))
    @configuration_menu_perm = permissions.index(Permission.find_by_name(CONFIGURATION_MENU_PERM)) || (User.count == 1 && @user.id)
    @ban_perm = permissions.index(Permission.find_by_name(BAN_PERM))
    @logs_perm = permissions.index(Permission.find_by_name(LOGS_PERM))
    @map_upload_perm = permissions.index(Permission.find_by_name(MAP_UPLOAD_PERM))
    @player_info_perm = permissions.index(Permission.find_by_name(PLAYER_INFO_PERM))
    @server_control_perm = permissions.index(Permission.find_by_name(SERVER_CONTROL_PERM))
    @short_ban_perm = permissions.index(Permission.find_by_name(SHORT_BAN_PERM))
    @test_server_control_perm = permissions.index(Permission.find_by_name(TEST_SERVER_CONTROL_PERM))
    @view_private_chat_perm = permissions.index(Permission.find_by_name(VIEW_PRIVATE_CHAT_PERM))
  end

  def read_html_and_strip_to_body_content(file)
    content = IO.read(file)
    # Strip off the header
    content = content.sub(/^.*<body[^>]*>/im, '')
    # Strip off the trailer
    content = content.sub(/<\/body>.*$/im, '')
  end
end
