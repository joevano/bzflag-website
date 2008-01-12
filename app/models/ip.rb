class Ip < ActiveRecord::Base
  has_many :player_connections
  has_many :callsigns, :through => :player_connections, :uniq => true

  attr_accessor :first_join_at, :last_part_at

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
    # Sort two IPs by the latest player connection part_at time
    #

    # Get the last part_at time if we have one for this IP
    lastpart = self.player_connections.find(:first, :order => 'join_at desc')
    lastpart = lastpart.part_at if lastpart

    # Get the last part_at time for the other IP if it has one
    otherlastpart = other.player_connections.find(:first, :order => 'join_at desc')
    otherlastpart = otherlastpart.part_at if otherlastpart

    # If the other IP has no part_at sort it to the bottom
    # If we have not part_at sort it to the bottom
    # Otherwise compare the part_at times and sort accordingly
    if lastpart.nil?
      1
    elsif otherlastpart.nil?
      -1
    else
      otherlastpart <=> lastpart
    end
  end
end
