require 'open-uri'
require 'nokogiri'

def scrapper_properties(link)
  # Array que almacenará url's de las propiedades
  items_url = []

  # Propiedades en venta
  # Url propiedades en ventas
  url_ventas = "#{link}/venta/propiedades"

  # Scrapping para traer urls de items

  # Traer el número de paginas de items
  doc_html = Nokogiri::HTML(URI.open(url_ventas).read)
  pt = doc_html.search('.pagination').first.attributes['data-tp'].value.to_i
  i = 1
  pt.times do
    page = "#{url_ventas}/pt-#{i}"
    i += 1
    Nokogiri::HTML(URI.open(page).read).search('.listado-viviendas .vivienda-item .title a').each do |title|
      url = URI.parse(title.attributes['href'].value)
      url.scheme = 'https'
      url.host = 'www.laencontre.com.pe'
      url.query = nil
      # se almacena item en array
      items_url << url.to_s
    end
  end

  # Traer las urls de las propiedades en alquiler
  # Url propiedades en alquiler
  url_alquiler = "#{link}/alquiler/propiedades"

  # Scrapping para traer urls de items
  doc_html = Nokogiri::HTML(URI.open(url_alquiler).read)
  pt = doc_html.search('.pagination').first.attributes['data-tp'].value.to_i
  i = 1
  pt.times do
    page = "#{url_alquiler}/pt-#{i}"
    i += 1
    Nokogiri::HTML(URI.open(page).read).search('.listado-viviendas .vivienda-item .title a').each do |title|
      url = URI.parse(title.attributes['href'].value)
      url.scheme = 'https'
      url.host = 'www.laencontre.com.pe'
      url.query = nil
      # se almacena item en array
      items_url << url.to_s
    end
  end

  items_url.uniq
end
