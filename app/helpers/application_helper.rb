module ApplicationHelper

  def alternate_link_to(text, path, format)
    link_to text, path, :type => Mime::Type.lookup_by_extension(format.to_s).to_s, :rel => [:alternate,:nofollow]
  end

end
