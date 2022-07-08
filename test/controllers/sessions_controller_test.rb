require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "devrait rediriger vers la page d'identification" do
    get login_path
    assert_response :success
  end
end
