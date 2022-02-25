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
    header = html.search('h1').first.text.split(' ')
    property_type = {
      name: header[0],
      slug: header[0].downcase
    }
    operation_type = {
      name: header[2],
      slug: header[2].downcase
    }
    usd_price = html.search('.price h2').first.text.split(' ')[1].gsub(',', '').to_f
    total_area = html.search('.dimensions').first.text.split('m')[0].to_i
    bedrooms = html.search('.bedrooms').first ? html.search('.bedrooms').first.text.split(' ')[0].to_i : 0
    bathrooms = html.search('.bathrooms').first ? html.search('.bathrooms').first.text.split(' ')[0].to_i : 0
    garages = html.search('.garages').first ? html.search('.garages').first.text.split(' ')[0].to_i : 0

    data << {
      id: id,
      title: title,
      original_url: original_url,
      original_pictures: original_pictures,
      description: description,
      property_type: property_type,
      operation_type: operation_type,
      usd_price: usd_price,
      local_price: usd_price * 3.8,
      total_area: total_area,
      build_area: total_area,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      garages: garages
    }
  end
  data
end

puts scrapping_items
