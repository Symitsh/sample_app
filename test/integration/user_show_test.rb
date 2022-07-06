require "test_helper"

class UserShowTest < ActionDispatch::IntegrationTest

  def setup
    @inactive_user = users(:inactive)
    @activated_user = users(:archer)
  end

  test "devrait rediriger lorsque l'utilisateur n'est pas activé" do
    get user_path(@inactive_user)
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "devrait afficher l'utilisateur lorsqu'il est activé" do
    get user_path(@activated_user)
    assert_response :success
    assert_template 'users/show'
  end
end
