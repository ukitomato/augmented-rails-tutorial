require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    # このコードは慣習的に正しくない
    @micropost = @user.microposts.build(content: "Lorem ipsum")
    @reply = @user.microposts.build(content: "@duchess Send Reply.")
    @invalid_reply = @user.microposts.build(content: "@duches Send Reply.")
  end

  test 'should be valid' do
    assert @micropost.valid?
    assert @reply.valid?
    assert_not @invalid_reply.valid?
  end

  test 'user id should be present' do
    @micropost.user_id = nil
    @reply.user_id = nil
    assert_not @micropost.valid?
    assert_not @reply.valid?
  end

  test "content should be present" do
    @micropost.content = "   "
    @reply.content = "    "
    assert_not @micropost.valid?
    assert_not @reply.valid?
  end

  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    @reply.content = "a" * 141
    assert_not @micropost.valid?
    assert_not @reply.valid?
  end

  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end

  test "in_reply_to should be present in reply" do
    @reply.save
    assert @reply.in_reply_to.present?
  end

  test "reply_user_name should be match" do
    @reply.save
    assert_equal @reply.reply_user_name, 'duchess'
  end

  test "replay_user_name_should_be_present_in_users" do
    @reply.save
    assert User.find_by_user_name(@reply.reply_user_name)
  end


end