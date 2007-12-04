#!/usr/bin/env ruby
require 'config/environment'

def usage
  puts "usage: parse_bzfs_log.rb HOST:PORT"
  exit 1
end

def process_log
  STDIN.each do |line|
    puts "got: #{line}"
  end
end

def init
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
end

init
process_log
