class Ip < ActiveRecord::Base
  has_many :player_connections
  has_many :callsigns, :through => :player_connections, :uniq => true

  def self.locate(ip)
    newip = Ip.find_by_ip(ip)
    if newip.nil?
      newip = Ip.create!(:ip => ip)
      begin
        newip.hostname = Socket.gethostbyaddr(ip.split(".").collect{|y| y.to_i}.pack("CCCC"))[0]
      rescue
      end
      newip.save!
    end
    return newip
  end

  def <=>(other)
    lastpart = self.player_connections.find(:first, :order => 'join_at desc').part_at
    otherlastpart = other.player_connections.find(:first, :order => 'join_at desc').part_at
    otherlastpart <=> lastpart
  end
end
