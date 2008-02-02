class Callsign < ActiveRecord::Base
  validates_presence_of :name
  has_many :player_connections
  has_many :ips, :through => :player_connections, :uniq => true
  has_many :teams, :through => :player_connections, :uniq => true
  has_many :log_messages

  def self.locate(name)
    if name == '' || name =~ /^\s+$/
      name = 'UNKNOWN'
    end
    Callsign.find_or_create_by_name(name)
  end
end
