class PodcastFinder::Station

  attr_accessor :name, :url
  attr_reader :podcasts

  @@all = []

  def initialize(podcast_hash) #can this use self.send?
    @name = podcast_hash[:station]
    @url = podcast_hash[:station_url]
    @podcasts = []
    self.save
  end

  def add_podcast(podcast)
    if podcast.class == PodcastFinder::Podcast && self.class.all.detect {|item| item.name == name}.nil?
      @podcasts << podcast
    end
    podcast.station = self
  end

  def self.new_from_collection(podcasts) #i don't like this logic here
    podcasts.each do |podcast_hash|
			check_station = podcast_hash[:station]
			if self.find_by_name(check_station).nil?
				station = self.new(podcast_hash)
			end
		end
  end

  def save
    @@all << self
  end

  def self.all
    @@all
  end

  def self.find_by_name(name)
    self.all.detect {|item| item.name == name}
  end

  def self.find_or_create_by_name(hash)
    if self.all.detect {|item| item.name == hash[:name]}.nil?
      self.new(hash)
    else
      self.all.detect {|item| item.name == hash[:name]}
    end
  end

end
