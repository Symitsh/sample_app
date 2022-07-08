require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @base_title = "Ruby on Rails Tutorial Sample App"
  end

  test "devrait retourner la page d'accueil" do
    get root_url
    assert_response :success
  end

  test "devrait retourner la bonne page pour la page d'identification" do
    get root_path
    assert_response :success
    assert_select "title", "#{@base_title}"
  end

  test "devrait retourner la bonne page pour la page d'information" do
    get help_path
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end

  test "devrait retourner la bonne page pour la page A propos" do
    get about_path
    assert_response :success
    assert_select "title", "About | #{@base_title}"
  end

  test "devrait retourner la bonne page pour la page Contact" do
    get contact_path
    assert_response :success
    assert_select "title", "Contact | #{@base_title}"
  end
end
