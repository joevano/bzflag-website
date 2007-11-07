class BzflagController < ApplicationController
  before_filter :get_user

  def index
  end

  private

  def get_user
    @userid = session[:bzid]
    @callsign = session[:callsign]
  end

end
