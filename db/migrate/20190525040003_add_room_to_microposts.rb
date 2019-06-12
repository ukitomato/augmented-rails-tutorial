class AddRoomToMicroposts < ActiveRecord::Migration[5.1]
  def change
    add_reference :microposts, :room, foreign_key: true
  end
end
