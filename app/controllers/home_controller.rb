# show home page
class HomeController < ApplicationController
  def index
    @plaques_count = Plaque.count
    @plaques = Plaque.photographed.random(12)
    if Date.today == '2021-03-08'.to_date
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
    p1 = Plaque.find_by_id(2825)
    if p1
      GoogleAnalytic.find_or_create_by(page: '/plaques/2825', period: 'all time', record: p1, page_views: 19_526)
      p2 = Plaque.find(2885)
      GoogleAnalytic.find_or_create_by(page: '/plaques/2885', period: 'all time', record: p2, page_views: 15_077)
      p3 = Plaque.find(189)
      GoogleAnalytic.find_or_create_by(page: '/plaques/189', period: 'all time', record: p3, page_views: 6_390)
      p4 = Plaque.find(595)
      GoogleAnalytic.find_or_create_by(page: '/plaques/595', period: 'all time', record: p4, page_views: 5_714)
      p5 = Plaque.find(3276)
      GoogleAnalytic.find_or_create_by(page: '/plaques/3276', period: 'all time', record: p5, page_views: 4_085)
      p6 = Plaque.find(628)
      GoogleAnalytic.find_or_create_by(page: '/plaques/628', period: 'all time', record: p6, page_views: 3_846)
      p7 = Plaque.find(1619)
      GoogleAnalytic.find_or_create_by(page: '/plaques/1619', period: 'all time', record: p7, page_views: 3_679)
      p8 = Plaque.find(1114)
      GoogleAnalytic.find_or_create_by(page: '/plaques/1114', period: 'all time', record: p8, page_views: 3_339)
      p9 = Plaque.find(178)
      GoogleAnalytic.find_or_create_by(page: '/plaques/178', period: 'all time', record: p9, page_views: 3_027)
      p10 = Plaque.find(768)
      GoogleAnalytic.find_or_create_by(page: '/plaques/768', period: 'all time', record: p10, page_views: 3_006)   
      @top10 = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10]
    end
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
end
