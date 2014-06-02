require 'ebay/importer'
require 'ioffer/importer'

require 'rubygems'
require "mechanize"
require "open-uri"

module ListImporter #products list, feedbacks list
  def self.included(recipient)
    recipient.extend(ModelClassMethods)
    recipient.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods   
    def import(target, importer) # target: products or feedbacks
      store = Store.find importer.store_id
      store.import(target, importer)
    end
  end # class methods

  module ModelInstanceMethods   
    def import(target, importer)
      case importer.origin
      when "eBay"
        extend Ebay::Importer
        target_at_and_for target, importer
      when "iOffer"
        extend Ioffer::Importer
        target_at_and_for target, importer
      end 
    end
  end# instance methods
end


