# Specifications for the CLI Assessment

Specs:
- [x] Have a CLI for interfacing with the application
Created a user-friendly CLI with a main menu and help menu, that allows the user to go back and forth between levels of data and exit at any time from any point in the program.
- [x] Pull data from an external source
Uses Nokogiri to scrape content from NPR's Podcast Directory
  - Pulls category data from http://www.npr.org/podcasts
  - Pulls podcast data from individual category pages
  - Pulls episode data from individual podcast pages
- [x] Implement both list and detail views
  - Uses OO to associate podcasts with categories and episodes with podcasts, so that the user can view any of the following:
    - list of categories
    - lists of podcasts by category
    - descriptions of podcasts
    - lists of episodes for podcasts
    - descriptions of individual episodes, their runtimes, and links to listen and download when available
