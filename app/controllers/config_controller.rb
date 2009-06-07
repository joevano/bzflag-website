#-------------------------------------------------------------------------------
# The BZFlag Website Project - administration and monitoring of BZFlag servers
# Copyright (C) 2009  Bernt T. Hansen
#
# This website project is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This website project is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this website project; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#-------------------------------------------------------------------------------

class ConfigController < ApplicationController
  before_filter :authorize_configuration_menu_perm

  def index
  end

  def permission_list
    @groups = Group.find(:all, :order => "id")
    @permissions = Permission.find(:all, :order => "id")

    # Replace the permissions with whatever is checked
    if request.post?
      @groups.each do |g|
        newperms = []
        @permissions.each do |p|
          if params["g#{g.id}p#{p.id}"]
            newperms << p
          end
        end
        g.permissions.replace(newperms)
      end
      flash.now[:notice] = "Permissions updated"
    end
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
    @groups = Group.find(:all, :order => "id")
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
    @bz_servers = BzServer.find(:all, :order => "server_host_id, port")
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
    @server_hosts = ServerHost.find(:all, :order => "hostname")
    if request.post?
      if @bz_server.update_attributes(params[:bz_server])
        flash[:notice] = "BZFlag Server saved"
        redirect_to :action=> :bz_server_list
      end
    end
  end
end
