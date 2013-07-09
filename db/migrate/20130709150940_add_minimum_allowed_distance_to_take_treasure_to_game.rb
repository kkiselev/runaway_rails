class AddMinimumAllowedDistanceToTakeTreasureToGame < ActiveRecord::Migration
  def change
  	add_column :games, :treasure_allowed_distance, :integer
  end
end
