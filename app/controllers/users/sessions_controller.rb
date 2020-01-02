# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  include SimpleCaptcha::ControllerHelpers
  prepend_before_action :captcha_valid,:only=> [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end
  
  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  private
  def captcha_valid
    if simple_captcha_valid?
      true
    else
      flash[:alert]="验证码有误，请重新登录"
      self.resource=resource_class.new(sign_in_params)
      respond_with_navigational(resource){render :new}
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def after_sign_in_path_for(resource_or_scope)
    root_path
  end
end
