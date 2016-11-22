class PodcastFinder::CLI

  attr_accessor :quit, :podcast_counter, :category_choice, :input, :podcast_choice, :episode_choice

  def initialize(quit = "NO")
    @quit = quit
  end

  def call
    startup_sequence
    until @quit == "YES"
      browse_all_categories
    end
    puts "Thanks for using the Command Line Podcast Finder!"
  end

  #methods needed for startup

  def startup_sequence
    puts "Setting up your command line podcast finder...".colorize(:light_red)
    PodcastFinder::Scraper.scrape_category_list('http://www.npr.org/podcasts')
    sleep(0.5)
    puts ".".colorize(:light_red)
    sleep(0.5)
    puts ".".colorize(:light_yellow)
    sleep(0.5)
    puts ".".colorize(:light_green)
    sleep(0.5)
    puts "Setup complete.".colorize(:light_green)
    sleep(0.5)
    puts ""
    puts "Welcome to the Command Line Podcast Finder!"
    puts "You can use this command line gem to find and listen to interesting podcasts produced by NPR and affiliated stations."
    sleep(0.5)
  end

  #basic menu display methods

  def help
    puts ""
    puts "Help: Commands".colorize(:light_blue)
    puts "--To access any numbered menu, simply type the number of the item you're selecting and press Enter to confirm."
    puts "  Example Menu: All Categories"
    puts "   (1) Arts"
    puts "   (2) Business"
    puts "   (3) Comedy"
    puts "  For example: if you want to view the Comedy category, just type '3' (without the quotes) and press Enter"
    puts "--Type 'exit' at any time to quit the browser"
    puts "--Type 'menu' at any time to go back to the main category menu"
    puts "--Type 'help' if you need a quick reminder about the commands"
    puts "To proceed, enter a command from above or type 'continue' to return to what you were doing".colorize(:light_blue)
  end

  #methods for gets-ing, parsing and acting based on user input

  def get_input
    input = gets.strip
    parse_input(input)
  end

  def parse_input(input)
    if input.match(/^\d+$/)
      @input = input.to_i
    elsif input.upcase == "HELP" || input.upcase == "MENU" || input.upcase == "EXIT" || input.upcase == "MORE" || input.upcase == "BACK" || input.upcase == "PODCASTS" || input.upcase == "CONTINUE"
      @input = input.upcase
    else
      @input = "STUCK"
    end
  end

  def proceed_based_on_input
    case @input
    when "STUCK"
      puts "Sorry, that's not an option. Please type a command from the options above. Stuck? Type 'help'.".colorize(:light_blue)
    when "HELP"
      help
      get_input
      proceed_based_on_input
    when "MENU"
      browse_all_categories
    when "YES"
      @quit = "YES"
    when @input == "BACK" || @input == "MORE" || @input == "PODCASTS" || @input == "CONTINUE"
      @input
    when @input == Fixnum && @input >= 1
      @input
    end
  end

