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

require 'test_helper'
require 'stringio'
require 'lib/log_server'

class ParseBzfsLogServer < ActiveSupport::TestCase
  def setup
    @server = LogServer.new
  end

  def simulate_request(request)
    client = StringIO.new(request)
    @server.serve(client)
    client.string[request.size - 2 .. -2]
  end

  def test_bad_port
    result = simulate_request("bzflag|6001|#{Time.now.gmtime.strftime("%Y-%m-%dT%H:%M:%SZ MSG-REPORT 5:WQR42 This is the coolest website project ever!")}")
    assert_equal('1', result)
  end

  def test_good_record
    result = simulate_request("bzflag|5154|#{Time.now.gmtime.strftime("%Y-%m-%dT%H:%M:%SZ")} PLAYER-AUTH 22:this is really long...  IP:10.168.124.93 ADMIN OPERATOR")
    assert_equal('0', result)
  end
end