require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with valid email/invalid password" do
    get login_path                                                      # Visitez le chemin de connexion.
    assert_template 'sessions/new'                                      # Vérifiez que le nouveau formulaire de sessions s'affiche correctement.
    post login_path, params: { session: { email: @user.email,
                                          password: "invalid" } }       # Soumettez un formulaire de connexion non valide.
    assert_response :unprocessable_entity                               # Vérifiez que la réponse HTTP est un code d'erreur 422.
    assert_template 'sessions/new'                                      # Vérifiez que le formulaire de connexion reste affiché.
    assert_not flash.empty?                                             # Vérifiez que le message d'erreur est affiché.
    get root_path                                                       # Visitez une nouvelle page tel la page d'accueil.
    assert flash.empty?                                                 # Vérifiez que le message d'erreur n'apparaît pas sur la nouvelle page.
  end

  test "login with valid information" do
    post login_path, params: { session: { email: @user.email,
                                          password: "password" } }
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end
