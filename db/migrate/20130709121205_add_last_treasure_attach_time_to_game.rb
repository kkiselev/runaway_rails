class AddLastTreasureAttachTimeToGame < ActiveRecord::Migration
  def change
  	add_column :games, :treasure_attached_at, :timestamp
  end
end
