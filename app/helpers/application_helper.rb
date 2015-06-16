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

  # Split string into left and right context around each match.
  def split_context(str, offset = 0, context_size = 55)
    b = str.index(' <mark>', offset)
    return nil if b.nil?
    start = b > context_size ? b - context_size : 0
    lc = str[start..b-1].gsub(/<\/?mark>/,'')
    b += 7
    c = str.index('</mark>', b)
    return nil if c.nil?
    ma = str[b..c-1]
    c += 7
    rc = str[c,context_size].gsub(/<\/?mark>/,'')

    return c, lc, ma, rc
  end

end
