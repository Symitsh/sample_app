require "test_helper"

class PasswordResets < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end
end

class ForgotPasswordFormTest < PasswordResets

  test "chemin de réinitialisation du mot de passe" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  test "réinitialiser le chemin avec un e-mail invalide" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end
end
class PasswordResetForm < PasswordResets

  def setup
    super
    @user = users(:michael)
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end


class PasswordFormTest < PasswordResetForm

  test "réinitialiser avec un email valide" do
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "réinitialiser avec un mauvais e-mail" do
    get edit_password_reset_path(@reset_user.reset_token, email: "")
    assert_redirected_to root_url
  end

  test "réinitialiser avec un utilisateur inactif" do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "réinitialiser avec le bon e-mail mais le mauvais token" do
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    assert_redirected_to root_url
  end


  #test "réinitialiser avec le bon e-mail et le bon token" do
  #  get edit_password_reset_path(@reset_user.reset_token,
  #                               email: @reset_user.email)
  #  assert_template 'password_resets/edit'
  #  assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  #end

end

=begin
class PasswordUpdateTest < PasswordResetForm

  test "mise à jour avec mot de passe invalide et confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
  end

  test "mettre à jour avec un mot de passe vide" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
  end

  test "mise à jour avec mot de passe valide et confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user
  end
end
=end

class ExpiredToken < PasswordResets

  def setup
    super
    # Créer un token de réinitialisation de mot de passe.
    post password_resets_path,
          params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
    # Faites expirer le token à la main.
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    # Essayez de mettre à jour le mot de passe de l'utilisateur.
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
  end
end

=begin
class ExpiredTokenTest < ExpiredToken

  test "devrait rediriger vers la page de réinitialisation du mot de passe" do
    assert_redirected_to new_password_reset_url
  end

  test "doit inclure le mot 'expired' sur la page de réinitialisation du mot de passe" do
    follow_redirect!
    assert_match /expired/i, response.body
  end
end
=end
