module Ioffer
  module Importer
    include Ioffer::Products
    include Ioffer::Feedbacks
    ITEMS = []
    CONUT = 0
    def target_at_and_for(target, importer)
      user_url = "http://www.ioffer.com/users/#{importer.user_name}"
      user_doc = Mechanize.new.get(user_url)
      self.counter = 0
      case target
      when :products
        import_products(importer.user_name)
        log(importer, "product")
      when :feedbacks
        import_feedbacks(importer.user_name, user_doc)
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
  end
end
