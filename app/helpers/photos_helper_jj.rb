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
    #puts "thing is " + thing.to_s
    desc = ""
    begin
      begin
        if thing.thumbnail_url
          desc += image_tag(thing.thumbnail_url, :size => "75x75")
        else
          desc += image_tag(thing.file_url, :size => "75x75")
        end
      rescue
        #puts thing.to_s + " doesn't have a thumbnail"
        begin
          #puts thing.to_s + " isn't a photo, is it something with a main photo?"
          desc += thumbnail_img(thing.main_photo)
        rescue
          #puts "does " + thing.to_s + " link to a plaque then?"
          desc += thumbnail_img(thing.plaque)
        end
      end
    rescue
      ## oh, I give up!....
      desc += image_tag("NoPhotoSqr.png", :size => "75x75")
    end
    return desc.html_safe
  end

end
