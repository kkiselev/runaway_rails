class AddGameToPlayer < ActiveRecord::Migration
  def change
    change_table :players do |t|
  		t.references :game
  	end
	end
end
