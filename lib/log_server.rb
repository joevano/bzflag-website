#!/usr/bin/env ruby
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
# Parse BZFlag server log file data from the logDetail plugin
#
# Create database records from the log for use with the bzflag_website
require 'gserver'
require 'lib/log_parser'

class LogServer < GServer
  def initialize(host = 'localhost', port = '3333')
    super(port, host)
    @logger = LogParser.new
  end

  def serve(client)
    text = client.gets
    response = @logger.process_socketrequest(text)
    client.puts response
  end
end
