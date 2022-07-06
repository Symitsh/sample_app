require "test_helper"

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "devrait être valide" do
    assert @micropost.valid?
  end

  test "l'identifiant de l'utilisateur doit être présent" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "le contenu doit être présent" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  test "le contenu ne doit pas dépasser 140 caractères" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "les micro-messages doivent être triés par date décroissante" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
