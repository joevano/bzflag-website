class LogMessage < ActiveRecord::Base
  belongs_to :log_type
  belongs_to :callsign
  belongs_to :to_callsign, :class_name => "Callsign", :foreign_key => "to_callsign_id"
  belongs_to :team
  belongs_to :message
  belongs_to :bz_server
  has_one :last_chat_log_server, :class_name => "BzServer", :foreign_key => "last_chat_log_message_id"
  has_one :last_filtered_log_server, :class_name => "BzServer", :foreign_key => "last_filtered_log_message_id"
end
