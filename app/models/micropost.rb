class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  scope :feed, lambda { |following_ids|
                 where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)}
  scope :replies, -> { where(in_reply_to: user_id) }
  scope :including_replies, ->(following_ids) { feed(following_ids).or(replies) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validate :picture_size

  before_save :handle_reply

  private

  # アップロードされた画像のサイズをバリデーションする
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "should be less than 5MB")
    end
  end

  # Replyの場合は返信先ユーザと本文を返す（Replyじゃない場合はnil）
  def reply_to
    content = self.content
    [content[/^@(\w+) (.*)/, 1], content[/^@(\w+) (.*)/, 2]]
  end

  # user_nameのidを返す
  def user_name_to_id(user_name)
    user = User.find_by_user_name(user_name)
    user.id
  end

  # replyか判定し、replyなら処理
  def handle_reply
    user_name, content = reply_to
    if user_name
      self.in_reply_to = user_name_to_id(user_name)
      self.content = content
    end
  end
end
