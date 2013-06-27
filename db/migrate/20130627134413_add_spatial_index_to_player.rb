class AddSpatialIndexToPlayer < ActiveRecord::Migration
  def change
  	add_index :players, [:game_id, :loc], :spatial => true
  end
end
