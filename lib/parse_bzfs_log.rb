#!/usr/bin/env ruby
require 'config/environment'
require 'time'

def usage
  puts "usage: parse_bzfs_log.rb HOST:PORT"
  exit 1
end

def get_callsign(detail)
  callsign, detail = parse_callsign(detail)
  cs = Callsign.locate(callsign)
  return cs, detail
end

def get_message(message)
  msg = Message.locate(message)
end

def get_team(detail)
  team, detail = detail.split(' ', 2)
  t = Team.locate(team)
  return t, detail
end

def parse_callsign(msg, skip=2)
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

def parse_bzid(detail)
  bzid = nil
  if detail =~ /^BZid:/
    bzid, detail = detail.split(' ', 2)
    bzid = bzid[5..-1]
  end
  return bzid, detail
end

def parse_player_email(data)
  # Parse player data that looks like this:
  #
  # [+]9:Bad Sushi() [+]10:spatialgur(15:spatialguru.com) [@]12:drunk driver()
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

# Log Type Constants
PLAYER_JOIN = 'PLAYER-JOIN'
PLAYER_PART = 'PLAYER-PART'
PLAYER_AUTH = 'PLAYER-AUTH'
SERVER_STATUS = 'SERVER-STATUS'
MSG_BROADCAST = 'MSG-BROADCAST'
MSG_FILTERED = 'MSG-FILTERED'
MSG_DIRECT = 'MSG-DIRECT'
MSG_TEAM = 'MSG-TEAM'
MSG_REPORT  = 'MSG-REPORT'
MSG_COMMAND = 'MSG-COMMAND'
MSG_ADMINS = 'MSG-ADMINS'
PLAYERS = 'PLAYERS'

# Get Log Type ids
log_types = {
  PLAYER_JOIN   => LogType.find_by_token(PLAYER_JOIN).id,
  PLAYER_PART   => LogType.find_by_token(PLAYER_PART).id,
  PLAYER_AUTH   => LogType.find_by_token(PLAYER_AUTH).id,
  SERVER_STATUS => LogType.find_by_token(SERVER_STATUS).id,
  MSG_BROADCAST => LogType.find_by_token(MSG_BROADCAST).id,
  MSG_FILTERED  => LogType.find_by_token(MSG_FILTERED).id,
  MSG_DIRECT    => LogType.find_by_token(MSG_DIRECT).id,
  MSG_TEAM      => LogType.find_by_token(MSG_TEAM).id,
  MSG_REPORT    => LogType.find_by_token(MSG_REPORT).id,
  MSG_COMMAND   => LogType.find_by_token(MSG_COMMAND).id,
  MSG_ADMINS    => LogType.find_by_token(MSG_ADMINS).id,
  PLAYERS       => LogType.find_by_token(PLAYERS).id
}

# Process the Log
STDIN.each do |line|
  date, log_type, detail = line.chomp.split(' ', 3)
  log_type_id = log_types[log_type]
  log = Log.new(:bz_server => bz_server, :logged_at => date, :log_type_id => log_type_id)

  case log_type

  when PLAYER_JOIN
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

    is_verified = detail =~ /VERIFIED/
    is_globaluser = detail =~ /GLOBALUSER/
    is_admin = detail =~ /ADMIN/

    pc = PlayerConnection.create!(:bz_server => bz_server,
                                  :join_at => date,
                                  :ip => ip,
                                  :callsign => callsign,
                                  :is_verified => is_verified,
                                  :is_admin => is_admin,
                                  :bzid => bzid,
                                  :team => team,
                                  :slot => slot)

    log.callsign = callsign
    log.bzid = bzid

  when PLAYER_PART
    log.callsign, detail = get_callsign(detail)
    pc = PlayerConnection.find(:first, :conditions => "bz_server_id = #{bz_server.id} and part_at is null and callsign_id = #{log.callsign.id}")
    if pc
      pc.part_at = date
      pc.save!
    end
    slot, detail = detail.split(' ', 2)
    slot = slot[1..-1]
    bzid, detail = parse_bzid(detail)
    log.message = get_message(detail)

  when PLAYER_AUTH
    log.callsign, detail = get_callsign(detail)
    begin
      pc = PlayerConnection.find(:first, :conditions => "bz_server_id = #{bz_server.id} and part_at is null and callsign_id = #{log.callsign.id}")
      pc.is_verified = true
      pc.save!
    rescue
    end

  when SERVER_STATUS
    log.message = get_message(detail)

  when MSG_BROADCAST, MSG_FILTERED, MSG_REPORT, MSG_COMMAND, MSG_ADMINS
    log.callsign, detail = get_callsign(detail)
    log.message = get_message(detail)

  when MSG_DIRECT
    log.callsign, detail = get_callsign(detail)
    log.to_callsign, detail = get_callsign(detail)
    log.message = get_message(detail)

  when MSG_TEAM
    log.callsign, detail = get_callsign(detail)
    log.team, detail = get_team(detail)
    log.message = get_message(detail)

  when PLAYERS
    log.log_type_id = nil    # We don't save PLAYERS data in the log
    count, callsigns = detail.split(" ", 2)
    count = count.slice(1..-2).to_i
    bz_server.current_player_count = count
    bz_server.save!
    if count == 0
      # Close out all player connections for this server
      PlayerConnection.find(:all, :conditions => "bz_server_id = #{bz_server.id} and part_at is null").each do |pc|
        pc.part_at = date
        pc.save!
      end
    end
  end

  # Save the log if it has a valid id
  log.log_type_id && log.save!
end
