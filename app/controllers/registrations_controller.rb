class RegistrationsController < Devise::RegistrationsController
  after_action :create_account, only: :create

  protected

  def create_account
    if resource.persisted? # user is created successfuly
      resource.build_account.save!
    end
  end
end
