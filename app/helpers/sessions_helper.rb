module SessionsHelper

  # Se connecte à l'utilisateur donné.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Renvoie l'utilisateur actuellement connecté (le cas échéant).
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  # Renvoie true si l'utilisateur est connecté, false sinon.
  def logged_in?
    !current_user.nil?
  end
end
