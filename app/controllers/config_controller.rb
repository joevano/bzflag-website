class ConfigController < ApplicationController

  def index
  end

  def permission_list
    @groups = Group.find(:all, :order => "name")
    @permissions = Permission.find(:all, :order => "name")
  end

  def server_host_add
    if request.post?
      @server_host = ServerHost.new(params[:server_host])
      if @server_host.save
        flash[:notice] = 'Server host was successfully created.'
        redirect_to :action => 'server_host_list'
      end
    end
  end

  def server_host_del
    if request.post?
      server_host = ServerHost.find(params[:id])
      begin
        server_host.destroy
        flash[:notice] = "Server host #{server_host.hostname} deleted"
      rescue Exception => e
        flash[:notice] = e.message
      end
    end
    redirect_to(:action => :server_host_list)
  end

  def server_host_list
    @server_hosts = ServerHost.find(:all, :order => "hostname")
  end

  def server_host_edit
    @server_host = ServerHost.find(params[:id])
    if request.post?
      if @server_host.update_attributes(params[:server_host])
        flash[:notice] = "Server host saved"
        redirect_to :action=> :server_host_list
      end
    end
  end

  def group_list
    @groups = Group.find(:all, :order => "name")
  end

  def group_add
    if request.post?
      @group = Group.new(params[:group])
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        redirect_to :action => 'group_list'
      end
    end
  end

  def group_del
    if request.post?
      group = Group.find(params[:id])
      begin
        group.destroy
        flash[:notice] = "Group #{group.name} deleted"
      rescue Exception => e
        flash[:notice] = e.message
      end
    end
    redirect_to(:action => :group_list)
  end

  def group_edit
    @group = Group.find(params[:id])
    if request.post?
      if @group.update_attributes(params[:group])
        flash[:notice] = "Group saved"
        redirect_to :action=> :group_list
      end
    end
  end

  def bz_server_list
    @bz_servers = BzServer.find(:all, :order => "port")
  end

  def bz_server_add
    @server_hosts = ServerHost.find(:all, :order => "hostname")
    if request.post?
      @bz_server = BzServer.new(params[:bz_server])
      if @bz_server.save
        flash[:notice] = 'BZFlag Server was successfully created.'
        redirect_to :action => 'bz_server_list'
      end
    end
  end

  def bz_server_del
    if request.post?
      bz_server = BzServer.find(params[:id])
      begin
        bz_server.destroy
        flash[:notice] = "BZFlag Server #{bz_server.port} deleted"
      rescue Exception => e
        flash[:notice] = e.message
      end
    end
    redirect_to(:action => :bz_server_list)
  end

  def bz_server_edit
    @bz_server = BzServer.find(params[:id])
    @server_hosts = ServerHosts.find(:all, :order => "hostname")
    if request.post?
      if @bz_server.update_attributes(params[:bz_server])
        flash[:notice] = "BZFlag Server saved"
        redirect_to :action=> :bz_server_list
      end
    end
  end
end
