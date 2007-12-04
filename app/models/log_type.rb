class LogType < ActiveRecord::Base
  validates_uniqueness_of :token
end
