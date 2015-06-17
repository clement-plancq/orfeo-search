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
  # The context sizes are measured in number of words.
  def split_context(str, offset = 0, lc_size = 5, rc_size = 5)
    b = str.index(' <mark>', offset)
    return nil if b.nil?
    lc = str[0...b].gsub(/<\/?mark>/,'').split()
    lc = lc[-lc_size..-1] if lc.size > lc_size
    lc = lc.join(' ')

    b += 7
    c = str.index('</mark>', b)
    return nil if c.nil?
    ma = str[b...c]
    rc = str[c..-1].gsub(/<\/?mark>/,'').split()[0...rc_size].join(' ')

    return c, lc, ma, rc
  end
end
