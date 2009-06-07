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
class AddLogTypes < ActiveRecord::Migration
  def self.up
    down
    LogType.new(:token => 'PLAYER-JOIN').save!
    LogType.new(:token => 'PLAYER-PART').save!
    LogType.new(:token => 'PLAYER-AUTH').save!
    LogType.new(:token => 'SERVER-STATUS').save!
    LogType.new(:token => 'MSG-BROADCAST').save!
    LogType.new(:token => 'MSG-FILTERED').save!
    LogType.new(:token => 'MSG-DIRECT').save!
    LogType.new(:token => 'MSG-TEAM').save!
    LogType.new(:token => 'MSG-REPORT ').save!
    LogType.new(:token => 'MSG-COMMAND').save!
    LogType.new(:token => 'MSG-ADMINS').save!
    LogType.new(:token => 'PLAYERS').save!
  end

  def self.down
    LogType.delete_all
  end
end
