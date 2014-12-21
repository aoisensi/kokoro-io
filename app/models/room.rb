class Room < ActiveRecord::Base
  extend FriendlyId
  friendly_id :room_name

  validates :room_name, :screen_name, :description, presence: true
  validates :room_name, friendly_id: true
  validates :room_name, length: { in: 1..255 }
  validates :room_name, uniqueness: true
  validates :screen_name, length: { in: 2..64 }
  validates :description, length: { in: 1..1000 }
  validates :private, inclusion: {in: [true, false]}

  has_many :messages
  has_many :memberships
  has_many :users,
    ->{ where memberships: { memberable_type: 'User' } },
    { through: :memberships, source: :user, class_name: 'User' }
  has_many :bots,
    -> { where memberships: { memberable_type: 'Bot' } },
    { through: :memberships, source: :bot, class_name: 'Bot' }

  Membership.authorities.each do |k, v|
    association_name = "#{k}_users".to_sym
    has_many association_name,
      ->{ where memberships: { memberable_type: 'User', authority: v } },
      { through: :memberships, source: :user, class_name: 'User' }
  end


  accepts_nested_attributes_for :users

  scope :public_rooms, -> { where private: false }
  scope :private_rooms, -> { where private: true }

  def private?
    private
  end

  def public?
    !private?
  end

  def authority user
    self.memberships.where( user: user ).first.authority.to_sym
  end

  def destroyable? user
    [:administer].include? authority(user)
  end

  def maintainable? user
    [:administer, :maintainer].include? authority(user)
  end

  def leaveable? user
    case authority user
    when :administer
      administer_users.size == 1 ? false : true
    when :maintainer
      true
    when :member
      true
    else
      false
    end
  end

  def bot_addable? user
    [:administer, :maintainer].include? authority(user)
  end

  def kickable? user
    [:administer, :maintainer].include? authority(user)
  end

  def promotable? user, target
    # Can't promote yourself.
    return false if user == target

    case authority user
    when :administer
      [:maintainer, :member].include? authority(target)
    when :maintainer
      [:member].include? authority(target)
    when :member
      false
    else
      false
    end
  end

  def demotable? user, target
    # Can't demote yourself.
    return false if user == target

    case authority user
    when :administer
      [:maintainer].include? authority(target)
    when :maintainer
      false
    when :member
      false
    else
      false
    end
  end

  def invitable? user
    # Anyone can join or be invited on public room
    true if public?

    [:administer, :maintainer].include? authority(user)
  end

end
