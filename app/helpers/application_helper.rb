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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_date(date)
    date && date.strftime("%Y %b %d %H:%M:%S")
  end

  def display_date_range(d1, d2)
    range = display_date(d1)
    if d2
      range = range + " - "
      if d2.strftime("%Y") != d1.strftime("%Y")
        range = range + display_date(d2)
      elsif d2.strftime("%b") != d1.strftime("%b") || d2.strftime("%d") != d1.strftime("%d")
        range = range + d2.strftime("%b %d %H:%M:%S")
      else
        range = range + d2.strftime("%H:%M:%S")
      end
    end
    range
  end

  def display_server(bz_server)
    "#{bz_server.server_host.hostname}:#{bz_server.port}"
  end
end
