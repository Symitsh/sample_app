require "test_helper"

class UsersLogin < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end
end

class InvalidPasswordTest < UsersLogin

  test "visite le login_path" do
    get login_path                                                      # Visitez le chemin de connexion.
    assert_template 'sessions/new'                                      # Vérifiez que le nouveau formulaire de sessions s'affiche correctement.
  end

  test "connection avec un email valide/un mot de passe invalide" do
    post login_path, params: { session: { email: @user.email,
                                          password: "invalid" } }       # Soumettez un formulaire de connexion non valide.
    assert_not is_logged_in?                                            # Vérifiez que l'utilisateur n'est pas connecté.
    assert_response :unprocessable_entity                               # Vérifiez que la réponse HTTP est un code d'erreur 422.
    assert_template 'sessions/new'                                      # Vérifiez que le formulaire de connexion reste affiché.
    assert_not flash.empty?                                             # Vérifiez que le message d'erreur est affiché.
    get root_path                                                       # Visitez une nouvelle page tel la page d'accueil.
    assert flash.empty?                                                 # Vérifiez que le message d'erreur n'apparaît pas sur la nouvelle page.
  end
end

class ValidLogin < UsersLogin

  def setup
    super
    post login_path, params: { session: { email: @user.email,
                                          password: "password" } }
  end
end

class ValidLoginTest < ValidLogin

  test "connexion valide" do
    assert is_logged_in?
    assert_redirected_to @user
  end

  test "rediriger après la connexion" do
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end

class Logout < ValidLogin

  def setup
    super
    delete logout_path
  end
end

class LogoutTest < Logout

  test "déconnexion réussie" do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "rediriger après la déconnexion" do
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,     count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "devrait toujours fonctionner après la déconnexion dans la deuxième fenêtre" do
    delete logout_path
    assert_redirected_to root_url
  end

  class RememberingTest < UsersLogin

    test "connexion avec mémorisation" do
      log_in_as(@user, remember_me: '1')
      assert_not cookies[:remember_token].blank?
    end

    test "se connecter sans se souvenir" do
      # Connection pour définir le cookie
      log_in_as(@user, remember_me: '1')
      # Connection à nouveau et vérifiez que le cookie est supprimé.
      log_in_as(@user, remember_me: '0')
      assert cookies[:remember_token].blank?
    end
  end
end
