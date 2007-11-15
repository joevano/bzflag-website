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
    @groups = @user.groups.collect { |g| g.name } || []
    @admin = @groups.length > 0
  end

  def read_html_and_strip_to_body_content(file)
    content = IO.read(file)
    # Strip off the header
    content = content.sub(/^.*<body[^>]*>/im, '')
    # Strip off the trailer
    content = content.sub(/<\/body>.*$/im, '')
  end
end
