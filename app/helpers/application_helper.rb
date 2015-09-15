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
  # If phrase is specified, only matching results are shown.
  # Yields left context, match, right context, start and end indices of the match.
  def split_context(str, lc_size = 5, rc_size = 5, phrase = nil)
    return unless block_given?

    # Split string into words, then find which words are matches. It is assumed
    # that the start and end tags are balanced, and that there is at most one
    # mark tag within a word. We store a list of indices (of words) where
    # highlighted strings start and another list of indices where they end.
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

    # After this, phrase is either nil or an array of words.
    phrase = phrase.split if phrase

    # Merge contiguous matches.
    i = 0
    while i < starts.size
      # Start from index i and loop j upwards, checking whether they form a
      # contiguous set of matching words to be combined.
      # Match status is always either :fail, :ok or blank (nil).
      j = i
      match_status = nil
      while j < starts.size && (i==j || starts[j] == ends[j-1]+1)
        if phrase && words[starts[j]] != phrase[j-i]
          match_status = :fail
          break
        end
        j += 1
        if phrase && j-i == phrase.size
          # The match is complete.
          match_status = :ok
          break
        end
      end

      # If the match is not complete at the end of the string (e.g. searching
      # for "bien que" but the last word of the string is "bien"), reject it.
      if phrase && match_status.nil? && j-i < phrase.size
        match_status = :fail
      end

      if match_status == :fail
        # Just remove the first non-matching word before trying again.
        starts.slice!(i)
        ends.slice!(i)
      else
        j -= 1
        if j > i
          ends[i] = ends[j]
          starts.slice!(i+1..j)
          ends.slice!(i+1..j)
        end
        i += 1
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
      yield lc, match, rc, st, en
    end
  end

  def lc_size
    params.fetch(:lc, 5).to_i
  end

  def rc_size
    params.fetch(:rc, 5).to_i
  end
end
