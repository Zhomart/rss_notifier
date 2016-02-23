module RssNotifier
  class Item
    DONT_SAVE = [ '@is_changed' ]

    attr_accessor :rss_url
    attr_accessor :rss_title
    attr_accessor :link
    attr_accessor :title
    attr_accessor :description
    attr_accessor :date
    attr_accessor :saved_at

    attr_accessor :is_changed


    def initialize(params = nil)
      params and params.each do |k, v|
        self.send("#{k}=", v)
      end
      self.is_changed = false
    end

    def update(params)
      old_title = self.title
      params.each do |k, v|
        send("#{k}=", v)
      end
      self.is_changed = old_title != self.title
    end

    def changed?
      self.is_changed
    end

    def new_record?
      !self.saved_at
    end

    def to_h
      {
        rss_url: rss_url,
        rss_title: rss_title,
        link: link,
        title: title,
        description: description,
        date: date,
      }
    end

    def encode_with(coder)
      vars = instance_variables.map { |x| x.to_s } - DONT_SAVE

      vars.each do |var|
        var_val = eval(var)
        coder[var.gsub('@', '')] = var_val
      end
    end

  end
end
