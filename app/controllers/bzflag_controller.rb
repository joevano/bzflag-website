class BzflagController < ApplicationController
  before_filter :get_user

  def index
  end

  def servers
  end

  private

  def get_user
    @userid = session[:bzid]
    @username = session[:username]
  end

end
