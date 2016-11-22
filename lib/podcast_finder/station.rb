class PodcastFinder::Station < CreateAndRead
  include CreateAndRead::InstanceMethods
  extend CreateAndRead::ClassMethods

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
    if podcast.class == PodcastFinder::Podcast && self.class.all.detect {|item| item.name == name}.nil?
      @podcasts << podcast
    end
    podcast.station = self
  end

end
