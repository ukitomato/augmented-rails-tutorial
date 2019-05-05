class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> {order(created_at: :desc)}
  scope :feed, ->(user_id, following_ids) {
    where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: user_id)}
  scope :replies, ->(user_name) {where(in_reply_to: user_name)}
  scope :including_replies, ->(user_name, user_id, following_ids) {feed(user_id, following_ids).or(replies(user_name))}
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
  # @return [user_id, user_name, content]
  def reply_to
    content = self.content
    user_name = content[/^@(\w+) (.*)/, 1]
    content = content[/^@(\w+) (.*)/, 2]
    user_id = User.find_by_user_name(user_name).id
    [user_id, user_name, content]
  end


  # replyか判定し、replyなら処理
  def handle_reply
    user_id, user_name, content = reply_to
    if user_name
      self.in_reply_to = user_id
      self.reply_user_name = user_name
      self.content = content
    end
  end
end
