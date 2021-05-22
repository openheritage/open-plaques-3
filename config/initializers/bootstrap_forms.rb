require 'action_view/helpers/tags/base'
# Most input types need the form-control class on them.  This is the easiest way to get that into every form input
module BootstrapTag
  def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
    # puts "content_tag #{name} #{options}"
    options = add_bootstrap_class_to_options(options, 'form-control') if name.to_s == 'textarea'
    options = add_bootstrap_class_to_options(options, 'form-select') if name.to_s == 'select'
    super
  end

  def select_tag(name, option_tags = nil, options = {})
    # puts("select_tag #{name}:#{option_tags}:#{options}")
    super
  end

  def submit_tag(value = "Save changes", options = {})
    # puts("submit_tag #{value} #{options}")
    options = add_bootstrap_class_to_options(options, 'btn btn-primary')
    super
  end

  def tag(name, options, *)
    # puts "tag #{name} #{options}"
    options = add_bootstrap_class_to_options(options, 'form-control', true) if name.to_s == 'input'
    super
  end

  private

  def add_bootstrap_class_to_options(options, default, check_type = false)
    options = {} if options.nil?
    options.stringify_keys!
    if !check_type || options['type'].to_s.in?(%w(text password number email))
      options['class'] = [] unless options.has_key? 'class'
      options['class'] << default if options['class'].is_a?(Array) && !options['class'].include?(default)
      options['class'] << " #{default}" if options['class'].is_a?(String) && options['class'] !~ /\b#{default}\b/
    end
    options
  end

  def content_tag_string(name, content, options, *)
    # puts "content_tag_string #{name} #{options}"
    options = add_bootstrap_class_to_options(options, 'form-control') if name.to_s.in? %w(select textarea)
    super
  end

  def label_tag(name = nil, content_or_options = nil, options = nil, &block)
    # puts "label_tag #{name} #{content_or_options} #{options}"
    options = add_bootstrap_class_to_options(options, 'form-label')
    super
  end
end

ActionView::Helpers::Tags::Base.send :include, BootstrapTag
ActionView::Base.send :include, BootstrapTag
