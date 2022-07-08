require "test_helper"

class RelationshipTest < ActiveSupport::TestCase

  def setup
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id)
  end

  test "devrait être valide" do
    assert @relationship.valid?
  end

  test "doit avoir un follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "doit avoir un followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end
