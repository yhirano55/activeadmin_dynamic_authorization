class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authorize_access_resource!, except: %i(index show new create edit update destroy google_oauth2)

  def authorize_access_resource!
    authorize_resource!(active_admin_config.resource_class) if active_admin_config.respond_to?(:resource_class)
  end
end