#methods for browsing categories and viewing podcasts

  def browse_all_categories
    @podcast_counter = 0
    puts ""
    puts "Main Menu: All Categories".colorize(:light_blue)
    PodcastFinder::Category.each_with_index do |category, index|
      puts "(#{index + 1}) #{category.name}"
    end
    puts ""
    puts "To get started, choose a category above (1-#{PodcastFinder::Category.all.size}) or type 'help' to see a list of commands.".colorize(:light_blue)
    puts "You can also type 'exit' at any point to quit.".colorize(:light_blue)
    choose_category
  end

  def choose_category
    get_input
    if @input.class == Fixnum && @input.between?(1, PodcastFinder::Category.all.size)
      @category_choice = PodcastFinder::Category.all[@input - 1]
      puts "Loading podcasts from #{@category_choice.name}, please wait..."
      PodcastFinder::Scraper.scrape_podcasts_and_stations(@category_choice)
      browse_category
    else
      if @input.class == Fixnum && !@input.between?(1, PodcastFinder::Category.all.size)
        puts "Sorry, that's not a category. Please enter a number between 1 and 16"
        choose_category
      else
        if @input == "BACK"
          @input = "MENU"
        elsif @input == "HELP"
          proceed_based_on_input
          if @input == "CONTINUE"
            browse_all_categories
          end
        end
        proceed_based_on_input
        choose_category unless @quit == "YES"
      end
    end
  end

  def browse_category
    puts ""
    puts "Category: #{@category_choice.name}".colorize(:light_blue)
    display_podcasts
    choose_podcast
  end

  def display_podcasts
    @listed_podcasts = list_podcasts(@podcast_counter)
    if @listed_podcasts == 10 && @category_choice.podcasts.size > @podcast_counter + @listed_podcasts
      puts ""
      puts "Enter the number of the podcast you'd like to check out (1-#{@podcast_counter + @listed_podcasts})".colorize(:light_blue)
      puts "Type 'menu' to return to the category list".colorize(:light_blue)
      puts "Type 'more' to see the next 10 podcasts".colorize(:light_blue)
    else
      puts ""
      puts "That's all the podcasts for this category!".colorize(:light_blue)
      puts "Enter the number of the podcast you'd like to check out (1-#{@podcast_counter + @listed_podcasts})".colorize(:light_blue)
      puts "Type 'menu' to return to the category list".colorize(:light_blue)
    end
  end

  def list_podcasts(number)
    counter = 1 + number
    podcast_list_count = 0
    until counter > (number + 10) do
      if counter <= @category_choice.podcasts.size
        podcast = @category_choice.podcasts[counter - 1]
        puts "(#{counter}) #{podcast.name}"
        counter += 1
        podcast_list_count += 1
      else
        counter += 10
      end
    end
    podcast_list_count
  end

  def choose_podcast
    get_input
    if @input.class == Fixnum && @input.between?(1, @podcast_counter + @listed_podcasts)
      display_podcast_info
    elsif @input.class == Fixnum && !@input.between?(1, @podcast_counter + @listed_podcasts)
      puts "Sorry, that's not an option. Please choose a number that corresponds to a podcast or type 'more' to see more podcasts.".colorize(:light_blue)
      choose_podcast
    elsif @input == "MENU"
      @category_choice = nil
      proceed_based_on_input
    elsif @input == "MORE"
      @podcast_counter += 10
      browse_category
    else
      if @input == "BACK"
        @input = "MENU"
      elsif @input == "HELP"
        proceed_based_on_input
        if @input == "CONTINUE"
          browse_category
        end
      end
      proceed_based_on_input
      choose_podcast unless @quit == "YES"
    end
  end

