class CallsignsUseName < ActiveRecord::Migration
  def self.up
    add_column :callsigns, :name, :string
    remove_column :callsigns, :callsign
  end

  def self.down
    add_column :callsigns, :callsign, :string
    remove_column :callsigns, :name
  end
end
