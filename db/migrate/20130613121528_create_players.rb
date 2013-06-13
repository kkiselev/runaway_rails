class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.point :loc, :srid => 4326
      t.references :game

      t.timestamps
    end
  end
end
