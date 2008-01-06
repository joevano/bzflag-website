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
    team = nil
    if detail =~ /\s*(\w+)\s+(.*)$/
      team = Team.locate($1)
      detail = $2
    end
    return team, detail
  end

  # Parse the slot number from a string
  def self.parse_slot(detail)
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
  # 	e.g. 7:Thumper
  # 	returns 'Thumper' as the callsign and the remainder of the string
  def self.parse_callsign(msg)
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
  def self.parse_bzid(detail)
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
  def self.parse_player_email(data)
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
  def self.process_line(server_host, bz_server, line)
    # The date can be in 3 formats:
    #
    # 2007-12-16T11:09:42Z
    # 2007-12-16 11:09:42:
    # or missing in which case we use the last date we have available
    if line =~ /(\d\d\d\d-\d\d-\d\d[T ]\d\d:\d\d:\d\dZ?):?\s+(.*)$/
      date = $1
      @date = date
      detail = $2
    else
      date = @date
      detail = line
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

      lm.callsign = callsign
      lm.bzid = bzid
      lm.team = team
      lm.save!

    when 'PLAYER-PART'
      lm.callsign, detail = get_callsign(detail)
      pc = PlayerConnection.find(:first, :conditions => "bz_server_id = #{bz_server.id} and part_at is null and callsign_id = #{lm.callsign.id}")
      if pc
        pc.part_at = date
        pc.save!
      end
      slot, detail = parse_slot(detail)
      bzid, detail = parse_bzid(detail)
      lm.bzid = bzid
      lm.message = get_message(detail)
      lm.save!

    when 'PLAYER-AUTH'
      lm.callsign, detail = get_callsign(detail)
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
      lm.save!

    when 'SERVER-STATUS'
      lm.message = get_message(detail)
      lm.save!
      bz_server.server_status_log_message_id = lm.id
      bz_server.save!

    when 'MSG-REPORT', 'MSG-COMMAND'
      lm.callsign, detail = get_callsign(detail)
      lm.message = get_message(detail)
      lm.save!

    when 'MSG-BROADCAST', 'MSG-ADMIN'
      lm.callsign, detail = get_callsign(detail)
      lm.message = get_message(detail)
      lm.save!
      bz_server.last_chat_log_message_id = lm.id
      bz_server.save!

    when 'MSG-FILTERED'
      lm.callsign, detail = get_callsign(detail)
      lm.message = get_message(detail)
      lm.save!
      bz_server.last_filtered_log_message_id = lm.id
      bz_server.save!

    when 'MSG-DIRECT'
      lm.callsign, detail = get_callsign(detail)
      lm.to_callsign, detail = get_callsign(detail)
      lm.message = get_message(detail)
      lm.save!
      bz_server.last_chat_log_message_id = lm.id
      bz_server.save!

    when 'MSG-TEAM'
      lm.callsign, detail = get_callsign(detail)
      lm.team, detail = get_team(detail)
      lm.message = get_message(detail)
      lm.save!
      bz_server.last_chat_log_message_id = lm.id
      bz_server.save!

    when 'PLAYERS'
      # We do not save PLAYERS data in log messages
      # This updates current_players instead
      count, callsigns = detail.split(" ", 2)
      count = count.slice(1..-2).to_i
      if count == 0
        # Close out all player connections for this server
        PlayerConnection.find(:all, :conditions => "bz_server_id = #{bz_server.id} and part_at is null").each do |pc|
          pc.part_at = date
          pc.save!
        end
      else
        CurrentPlayer.delete_all(:bz_server_id => bz_server.id)
        1.upto(count) do |idx|
          v, callsign, email, callsigns = parse_player_email(callsigns)
          is_admin = (v == '@')
          is_verified = (v == '+' || is_admin)
          cp = bz_server.current_players.create!(:is_verified => is_verified, :is_admin => is_admin, :callsign => callsign, :email => email, :slot_index => idx)
        end
      end
    end
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
