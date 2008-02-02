class Message < ActiveRecord::Base
  has_many :log_messages
end
