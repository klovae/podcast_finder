class PodcastFinder::Station

  attr_accessor :name, :url
  attr_reader :podcasts

  @@all = []

  def initialize(podcast_hash)
    @name = podcast_hash[:station]
    @url = podcast_hash[:station_url]
    @podcasts = []
    self.save
  end

  def add_podcast(podcast)
    if podcast.class == Podcast
      @podcasts << podcast
      podcast.station = self
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

end
