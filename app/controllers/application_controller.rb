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
    logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    if params[:locale].blank?
      redirect_to({ locale: extract_locale_from_accept_language_header }.merge params)
    else
      I18n.locale = params[:locale]
    end
    logger.debug "* Locale set to '#{I18n.locale}'"
  end

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/) do |str|
      return str if I18n.available_locales.include? str.to_sym
    end
    return I18n.default_locale
  end

  def default_url_options(options={})
    { locale: I18n.locale }.merge options
  end
end
