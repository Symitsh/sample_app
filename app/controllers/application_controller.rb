class ApplicationController < ActionController::Base
  include SessionsHelper

  private

    # Confirme un utilisateur connecté.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Veuillez vous connecter."
        redirect_to login_url, status: :see_other
      end
    end
end
