class PodcastFinder::Episode

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

  def display_date
    @date.strftime('%B %-d, %Y')
  end

  def self.create_from_collection(episode_array)
    episode_array.each {|episode_hash| self.new(episode_hash)}
  end

  def list_data
    puts "Episode: #{self.title}".colorize(:light_blue)
    puts "Podcast: ".colorize(:light_blue) + "#{self.podcast.name}"
    puts "Date ".colorize(:light_blue) + "#{self.display_date}"
    if self.length.nil?
      puts "Length: ".colorize(:light_blue) + "Not Available"
    else
      puts "Length: ".colorize(:light_blue) + "#{self.length}"
    end
    puts "Description: ".colorize(:light_blue) + "#{self.description}"
    puts "Link to download: ".colorize(:light_blue) + "#{self.download_link}"
    puts "Link to listen:  ".colorize(:light_blue) + "#{self.podcast.url}"
  end

  def save
    @@all << self
  end

  def self.all
    @@all
  end

end
