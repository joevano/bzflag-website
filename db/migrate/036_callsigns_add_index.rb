class CallsignsAddIndex < ActiveRecord::Migration
  def self.up
    add_index :callsigns, :name
  end

  def self.down
    remove_index :callsigns, :name
  end
end
