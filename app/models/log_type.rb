class LogType < ActiveRecord::Base
  validates_uniqueness_of :token
  belongs_to :log_messages
end
