module MicropostsHelper
  def reply?(micropost)
    micropost.in_reply_to.present?
  end
end
