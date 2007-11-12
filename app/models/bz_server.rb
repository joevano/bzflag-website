class BzServer < ActiveRecord::Base
  belongs_to :server_host

  validates_uniqueness_of :port, :scope => :server_host_id
end