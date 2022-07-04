class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }
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
  def authenticated?(remember_token)
    return false if remember_digest.nil?    # Si le digest est nil, l'utilisateur n'a pas de clé de mémorisation.
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Déconnecte l'utilisateur actuellement connecté.
  def forget
    update_attribute(:remember_digest, nil)
  end
end
