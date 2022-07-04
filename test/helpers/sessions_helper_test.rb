require "test_helper"

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)           # Définie l'utilisateur michael comme l'utilisateur courant.
    remember(@user)                   # Mémorise l'utilisateur courant.
  end

  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user  # Vérifie que l'utilisateur courant est égal à l'utilisateur donné.
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user           # Vérifie que l'utilisateur courant est nil.
  end
end
