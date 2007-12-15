class Message < ActiveRecord::Base
  has_many :logs

  def self.locate(text)
    Message.find_by_text(text) || Message.create!(:text => text)
  end
end
