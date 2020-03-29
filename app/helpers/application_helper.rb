# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def button_delete(path)
    button_to(t('buttons.delete'), path, { method: :delete, class: 'btn btn-danger' })
  end

  def alternate_link_to(text, path, format)
    link_to text, path, type: Mime::Type.lookup_by_extension(format.to_s).to_s, rel: %i[alternate nofollow]
  end

  def div(options = {}, &block)
    content_tag(:div, options, &block)
  end

  def csv_escape(string)
    unless string.blank?
      '"' + string.gsub(/[\r\n]/, ' ').gsub(/\s\s+/, ' ').strip + '"'
    else
      ''
    end
  end

  def block_tag(tag, options = {}, &block)
    concat(content_tag(tag, capture(&block), options), block.binding)
  end

  # h() replaces some characters, but not apostrophes or carriage returns
  def html_safe(phrase)
    h(phrase).gsub(/'/, '&#39;').gsub(/\r\n/, '<br/>')
  end

  def unknown(text = 'unknown')
    content_tag(:span, text, class: :unknown)
  end

  # Outputs an abbreviation tag for 'circa'.
  #
  # ==== Example output:
  #   <abbr title="circa">c</abbr>
  def circa_tag
    content_tag(:abbr, 'c', { title: 'circa' })
  end

  # Produces a link wrapped in a list item element (<li>).
  def list_link_to(link_text, options = {}, html_options = {})
    content_tag(:li, link_to(link_text, options, html_options))
  end

  # Returns 'a' or 'an' depending on whether the word starts with a vowel or not
  #
  # ==== Parameters
  # <tt>name</tt> - the word
  # <tt>include_name - whether to include the name in the string output or not.
  def a_or_an(name, include_name = true)
    if name[0,1] =~ /[aeiou]/
      article = 'an'.html_safe
    else
      article = 'a'.html_safe
    end
    if include_name
      article + ' '.html_safe + name
    else
      article
    end
  end

  # Returns "hasn't" or "haven't" depending on whether a number is more than 1.
  def havent_or_hasnt(number)
    if number == 1
      "hasn't"
    else
      "haven't"
    end
  end

  def pluralize_is_or_are(number, name)
    word = number > 1 ? 'are' : 'is'
    word + ' ' + pluralize(number, name)
  end

  def pluralize_no_count(count, singular, plural = nil)
    ((count == 1 || count == '1') ? singular : (plural || singular.pluralize))
  end

  # A persistant navigation link, as used in "top navs" or "left navs".
  # The main difference is that the link is replaced by a <span> tag when
  # the link would otherwise lead to the page you're already on. This can be used
  # for styling in CSS.
  def navigation_link_to(name, options = {}, html_options = {})
    current_page?(options) ? content_tag(:span, name) : link_to(name, options, html_options)
  end

  # A (persistant) navigation link embedded within a list item.
  # === Example
  #   <%= navigation_list_link_to("Home", root_path) %>
  # Produces:
  #   <li><a href="/">Home</a></li>
  def navigation_list_link_to(name, options = {}, html_options = {})
    content_tag(:li, navigation_link_to(name, options, html_options))
  end

  def pluralize_with_no(number, name)
    number.zero? ? "no #{name}" : pluralize(number, name)
  end

  def pluralize_word(count, singular, plural = nil)
    (count == 1 || count =~ %r/^1(\.0+)?$/) ? singular : (plural || singular.pluralize)
  end

  def make_slug_not_war
    return unless slug.blank?

    self.slug = name.to_s.strip.downcase.tr(' ', '_').tr('-', '_').tr(',', '_').tr('.', '_').tr("'", '').gsub('__', '_')
  end

  def markdown(text)
    markdown = Redcarpet::Markdown.new(
      CustomRender,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      disable_indented_code_blocks: true
    )
    ERB.new(markdown.render(text).html_safe).result(binding).html_safe
  end
end

# Render plaques etc. inside Markdown
class CustomRender < Redcarpet::Render::HTML
  def paragraph(text)
    text.gsub!(/plaque ([0-9]+)/) do |match|
      %(<div class="col-xs-6 col-sm-4 col-md-3"><%= render partial: 'plaques/tile', object: Plaque.find(#{match[7..-1]}), as: :plaque  %></div>)
    end
    %(<div class="row">#{text}</div>)
  end
end
