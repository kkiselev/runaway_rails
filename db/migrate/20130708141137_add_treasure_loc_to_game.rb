class AddTreasureLocToGame < ActiveRecord::Migration
  def change
  	change_table :games do |t|
  		t.point :treasure_loc, :srid => 4326
  	end
  end
end
