class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

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

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "Ne peut pas être vide")
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params)
      # user.update_attribute(:reset_digest, nil) # exercice 12.18
      reset_session
      log_in @User
      @user.update_attribute(:reset_digest, nil)  # exercice 12.23
      flash[:success] = "Mot de passe mis à jour"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # Avant les filtres
    def get_user
      @user = User.find_by(email: params[:email])
    end

    # Confirme un utilisateur valide
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # Vérifie que le jeton a expiré
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "La réinitialisation du mot de passe a expiré"
        redirect_to new_password_reset_url
      end
    end
end
