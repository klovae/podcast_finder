class PodcastFinder::Podcast < PodcastFinder::CreateAndRead
  include PodcastFinder::CreateAndRead::InstanceMethods
  extend PodcastFinder::CreateAndRead::ClassMethods

  attr_accessor :name, :url
  attr_reader :station, :categories, :description, :episodes

  @@all = []

  def self.all
    @@all
  end

  def initialize(podcast_hash)
    @name = podcast_hash[:name]
    @url = podcast_hash[:url]
    @description = nil
    @categories = []
    @episodes = []
    self.save
  end

  def add_category(category)
    if category.class == PodcastFinder::Category && !self.categories.include?(category)
      @categories << category
    end
  end

  def add_episode(episode)
    self.episodes << episode
    episode.podcast = self
  end

  def station=(station)
    if station.class == PodcastFinder::Station
      @station = station
    end
  end

  def description=(description)
    @description = description
  end

end
