# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_account

  def current_account
    @current_account ||= current_user.account
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end
