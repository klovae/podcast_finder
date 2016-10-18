class PodcastFinder::DataImporter

  def self.import_podcast_data(category)
    podcast_array = PodcastFinder::Scraper.new.scrape_podcasts(category.url)
    self.import_stations(podcast_array)
    self.import_podcasts(podcast_array, category)
  end

  #helper methods for import_podcast_data

  def self.import_stations(podcast_array)
    podcast_array.each do |podcast_hash|
      check_station = podcast_hash[:station]
      if PodcastFinder::Station.find_by_name(check_station).nil?
        station = PodcastFinder::Station.new(podcast_hash)
      end
    end
  end

  def self.import_podcasts(podcast_array, category)
    podcast_array.each do |podcast_hash|
      check_podcast = podcast_hash[:name]
      if PodcastFinder::Podcast.find_by_name(check_podcast).nil?
        podcast = PodcastFinder::Podcast.new(podcast_hash)
        category.add_podcast(podcast)
        station = PodcastFinder::Station.find_by_name(podcast_hash[:station])
        station.add_podcast(podcast)
      else
        podcast = PodcastFinder::Podcast.find_by_name(check_podcast)
        category.add_podcast(podcast)
      end
    end
  end

  def self.import_description(podcast)
    if podcast.description.nil?
      podcast.description = PodcastFinder::Scraper.new.get_podcast_description(podcast.url)
    end
  end

  def self.import_episodes(podcast)
    if podcast.episodes == []
      episode_list = PodcastFinder::Scraper.new.scrape_episodes(podcast.url)
      episode_list.each do |episode_hash|
        episode = PodcastFinder::Episode.new(episode_hash)
        podcast.add_episode(episode)
      end
    end
  end

end
