class BzServer < ActiveRecord::Base
  belongs_to :server_host
  has_many :player_connections
  has_many :users, :through => :player_connections
  has_many :log_messages
  has_many :current_players
  has_one :last_chat_log_message, :class_name => "LogMessage", :foreign_key => "id"
  has_one :last_filtered_log_message, :class_name => "LogMessage", :foreign_key => "id"

  validates_uniqueness_of :port, :scope => :server_host_id
end
