# match a Google Sheet with the database
class MatchController < ApplicationController
  def index
    puts 'matching....'
    @username = params[:username]
    @password = params[:password]
    @key = '0Am_uPM5PCfK4dEZiR01YNndWSGp5cXpwVGdVeTZxekE'.freeze
    @name_column = 1
    @open_plaques_column = 2
    @address_column = 6
    @area = 'London'

    session = GoogleSpreadsheet.login(@username, @password)
    ws = session.spreadsheet_by_key(@key).worksheets[0]

    (1..ws.num_rows).each do |row|
      puts row
      @phrase = ws[row, @name_column][/([a-zA-Z][a-z A-Z]+)/]
      @street = ws[row, @address_column][/([a-zA-Z][a-z A-Z]+)/]
      next unless !@phrase.nil? && !@street.nil?

      @search_results = Plaque.find(:all, joins: :location, conditions: ["lower(inscription) LIKE ? and lower(locations.name) LIKE ? and areas.name = 'London'", "%#{@phrase.downcase}%", "%#{@street.downcase}%"], include: [[personal_connections: [:person]], [location: [area: :country]]])
      if !@search_results.nil? && @search_results.size == 1
        if ws[row, @open_plaques_column] == ''
          puts 'update the op column'
          ws[row, @open_plaques_column] = @search_results[0].id
        else
          puts 'op column already has a value'
        end
      end
    end
    ws.save
  end
end
