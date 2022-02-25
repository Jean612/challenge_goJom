require 'open-uri'
require 'nokogiri'

def traer_items(url)
  items = []
  doc_html = Nokogiri::HTML(URI.open(url).read)
  # Traer número de paginas del catalogo
  pt = doc_html.search('.pagination').first.attributes['data-tp'].value.to_i
  i = 1
  pt.times do
    page = "#{url}/pt-#{i}"
    i += 1
    Nokogiri::HTML(URI.open(page).read).search('.listado-viviendas .vivienda-item .title a').each do |title|
      uri = URI.parse(title.attributes['href'].value)
      uri.scheme = 'https'
      uri.host = 'www.laencontre.com.pe'
      uri.query = nil
      # se almacena item en array
      items << uri.to_s
    end
  end
  items
end

def scrapper_properties(link)
  # Array que almacenará url's de las propiedades
  items_url = []

  # Propiedades en venta
  # Url propiedades en ventas
  url_ventas = "#{link}/venta/propiedades"

  # Scrapping para traer urls de items
  items_url += traer_items(url_ventas)

  # Traer las urls de las propiedades en alquiler
  # Url propiedades en alquiler
  url_alquiler = "#{link}/alquiler/propiedades"

  # Scrapping para traer urls de items
  items_url += traer_items(url_alquiler)

  items_url.uniq
end
