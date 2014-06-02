module Ebay
  module Products

    def import_products(user_doc)
      store_url = get_store_url(user_doc)
      pages = get_pages(store_url)
      p "pages size #{pages.size}"
      pages.each do |page|
        get_products(page).each do |item|
          product = get_product(item)
          unless Product.exists?(:origin_url => product.origin_url)
            product.save(false)
            product.create_product_detail(:brief_desc => product.name)
            self.counter += 1
          end
        end
      end
    end

    def get_pages(store_url)
      pages = []
      pages << store_url
      store_doc = Mechanize.new.get(store_url)
      enabled_urls = (store_doc.search("//table[@class='pager']")/"td.pages")/"a.enabled"

      if enabled_urls.size > 1
        sample_url =  enabled_urls.first.attributes["href"].value
        pgn = ((store_doc.search("//table[@class='pgbc']")/"td.l")/"span.page").inner_html.match(/\d+$/).to_s.to_i
        2.upto pgn do |i|
          href_i = sample_url.gsub(/(\?_pgn=)/, "&_pgn=").gsub(/\d+$/, "#{i}")
          href = "http://stores.ebay.com" + href_i unless href_i.match(/^http/)
          pages << href
        end
      end
      pages
    end

    def get_products(page)
      store_doc = Mechanize.new.get(page)
      return if no_listing?(store_doc)
      nodes = store_doc.search("//table[@class='li']") #li nol
      if nodes.blank?
        nodes = store_doc.search("//table[@class='li nol']")
      end
      nodes
    end


    def get_product(item)
      dtl_node = get_detail_link(item)
      Product.new(
        :store_id => self.id,
        :name => ProductDetail.clean_with_tidy((dtl_node.first/"a").inner_html),
        :origin_url => (dtl_node.first/"a").first.attributes["href"].value,
        :sell_price => (item/"td.bids").first.next.inner_html.match(/\d*\.\d*/).to_s
        #        :time_left => ((item/"td").last/"span").first.inner_html
        #        :img_url => (item/"td/a/img").first.attributes["src"].value
      )
    end

    def no_listing?(store_doc)
      no_listing = false
      msg_text = store_doc.search("//div[@class='msg']").text
      if msg_text.match(/has 0 listings/)
        self.importers.find_by_origin("eBay").update_attribute(:last_error, "This eBay Store currently has 0 listings.")
        no_listing = true
      end
      no_listing
    end

    def get_detail_link(item_node)
      (item_node/"td.details").blank? ? item_node/"td.dtl" : item_node/"td.details"
    end
  end
end


