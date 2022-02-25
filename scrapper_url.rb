require 'open-uri'
require 'nokogiri'

def traer_items(url)
  items = []
  doc_html = Nokogiri::HTML(URI.open(url).read)                                 # trae los datos de la pagina web conf formato nokogiri
  # Traer número de paginas del catalogo
  pt = doc_html.search('.pagination').first.attributes['data-tp'].value.to_i # 8
  i = 1
  # itera tantas veces como sea el número de paginas del catalogo
  pt.times do
    # Creo la url de cada pagina del catalogo
    page = "#{url}/p_#{i}"
    # aumento 1 al indicador para en la siguiente iteracion cree la url con la siguiente pagina
    i += 1
    # Extraigo la url de cada item de la pagina y le doy el formato de URI
    Nokogiri::HTML(URI.open(page).read).search('.listado-viviendas .vivienda-item .title a').each do |title|
      uri = URI.parse(title.attributes['href'].value)
      uri.scheme = 'https'
      uri.host = 'www.laencontre.com.pe'
      uri.query = nil
      # se almacena item en array con formato de url y en tipo string
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
