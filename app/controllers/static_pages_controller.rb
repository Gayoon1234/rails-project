require 'json'
class StaticPagesController < ApplicationController
  file = File.read("quiz.json")
  @@json_hash = JSON.parse(file)
  
  def home
    #@out = `curl https://quizapi.io/api/v1/questions -G -d apiKey=QDPJY0cQLHwllKvmAmygqEm5iOxEjlyLhoeUxViy -d limit=10`
   
    
  end
  
  def quiz
    @arrayOfRandomQuestions = Array.new
    while @arrayOfRandomQuestions.length < 4
      randomObject = @@json_hash[rand(@@json_hash.length)]
      @arrayOfRandomQuestions.push(randomObject) unless @arrayOfRandomQuestions.include?(randomObject)
    end
  end
  
  def submit
    @answers = Hash.new
    params.each do |x,y|
      if y =~ /^answer\_[a-g]$/
        @@json_hash.each{|object|
          @answers[object] = y if object["id"]== x.to_i
        }
      end
    end
    
    @numCorrect = 0;
    @answers.each{|object, answer| @numCorrect += 1 if object["correct_answers"]["#{answer}_correct"] == "true"}
  end
end
