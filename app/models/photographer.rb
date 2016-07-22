class Photographer
  attr_accessor :id
  attr_accessor :photos_count
  attr_accessor :photos
  attr_accessor :url

  def photos
    return Photo.where(photographer: self.id)
  end

  def plaques
    @plaque_list = []
    photos.each do |photo|
      @plaque_list << photo.plaque if photo.linked?
    end
    @plaque_list
  end

  def self.all
    data = Photo.where.not(plaque_id: nil).group('photographer').order('count_plaque_id desc').distinct.count(:plaque_id)
    @photographers = []
    data.each do |d|
      photographer = Photographer.new
      photographer.id = d[0].to_s.gsub(/\_/,'.')
      photographer.photos_count = d[1]
      @photographers << photographer
    end
    @photographers
  end

end
