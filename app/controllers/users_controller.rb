class UsersController < InheritedResources::Base
  include Garage::RestfulActions
  actions :all, except: [ :index ]

  defaults resource_class: User.friendly

  def require_resources
    @resources = User.all
  end

  private
  def permitted_params
    params.permit(user: [:screen_name, :user_name])
  end

end
