class CreateRoomsUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :rooms_users do |t|
      t.references :room, foreign_key: true
      t.references :user, foreign_key: true
    end
  end
end
