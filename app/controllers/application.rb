# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_bzflag.norang.ca_session_id'

  private

  def get_user
    @bzid = session[:bzid]
    @username = session[:username]
    @admin = is_admin()
    @groups = session[:groups]
    @ip = session[:ip]
  end

  def is_admin
    admin = false
    if not session[:groups].nil?
      ["NORANG.HIDE","NORANG.JRADMIN","NORANG.SRADMIN","NORANG.TRADMIN"].each do |grp|
        if session[:groups].index(grp)
          admin = true
        end
      end
    end
    admin
  end
end
