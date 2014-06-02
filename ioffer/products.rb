module Ioffer
  module Products
    include Ioffer::Photos

    def import_products(username)
      store_url = "http://www.ioffer.com/selling/" + username # "esbuys"
      products_urls = get_pages(store_url)
      unless products_urls.blank?
        get_products(products_urls)
      end
    end
    
    def get_pages(store_url)
      products_urls = []
      products_urls << store_url
      store_doc = Mechanize.new.get(store_url)
      png_div_node = store_doc.search("//div[@class='pagination']")
      link_count = (png_div_node/"a").size
      if link_count > 2
        last_pg_number = (png_div_node/"a")[link_count-2].inner_html.to_i
        2.upto last_pg_number do |i|
          pg_url = store_url + "?page=" + i.to_s
          products_urls << pg_url
        end
      end
      products_urls
    end

    def get_products(products_urls)
      products_urls.each do |page|
        get_product(page)
      end
    end

    def get_product(page)
      pgi_doc = Mechanize.new.get(page)
      items_nodes = pgi_doc.search("//div[@id='storeItemParentContainer']")
      items_nodes.each do |item_node|
        pro = assign_product(item_node)
      end
    end

    def assign_product(item_node)
      item_title_node = item_node/"div[@class='store-body-item-title']"
      name =  (item_title_node/"a").inner_html
      url = (item_title_node/"a").first.attributes["href"].value
      price = ((item_node/"div[@class='align-right store-body-item-price']")/"a span").text.delete("$")
      product = Product.new(
        :store_id => self.id,
        :name => name,
        :origin_url => url,
        :sell_price => price
      )
      product.save(false)
      #      self.counter += 1
      product
    end
  end
end


