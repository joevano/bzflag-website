#!/usr/bin/env ruby
require 'config/environment'

def usage
  puts "usage: parse_bzfs_log.rb HOST:PORT"
  exit 1
end

def get_callsign(msg, skip=2)
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

def parse_player_email(data)
  # Parse player data that looks like this:
  #
  # [+]9:Bad Sushi() [+]10:spatialgur(15:spatialguru.com) [@]12:drunk driver()
  data =~ /\[(.)\]([^\(]*)\(([^\)]*\)) ?(.*)/
  v, callsign, email, data = "#$1", "#$2", "#$3", "#$4"
  callsign, junk = get_callsign(callsign)
  email, junk = get_callsign(email)
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
bz_server = BzServer.find_by_server_host_id_and_port(server_host.id, port)

if server_host.nil? || bz_server.nil?
  puts "Can't find server #{hostname}:#{port}"
  exit 1
end

puts("Server Host: #{server_host.id}, Bz Server = #{bz_server.id}")

# Log Type Constants
PLAYER_JOIN = 'PLAYER-JOIN'
PLAYER_PART = 'PLAYER-PART'
PLAYER_AUTH = 'PLAYER-AUTH'
SERVER_STATUS = 'SERVER-STATUS'
MSG_BROADCAST = 'MSG-BROADCAST'
MSG_FILTERED = 'MSG-FILTERED'
MSG_DIRECT = 'MSG-DIRECT'
MSG_TEAM = 'MSG-TEAM'
MSG_REPORT  = 'MSG-REPORT '
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
  log = Log.new(:logged_at => date, :log_type_id => log_type_id)

  case log_type
  when PLAYER_JOIN
  when PLAYER_PART
  when PLAYER_AUTH
  when SERVER_STATUS
    log.message = detail
  when MSG_BROADCAST
  when MSG_FILTERED
  when MSG_DIRECT
  when MSG_TEAM
  when MSG_REPORT
  when MSG_COMMAND
  when MSG_ADMINS
  when PLAYERS
    log.log_type_id = nil
    count, callsigns = detail.split(" ", 2)
    count = count.slice(1..-2).to_i
    bz_server.current_player_count = count
    bz_server.save!
    bz_server.current_players.destroy_all
    1.upto(count) do
      verified, callsign, email, detail = parse_player_email(detail)
      cs = Callsign.locate(callsign)
      cp = CurrentPlayer.new(:bz_server_id => bz_server.id, :callsign_id => cs.id, :email => email)

      case verified
      when "+"
        cp.is_verified = true
      when "@"
        cp.is_verified = true
        cp.is_admin = true
      end
      cp.save!
      bz_server.current_players << cp
    end
  end

  if log.log_type_id
    log.save!
  end
end
