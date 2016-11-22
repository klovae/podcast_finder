class PodcastFinder::Episode < CreateAndRead
  include CreateAndRead::InstanceMethods
  extend CreateAndRead::ClassMethods

  attr_accessor :date, :title, :description, :download_link, :length, :podcast

  @@all = []

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

  def save
    @@all << self
  end

  def self.all
    @@all
  end

end
