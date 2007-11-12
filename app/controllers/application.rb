# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'fileutils'

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_bzflag.norang.ca_session_id'

  before_filter :get_user

  layout "bzflag"

  private

  def get_user
    @bzid = session[:bzid]
    @username = session[:username]
    @jradmin = is_jradmin()
    @sradmin = is_sradmin()
    @tradmin = is_tradmin()
    @hideadmin = is_hideadmin()
    @admin = @jradmin || @sradmin || @tradmin || @hideadmin
    @groups = session[:groups]
    @ip = session[:ip]
  end

  def is_hideadmin
    session[:groups] and !session[:groups].index("NORANG.HIDE").nil?
  end

  def is_jradmin
    session[:groups] and !session[:groups].index("NORANG.JRADMIN").nil?
  end

  def is_sradmin
    session[:groups] and !session[:groups].index("NORANG.SRADMIN").nil?
  end

  def is_tradmin
    session[:groups] and !session[:groups].index("NORANG.TRADMIN").nil?
  end

  def read_html_and_strip_to_body_content(file)
    content = IO.read(file)
    # Strip off the header
    content = content.sub(/^.*<body[^>]*>/im, '')
    # Strip off the trailer
    content = content.sub(/<\/body>.*$/im, '')
  end
end
