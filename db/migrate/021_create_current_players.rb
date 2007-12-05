class CreateCurrentPlayers < ActiveRecord::Migration
  def self.up
    create_table :current_players do |t|
      t.integer :bz_server_id
      t.boolean :is_verified
      t.boolean :is_admin
      t.integer :callsign_id
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :current_players
  end
end
