class ConfigController < ApplicationController

  layout "bzflag"

  def index
  end

  def access_level_list
    @access_levels = AccessLevel.find(:all)
  end

  def access_level_add
  end

  def access_level_del
  end

  def access_level_edit
  end

  def server_host_add
  end

  def server_host_del
  end

  def server_host_list
  end

  def server_host_edit
  end

  def group_list
  end

  def group_add
  end

  def group_del
  end

  def group_edit
  end

  def bzserver_list
  end

  def bzserver_add
  end

  def bzserver_del
  end

  def bzserver_edit
  end
end
