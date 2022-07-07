require "test_helper"

class MicropostsInterface < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    log_in_as(@user)
  end
end

class MicropostsInterfaceTest < MicropostsInterface

  test "devrait paginer les microposts" do
    get root_path
    # assert_select 'div.pagination'
  end

  test "doit afficher des erreurs mais ne pas créer de micropost en cas de soumission invalide" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    # assert_select 'a[href=?]', '/?page=2'  # Correct pagination link
  end

  test "devrait créer un micropost avec succès" do
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  test "devrait avoir des liens de suppression de micropost sur sa propre page de profil" do
    get users_path(@user)
    assert_select 'a', text: 'delete'
  end

  test "devrait supprimer un micropost sur sa propre page de profil" do
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  test "devrait pas avoir un lien de 'supprimer' sur les pages des autres utilisateurs" do
    get user_path(users(:archer))
    assert_select 'a', { text: 'delete', count: 0 }
  end
end

class MicropostSidebarTest < MicropostsInterface

  test "devrait afficher le bon nombre de microposts" do
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
  end

  test "devrait utliser la pluralisation appropriée pour zéro microposts" do
    log_in_as(users(:malory))
    get root_path
    assert_match "0 microposts", response.body
  end

  test "devrait utiliser la pluralisation appropriée pour un micropost" do
    log_in_as(users(:lana))
    get root_path
    assert_match "1 micropost", response.body
  end
end
