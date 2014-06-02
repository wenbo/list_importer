module Ebay
  module Shippings
    def get_shipping_detail(detail_page, free_category_id, standard_category_id)
      shipping_category_id = (free_shipping?(detail_page) ? free_category_id : standard_category_id)
      self.product.update_attribute(:shipping_category_id, shipping_category_id)
      self.product.update_attribute(:auction, true) if auction?(detail_page)
      assigin_shipping_desc(detail_page)
    end

    def auction?(detail_page)
      auction_node = detail_page.search("//form[@class='vi-is1-s4']")/"th.vi-is1-lblp"
      auction_node.inner_html.include?("Starting bid") ? true :false
    end
    
    def free_shipping?(detail_page)
      shipping_price_node = detail_page.search("//form[@class='vi-is1-s4']")/"td.vi-is1-clr"
      shipping_price_node.inner_html.include?("Free") ? true : false
    end

    def assigin_shipping_desc(detail_page)
      shipping_desc = detail_page.search("//div[@id='vi_tabs_1_cnt']").inner_html
      self.update_attribute(:shipping_desc, ProductDetail.clean_with_tidy(shipping_desc))
    end
  end
end
