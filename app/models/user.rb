class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 25 }
  validates :email, presence: true, length: { maximum: 40 }
end
