source 'https://rubygems.org'

#gem 'data_mapper'
gem 'sequel'
gem 'haml'
gem "bcrypt-ruby", :require => "bcrypt"

gem 'thin'
gem 'sinatra'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'

gem 'pry'
gem 'erubis'
#gem "rspec", ">= 1.2.1"

#Gemas estadistica
#gem 'rest-client'
#gem 'xml-simple'
#gem 'chartkick'

gem 'sinatra-flash'

group :development do
	gem 'sqlite3'
	gem "dm-sqlite-adapter"
end

group :production do
    gem "pg"
    gem "dm-postgres-adapter"
end

group :development, :test do
  gem 'sinatra-contrib'
  gem "rspec", ">= 1.2.1"
  gem "capybara", ">= 1.1.2"
  gem "selenium-webdriver"
  gem "poltergeist"
  gem "rack-test"
  gem "rake"
  gem 'coveralls', require: false
end