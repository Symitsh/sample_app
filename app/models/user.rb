class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   { self.email.downcase! }
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 25 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 40 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # Renvoie le hash digest de la chaîne donnée.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Renvoie un nouvel objet SecureRandom.urlsafe_base64.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Mémorise un utilisateur dans la base de donnée en mettant en session une clé et une valeur.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # Renvoie un token de session pour empêcher le détournement de session.
  # Nous réutilisons le résumé de rappel pour plus de commodité.
  def session_token
    remember_digest || remember
  end

  # Retourne true si le token donnée correspond à la digest de la clé.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if remember_digest.nil?    # Si le digest est nil, l'utilisateur n'a pas de clé de mémorisation.
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Déconnecte l'utilisateur actuellement connecté.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Active le compte de l'utilisateur.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Envoie un e-mail d'activation à l'utilisateur.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Définit les attributs de réinitialisation du mot de passe.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # Envoie un e-mail de réinitialisation du mot de passe
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Renvoie true si une réinitialisation de mot de passe a expiré.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

  # Convertis tous les emails en minuscules.
  def downcase_email
    self.email = email.downcase
  end

  # Crée et attribue le token d'activation et le digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
