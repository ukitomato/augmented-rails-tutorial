class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> {order(created_at: :desc)}
  scope :feed, ->(user_id, following_ids) {
    where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: user_id)}
  scope :replies_to, ->(user_id) {where(in_reply_to: user_id)}
  scope :including_replies, ->(user_id, following_ids) {feed(user_id, following_ids).or(replies_to(user_id))}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validate :picture_size
  validate :handle_reply


  private

  # アップロードされた画像のサイズをバリデーションする
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "should be less than 5MB")
    end
  end

  # Replyの場合は返信先ユーザと本文を返す（Replyじゃない場合はnil）
  # @return [user_name, content]
  def reply_to
    content = self.content
    if content.include?('@')
      user_name = content[/^@(\w+) (.*)/, 1]
      content = content[/^@(\w+) (.*)/, 2]
      [user_name, content]
    end
  end

  # replyか判定し、正しいreplyなら処理
  def handle_reply
    if (user_name, content = reply_to)
      if (reply_user = User.find_by_user_name(user_name))
        self.in_reply_to = reply_user.id
        self.reply_user_name = user_name
        self.content = content
      else
        errors.add(:reply_user_name, "should be correct Username")
      end
    end
  end
end
