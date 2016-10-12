module NavbarHelper
  # Generate <li><a href=...></a></li> appropriate for the Bootstrap navbar.
  # If :active_when hash is provided in the options, a class=active will
  # automatically be added to the <li> when appropriate.
  #
  # Example:
  #
  #     <%= navbar_link_to(
  #           "Home",
  #           root_path,
  #           active_when: { controller: :home }) %>
  #
  def navbar_link_to(label, path, options={})
    active_when = options.delete(:active_when) { Hash.new }
    active = active_when.all? do |key, value|
      params[key].to_s == value.to_s
    end
    active_class = ""
    active_class = " active" if active
    options[:class] = "nav-link"
    content_tag(:li, class: ("nav-item" + active_class)) do
      link_to(label, path, options)
    end
  end
end
