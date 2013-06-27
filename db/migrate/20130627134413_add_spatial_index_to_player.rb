class AddSpatialIndexToPlayer < ActiveRecord::Migration
  def change
  	add_index :players, :loc, :spatial => true
  end
end
