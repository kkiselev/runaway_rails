class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :login
      t.string :password
      t.string :last_name
      t.string :first_name

      t.timestamps
    end
  end
end
