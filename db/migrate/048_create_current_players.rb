class CreateCurrentPlayers < ActiveRecord::Migration
  def self.up
    create_table :current_players do |t|
      t.integer :slot_index
      t.boolean :is_verified
      t.boolean :is_admin
      t.string :callsign
      t.string :email
      t.integer :bz_server_id

      t.timestamps
    end
  end

  def self.down
    drop_table :current_players
  end
end
