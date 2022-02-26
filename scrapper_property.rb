require_relative 'scrapper_url'
require 'open-uri'
require 'nokogiri'
require 'json'

class ScrapperLaEncontre
  def self.import(user_id)
    # llamo al metodo que me trae los links de los items con la url
    puts 'Trayendo los links'
    links = scrapper_properties("https://www.laencontre.com.pe/agente/palo-alto-inmobiliaria-#{user_id}")

    # Array que almacenara los datos de cada item o propiedad
    data = []
    puts 'Trayendo data de las propiedades'
    links.each do |link|
      html = Nokogiri::HTML(URI.open(link).read)
      id = "LE-#{link[-6..-1]}"

      # Extracción de datos

      title = html.at('.detail-subtitle').text
      original_url = link
      original_pictures = html.search('item.mfp-gallery').map { |img| img.attributes['src'].value }
      description = html.at('.description').text
      header = html.at('h1').text.split(' ')
      property_type = {
        name: header[0],
        slug: header[0].downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
      }
      operation_type = {
        name: header[2],
        slug: header[2].downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
      }
      usd_price = html.at('.price h2').text.split(' ')[1].gsub(',', '').to_f
      total_area = html.at('.dimensions') ? html.at('.dimensions').text.split('m')[0].to_i : 0
      bedrooms = html.at('.bedrooms') ? html.at('.bedrooms').text.split(' ')[0].to_i : 0
      bathrooms = html.at('.bathrooms') ? html.at('.bathrooms').text.split(' ')[0].to_i : 0
      garages = html.at('.garages') ? html.at('.garages').text.split(' ')[0].to_i : 0
      ubi = html.at('#locationShown') ? html.at('#locationShown').attributes['value'].value : ''
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

    puts 'Datos listos'
    puts 'Creando JSON'
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
end

ScrapperLaEncontre.import(37195)
