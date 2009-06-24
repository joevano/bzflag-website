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
# BZFlag ban file parser

class BanEntry
  attr_reader :endtime, :banner, :reason

  def initialize(endtime, banner, reason)
    @endtime = endtime
    @banner = banner
    @reason = reason
  end

  def to_s()
    s =  "end: %s\n" % @endtime
    s += "banner: %s\n" % @banner
    s += "reason: %s\n\n" % @reason
  end
end

class IDBanEntry < BanEntry
  attr_reader :id
  def initialize(id, endtime, banner, reason)
    super(endtime, banner, reason)
    @id = id
  end

  def to_s()
    s = "bzid: %s\n" % @id
    s += super.to_s()
  end
end

class IPBanEntry < BanEntry
  attr_reader :ip
  def initialize(ip, endtime, banner, reason)
    super(endtime, banner, reason)
    @ip = ip
  end

  def to_s()
    s = "%s\n" % @ip
    s += super.to_s()
  end
end

class HostBanEntry < BanEntry
  attr_reader :host

  def initialize(host, endtime, banner, reason)
    super(endtime, banner, reason)
    @host = host
  end

  def to_s()
    s = "host: %s\n" % @host
    s += super.to_s()
  end
end

class Ban
  attr_reader :bans

  def initialize(filename)
    @filename = filename
    load()
  end

  def load()
    ip = host = bzid = endtime = banner = reason = nil
    @bans = []

    open(@filename, 'r') { |f|
      f.each { |line|
        line.rstrip!
        if line == ""
          if !endtime.nil? and !banner.nil? and !reason.nil?
            ban = nil
            if !ip.nil?
              add(IPBanEntry.new(ip, endtime, banner, reason))
            elsif !host.nil?
              add(HostBanEntry.new(host, endtime, banner, reason))
            elsif !bzid.nil?
              add(IDBanEntry.new(bzid, endtime, banner, reason))
            end
            host = bzid = endtime = banner = reason = ip = nil
          end
          next
        end
        if line =~ /^\d+\.\d+\.\d+\.\d+$/
          ip = line
          next
        else
          date = ""
          begin
            tag, data = line.split(": ", 2)
          rescue
            tag = line
          end
          if tag == "host"
            host = data
          elsif tag == "bzid"
            bzid = data
          elsif tag == "end"
            endtime = data
          elsif tag == "banner"
            banner = data
          elsif tag == "reason"
            reason = data
          end
        end
      }
    }
  end

  def save(file)
    file = File.open(file, "w")
    @bans.each{ |b|
      file << b.to_s()
    }
    file.close()
  end

  def add(ban)
    @bans << ban
  end

  def update(ban)
    idx = find(ban)
    if idx
      @bans[idx] = ban
    else
      @bans.push(ban)
    end
  end

  def remove(ban)
    @bans.delete(ban)
  end

  def findIPBan(ip)
    ban = IPBanEntry.new(ip, nil, nil, nil)
    idx = find(ban)
    if idx
      @bans[idx]
    else
      nil
    end
  end

  def find(ban)
    idx = -1
    @bans.each { |b|
      idx += 1
      if b.instance_of?(IPBanEntry) and ban.ip == b.ip
        return idx
      end
      if b.instance_of?(HostBanEntry) and ban.host == b.host
        return idx
      end
      if b.instance_of?(IDBanEntry) and ban.id == b.id
        return idx
      end
    }
    nil
  end

  def permbans_expire(expiretime)
    modified = false
    @bans.each{ |b|
      if b.end.to_int == 0 or b.end.to_int > expiretime
        b.end = expiretime
        update(b)
        modified = true
      end
    }
    modified
  end
end
