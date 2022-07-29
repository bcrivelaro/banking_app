# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  after_action :create_account, only: :create

  protected

  def create_account
    resource.build_account.save! if resource.persisted? # user is created successfuly
  end
end
