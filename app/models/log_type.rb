class LogType < ActiveRecord::Base
  validates_uniqueness_of :token
  belongs_to :log_messages

  def self.ids(tokens)
    tokens.collect{|l| LogType.find_by_token(l).id}.join(",")
  end
end
