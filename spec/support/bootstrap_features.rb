module Features
  module Bootstrap
    def click_on_nav_item(value)
      within '#navbarItemsMain' do
        click_on(value)
      end
    end

    def have_main_heading(value)
      have_css 'h1', text: value
    end

    def have_sub_heading(value)
      have_css 'h2', text: value
    end
  end
end
  
RSpec.configure do |config|
  config.include Features::Bootstrap, type: :feature
end
