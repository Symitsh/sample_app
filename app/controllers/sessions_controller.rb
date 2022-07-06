class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        forwarding_url = session[:forwarding_url]
        reset_session
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        log_in user
        redirect_to forwarding_url || user
      else
        message  = "Compte non activé. "
        message += "Vérifiez votre e-mail pour le lien d'activation."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Combinaison e-mail/mot de passe invalide'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?   # Si l'utilisateur est connecté, déconnecte l'utilisateur.
    redirect_to root_url, status: :see_other
  end
end
