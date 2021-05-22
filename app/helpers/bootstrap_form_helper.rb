# Assist creation of forms
module BootstrapFormHelper
  def bootstrap_text_field(form, key)
    field = form.text_field(key)
    bootstrap_field(form, key, field)
  end

  def bootstrap_select_field(form, key, options)
    field = form.select(key, options, {})
    bootstrap_field(f, key, field)
  end

  def bootstrap_readonly_text_field(form, key, field_value = nil)
    field = form.text_field(key, class: 'form-control-plaintext')
    field = content_tag(:span, class: 'form-control-plaintext') { field_value } if field_value
    bootstrap_field(f, key, field)
  end

  def bootstrap_field(form, key, field)
    content_tag(:div, class: 'row mb-3') do
      content_tag(:div, class: 'col-md-6') do
        content_tag(:div, class: 'form-group') do
          form.label(key) +
            field
        end
      end
    end
  end
end
