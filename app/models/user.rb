class User < ActiveRecord::Base
  validates_uniqueness_of :bzid
  has_and_belongs_to_many :groups
  has_many :permissions, :through => :groups

  def permissions
    perms = []
    self.groups.each do |g|
      perms = perms | g.permissions
    end
    perms
  end
end
