class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'blacklight'

  before_action :set_locale

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def set_locale
    if params[:locale].blank?
      best_locale = http_accept_language.compatible_language_from(I18n.available_locales)
      best_locale ||= I18n.default_locale
      redirect_to({ locale: best_locale }.merge params)
    else
      I18n.locale = params[:locale]
    end
  end

  def default_url_options(options={})
    { locale: I18n.locale }.merge options
  end
end
