require 'open-uri'
require 'json'
require 'nokogiri'

r = /([\w\W]*)([\bNEVADA\b\s]*[\bSTATE OF NEVADA\b\s]*[STATE\b\s]*[\bCENTENNIAL\b\s]*[\bHISTORIC[AL]*\b\s]*MA[R]*KER)\s(NO[.]*|number|NUMBER)\W*(\d*)\W*(.*)\W*(.*)\W*(.*)\W*(.*)\W*(.*)\W*/i
j = JSON.parse(open('http://shpo.nv.gov/historical-markers-json').read)
j.each do |js|
  puts "#{js['slug']}"
  output = Nokogiri::HTML(open("http://shpo.nv.gov/nevadas-historical-markers/historical-markers/#{js['slug']}"))
  contents = output.search('.//article/h1').text.strip
  contents += ". " unless contents == nil || contents.empty?
  contents += output.search('.//article/p').text.strip
  contents += output.search('.//article/h3').text.strip
  if /MARKER/.match(contents)
    matches = r.match(contents)
#    matches.to_a.each_with_index do |m, index|
#      puts "matches[#{index}] = #{m}"
#    end
    puts "#{matches[1].gsub('NEVADA CENTENNIAL','').gsub('CENTENNIAL','').gsub('STATE HISTORICAL','')}"
    puts "#{matches[5].gsub('STATE HISTORIC PRESERVATION OFFICE','')}"
  end
end
