class Room < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :microposts, dependent: :destroy

  default_scope -> {order(updated_at: :desc)}

  def direct_message(user_id)
    user = User.find(user_id)
    user.rooms << self
    self.name = user.name
  end
end
