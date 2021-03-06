class User < ActiveRecord::Base
  include Garage::Representer
  include Garage::Authorizable

  property :screen_name
  property :user_name
  property :uid

  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner

  def self.build_permissions(perms, other, target)
    perms.permits! :read
  end

  def build_permissions(perms, other)
    perms.permits! :read
    # perms.permits! :write
  end

  # /garage

  extend FriendlyId
  friendly_id :screen_name

  validates :screen_name, uniqueness: true
  # Github username may only contain alphanumeric
  # characters or dashes and cannot begin with a dash
  validates :screen_name, friendly_id: true
  validates :screen_name, length: { in: 1..39 }
  validates :uid, uniqueness: true
  validates :provider, :uid, :screen_name, :user_name, :avatar_url, presence: true

  has_many :access_tokens
  has_many :messages, as: :publisher
  has_many :memberships, as: :memberable
  has_many :rooms, through: :memberships
  has_many :bots
  has_many :applications, class_name: 'Doorkeeper::Application', as: :owner
  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant', foreign_key: :resource_owner_id
  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken', foreign_key: :resource_owner_id

  # Has scoped rooms by each authority
  has_many :administer_memberships, -> { administer }, as: :memberable, class_name: 'Membership'
  has_many :maintainer_memberships, -> { maintainer }, as: :memberable, class_name: 'Membership'
  has_many :member_memberships,     -> { member     }, as: :memberable, class_name: 'Membership'
  has_many :invited_memberships,    -> { invited    }, as: :memberable, class_name: 'Membership'
  has_many :chattable_memberships,  -> { administer || maintainer || member }, as: :memberable, class_name: 'Membership'
  has_many :administer_rooms, source: :room, through: :administer_memberships
  has_many :maintainer_rooms, source: :room, through: :maintainer_memberships
  has_many :member_rooms,     source: :room, through: :member_memberships
  has_many :invited_rooms,    source: :room, through: :invited_memberships
  has_many :chattable_rooms,  source: :room, through: :chattable_memberships

  delegate :private_rooms, to: :rooms
  delegate :public_rooms, to: :rooms

  def avatar_thumbnail_url size = 64
    "#{avatar_url}&s=#{size}"
  end

  def self.uniq_screen_name github_screen_name
    github_screen_name.downcase!
    return github_screen_name if User.where(screen_name: github_screen_name).size == 0
    loop.with_index(2) do |_, i|
      screen_name = "#{github_screen_name}#{i}"
      return screen_name if User.where(screen_name: screen_name).size == 0
    end
  end

  def self.from_omniauth auth
    User.find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.screen_name = auth.info.name
      user.user_name = uniq_screen_name auth.info.nickname
      user.avatar_url = auth.info.image
      essential_token = user.access_tokens.new
      essential_token.name = '-'
      essential_token.token = AccessToken.generate_token
      essential_token.essential = true
    end
  end

end
