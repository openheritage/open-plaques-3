class AreaSubjectsController < ApplicationController

  before_action :find_country, only: [:show]
  before_action :find, only: [:show]

  def show
    respond_to do |format|
      format.html {
        @plaques = @area.plaques.connected#.paginate(page: params[:page], per_page: 20)
        @people = people(@plaques)
        render 'areas/subjects/show'
      }
      format.csv {
        @plaques = @area.plaques.connected
        @people = people(@plaques)
        send_data(
          "\uFEFF#{PersonCsv.new(@people).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@area.name}-subjects-#{Date.today.to_s}.csv",
          disposition: 'attachment'
        )
      }
    end
  end

  protected

  def people(plaques)
    @people = []
    @plaques.each do |p|
      p.people.each do |per|
        per.define_singleton_method(:plaques_count) do
          1
        end
        @people << per
      end
    end
    @people.uniq!
  end

  def find_country
    @country = Country.find_by_alpha2!(params[:country_id])
  end

  def find
    @area = @country.areas.find_by_slug!(params[:area_id])
  end

end
