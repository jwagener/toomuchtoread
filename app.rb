#!/usr/bin/env ruby
require 'sinatra'
require 'sinatra/reloader'
require 'sprockets-sass'
require 'haml'
require 'uri'
require 'json'

configure do
  Compass.configuration do |config|
    config.sprite_load_path = "assets/images"
    config.images_path = "assets/images"
    config.generated_images_path = "public/sprites"
    config.images_dir = "sprites"
  end
end

get '/' do
  @term = ""
  doit()
end

get '/*' do |term|
  @term = term
  doit()
end

def doit
  @offset = (params["offset"] || 0).to_i
  @books = find_books(@term)[@offset..@offset+9]
  if request.xhr?
    JSON.generate(@books)
  else
    haml :index
  end
end

def find_books(term="")
  if term == ""
    output = IO.popen(["cat", "./sorted-index"], :external_encoding=>"UTF-8")
    results = output.read.split("\n")[0..100]
  else
    output = IO.popen(["grep", "-i", term, "./sorted-index"], :external_encoding=>"UTF-8")
    results = output.read.split("\n")
  end
  results.map! do |line|
    line.split("\t")
  end
end

module Haml
  module Helpers
    def partial(template, *args)
      template_array = template.to_s.split('/')
      template = template_array[0..-2].join('/') + "/_#{template_array[-1]}"
      options = args.last.is_a?(Hash) ? args.pop : {}
      options.merge!(:layout => false)
      if collection = options.delete(:collection) then
        collection.inject([]) do |buffer, member|
          buffer << haml(:"#{template}", options.merge(:layout =>
          false, :locals => {template_array[-1].to_sym => member}))
        end.join("\n")
      else
        haml(:"#{template}", options)
      end
    end
  end
end