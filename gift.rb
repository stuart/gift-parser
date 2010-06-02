require 'treetop'
require File.expand_path('../gift_parser.rb', __FILE__)

module Gift
  
  class Question < Treetop::Runtime::SyntaxNode 

    def answers
      []
    end
     
    def text
      question_text.text_value.strip
    end 
    
  end
  
  class EssayQuestion < Question
    
  end
  
  class DescriptionQuestion < Question
  
  end

  class TrueFalseQuestion < Question   
    
    def answers
      [elements[6].answer]
    end
    
  end
  
  class MultipleChoiceQuestion < Question
    
    def answers
      elements[6].elements.map{|e| e.answer}
    end
  end
  
  class ShortAnswerQuestion < Question 
    
    def answers
      elements[6].elements.map{ |e| e.answer}
    end
  end
  
  class NumericQuestion < Question
    
    def answers
       elements[6].elements.map{|e| e.answer}
    end
  end
  
  class MatchQuestion < Question
     def answers
       elements[6].elements.map{ |e| e.answer}
     end 
     
  end
  
  class FillInQuestion < Question
    def text
      question_text.text_value + "%%" + elements[9].text_value
    end
    
    def answers
      elements[6].elements.map{|e| e.answer}
    end
  end
  
end