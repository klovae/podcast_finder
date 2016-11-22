class PodcastFinder::Category < CreateAndRead
  include CreateAndRead::InstanceMethods
  extend CreateAndRead::ClassMethods

  attr_accessor :name, :url, :podcasts

  @@all = []

  def initialize(category_hash)
    category_hash.each {|key, value| self.send("#{key}=", value)}
    @podcasts = []
    self.save
  end

  def add_podcast(podcast)
    self.podcasts << podcast
    podcast.add_category(self)
  end

  def self.create_from_collection(category_array)
    category_array.each {|category_hash| self.new(category_hash)}
  end

end
