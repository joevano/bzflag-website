class IpsAddFirstJoinLastPart < ActiveRecord::Migration
  def self.up
    add_column :ips, :first_join_at, :datetime
    add_column :ips, :last_part_at, :datetime

    execute "update ips set first_join_at = (select join_at from player_connections where player_connections.ip_id = ips.id order by join_at limit 1),
                            last_part_at = (select part_at from player_connections where player_connections.ip_id = ips.id order by part_at desc limit 1);"
      
  end

  def self.down
    remove_column :ips, :first_join_at
    remove_column :ips, :last_part_at
  end
end
