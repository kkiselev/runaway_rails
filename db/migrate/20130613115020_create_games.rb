class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :name
      t.polygon :area, :srid => 4326

      t.timestamps
    end
  end
end
