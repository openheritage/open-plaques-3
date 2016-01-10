class HomeController < ApplicationController
  def index
    @plaques_count = Plaque.count
    @recent_plaques = Plaque.photographed.order("random()").limit(6)
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

  def gc
    puts '*** run garbage collection'
    heap_live_slots_before = GC.stat(:heap_live_slots)
    total_allocated_object_before = GC.stat(:total_allocated_object)
    GC.start
    heap_live_slots_after = GC.stat(:heap_live_slots)
    difference = heap_live_slots_before - heap_live_slots_after
    puts '*** ended garbage collection'
    render :json => { 
      'reply' => 'thank you',
      'heap_live_slots before' => heap_live_slots_before.to_s,
      'heap_live_slots after' => heap_live_slots_after.to_s,
      'difference' => difference.to_s,
      'total_allocated_object before' => total_allocated_object_before.to_s,
      'total_allocated_object after' => GC.stat(:total_allocated_object).to_s
    }, :status => :ok
  end
end
