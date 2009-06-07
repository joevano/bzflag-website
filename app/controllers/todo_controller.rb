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

class TodoController < ApplicationController
  before_filter :authorize_admin_menu_perm

  def method_missing(action)
    if action == "index"
      action = "bzflag"
    end

    @action = action
    file = "public/#{action}.html"
    begin
      @content = read_html_and_strip_to_body_content(file)
    rescue
      flash.now[:notice] = "Can't find todo list: #{action}"
    end
    render :template => "mailing_list/article"
  end
end
