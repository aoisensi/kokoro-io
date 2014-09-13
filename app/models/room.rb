class Room < ActiveRecord::Base
  extend FriendlyId
  friendly_id :room_name

  validates :room_name, :screen_name, presence: true
  validates :room_name, length: { in: 1..255 }
  validates :room_name, uniqueness: true
  validates :screen_name, length: { in: 2..64 }
  validates :private, inclusion: {in: [true, false]}

  has_many :messages
  has_many :memberships
  has_many :users, through: :memberships
  accepts_nested_attributes_for :users

  # def private?
  #   private
  # end

end
