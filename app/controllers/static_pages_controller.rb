require 'date'
class StaticPagesController < ApplicationController
 
  
  def home
  end
  
  def quiz
    @questionCount = params["questionCount"].to_i #unless params["questionCount"] == "" 
    @questionCount = 4 if @questionCount < 4 || @questionCount >8
    puts @questionCount,"???"
    allCategories = ["Linux","DevOps","SQL","Bash"]
    
    @arrayOfRandomQuestions = Array.new

    if allCategories.any? { |i| params.has_key? i }
        chosenCategories = params.keys & allCategories
        
        if chosenCategories.length == 1
          newQuestions(chosenCategories[0]) 
        else
          newQuestions(chosenCategories[0]) 
          chosenCategories[1..].each{|category| appendQuestions(category)}
        end
    end
      shuffledObjects = @@json_hash.shuffle
      @questionCount.times do
      @arrayOfRandomQuestions.push(shuffledObjects.pop) unless shuffledObjects.empty?
    end
    
  end
  
  def submit
    
    @questionCount = params["questionCount"].to_i
    
    @pastResults = Array.new
    #_17-06-2021.5AM.1.4_17-06-2021.5AM.1.4_17-06-2021.5AM.2.4
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
    params.each do |x,y|
      if y =~ /^answer\_[a-g]$/
        @@json_hash.each{|object| @answers[object] = y if object["id"]== x.to_i}
      end
    end
    
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
    
   # puts timeAndScore
    
  end
  
  def newQuestions(category,difficulty)
    file = `curl https://quizapi.io/api/v1/questions -G -d apiKey=QDPJY0cQLHwllKvmAmygqEm5iOxEjlyLhoeUxViy -d limit=10 -d category=#{category} -d difficulty=#{difficulty}`
    file ||= File.read("quiz.json")
    @@json_hash = JSON.parse(file)
  end
  
  def appendQuestions(category,difficulty)
    jsonData = `curl https://quizapi.io/api/v1/questions -G -d apiKey=QDPJY0cQLHwllKvmAmygqEm5iOxEjlyLhoeUxViy -d limit=10 -d category=#{category} -d difficulty=#{difficulty}`
    parsedData = JSON.parse(jsonData)
    if parsedData
      parsedData.each{|jsonObject| @@json_hash.push(jsonObject)}
    end
  end
end
