module SessionsHelper

  # Se connecte à l'utilisateur donné.
  def log_in(user)
    session[:user_id] = user.id
    # Protégez-vous des attaques de relecture de session.
    # Voir https://bit.ly/33UvK0w pour plus d'informations.
    session[:session_token] = user.session_token
  end

  # Se souvient d'un utilisateur dans une session persistante.
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Renvoie l'utilisateur correspondant au cookie de mémorisation du token.
  def current_user
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      if user && session[:session_token] == user.session_token
        @current_user = user
      end
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Renvoie true si l'utilisateur donné est l'utilisateur actuel.
  def current_user?(user)
    user && user == current_user
  end

  # Renvoie l'utilisateur actuellement connecté (le cas échéant).
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: session[:user_id])
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Renvoie true si l'utilisateur est connecté, false sinon.
  def logged_in?
    !current_user.nil?
  end

  # Oublie une session persistante.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Déconnecte l'utilisateur actuellement connecté.
  def log_out
    forget(current_user)
    reset_session
    @current_user = nil
  end

  # Stocke l'URL essayant d'être accessible
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
