class BzServer < ActiveRecord::Base
  belongs_to :server_host
  has_many :player_connections
  has_many :users, :through => :player_connections
  has_many :logs

  validates_uniqueness_of :port, :scope => :server_host_id
end
