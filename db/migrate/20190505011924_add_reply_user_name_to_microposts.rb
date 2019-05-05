class AddReplyUserNameToMicroposts < ActiveRecord::Migration[5.1]
  def change
    add_column :microposts, :reply_user_name, :string
  end
end
