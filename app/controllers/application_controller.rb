require 'json'
class ApplicationController < ActionController::Base
  file = `curl https://quizapi.io/api/v1/questions -G -d apiKey=QDPJY0cQLHwllKvmAmygqEm5iOxEjlyLhoeUxViy -d limit=10`
  file ||= File.read("quiz.json")
  @@json_hash = JSON.parse(file)
  @questionCount = 4
end
