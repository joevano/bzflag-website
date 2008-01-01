class Callsign < ActiveRecord::Base
  validates_presence_of :name
  has_many :player_connections
  has_many :ips, :through => :player_connections, :uniq => true
  has_many :teams, :through => :player_connections, :uniq => true
  has_many :log_messages

  def self.locate(name)
    if name == ''
      name = 'UNKNOWN'
    end
    Callsign.find_by_name(name) || Callsign.create!(:name => name)
  end
end
