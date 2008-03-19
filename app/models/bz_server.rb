class BzServer < ActiveRecord::Base
  belongs_to :server_host
  has_many :player_connections
  has_many :users, :through => :player_connections
  has_many :log_messages
  has_many :current_players
  belongs_to :last_chat_message, :class_name => "LogMessage", :foreign_key => "last_chat_message_id"
  belongs_to :last_filtered_message, :class_name => "LogMessage", :foreign_key => "last_filtered_message_id"
  belongs_to :server_status_message, :class_name => "LogMessage", :foreign_key => "server_status_message_id"

  validates_uniqueness_of :port, :scope => :server_host_id

  def is_idle
    !last_chat_message || last_chat_message.logged_at < 24.hours.ago
  end

  def is_stopped
    server_status_message && server_status_message.message && server_status_message.message.text.downcase == 'stopped'
  end
end
