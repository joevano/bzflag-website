class Message < ActiveRecord::Base
  has_many :log_messages

  def self.locate(text)
    Message.find_by_text(text) || Message.create!(:text => text)
  end
end
