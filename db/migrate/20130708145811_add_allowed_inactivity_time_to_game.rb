class AddAllowedInactivityTimeToGame < ActiveRecord::Migration
  def change
  	add_column :games, :allowed_inactivity_time, :integer
  end
end
