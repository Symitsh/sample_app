class PasswordResetsController < ApplicationController

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "E-mail envoyé avec les instructions de réinitialisation du mot de passe"
      redirect_to root_url
    else
      flash.now[:danger] = "Adresse e-mail introuvable"
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end
end
