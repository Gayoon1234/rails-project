class StaticPagesController < ApplicationController
  def home
    @out = `curl https://quizapi.io/api/v1/questions -G -d apiKey=QDPJY0cQLHwllKvmAmygqEm5iOxEjlyLhoeUxViy -d limit=10`
  end
end
