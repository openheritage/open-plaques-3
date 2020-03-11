module BootstrapFormHelper

  def bootstrap_text_field(f, key)
    field = f.text_field(key, class: 'form-control')
    bootstrap_field(f, key, field)
  end

  def bootstrap_select_field(f, key, options)
    field = f.select(key, options, {}, class: 'form-control')
    bootstrap_field(f, key, field)
  end

  def bootstrap_readonly_text_field(f, key, field_value=nil)
    field = f.text_field(key, class: 'form-control-plaintext')
    field = content_tag(:span, class: 'form-control-plaintext') { field_value } if field_value
    bootstrap_field(f, key, field)
  end

  def bootstrap_field(f, key, field)
    content_tag(:div, class: 'row mb-3') do
      content_tag(:div, class: 'col-md-6') do
        content_tag(:div, class: 'form-group') do
          f.label(key, class: 'form-control-label') +
          field 
        end
      end
    end
  end
end