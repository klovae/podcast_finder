class PodcastFinder::Category

  attr_accessor :name, :url, :podcasts

  @@all = []

  def initialize(category_hash)
    category_hash.each {|key, value| self.send("#{key}=", value)}
    @podcasts = []
    self.save
  end

  def save
    @@all << self
  end

  def self.all
    @@all
  end

  def add_podcast(podcast)
    self.podcasts << podcast
    podcast.add_category(self)
  end

  def self.create_from_collection(category_array)
    category_array.each {|category_hash| self.new(category_hash)}
  end

  def self.list_categories
    self.all.each_with_index do |category, index|
      puts "(#{index + 1}) #{category.name}"
    end
  end

  def list_podcasts(number)
    counter = 1 + number
    podcast_list_count = 0
    until counter > (number + 10) do
      if counter <= self.podcasts.size
        podcast = self.podcasts[counter - 1]
        puts "(#{counter}) #{podcast.name}"
        counter += 1
        podcast_list_count += 1
      else
        counter += 10
      end
    end
    podcast_list_count
  end

end
