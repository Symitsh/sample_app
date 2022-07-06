require "test_helper"

class UsersIndex < ActionDispatch::IntegrationTest

  def setup
    @admin    = users(:michael)
    @non_admin = users(:archer)
  end
end

class UsersIndexAdmin < UsersIndex

  def setup
    super
    log_in_as(@admin)
    get users_path
  end
end

class UsersIndexAdminTest < UsersIndexAdmin

  test "devrait afficher la page d'index" do
    assert_template 'users/index'
  end

  test "devrait paginer les utilisateurs" do
    assert_select 'div.pagination'
  end

  test "devrait avoir des liens de suppression" do
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
      unless user == @admin
        assert_select "a[href=?]", user_path(user), text: "delete"
      end
    end
  end

  test "devrait pouvoir supprimer un utilisateur non admin" do
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
    assert_response :see_other
    assert_redirected_to users_url
  end

  test "devrait afficher uniquement les utilisateurs activés" do
    # Désactivez le premier utilisateur sur la page.
    # Rendre un utilisateur de fixture inactif n'est pas suffisant car Rails ne peut pas
    # garantir qu'il apparaîtrait sur la page première page.
    User.paginate(page: 1).first.toggle!(:activated)
    # Assurez-vous que tous les utilisateurs affichés sont activés.
    assigns(:users).each do |user|
      assert user.activated?
    end
  end
end

class UsersNonAdminIndexTest < UsersIndex

  test "ne devrait pas avoir de liens de suppression en tant que non-administrateur" do
    log_in_as(@non_admin)
    get users_path
    assert_select "a", text: "Supprimer", count: 0
  end
end
