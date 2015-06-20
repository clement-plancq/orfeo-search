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

  # If 'url' is defined, make the specified field show as a link to it.
  def sample_link_helper args
    if args[:document][:url]
      link_to(args[:document][args[:field]], args[:document][:url])
    else
      args[:document][args[:field]]
    end
  end

  # Split string into left and right context around each match.
  # The context sizes represent number of words.
  def split_context(str, lc_size = 5, rc_size = 5)
    return unless block_given?

    # Split string into words, then find which words are matches. It is assumed
    # that the start and end tags are balanced, and that there is at most one
    # mark tag within a word.
    words = str.split
    starts = []
    ends = []
    in_match = false
    words.each_with_index do |word, idx|
      if (!in_match) && word =~ /<mark>/
        starts.push idx
        word.sub!(/<mark>/, '')
        in_match = true
      end
      if in_match && word =~ /<\/mark>/
        ends.push idx
        word.sub!(/<\/mark>/, '')
        in_match = false
      end
    end

    # Now go through the list previously found matches and yield each.
    starts.each_with_index do |st, i|
      en = ends[i]
      if st < lc_size
        lc = words[0...st].join(' ')
      else
        lc = words[st-lc_size...st].join(' ')
      end
      if st == en
        match = words[st]
      else
        match = words[st..en].join(' ')
      end
      rc = words[en+1..en+rc_size].join(' ')
      yield lc, match, rc
    end
  end

  def lc_size
    params.fetch(:lc, 5).to_i
  end

  def rc_size
    params.fetch(:rc, 5).to_i
  end
end
