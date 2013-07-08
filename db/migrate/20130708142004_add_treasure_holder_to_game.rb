class AddTreasureHolderToGame < ActiveRecord::Migration
  def change
  	change_table :games do |t|
  		t.integer :treasure_holder_id
  	end
  end
end
