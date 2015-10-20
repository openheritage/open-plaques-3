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
    desc = ""
    begin
      begin
        if thing.thumbnail_url
          desc += image_tag(thing.thumbnail_url, :size => "75x75", :class => "img-rounded")
        else
          desc += image_tag(thing.file_url, :size => "75x75", :class => "img-rounded")
        end
      rescue
        begin
          desc += thumbnail_img(thing.main_photo)
        rescue
          desc += thumbnail_img(thing.plaque)
        end
      end
    rescue
      ## oh, I give up!....
      desc += image_tag("NoPhotoSqr.png", :size => "75x75", :class => "img-rounded")
    end
    return desc.html_safe
  end

end
