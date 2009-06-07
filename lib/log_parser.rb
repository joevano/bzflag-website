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
require 'config/environment'
require 'time'
require 'parsedate'

class LogParser
  attr_accessor :last_log_time

  # Display format of command line usage
  def usage
    puts "usage: parse_bzfs_log.rb HOST:PORT"
    exit 1
  end

  # Get a callsign from a string
  #
  # Returns the callsign object that matches the parsed counted string callsign
  # New callsign objects are created if necessary
  def get_callsign(detail)
    callsign, detail = parse_callsign(detail)
    cs = Callsign.locate(callsign)
    return cs, detail
  end

  # Find or create a Message object for a string
  def get_message(message)
    msg = Message.find_or_create_by_text(message)
  end

  # Find or create a Team object for a string
  def get_team(detail)
    team = nil
    if detail =~ /\s*(\w+)\s+(.*)$/
      team = Team.find_or_create_by_name($1)
      detail = $2
    end
    return team, detail
  end

  # Parse the slot number from a string
  def parse_slot(detail)
    # Get slot number
    slot = nil
    if detail =~ /\s*#(\d+)\s+(.*)$/
      slot = $1
      detail = $2
    end
    return slot, detail
  end

  # Parse a counted callsign from a string
  # Returns the callsign and the remainder of the string
  #
  #	e.g. 7:Thumper
  #	returns 'Thumper' as the callsign and the remainder of the string
  def parse_callsign(msg)
    begin
      callsign = "UNKNOWN"
      length = 0
      length, rest = $1, $2 if msg =~ /^(\d+):(.*)$/
      callsign, msg = $1, $2 if rest =~ /(.{#{length}}) ?(.*)$/
    rescue
    end

    return callsign , msg
  end

  # Retrieve an optional bzid from the log line
  #
  # Finds a bzid of the format BZid:nnnn as the next token on the log line
  # and returns the bzid value if one is found.
  def parse_bzid(detail)
    bzid = nil
    if detail =~ /^\s*BZid:(\d+)\s+(.*)$/
      bzid = $1
      detail = $2
    end
    return bzid, detail
  end

  # Parse player data that looks like this:
  #
  # [+]9:Bad Sushi() [+]10:spatialgur(15:spatialguru.com) [@]12:drunk driver()
  def parse_player_email(data)
    v, data = $1, $2 if data =~ /^\[(.)\](.*)$/

    callsign, data = parse_callsign(data)

    # Skip the ( prefixing the email
    data = $1 if data =~ /^\((.*)$/

    email, data = parse_callsign(data)
    if email == 'UNKNOWN'
      email = ''
    else
      email = '(' + email + ')'
    end
    # Skip the final ) after the email
    data = $1 if data =~ /^\) ?(.*)$/

    return v, callsign, email, data
  end

  # Process a line from the log file
  #
  def process_line(server_host, bz_server, line)
    # The date can be in 3 formats:
    #
    # 2007-12-16T11:09:42Z
    # 2007-12-16 11:09:42:
    # or missing in which case we use the last date we have available
    if line =~ /^(\d\d\d\d-\d\d-\d\d[T ]\d\d:\d\d:\d\dZ?):?\s+(.*)$/
      date = Time.gm(*ParseDate.parsedate($1))
      detail = $2
    else
      date = @date
      detail = line
    end
    # Save the date/time in case the next log line has no time -- we'll just reuse this one
    @date = date

    # If the last_log_time is set then we're updating logs and we should skip all of the logs
    # until the date is greater than or equal to the last_log_time
    if @last_log_time and @last_log_time > @date
      return
    end

    if detail =~ /(\S+)\s+(.*)$/
      log_type = $1
      detail = $2
    else
      # Can't parse the line :-P ignore it
      return
    end

    log_type_id = LogType.ids([log_type])
    lm = LogMessage.new(:bz_server => bz_server, :logged_at => date, :log_type_id => log_type_id)

    case log_type

    when 'PLAYER-JOIN'
      # Get callsign
      callsign, detail = get_callsign(detail)

      slot, detail = parse_slot(detail)

      # Get bzid
      bzid, detail = parse_bzid(detail)

      # Get team
      team, detail = get_team(detail)

      # Get ip
      if detail =~ /\s*IP:(\d+\.\d+\.\d+\.\d+)\s*(.*)$/
        ip = Ip.locate($1)
        if ip.first_join_at.nil?
          ip.first_join_at = date
          ip.save!
        end
        detail = $2
      end

      is_verified = false
      if detail =~ /\bVERIFIED\b/
        is_verified = true
      end

      is_globaluser = false
      if detail =~ /\bGLOBALUSER\b/
        is_globaluser = true
      end

      is_admin = false
      if detail =~ /\bADMIN\b/
        is_admin = true
      end

      is_operator = false
      if detail =~ /\bOPERATOR\b/
        is_operator = true
      end

      lm.callsign = callsign
      lm.bzid = bzid
      lm.team = team

      return if @last_log_time and @last_log_time = lm.logged_at and bz_server.log_messages.find_by_logged_at_and_log_type_id_and_callsign_id_and_bzid_and_team_id(lm.logged_at, lm.log_type_id, lm.callsign_id, lm.bzid, lm.team_id)

      lm.save!

      # Any existing player connections on this server for this callsign
      # can't be connected anymore - so log the part time
      bz_server.player_connections.find(:all, :conditions => "callsign_id = #{callsign.id} and part_at is null").each do |pc|
        pc.part_at = date
        pc.save!
      end

      # Any existing player connections on this server and slot
      # can't be connected anymore - so log the part time
      bz_server.player_connections.find(:all, :conditions => "slot = #{slot} and part_at is null").each do |pc|
        pc.part_at = date
        pc.save!
      end

      pc = PlayerConnection.create!(:bz_server => bz_server,
                                    :join_at => date,
                                    :ip => ip,
                                    :callsign => callsign,
                                    :is_verified => is_verified,
                                    :is_admin => is_admin,
                                    :is_globaluser => is_globaluser,
                                    :is_operator => is_operator,
                                    :bzid => bzid,
                                    :team => team,
                                    :slot => slot)

    when 'PLAYER-PART'
      lm.callsign, detail = get_callsign(detail)

      slot, detail = parse_slot(detail)
      bzid, detail = parse_bzid(detail)
      lm.bzid = bzid
      lm.message = get_message(detail)

      # Skip it if we've already recorded it
      return if @last_log_time and @last_log_time = lm.logged_at and bz_server.log_messages.find_by_logged_at_and_log_type_id_and_callsign_id_and_bzid_and_message_id(lm.logged_at, lm.log_type_id, lm.callsign_id, lm.bzid, lm.message_id)

      lm.save!

      pc = PlayerConnection.find(:first, :conditions => "bz_server_id = #{bz_server.id} and part_at is null and callsign_id = #{lm.callsign.id}", :include => :ip)
      if pc
        pc.part_at = date
        pc.ip.last_part_at = date
        pc.ip.save!
        pc.save!
      end

    when 'PLAYER-AUTH'
      lm.callsign, detail = get_callsign(detail)

      # Skip it if we've already recorded it
      return if @last_log_time and @last_log_time = lm.logged_at and bz_server.log_messages.find_by_logged_at_and_log_type_id_and_callsign_id(lm.logged_at, lm.log_type_id, lm.callsign_id)

      lm.save!

      begin
        pc = PlayerConnection.find(:first, :conditions => "bz_server_id = #{bz_server.id} and part_at is null and callsign_id = #{lm.callsign.id}")
        pc.is_verified = true

        if detail =~ /\bADMIN\b/
          pc.is_admin = true
        end

        if detail =~ /\bOPERATOR\b/
          pc.is_operator = true
        end

        pc.save!
      rescue
      end

    when 'SERVER-STATUS'
      lm.message = get_message(detail)

      # Skip it if we've already recorded it
      return if @last_log_time and @last_log_time = lm.logged_at and bz_server.log_messages.find_by_logged_at_and_log_type_id_and_callsign_id_and_message_id(lm.logged_at, lm.log_type_id, lm.callsign_id, lm.message_id)

      lm.save!

      bz_server.server_status_message = lm
      bz_server.save!

    when 'SERVER-MAPNAME'
      lm.message = get_message(detail)

      # Skip it if we've already recorded it
      return if @last_log_time and @last_log_time = lm.logged_at and bz_server.log_messages.find_by_logged_at_and_log_type_id_and_callsign_id_and_message_id(lm.logged_at, lm.log_type_id, lm.callsign_id, lm.message_id)

      lm.save!

      bz_server.map_name = detail
      bz_server.save!

    when 'MSG-REPORT', 'MSG-COMMAND'
      lm.callsign, detail = get_callsign(detail)
      lm.message = get_message(detail)

      # Skip it if we've already recorded it
      return if @last_log_time and @last_log_time = lm.logged_at and bz_server.log_messages.find_by_logged_at_and_log_type_id_and_callsign_id_and_message_id(lm.logged_at, lm.log_type_id, lm.callsign_id, lm.message_id)
      lm.save!

    when 'MSG-BROADCAST', 'MSG-ADMIN'
      lm.callsign, detail = get_callsign(detail)
      lm.message = get_message(detail)

      # Skip it if we've already recorded it
      return if @last_log_time and @last_log_time = lm.logged_at and bz_server.log_messages.find_by_logged_at_and_log_type_id_and_callsign_id_and_message_id(lm.logged_at, lm.log_type_id, lm.callsign_id, lm.message_id)
      lm.save!

      bz_server.last_chat_message = lm if lm.callsign.name != "SERVER"
      bz_server.save!

    when 'MSG-FILTERED'
      lm.callsign, detail = get_callsign(detail)
      lm.message = get_message(detail)

      # Skip it if we've already recorded it
      return if @last_log_time and @last_log_time = lm.logged_at and bz_server.log_messages.find_by_logged_at_and_log_type_id_and_callsign_id_and_message_id(lm.logged_at, lm.log_type_id, lm.callsign_id, lm.message_id)
      lm.save!

      bz_server.last_filtered_message = lm
      bz_server.save!

    when 'MSG-DIRECT'
      lm.callsign, detail = get_callsign(detail)
      lm.to_callsign, detail = get_callsign(detail)
      lm.message = get_message(detail)

      # Skip it if we've already recorded it
      return if @last_log_time and @last_log_time = lm.logged_at and bz_server.log_messages.find_by_logged_at_and_log_type_id_and_callsign_id_and_to_callsign_id_and_message_id(lm.logged_at, lm.log_type_id, lm.callsign_id, lm.to_callsign_id, lm.message_id)
      lm.save!

      bz_server.last_chat_message = lm
      bz_server.save!

    when 'MSG-TEAM'
      lm.callsign, detail = get_callsign(detail)
      lm.team, detail = get_team(detail)
      lm.message = get_message(detail)

      # Skip it if we've already recorded it
      return if @last_log_time and @last_log_time = lm.logged_at and bz_server.log_messages.find_by_logged_at_and_log_type_id_and_callsign_id_and_team_id_and_message_id(lm.logged_at, lm.log_type_id, lm.callsign_id, lm.team_id, lm.message_id)
      lm.save!

      bz_server.last_chat_message = lm
      bz_server.save!

    when 'PLAYERS'
      # We do not save PLAYERS data in log messages
      # This updates current_players instead
      count, callsigns = detail.split(" ", 2)
      count = count.slice(1..-2).to_i
      bz_server.current_players.destroy_all
      if count == 0
        # Close out all player connections for this server
        bz_server.player_connections.find(:all, :conditions => "part_at is null").each do |pc|
          pc.part_at = date
          pc.save!
        end
      elsif date > 15.minutes.ago
        1.upto(count) do |idx|
          v, callsign, email, callsigns = parse_player_email(callsigns)
          is_admin = (v == '@')
          is_verified = (v == '+' || is_admin)
          cp = bz_server.current_players.create!(:is_verified => is_verified, :is_admin => is_admin, :callsign => callsign, :email => email, :slot_index => idx)
        end
      end
      bz_server.reload.current_players_count
    end
  end

  def process
    # Initialization
    #
    # Get the server host and BZFlag server record ids
    args = ARGV

    #
    while arg = ARGV.shift
      if arg =~ /^([\w.]+):(\d+)$/
        hostname, port = $1, $2
      else
        usage
      end
    end
    usage if hostname.nil? || port.nil?

    server_host = ServerHost.find_by_hostname(hostname)
    bz_server = BzServer.find_by_server_host_id_and_port(server_host.id, port) if server_host

    if server_host.nil? || bz_server.nil?
      puts "Can't find server #{hostname}:#{port}"
      exit 1
    end

    lm = bz_server.log_messages.find(:first, :order => "logged_at desc")
    @last_log_time = lm.logged_at if lm

    # Process the Log Messages
    STDIN.each do |line|
      process_line(server_host, bz_server, line)
    end
  end
end
