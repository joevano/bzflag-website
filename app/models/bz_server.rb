class BzServer < ActiveRecord::Base
  belongs_to :server_host
  has_many :player_connections
  has_many :users, :through => :player_connections
  has_many :log_messages
  has_many :current_players
  belongs_to :last_chat_message, :class_name => "LogMessage", :foreign_key => "last_chat_log_message_id"
  belongs_to :last_filtered_message, :class_name => "LogMessage", :foreign_key => "last_filtered_log_message_id"

  validates_uniqueness_of :port, :scope => :server_host_id
end
