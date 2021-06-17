require 'json'
class ApplicationController < ActionController::Base
  file = File.read("quiz.json")
  @@json_hash = JSON.parse(file)
end
