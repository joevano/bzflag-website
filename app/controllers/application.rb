# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'fileutils'

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_bzflag.norang.ca_session_id'

  before_filter :get_user

  private

  def get_user
    @user = session[:user_id] && User.find(session[:user_id]) || User.new
    admin_menu_permission = Permission.find_by_name("Admin Menu")
    configuration_menu_permission = Permission.find_by_name("Configuration Menu") || (User.count == 1 && @user.id)
    @admin_menu = @user.permissions.index(admin_menu_permission)
    @configuration_menu = @user.permissions.index(configuration_menu_permission)
  end

  def read_html_and_strip_to_body_content(file)
    content = IO.read(file)
    # Strip off the header
    content = content.sub(/^.*<body[^>]*>/im, '')
    # Strip off the trailer
    content = content.sub(/<\/body>.*$/im, '')
  end
end
