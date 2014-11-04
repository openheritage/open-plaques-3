class HomepageController < ApplicationController

  def index
    @plaques_count = Plaque.count
    @recent_plaques = Plaque.photographed.random(2)
    @todays = Pick.todays
    begin
      set_meta_tags :open_graph => {
        :type  => :website,
        :url   => url_for(:only_path=>false),
        :image => view_context.root_url[0...-1] + view_context.image_path("openplaques-icon.png"),
        :title => "Open Plaques",
        :description => "Documenting the historical links between people and places, as recorded by commemorative plaques",
      }
    rescue
    end
  end

end