module Ebay
  module Importer
    include Ebay::Products
    include Ebay::Feedbacks
    ITEMS = []
    
    def target_at_and_for(target, importer)
      #http://members.ebay.com/ws/eBayISAPI.dll?ViewUserPage&userid=beltal
      user_url = "http://myworld.ebay.com/#{importer.user_name}"
      user_doc = Mechanize.new.get(user_url)
      self.counter = 0
      case target
      when :products
        import_products(user_doc)
        log(importer, "product")
      when :feedbacks
        import_feedbacks(user_doc)
        log(importer, "feedback")
      end
    end

    def log(importer, kind)
      ImporterLog.create(
        :importer_id => importer.id,
        :kind => kind,
        :count => self.counter
      )
    end

    def get_store_url(user_doc)
      links = user_doc.links
      store_link =links.find do |link|
        link.text == "Visit my store"
      end
      if store_link.blank?
        store_link =links.find do |link|
          link.text == "Items for sale"
        end
      end
      store_link.try(:href) << "/_i.html?_dmd=1"
    end

  end
end
