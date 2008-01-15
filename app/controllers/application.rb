# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'fileutils'

class ApplicationController < ActionController::Base
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
end
