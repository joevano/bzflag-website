class User < ActiveRecord::Base
  validates_uniqueness_of :bzid
end
