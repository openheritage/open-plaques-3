module PhotosHelper

  def thumbnail_img(thing, decorations = nil)
    clazz = "img-rounded card-img-top"
    desc = ""
    begin
      begin
        if thing.thumbnail_url
          desc = image_tag(thing.thumbnail_url, :class => clazz, :width => '100%')
        else
          desc = image_tag(thing.file_url, :class => clazz, :width => '100%')
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
