class ChangeDatatypeInReplyToOfMicroposts < ActiveRecord::Migration[5.1]
  def change
    change_column :microposts, :in_reply_to, :string
  end
end
