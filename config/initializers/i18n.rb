# Based on https://www.ruby-forum.com/topic/202131

module I18n
  def self.name_for_locale(locale)
    catch (:exception) do
      return I18n.backend.translate(locale, "meta.lang_name")
    end
    locale.to_s
  end
end
