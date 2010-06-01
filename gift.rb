require 'treetop'
require File.expand_path('../gift_parser.rb', __FILE__)

module Gift
  
  class Question < Treetop::Runtime::SyntaxNode 

    def answers
      []
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
  
  end
  
  class FillInQuestion < Question
  
  end
  
end