class LogType < ActiveRecord::Base
  validates_uniqueness_of :token
  belongs_to :log_messages

  def self.ids(tokens)
    t = tokens.collect do |l| 
      lt = LogType.find_by_token(l)
      lt and lt.id
    end
    t.join(",")
  end
end
