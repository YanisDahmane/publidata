class Invitation < ApplicationRecord
    belongs_to :establishment
    belongs_to :establishment_period
    belongs_to :user
    belongs_to :room, optional: true
  
    validates :name, presence: true, uniqueness: { scope: :establishment_id }
    validates :role, presence: true
    validates :expires_at, presence: true
  
    scope :search, ->(query) { where("name LIKE ?", "%#{query}%") if query.present? }
  
    before_create :generate_token
  
    default_scope { order(created_at: :desc) }
  
    paginates_per 10
  
    def cant_use?
      self.expires_at < Time.now || self.max_use <= self.taken
    end
  
    def self.ransackable_attributes(auth_object = nil)
      %w[created_at establishment_id establishment_period_id expires_at id max_use name role room_id taken token updated_at user_id]
    end
  
    private
  
    def generate_token
      self.token = SecureRandom.hex(10)
    end
  end
  