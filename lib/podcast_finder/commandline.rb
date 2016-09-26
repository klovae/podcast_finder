class PodcastFinder::CLI

  attr_accessor :quit, :podcast_counter, :category_choice, :input, :podcast_choice, :episode_choice

  def initialize(quit = "NO")
    @quit = quit
  end

  def call
    self.startup_sequence
    until @quit == "YES"
      self.browse_all_categories
    end
    puts "Thanks for using the Command Line Podcast Finder!"
  end

  #methods needed for startup

  def startup_sequence
    puts "Setting up your command line podcast finder...".colorize(:light_red)
    self.start_import
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

  def start_import
    PodcastFinder::DataImporter.import_categories('http://www.npr.org/podcasts')
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
    puts "To proceed, enter a command from above or type 'back' to return to what you were doing".colorize(:light_blue)
    self.choose_after_help
  end

  def choose_after_help
    self.get_input
    if @input == "MENU" || @input == "EXIT" || @input == "HELP" || @input == "BACK"
      self.proceed_based_on_input
    else
      puts "Sorry, that's not an option. Please type a command from the help menu or type 'back' to return to what you were doing".colorize(:light_blue)
      self.choose_after_help
    end
  end

  #methods for gets-ing, parsing and acting based on user input

  def get_input
    input = gets.strip
    self.parse_input(input)
  end

  def parse_input(input)
    if input.match(/^\d+$/)
      @input = input.to_i
    elsif input.upcase == "HELP" || input.upcase == "MENU" || input.upcase == "EXIT" || input.upcase == "MORE" || input.upcase == "BACK" || input.upcase == "PODCASTS"
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
      self.help
    when "MENU"
      self.browse_all_categories
    when "EXIT"
      @quit = "YES"
    when @input == "BACK" || @input == "MORE" || @input == "PODCASTS"
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
    PodcastFinder::Category.list_categories
    puts ""
    puts "To get started, choose a category above (1-#{PodcastFinder::Category.all.size}) or type 'help' to see a list of commands.".colorize(:light_blue)
    puts "You can also type 'exit' at any point to quit.".colorize(:light_blue)
    self.choose_category
  end

  def choose_category
    self.get_input
    if @input.class == Fixnum && @input.between?(1, 16)
      @category_choice = PodcastFinder::Category.all[@input - 1]
      puts "Loading podcasts from #{@category_choice.name}, please wait..."
      PodcastFinder::DataImporter.import_podcast_data(@category_choice)
      self.browse_category
    else
      if @input.class == Fixnum && !@input.between?(1,16)
        puts "Sorry, that's not a category. Please enter a number between 1 and 16"
        self.choose_category
      else
        @input = "STUCK" unless @input == "EXIT" || @input == "HELP" || @input == "BACK"
        if @input == "BACK"
          @input = "MENU"
        elsif @input == "HELP"
          self.proceed_based_on_input
          if @input == "BACK"
            self.browse_all_categories
          end
        end
        self.proceed_based_on_input
        self.choose_category unless @quit == "YES"
      end
    end
  end

  def browse_category
    puts ""
    puts "Category: #{@category_choice.name}".colorize(:light_blue)
    self.display_podcasts
    self.choose_podcast
  end

  def display_podcasts
    @listed_podcasts = @category_choice.list_podcasts(@podcast_counter)
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

  def choose_podcast
    self.get_input
    if @input.class == Fixnum && @input.between?(1, @podcast_counter + @listed_podcasts)
      @podcast_choice = @category_choice.podcasts[@input - 1]
      self.display_podcast_info
    elsif @input.class == Fixnum && !@input.between?(1, @podcast_counter + @listed_podcasts)
      puts "Sorry, that's not an option. Please choose a number that corresponds to a podcast.".colorize(:light_blue)
      self.choose_podcast
    elsif @input == "MENU"
      @category_choice = nil
      self.proceed_based_on_input
    elsif @input == "MORE"
      @podcast_counter += 10
      self.browse_category
    else
      @input = "STUCK" unless @input == "EXIT" || @input == "HELP" || @input == "BACK"
      if @input == "BACK"
        @input = "MENU"
      elsif @input == "HELP"
        self.proceed_based_on_input
        if @input == "BACK"
          self.browse_category
        end
      end
      self.proceed_based_on_input
      self.choose_podcast unless @quit == "YES"
    end
  end

