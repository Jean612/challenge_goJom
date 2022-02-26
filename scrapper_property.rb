require_relative 'scrapper_url'
require 'open-uri'
require 'nokogiri'
require 'json'

def scrapping_items
  # llamo al metodo que me trae los links de los items con la url
  links = scrapper_properties('https://www.laencontre.com.pe/agente/palo-alto-inmobiliaria-37195')

  # Array que almacenara los datos de cada item o propiedad
  data = []
  links.each do |link|
    html = Nokogiri::HTML(URI.open(link).read)
    id = "LE-#{link[-6..-1]}"

    # Extracción de datos

    title = html.search('.detail-subtitle').first.text
    original_url = link
    original_pictures = html.search('.mfp-gallery picture img').map { |img| img.attributes['src'].value }
    description = html.search('.description').first.text
    header = html.search('h1').first.text.split(' ')
    property_type = {
      name: header[0],
      slug: header[0].downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    }
    operation_type = {
      name: header[2],
      slug: header[2].downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    }
    usd_price = html.search('.price h2').first.text.split(' ')[1].gsub(',', '').to_f
    total_area = html.search('.dimensions').first ? html.search('.dimensions').first.text.split('m')[0].to_i : 0
    bedrooms = html.search('.bedrooms').first ? html.search('.bedrooms').first.text.split(' ')[0].to_i : 0
    bathrooms = html.search('.bathrooms').first ? html.search('.bathrooms').first.text.split(' ')[0].to_i : 0
    garages = html.search('.garages').first ? html.search('.garages').first.text.split(' ')[0].to_i : 0
    ubi = html.search('#locationShown').first ? html.search('#locationShown').first.attributes['value'].value : ''
    location = {
      address: html.search('.location_info').first ? html.search('.location h2 span').first.text : '',
      country: 'Perú',
      region: ubi.split(',')[2].strip,
      province: ubi.split(',')[1].strip,
      district: ubi.split(',')[0].strip,
      zone: '',
      geo_point: {
        lat: html.search('.see-map').first ? html.search('.see-map').first.attributes['data-x'].value.to_f : '',
        lon: html.search('.see-map').first ? html.search('.see-map').first.attributes['data-y'].value.to_f : ''
      },
      country_slug: 'peru',
      region_slug: ubi.split(',')[2].strip.downcase.gsub(' ', '-').gsub(/[^\w-]/, ''),
      province_slug: ubi.split(',')[1].strip.downcase.gsub(' ', '-').gsub(/[^\w-]/, ''),
      district_slug: ubi.split(',')[0].strip.downcase.gsub(' ', '-').gsub(/[^\w-]/, ''),
      zone_slug: ''.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    }

    # ingresar nuevo hash con la data extraida al array de datos

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
      garages: garages,
      location: location
    }
  end

  # Si el file json existe sobreescribe la data, si no crea uno nuevo

  if File.exist?('data.json')
    File.open('data.json', 'wb') do |file|
      file.write({ data: data }.to_json)
    end
  else
    File.open('data.json', 'w') do |file|
      file.write({ data: data }.to_json)
    end
  end
end

scrapping_items
