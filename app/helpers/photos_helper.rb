module PhotosHelper

  def photo_img(plaque)
    desc = ""
    if plaque.photos.size > 0
      photo = plaque.photos.first
      desc += "<img src=\""+photo.url+"\"/>"
    end
    return desc.html_safe
  end

  def thumbnail_img(thing, decorations = nil)
    clazz = "img-rounded card-img-top img-responsive"
    desc = ""
    begin
      begin
        if thing.thumbnail_url
          desc = image_tag(thing.thumbnail_url, :class => clazz)
        else
          desc = image_tag(thing.file_url, :class => clazz)
        end
      rescue
        begin
          desc = thumbnail_img(thing.main_photo, decorations)
        rescue
          desc = thumbnail_img(thing.plaque, decorations)
        end
      end
      return desc.html_safe
    rescue
#      desc = image_tag("NoPhotoSqr.png", :size => "75x75", :class => clazz)
#      desc = image_tag("NoPhotoSqr.png", :class => clazz)
    end
  end

end
