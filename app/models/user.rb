class User < ActiveRecord::Base
  validates_uniqueness_of :bzid
  has_and_belongs_to_many :groups
end
