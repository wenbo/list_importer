module Ebay
  module Feedbacks
    def import_feedbacks(user_doc)
      self.counter = 0
      update_feedback_score_and_count(user_doc)
      feedback_urls = get_feedback_urls(user_doc)
      unless feedback_urls.blank?
        save_feedbacks(feedback_urls)
      end
    end	

    def update_feedback_score_and_count(user_doc)
      # user_url = "http://myworld.ebay.com/612carola/"
      begin
        self.build_feedback_info unless self.feedback_info
        self.feedback_info.feedbacks_count = (user_doc/"h1/a").inner_html.to_i
        td_node = user_doc.search("//td[@class='seeAllLatestFeedback']")
        feedback_url = (td_node/"a").first.attributes["href"].value
        feedback_doc = Mechanize.new.get(feedback_url)
        count_tds = feedback_doc.search("//td[@id='RFRId']")
        self.feedback_info.month_positive_count = count_tds[0].text
        self.feedback_info.half_year_positive_count = count_tds[1].text
        self.feedback_info.year_positive_count = count_tds[2].text
        self.feedback_info.month_neutral_count = count_tds[3].text
        self.feedback_info.half_year_neutral_count = count_tds[4].text
        self.feedback_info.year_neutral_count = count_tds[5].text
        self.feedback_info.month_negative_count = count_tds[6].text
        self.feedback_info.half_year_negative_count = count_tds[7].text
        self.feedback_info.year_negative_count = count_tds[8].text
        self.feedback_info.save
      rescue
        return
      end
    end

    def get_feedback_urls(user_doc)
      feedback_urls = []
      #      user_url = "http://myworld.ebay.com/612carola/"
      begin
        td_node = user_doc.search("//td[@class='seeAllLatestFeedback']")
        feedback_url = (td_node/"a").first.attributes["href"].value
        feedback_urls << feedback_url
        feedback_doc = Mechanize.new.get(feedback_url)
        feedback_table = feedback_doc.search("//div[@class='pg-w']/table")
        href_nodes = (feedback_table/"td.pg-cw")/"b[@class='pg-num']"/"a"
        if href_nodes.size > 1
          sample_url = href_nodes.last.attributes["href"].value
          pgn = sample_url.match(/\d+$/).to_s.to_i
          2.upto pgn do |i|
            feedback_urls << sample_url.gsub(/\d+$/, "#{i}")
          end
        end
        feedback_urls
      end
    end

    def get_feedback_by(feedback_url)
      feedback_doc = Mechanize.new.get(feedback_url)
      feedback_tbody = feedback_doc.search("//table[@class='FbOuterYukon']")
      (feedback_tbody/"tr").each do |tr|
        unless tr.attributes["class"] #&& tr.next.attributes["class"].value == "bot"
          hash = {}
          begin
            if (tr/"td/img").first.attributes["alt"].value == "Positive feedback rating"
              hash[:rank] = 1
            end
            hash[:text] = (tr/"td").first.next.children.text
            hash[:member_id] = (tr/"td[@id='memberBadgeId']"/"div/a/span").first.children.text
            hash[:feedback_score] = (tr/"td[@id='memberBadgeId']"/"div/span/a").first.children.text.split(/ /).last
            hash[:datetime] = (tr/"td").last.text.to_datetime

            bot_tr = tr.next
            hash[:product_name] = (bot_tr/"td")[1].text if (bot_tr/"td")[1]
            hash[:product_price] = (bot_tr/"td")[2] ? (bot_tr/"td")[2].text : "0"
          rescue
            next
          end
          assign_feedback(hash)
        end
      end
    end

    def assign_feedback(hash)
      Feedback.create(
        :store_id => self.id,
        :rating => hash[:rank],
        :buyer => hash[:member_id],
        :product_name => hash[:product_name],
        :content => hash[:text],
        :price => hash[:product_price].match(/\d*\.\d*/).to_s.to_d,
        :created_at => hash[:datetime]
      )
      self.counter += 1
    end

    def save_feedbacks(feedback_urls)
      feedback_urls.each do |feedback_url|
        get_feedback_by feedback_url
      end
    end
  end
end
