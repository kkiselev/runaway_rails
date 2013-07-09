class AddTreasureHolderToGame < ActiveRecord::Migration
  def change
  	add_column :games, :treasure_holder_id, :integer
  end
end
