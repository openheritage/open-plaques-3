xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  attributes = {:uri => photographer_url(@photographer.id)}
  xml.photographer(attributes) {
    xml.id @photographer.id
    @photographer.photos.each do |photo|
      xml.photo(:uri => photo_url(photo)) {
      }
    end
  }
}