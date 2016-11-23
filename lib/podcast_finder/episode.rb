class PodcastFinder::Episode < PodcastFinder::CreateAndRead
  include PodcastFinder::CreateAndRead::InstanceMethods
  extend PodcastFinder::CreateAndRead::ClassMethods

  attr_accessor :date, :title, :description, :download_link, :length, :podcast

  @@all = []

  def self.all
    @@all
  end

  def initialize(episode_hash)
    episode_hash.each {|key, value| self.send("#{key}=", value)}
    self.format_date
    self.save
  end

  def format_date
    date_string = @date.to_s
    @date = Date.parse(date_string, "%Y-%m-%d")
  end

  def self.create_from_collection(episode_array)
    episode_array.each {|episode_hash| self.new(episode_hash)}
  end

end
