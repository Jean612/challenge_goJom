require_relative 'scrapper_url'
require 'open-uri'
require 'nokogiri'

def scrapping_items
  links = scrapper_properties('https://www.laencontre.com.pe/agente/palo-alto-inmobiliaria-37195')
  data = []
  links.each do |link|
    html = Nokogiri::HTML(URI.open(link).read)
    id = "LE-#{link[-6..-1]}"
    title = html.search('.detail-subtitle').first.text
    original_url = link
    original_pictures = html.search('.mfp-gallery picture img').map { |img| img.attributes['src'].value }
    description = html.search('.description').first.text
    data << {
      id: id,
      title: title,
      original_url: original_url,
      original_pictures: original_pictures,
      description: description
    }
  end
  data
end

puts scrapping_items
