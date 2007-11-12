class ServerHost < ActiveRecord::Base
  has_many :bz_servers

  validates_uniqueness_of :hostname
  validates_presence_of :hostname, :owner

end
