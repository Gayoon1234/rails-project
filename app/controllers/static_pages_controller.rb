require 'date'
require 'json'

class StaticPagesController < ApplicationController
  def home
  end
  
  def quiz
    @questionCount = params["questionCount"].to_i 
    @questionCount = 4 if @questionCount < 4 || @questionCount >8
    allCategories = ["Linux","DevOps","SQL","Bash"]
    
    @difficulty = params["difficulty"]
    
    @arrayOfRandomQuestions = Array.new

  if !params["redo"]
    if allCategories.any? { |i| params.has_key? i }
        chosenCategories = params.keys & allCategories
        
        if chosenCategories.length == 1
          newQuestions(chosenCategories[0],@difficulty) 
        else
          newQuestions(chosenCategories[0],@difficulty) 
          chosenCategories[1..].each{|category| appendQuestions(category,@difficulty)}
        end
    end
    
      shuffledObjects = @@json_hash.shuffle  
      @questionCount.times do
      @arrayOfRandomQuestions.push(shuffledObjects.pop) unless shuffledObjects.empty?
    end
  else
    id_Array = params["redo"].split(".")
    id_Array.each do |id|
      object = objectFromId(id)
      @arrayOfRandomQuestions.push(object) unless object == nil
    end
  end
    
    p @arrayOfRandomQuestions
    
  end
  
  def submit
    
    @questionCount = params["questionCount"].to_i
    @difficulty = params["difficulty"]
    
    @pastResults = Array.new
    if(cookies["past"] != nil)
      splitString = cookies["past"].split("_")
      splitString = splitString.select{|x| x.length > 0}
      
      if(splitString.length > 5)
        splitString = splitString.last(5)
        cookies["past"] = splitString.join("_")
      end
      
      splitString.each do |x|
        x = x.to_s.split(".")
        statement = "At #{x[1]}, #{x[0]}, you answered #{x[2]}/#{x[3]} questions correctly"
        @pastResults.push(statement)
      end
    end
    
    @answers = Hash.new
    ids = Array.new
    params.each do |x,y|
      if y =~ /^answer\_[a-g]$/
        p x, y
        @@json_hash.each{|object| p object["id"]; @answers[object] = y if object["id"].to_s == x.to_s}
        ids.push(x)
      end
    end
    
    @ids = ids.join(".")
    
    
    @numCorrect = 0;
    @answers.each{|object, answer| @numCorrect += 1 if object["correct_answers"]["#{answer}_correct"] == "true"}
    
    
    d = DateTime.now
    timestamp = d.strftime("%d-%m-%Y %H")
    #timestamp = d.strftime("%d-%m-%Y")
    
    timeAndScore = timestamp.split()
    timeAndScore.push(@numCorrect)
    timeAndScore.push(@answers.length)
    
    timeAndScore[1] = timeAndScore[1].sub(/^0+/,"")
    currentHour = timeAndScore[1].to_i
    timeAndScore[1] = (currentHour>12) ? "#{currentHour-12}PM":"#{currentHour}AM" 
    
    timeAndScoreAsString = timeAndScore.join(".")
    cookies["past"] ||= ""
    cookies["past"] += "_" + timeAndScoreAsString
  end
  
  def newQuestions(category,difficulty)
    file =`curl https://quizapi.io/api/v1/questions -G -d apiKey=QDPJY0cQLHwllKvmAmygqEm5iOxEjlyLhoeUxViy -d limit=10 -d category=#{category} -d difficulty=#{difficulty}`
    file ||= File.read("quiz.json") #if JSON.parse(file)["error"]
    @@json_hash = JSON.parse(file)
  end
  
  def appendQuestions(category,difficulty)
    # jsonData = getJSONObject(category,difficulty)
    # parsedData = JSON.parse(jsonData)
    # if parsedData.length >3
    #   parsedData.each{|jsonObject| @@json_hash.push(jsonObject)}
    # end
  end
  
  def getJSONObject(category,difficulty)
      `curl https://quizapi.io/api/v1/questions -G -d apiKey=QDPJY0cQLHwllKvmAmygqEm5iOxEjlyLhoeUxViy -d limit=10 -d category=#{category} -d difficulty=#{difficulty}`
      #data = `curl https://quizapi.io/api/v1/questions -G -d apiKey=QDPPP0cQLHwllKvmAmygqEm5iOxEjlyLhoeUxViy -d limit=10 -d category=#{category} -d difficulty=#{difficulty}`
      #JSON.parse(data)  
  end
  
  def objectFromId(id)
    @@json_hash.each{|object| return object if object["id"].to_i == id.to_i}
    return nil
  end
end
