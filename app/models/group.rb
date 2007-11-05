class Group < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  has_one :access_level
end
