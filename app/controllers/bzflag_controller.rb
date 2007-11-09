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
