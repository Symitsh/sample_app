require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  test "login with invalid information" do
    get login_path                                                      # Visitez le chemin de connexion.
    assert_template 'sessions/new'                                      # Vérifiez que le nouveau formulaire de sessions s'affiche correctement.
    post login_path, params: { session: { email: "", password: "" } }   # Soumettez un formulaire de connexion non valide.
    assert_response :unprocessable_entity                               # Vérifiez que la réponse HTTP est un code d'erreur 422.
    assert_template 'sessions/new'                                      # Vérifiez que le formulaire de connexion reste affiché.
    assert_not flash.empty?                                             # Vérifiez que le message d'erreur est affiché.
    get root_path                                                       # Visitez une nouvelle page tel la page d'accueil.
    assert flash.empty?                                                 # Vérifiez que le message d'erreur n'apparaît pas sur la nouvelle page.
  end
end
