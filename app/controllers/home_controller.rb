# show home page
class HomeController < ApplicationController
  def index
    @plaques_count = Plaque.count
    @plaques = Plaque.photographed.random(12)
    if Date.today == '2019-03-08'.to_date
      @famous_women = Person
                      .connected
                      .female
                      .non_holocaust
                      .random(12)
                      .preload(:personal_roles, :roles, :main_photo)
    end
    @todays = Pick.todays
    @todays_place = Area.where(name: 'Norwich').first
    @todays_place_description = 'Norwich has a long history. It has been a city since 1094. From the Middle Ages until the Industrial Revolution, Norwich was the largest city in England after London and one of the most important. This is refelected in its plaques.'
    begin
      set_meta_tags open_graph: {
        type: :website,
        url: url_for(only_path: false),
        image: view_context.root_url[0...-1] + view_context.image_path('openplaques.png'),
        title: 'Open Plaques',
        description: 'Documenting the historical links between people and places, as recorded by commemorative plaques'
      }
      set_meta_tags twitter: {
        card: 'summary_large_image',
        site: '@openplaques',
        title: 'Open Plaques',
        image: {
          _: @todays.main_photo ? @todays.main_photo.file_url : view_context.root_url[0...-1] + view_context.image_path('openplaques.png'),
          width: 100,
          height: 100
        }
      }
    rescue
    end
  end

  def gc
    puts '*** run garbage collection'
    heap_live_slots_before = GC.stat(:heap_live_slots)
    total_allocated_object_before = GC.stat(:total_allocated_objects)
    GC.start
    heap_live_slots_after = GC.stat(:heap_live_slots)
    difference = heap_live_slots_before - heap_live_slots_after
    puts '*** ended garbage collection'
    render json: {
      'reply' => 'thank you',
      'heap_live_slots before' => heap_live_slots_before.to_s,
      'heap_live_slots after' => heap_live_slots_after.to_s,
      'difference' => difference.to_s,
      'total_allocated_object before' => total_allocated_object_before.to_s,
      'total_allocated_object after' => GC.stat(:total_allocated_objects).to_s
    }, status: :ok
  end
end
