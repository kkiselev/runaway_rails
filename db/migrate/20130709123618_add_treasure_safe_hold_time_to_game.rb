class AddTreasureSafeHoldTimeToGame < ActiveRecord::Migration
  def change
  	add_column :games, :treasure_safe_hold_time, :integer
  end
end
