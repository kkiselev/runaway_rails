class AddAccountToPlayer < ActiveRecord::Migration
  def change
  	change_table :players do |t|
  		t.references :account
  	end
  end
end
