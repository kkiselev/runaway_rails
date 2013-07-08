class AddAccountToPlayer < ActiveRecord::Migration
  def change
  	change_table :players do |t|
  		t.integer :treasure_holder_id
  	end
  end
end
