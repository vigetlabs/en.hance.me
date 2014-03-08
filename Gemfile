source 'https://rubygems.org'

ruby '2.1.0'

gem 'rails', '4.0.3'
gem 'pg',    '~> 0.17.0'

gem 'sass-rails', '~> 4.0.0'
gem 'uglifier',   '>= 1.3.0'

gem 'jquery-rails'

gem 'carrierwave'
gem 'mini_magick'
gem 'nokogiri'

group :test, :development do
  gem "rspec-rails"
  gem "factory_girl_rails"
end

group :development do
  gem "viget-deployment",
    :github => 'vigetlabs/viget-deployment',
    :require => false

  gem "rails-dev-tweaks"
  gem "quiet_assets"
end

group :test do
  gem "capybara"
  gem "shoulda-matchers"
  gem "launchy", require: false
end