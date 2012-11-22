#!/usr/bin/env ruby
require 'sinatra'
require 'sinatra/reloader'
require 'sprockets-sass'
require 'haml'
require 'uri'

configure do
  Compass.configuration do |config|
    config.sprite_load_path = "assets/images"
    config.images_path = "assets/images"
    config.generated_images_path = "public/sprites"
    config.images_dir = "sprites"
  end
end

get '/' do
  haml :index
end
