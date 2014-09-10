#NY WDI August 2014, Project 1#

##Overview##


Everything Books is an application about books and book-related topics that allows a user to be able to visit the homepage, and begin reading topic-related feeds, update their profile, and select or unselect the feeds to view only the feeds they would like to read. The user is also able to save that information in their profile for future visits.

Everything Books was developed by Anastasia Konecky as a first individual project during the August 2014 session of General Assembly's Web Development Immersive course.  It was developed over a four day project sprint, with the purpose of synthesizing everything the course covered over the first 5 weeks of class.  This project is currently a work that is still in development, although a working first version is accessible through Heroku Apps.

####Technologies Used####
Ruby 2.1.2
Sinatra 1.4.5
Redis 3.1.0
Testing Suite: rspec 3.0.0 and capybara 2.4.1


####APIs accessed####
-New York Times
-Twitter
-Weather Underground
-iDream Books


####RSS Feeds Accessed####
-Book Browse News

####OAuth Access####
-GitHub for login (ENV VARIABLES REQUIRED)

####Gems Used####
Twitter Gem
Sinatra Gem
Httparty Gem
Redis Gem

####User Stories Completed####
-As a user, I want to be able to visit the homepage, find prompts to direct me to how to use the app.

-As a user, I want to be able to login via my github login and be redirected to the app homepage.

-As a user, I want to be able to create a profile and select the feeds I am interested in viewing.
-As a user, I want to be able to view the feeds I've selected.

-As a user, I want to be able to update/change which feeds I want to see by updating/editing my profile page.

-As a user, I want to be able to return to my dashboard and be able to see my profile as i left it.


####To run the project on localhost:####
In Terminal, first open two windows in the bash shell.
In one window, enter redis-server in the command line.
In the other window, enter bundle exec rackup or bundle exec shotgun -p 9292 in the command line.
Then, in the web browser, enter localhost:9292 to begin using the app.

####To run the project on Heroku in your web browser:####
<http://limitless-beach-4779.herokuapp.com/>


