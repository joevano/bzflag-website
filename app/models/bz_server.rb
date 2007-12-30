class BzServer < ActiveRecord::Base
  belongs_to :server_host
  has_many :player_connections
  has_many :users, :through => :player_connections
  has_many :log_messages

  validates_uniqueness_of :port, :scope => :server_host_id

  def last_chat_at
    log_types = log_ids(["MSG-DIRECT","MSG-BROADCAST","MSG-TEAM","MSG-ADMINS"])
    lm = LogMessage.find(:first, :order => "logged_at desc", :conditions => "bz_server_id = #{id} and log_type_id in (#{log_types})")
    lm && lm.logged_at
  end

  def last_filtered_chat_at
    lt = log_ids(["MSG-FILTERED"])
    lm = LogMessage.find(:first, :order => "logged_at desc", :conditions => "bz_server_id = #{id} and log_type_id = #{lt}")
    lm && lm.logged_at
  end

  private

  def log_ids(tokens)
    tokens.collect{|l| LogType.find_by_token(l).id}.join(",")
  end
end
