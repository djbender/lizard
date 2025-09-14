class Project < ApplicationRecord
  has_many :test_runs, dependent: :destroy
  
  validates :name, presence: true
  
  before_create :generate_api_key
  
  private
  
  def generate_api_key
    self.api_key = SecureRandom.hex(32) if api_key.blank?
  end
end
