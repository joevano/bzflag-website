class BzflagController < ApplicationController
  before_filter :get_user

  def index
  end

  def servers
  end

  def help
  end

  def reports
  end

  def players
  end

  def bans
  end

  def recordings
  end

  def admins
  end

  def mailing_list
  end

  private

  def get_user
    @userid = session[:bzid]
    @username = session[:username]
    @admin = session[:admin]
    @groups = session[:groups]
    @ip = session[:ip]
  end

end
