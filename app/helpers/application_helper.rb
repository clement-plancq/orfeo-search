module ApplicationHelper
  def lang_switcher
    last_index = I18n.available_locales.size - 1
    content_tag('small') do
      I18n.available_locales.each_with_index do |loc, i|
        loc_name = I18n.name_for_locale loc
        if loc == I18n.locale
          concat content_tag(:strong, loc_name)
        else
          locale_param = request.path == root_path ? root_path(locale: loc) : params.merge(locale: loc)
          concat link_to loc_name, locale_param
        end
        concat ' | ' unless i == last_index
      end
    end
  end
end