#methods for getting details on a specific podcast
  def display_podcast_info
    puts "Loading details for #{@podcast_choice.name}..."
    PodcastFinder::DataImporter.import_description(@podcast_choice)
    puts ""
    @podcast_choice.list_data
    puts ""
    puts "Choose an option below to proceed:".colorize(:light_blue)
    puts "Type 'more' to get episode list".colorize(:light_blue)
    puts "Type 'back' to return to podcast listing for #{@category_choice.name}".colorize(:light_blue)
    puts "Type 'menu' to return to main category menu".colorize(:light_blue)
    self.choose_podcast_action
  end

  def choose_podcast_action
    self.get_input
    if @input == "MORE"
      self.display_episode_list
    elsif @input == "BACK"
      @podcast_counter = 0
      self.browse_category
    elsif @input == "MENU"
      self.proceed_based_on_input
    else
      @input = "STUCK" unless @input == "EXIT" || @input == "HELP"
      if @input == "HELP"
        self.proceed_based_on_input
        if @input == "BACK"
          self.display_podcast_info
        end
      end
      self.proceed_based_on_input
      self.choose_podcast_action unless @quit == "YES"
    end
  end

  def display_episode_list
    puts "Getting episodes for #{@podcast_choice.name}..."
    PodcastFinder::DataImporter.import_episodes(@podcast_choice)
    if !@podcast_choice.episodes.empty?
      puts ""
      puts "#{@podcast_choice.name} Recent Episode List".colorize(:light_blue)
      @podcast_choice.list_episodes
      puts ""
      puts "These are all the options currently available in Podcast Finder.".colorize(:light_blue)
      puts "To see more, check out #{@podcast_choice.name} online at #{@podcast_choice.url}"
      puts ""
      puts "Options:".colorize(:light_blue)
      puts "Select an episode (1-#{@podcast_choice.episodes.count}) to get a description and download link".colorize(:light_blue)
      puts "Type 'back' to return to podcast listing for #{@category_choice.name}".colorize(:light_blue)
      puts "Type 'menu' to see the category list".colorize(:light_blue)
      self.choose_episode
    else #for edge case where a podcast has no associated episodes but is listed as active by website
      puts ""
      puts "Looks like #{@podcast_choice.name} doesn't have episodes online.".colorize(:light_red)
      puts ""
      puts "Type 'back' to return to podcast listing for #{@category_choice.name}".colorize(:light_blue)
      puts "Type 'menu' to see the category list".colorize(:light_blue)
      self.choose_action_no_episodes
    end
  end

  def choose_action_no_episodes
    self.get_input
    if @input == "BACK"
      @podcast_counter = 0
      self.browse_category
    elsif @input == "MENU"
      self.proceed_based_on_input
    else
      @input = "STUCK" unless @input == "EXIT" || @input == "HELP"
      if @input == "HELP"
        self.proceed_based_on_input
        if @input == "BACK"
          self.display_episode_list
        end
      end
      self.proceed_based_on_input
      self.choose_action_no_episodes unless @quit == "YES"
    end
  end

  def choose_episode
    self.get_input
    if @input.class == Fixnum && @input.between?(1, @podcast_choice.episodes.count)
      @episode_choice = @podcast_choice.episodes[@input-1]
      self.display_episode_info
    elsif @input.class == Fixnum && !@input.between?(1, @podcast_choice.episodes.count)
      puts "Sorry, that's not an episode option. Please enter a number between 1 and #{@podcast_choice.episodes.count} to proceed."
      self.choose_episode
    elsif @input == "BACK"
      @podcast_counter = 0
      self.browse_category
    else
      @input = "STUCK" unless @input == "EXIT" || @input == "HELP"
      if @input == "HELP"
        self.proceed_based_on_input
        if @input == "BACK"
          self.display_episode_list
        end
      end
      self.proceed_based_on_input
      self.choose_episode unless @quit == "YES"
    end
  end

  def display_episode_info
    puts ""
    @episode_choice.list_data
    puts ""
    puts "Options:".colorize(:light_blue)
    puts "Type 'back' to return to episode listing for #{@podcast_choice.name}".colorize(:light_blue)
    puts "Type 'podcasts' to return to the podcast list for #{@category_choice.name}".colorize(:light_blue)
    puts "Type 'menu' to see the category list".colorize(:light_blue)
    self.choose_action_episode_info
  end

  def choose_action_episode_info
    self.get_input
    if @input == "BACK"
      @episode_choice = nil
      self.display_episode_list
    elsif @input == "PODCASTS"
      @podcast_counter = 0
      @podcast_choice = nil
      @episode_choice = nil
      self.browse_category
    else
      @input = "STUCK" unless @input == "EXIT" || @input == "HELP"
      if @input == "HELP"
        self.proceed_based_on_input
        if @input == "BACK"
          self.display_episode_info
        end
      end
      self.proceed_based_on_input
      self.choose_action_episode_info unless @quit == "YES"
    end
  end

end
