class PodcastFinder::Scraper

	def self.scrape_page(url)
	  Nokogiri::HTML(open(url))
	end

	def self.scrape_category_list(url)
		groups = PodcastFinder::Scraper.scrape_page('http://www.npr.org/podcasts').css('nav.global-navigation div.subnav.subnav-podcast-categories div.group')
		categories = groups.each do |group|
			category_info = group.css('ul li')
			category_info.each do |category_data|
				PodcastFinder::Category.new({
					:name => category_data.css('a').text,
					:url => "http://www.npr.org" + category_data.css('a').attribute('href').value
				})
			end
		end
	end

	# podcasts scraping

	def self.scrape_podcasts(category_url)
		counter = 1
		podcasts = []
		until counter == "done" do
			category_page = scrape_page(scrape_url = category_url + "/partials?start=#{counter}")
			if !category_page.css('article').first.nil?
				active_podcasts = category_page.css('article.podcast-active')
				active_podcasts.each {|podcast| podcasts << self.get_podcast_data(podcast)}
				counter += category_page.css('article').size
			else
				counter = "done"
			end
		end
		PodcastFinder::Station.new_from_collection(podcasts)
		self.import_podcasts(podcasts, category)
	end

	def self.import_podcasts(podcasts, category)
		podcasts.each do |podcast_hash|
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

	def self.get_podcast_data(podcast)
		data = {
			:name => podcast.css('h1.title a').text,
			:url => podcast.css('h1.title a').attribute('href').value,
			:station => podcast.css('h3.org a').text,
			:station_url => "http://www.npr.org" + podcast.css('h3.org a').attribute('href').value
		}
	end

	def self.get_podcast_description(podcast_url)
		scrape_page(podcast_url)
		if @index.css('div.detail-overview-content.col2 p').size == 1
			text = @index.css('div.detail-overview-content.col2 p').text
		elsif @indext.css('div.detail-overview-content.col2 p') > 1
			text = @index.css('div.detail-overview-content.col2 p').first.text
		end
			description = text.gsub(@index.css('div.detail-overview-content.col2 p a.more').text, "").gsub("\"", "'")
	end

	#individual episode methods

	def self.scrape_episodes(podcast_url)
		episode_list = []
		scrape_page(podcast_url)
		episodes = @index.css('section.podcast-section.episode-list article.item.podcast-episode')
		episodes.each do |episode|
			episode_data = self.get_episode_data(episode)
			episode_list << episode_data unless episode_data[:download_link].nil? #unless is for edge case
		end
		episode_list
	end

	def self.get_episode_data(episode)
		#for an edge case where sometimes the first podcast has no file associated with it
		if !episode.css('div.audio-module-tools').empty?
			link = episode.css('div.audio-module-tools ul li a').attribute('href').value
			length = episode.css('div.audio-module-controls b.audio-module-listen-duration').text[/(\d*:?\d{1,2}:\d\d)/]
		else
			link = nil
			length = nil
		end
		if episode.css('p').count > 1
			paragraphs = episode.css('p')
			p1 = paragraphs[0].text.gsub(episode.css('p.teaser time').text, "").gsub(/\n+\s*/, "").gsub("\"", "'")
			p2 = paragraphs[1].text.gsub(/\n+\s*/, "").gsub("\"", "'")
			description = p1 + p2 + " Read more online >>"
		else
			description = episode.css('p.teaser').text.gsub(episode.css('p.teaser time').text, "").gsub(/\n+\s*/, "").gsub("\"", "'")
		end
		#end edge case
		episode_data = {
			:date => episode.css('time').attribute('datetime').value,
			:title => episode.css('h2.title').text.gsub(/\n+\s*/, "").gsub("\"", "'"),
			:length => length,
			:description => description,
			:download_link => link
		}
	end

end
