require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  test "devrait rediriger vers la page new" do
    get signup_path
    assert_response :success
  end

  test "devrait rediriger l'index lorsqu'il n'est pas connecté" do
    get users_path
    assert_redirected_to login_url
  end

  test "devrait rediriger vers edit lorsqu'il n'est pas connecté" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "devrait rediriger la update lorsqu'il n'est pas connecté" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "devrait rediriger l'edit lorsqu'il est connecté en tant qu'utilisateur erroné" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "devrait rediriger vers update lorsqu'il est connecté en tant qu'utilisateur erroné" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "devrait rediriger destroy lorsqu'il n'est pas connecté" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "devrait rediriger destroy lorsque vous êtes connecté en tant que non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end

  test "devrait rediriger following lorsqu'il n'est pas connecté" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test "devrait rediriger les followers lorsqu'ils ne sont pas connectés" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
