class PodcastFinder::Podcast

  attr_accessor :name, :url
  attr_reader :station, :categories, :description, :episodes

  @@all = []

  def initialize(podcast_hash)
    @name = podcast_hash[:name]
    @url = podcast_hash[:url]
    @description = nil
    @categories = []
    @episodes = []
    self.save
  end

  def add_category(category)
    if category.class == Category && !self.categories.include?(category)
      @categories << category
    end
  end

  def add_episode(episode)
    self.episodes << episode
    episode.podcast = self
  end

  def station=(station)
    if station.class == Station
      @station = station
    end
  end

  def list_episodes
    self.episodes.each_with_index do |episode, index|
      puts "(#{index + 1}) #{episode.title} - #{episode.display_date}" + "#{" - " + episode.length unless episode.length.nil?}"
    end
  end

  def description=(description)
    @description = description
  end

  def list_data
    puts "Podcast: #{self.name}".colorize(:light_blue)
    puts "Station:".colorize(:light_blue) + "#{self.station.name}"
    puts "Description:".colorize(:light_blue) + " #{self.description}"
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
