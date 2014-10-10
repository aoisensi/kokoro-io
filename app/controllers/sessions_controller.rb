class SessionsController < ApplicationController
  skip_load_and_authorize_resource

  def create
    auth = request.env['omniauth.auth']
    user_name = User.uniq_user_name auth.info.nickname
    user = User.where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.screen_name = auth.info.name
      user.user_name = user_name
      user.avatar_url = auth.info.image

      essential_token = user.access_tokens.new
      essential_token.name = '-'
      essential_token.token = AccessToken.generate_token
      essential_token.essential = true
      user.save
    end
    session[:user_id] = user.id
    redirect_to root_path, notice: t('auth.signed_in')
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: t('auth.signed_out')
  end

end
