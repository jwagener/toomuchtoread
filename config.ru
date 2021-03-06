require 'bundler'
Bundler.setup :default
require 'sinatra/base'
require 'sprockets'
require 'sprockets-sass'
require 'compass'
require './app'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'assets/javascripts'
  environment.append_path 'assets/stylesheets'
  environment.append_path 'assets/images'
  run environment
end

map '/' do
  run Sinatra::Application
end