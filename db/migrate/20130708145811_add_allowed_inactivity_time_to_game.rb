class AddAllowedInactivityTimeToGame < ActiveRecord::Migration
  def change
  	change_table :games do |t|
  		t.integer :allowed_inactivity_time
  	end
  end
end
