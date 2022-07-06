require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < UsersSignup

  test "informations d'inscription invalides" do
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "informations d'inscription valides avec activation du compte" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end

class AccountActivationTest < UsersSignup

  def setup
    super
    post users_path, params: { user: { name:  "Example User",
                                       email: "user@example.com",
                                       password:              "password",
                                       password_confirmation: "password" } }
    @user = assigns(:user)
  end

  test "ne doit pas être activé" do
    assert_not @user.activated?
  end

  test "ne devrait pas pouvoir se connecter avant l'activation du compte" do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  test "ne devrait pas pouvoir se connecter avec un token d'activation invalide" do
    get edit_account_activation_path("invalid token", email: @user.email)
    assert_not is_logged_in?
  end

  test "ne devrait pas pouvoir se connecter avec une adresse e-mail invalide" do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not is_logged_in?
  end

  test "devrait se connecter avec succès avec un token d'activation et un e-mail valides" do
    #get edit_account_activation_path(@user.activation_token, email: @user.email)
    #assert @user.reload.activated?
    #follow_redirect!
    #assert_template 'users/show'
    #assert is_logged_in?
  end
end
