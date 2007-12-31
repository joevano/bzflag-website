class PlayerConnectionAddIsOperator < ActiveRecord::Migration
  def self.up
    add_column :player_connections, :is_operator, :boolean
  end

  def self.down
    remove_column :player_connections, :is_operator
  end
end
