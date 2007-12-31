#!/usr/bin/env ruby
# Parse BZFlag server log file data from the logDetail plugin
#
# Create database records from the log for use with the bzflag_website
require 'config/environment'
require 'time'

class LogParser

  # Display format of command line usage
  def self.usage
    puts "usage: parse_bzfs_log.rb HOST:PORT"
    exit 1
  end

  # Get a callsign from a string
  #
  # Returns the callsign object that matches the parsed counted string callsign
  # New callsign objects are created if necessary
  def self.get_callsign(detail)
    callsign, detail = parse_callsign(detail)
    cs = Callsign.locate(callsign)
    return cs, detail
  end

  # Find or create a Message object for a string
  def self.get_message(message)
    msg = Message.locate(message)
  end

  # Find or create a Team object for a string
  def self.get_team(detail)
    team, detail = detail.split(' ', 2)
    t = Team.locate(team)
    return t, detail
  end

  # Parse a counted callsign from a string
  # Returns the callsign and the remainder of the string
  #
  # 	e.g. 7:Thumper
  # 	returns 'Thumper' as the callsign and the remainder of the string
  def self.parse_callsign(msg, skip=2)
    begin
      colon = msg.index(":")
      length = msg[0..colon-1].to_i
      callsign = msg[colon+1..colon+length]
      msg = msg[colon+skip+length..-1]
    rescue
      callsign = "UNKNOWN"
    end
    return callsign , msg
  end

  # Retrieve an optional bzid from the log line
  #
  # Finds a bzid of the format BZid:nnnn as the next token on the log line
  # and returns the bzid value if one is found.
  def self.parse_bzid(detail)
    bzid = nil
    if detail =~ /^BZid:/
      bzid, detail = detail.split(' ', 2)
      bzid = bzid[5..-1]
    end
    return bzid, detail
  end

  # Parse player data that looks like this:
  #
  # [+]9:Bad Sushi() [+]10:spatialgur(15:spatialguru.com) [@]12:drunk driver()
  def self.parse_player_email(data)
    data =~ /\[(.)\]([^\(]*)\(([^\)]*\)) ?(.*)/
    v, callsign, email, data = "#$1", "#$2", "#$3", "#$4"
    callsign, junk = parse_callsign(callsign)
    email, junk = parse_callsign(email)
    if email == 'UNKNOWN'
      email = ''
    else
      email = '(' + email + ')'
    end
    return v, callsign, email, data
  end

  # Process a line from the log file
  #
  def self.process_line(server_host, bz_server, line)
    date, log_type, detail = line.chomp.split(' ', 3)
    log_type_id = LogType.ids([log_type])
    lm = LogMessage.new(:bz_server => bz_server, :logged_at => date, :log_type_id => log_type_id)

    case log_type

    when 'PLAYER-JOIN'
      callsign, detail = get_callsign(detail)
      slot, detail = detail.split(' ', 2)
      slot = slot[1..-1]
      bzid, detail = parse_bzid(detail)
      team, detail = get_team(detail)
      ip, detail = detail.split(' ', 2)
      if ip =~ /^IP:/
        ip = ip[3..-1]
      end
      ip = Ip.locate(ip)

      is_verified = false
      if detail =~ /VERIFIED/
        is_verified = true
      end

      is_globaluser = false
      if detail =~ /GLOBALUSER/
        is_globaluser = true
      end

      is_admin = false
      if detail =~ /ADMIN/
        is_admin = true
      end

      pc = PlayerConnection.create!(:bz_server => bz_server,
                                    :join_at => date,
                                    :ip => ip,
                                    :callsign => callsign,
                                    :is_verified => is_verified,
                                    :is_admin => is_admin,
                                    :is_globaluser => is_globaluser,
                                    :bzid => bzid,
                                    :team => team,
                                    :slot => slot)

      lm.callsign = callsign
      lm.bzid = bzid
      lm.team = team

    when 'PLAYER-PART'
      lm.callsign, detail = get_callsign(detail)
      pc = PlayerConnection.find(:first, :conditions => "bz_server_id = #{bz_server.id} and part_at is null and callsign_id = #{lm.callsign.id}")
      if pc
        pc.part_at = date
        pc.save!
      end
      slot, detail = detail.split(' ', 2)
      slot = slot[1..-1]
      bzid, detail = parse_bzid(detail)
      lm.bzid = bzid
      lm.message = get_message(detail)

    when 'PLAYER-AUTH'
      lm.callsign, detail = get_callsign(detail)
      begin
        pc = PlayerConnection.find(:first, :conditions => "bz_server_id = #{bz_server.id} and part_at is null and callsign_id = #{lm.callsign.id}")
        pc.is_verified = true
        pc.save!
      rescue
      end

    when 'SERVER-STATUS'
      lm.message = get_message(detail)

    when 'MSG-BROADCAST', 'MSG-FILTERED', 'MSG-REPORT', 'MSG-COMMAND', 'MSG-ADMIN'
      lm.callsign, detail = get_callsign(detail)
      lm.message = get_message(detail)

    when 'MSG-DIRECT'
      lm.callsign, detail = get_callsign(detail)
      lm.to_callsign, detail = get_callsign(detail)
      lm.message = get_message(detail)

    when 'MSG-TEAM'
      lm.callsign, detail = get_callsign(detail)
      lm.team, detail = get_team(detail)
      lm.message = get_message(detail)

    when 'PLAYERS'
      lm.log_type_id = nil    # We don't save PLAYERS data in the log
      count, callsigns = detail.split(" ", 2)
      count = count.slice(1..-2).to_i
      if count == 0
        # Close out all player connections for this server
        PlayerConnection.find(:all, :conditions => "bz_server_id = #{bz_server.id} and part_at is null").each do |pc|
          pc.part_at = date
          pc.save!
        end
      end
    end

    # Save the log if it has a valid id
    lm.log_type_id && lm.save!
  end

  def self.process
    # Initialization
    #
    # Get the server host and BZFlag server record ids
    if ARGV.length != 1
      usage
    end

    hostname, port = ARGV[0].split(':')

    server_host = ServerHost.find_by_hostname(hostname)
    if server_host
      bz_server = BzServer.find_by_server_host_id_and_port(server_host.id, port)
    end

    if server_host.nil? || bz_server.nil?
      puts "Can't find server #{hostname}:#{port}"
      exit 1
    end

    # Process the Log Messages
    STDIN.each do |line|
      process_line(server_host, bz_server, line)
    end
  end
end
