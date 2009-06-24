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

module BzflagHelper

  def banTimeStr(endtime)
    if endtime == 0
      return 'Forever'
    end

    now = Time.now.to_i
    duration = endtime - now
    seconds = 1
    minutes = (60 * seconds).to_i
    hours = (60 * minutes).to_i
    days = (24 * hours).to_i
    weeks = (days * 7).to_i
    years = (days * 365).to_i
    str = ""
    if duration < 0
      str += "Expired"
    end
    if duration > years
      str += pluralStr(duration / years, 'year') + ' '
      duration %= years
    end
    if duration > weeks
      str += pluralStr(duration / weeks, 'week') + ' '
      duration %= weeks
    end
    if duration > days
      str += pluralStr(duration / days, 'day') + ' '
      duration %= days
    end
    if duration > hours
      str += pluralStr(duration / hours, 'hour') + ' '
      duration %= hours
    end
    if duration > minutes
      str += pluralStr(duration / minutes, 'minute') + ' '
      duration %= minutes
    end
    str.rstrip
  end
end