#methods for getting details on a specific podcast
  def display_podcast_info
    @podcast_choice = @category_choice.podcasts[@input - 1]
    puts "Loading #{@podcast_choice.name}"
    PodcastFinder::Scraper.get_podcast_description(@podcast_choice)
    puts ""
    puts "Podcast: #{@podcast_choice.name}".colorize(:light_blue)
    puts "Station:".colorize(:light_blue) + "#{@podcast_choice.station.name}"
    puts "Description:".colorize(:light_blue) + " #{@podcast_choice.description}"
    puts ""
    puts "Choose an option below to proceed:".colorize(:light_blue)
    puts "Type 'more' to get episode list".colorize(:light_blue)
    puts "Type 'back' to return to podcast listing for #{@category_choice.name}".colorize(:light_blue)
    puts "Type 'menu' to return to main category menu".colorize(:light_blue)
    choose_podcast_action
  end

  def choose_podcast_action
    get_input
    if @input == "MORE"
      display_episode_list
    elsif @input == "BACK"
      @podcast_counter = 0
      browse_category
    elsif @input == "MENU"
      proceed_based_on_input
    else

      @input = "STUCK" unless @input == "EXIT" || @input == "HELP"
      proceed_based_on_input
      choose_podcast_action unless @quit == "YES"
    end
  end

  def display_episode_list
    puts "Getting episodes for #{@podcast_choice.name}"
    PodcastFinder::Scraper.scrape_episodes(@podcast_choice)
    if !@podcast_choice.episodes.empty?
      puts ""
      puts "#{@podcast_choice.name} Recent Episode List".colorize(:light_blue)
      @podcast_choice.episodes.each_with_index do |episode, index|
        puts "(#{index + 1}) #{episode.title} - #{episode.date.strftime('%B %-d, %Y')}" + "#{" - " + episode.length unless episode.length.nil?}"
      end
      puts ""
      puts "These are all the options currently available in Podcast Finder.".colorize(:light_blue)
      puts "To see more, check out #{@podcast_choice.name} online at #{@podcast_choice.url}"
      puts ""
      puts "Options:".colorize(:light_blue)
      puts "Select an episode (1-#{@podcast_choice.episodes.count}) to get a description and download link".colorize(:light_blue)
      puts "Type 'back' to return to podcast listing for #{@category_choice.name}".colorize(:light_blue)
      puts "Type 'menu' to see the category list".colorize(:light_blue)
      choose_episode
    else #for edge case where a podcast has no associated episodes but is listed as active by website
      puts ""
      puts "Looks like #{@podcast_choice.name} doesn't have episodes online.".colorize(:light_red)
      puts ""
      puts "Type 'back' to return to podcast listing for #{@category_choice.name}".colorize(:light_blue)
      puts "Type 'menu' to see the category list".colorize(:light_blue)
      choose_action_no_episodes
    end
  end

  def choose_action_no_episodes
    get_input
    if @input == "BACK"
      @podcast_counter = 0
      browse_category
    elsif @input == "MENU"
      proceed_based_on_input
    else
      if @input == "MORE"
        @input = "STUCK"
      end
      proceed_based_on_input
      choose_action_no_episodes unless @quit == "YES"
    end
  end

  def choose_episode
    get_input
    if @input.class == Fixnum && @input.between?(1, @podcast_choice.episodes.count)
      @episode_choice = @podcast_choice.episodes[@input-1]
      display_episode_info
    elsif @input.class == Fixnum && !@input.between?(1, @podcast_choice.episodes.count)
      puts "Sorry, that's not an episode option. Please enter a number between 1 and #{@podcast_choice.episodes.count} to proceed."
      choose_episode
    elsif @input == "BACK"
      @podcast_counter = 0
      browse_category
    else
      if @input == "MORE"
        @input = "STUCK"
      end
      proceed_based_on_input
      choose_episode unless @quit == "YES"
    end
  end

  def display_episode_info
    puts ""
  def list_data #this belongs in the CLI
    puts "Episode: #{@episode_choice.title}".colorize(:light_blue)
    puts "Podcast: ".colorize(:light_blue) + "#{@episode_choice.podcast.name}"
    puts "Date ".colorize(:light_blue) + "#{@episode_choice.date.strftime('%B %-d, %Y')}"
    if @episode_choice.length.nil?
      puts "Length: ".colorize(:light_blue) + "Not Available"
    else
      puts "Length: ".colorize(:light_blue) + "#{@episode_choice.length}"
    end
    puts "Description: ".colorize(:light_blue) + "#{@episode_choice.description}"
    puts "Link to download: ".colorize(:light_blue) + "#{@episode_choice.download_link}"
    puts "Link to listen:  ".colorize(:light_blue) + "#{@episode_choice.podcast.url}"

    puts ""
    puts "Options:".colorize(:light_blue)
    puts "Type 'back' to return to episode listing for #{@podcast_choice.name}".colorize(:light_blue)
    puts "Type 'podcasts' to return to the podcast list for #{@category_choice.name}".colorize(:light_blue)
    puts "Type 'menu' to see the category list".colorize(:light_blue)
    choose_action_episode_info
  end

  def choose_action_episode_info
    get_input
    if @input == "BACK"
      @episode_choice = nil
      display_episode_list
    elsif @input == "PODCASTS"
      @podcast_counter = 0
      @podcast_choice = nil
      @episode_choice = nil
      browse_category
    else
      if @input == "MORE" || @input.class == Fixnum
        @input = "STUCK"
      end
      proceed_based_on_input
      choose_action_episode_info unless @quit == "YES"
    end
  end

end
