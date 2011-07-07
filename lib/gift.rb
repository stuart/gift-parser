require 'treetop'
require File.expand_path('../gift_parser.rb', __FILE__)

module Gift
  
  class Gift
    
    attr_accessor :root
    
    # Create a Gift object form a file IO or string.
    # 
    def initialize(io_or_string)
      parser = GiftParser.new()
      case io_or_string
        when String
          # Add blank line to make sure we can parse.
          @root = parser.parse(io_or_string + "\n\n")
        when IO
          @root = parser.parse(io_or_string.read + "\n\n")
      end
      
      raise ArgumentError, "Cannot parse GIFT input.\nReason:\n#{parser.failure_reason.inspect}" if @root.nil?
    end
    
    # An array of the questions from the Gift file.
    def questions
      @root.questions
    end
    
  end
  
  # A representation of the questions in the gift format.
  # The GIFT format is described in http://docs.moodle.org/en/GIFT
  #
  # This is an abstract class representing question types. 
  # Correctly constructed questions will be one of the sub-types.
  class Question < Treetop::Runtime::SyntaxNode 
    
    attr_accessor :category
    
    def initialize(*args)
      self.category = Command::category
      super(*args)
    end
    
    # The set of possible answers for this question.
    # Returns a array of hashes with contents depending on the subclass.
    def answers
      []
    end
    
    # The question text.
    def text
      question_text.text_value.strip
    end
    
    # The question title, defaults to the question text if no title is given.
    def title
      t = _title.text_value.gsub("::", "")
      t.blank? ? self.text : t
    end
     
    # Any comment text before the question.
    # An example of a comment:
    #   //This is a comment
    #   What is the value of pi (to 3 decimal places)? {3.141..3.142}
    #
    def comment
      _comment.text_value.gsub("//", "").rstrip
    end
    
    # The markup language that the question text is encoded in.
    # This library does not do any of the markup translation,
    # programs can use this info to translate as needed.
    def markup_language
      _markup.text_value.gsub(/[\[\]]/, '')
    end
    
    
    # Returns the percentage value of the answer. 
    # Defaults to 100% if correct or 0% if wrong.
    # Subclasses are expected to implement their own version of this function.
    def mark_answer(response)
      correct_answers.include?(response) ? 100 : 0
    end
    
    def correct_answers
      answers.delete_if{|a| !a[:correct]}.map{|a| a[:value]}
    end
    
  end
  
  # A question with no set answer. Used for requestion an essay.
  # Gift example:
  #     Write 2000 words on parser generators{}
  # 
  # Answer format: none.
  class EssayQuestion < Question
    
  end
  
  # Purely a description or informative phrase.
  # Gift example:
  #      This is a description only
  #
  # Answer format: none
  class DescriptionQuestion < Question
  
  end

  # A question with a true or false boolean answer
  # Gift examples:
  #    Is the sky blue?{T}
  #    Is the sky up?{TRUE}
  #    Is the sea made of stone?{FALSE#It's made of water.}
  #
  # Answer format: 
  #  [{:value => true, :correct => true, :feedback => "Feedback string"}]  
  #
  class TrueFalseQuestion < Question   
    
    def answers
      [answer_list.answer]
    end
    
    def mark_answer(answer)
      (answers[0][:value] == answer) ? 100 : 0
    end
  end
  
  # A question with multiple choices avaialble
  # Each choice may be given a weight and feedback string.
  # Gift examples:
  #   // question: 1 name: Grants tomb
  #   ::Grants tomb::Who is buried in Grant's tomb in New York City? {
  #   =Grant
  #   ~No one
  #   #Was true for 12 years, but Grant's remains were buried in the tomb in 1897
  #   ~Napoleon
  #   #He was buried in France
  #   ~Churchill
  #   #He was buried in England
  #   ~Mother Teresa
  #   #She was buried in India
  #   }
  # 
  # Answer format: 
  #     [{:value => "Grant", :correct=> true, :feedback=> nil}, 
  #      {:value => "No one", :correct => false, :feedback => "Was true for 12 years, but Grant's remains were buried in the tomb in 1897"}]                          
  class MultipleChoiceQuestion < Question
    
    def answers
      answer_list.elements.map{|e| e.answer}
    end
  end
  
  # A question requiring a short written answer.
  # Differentiated from multiple choice by not having and wrong answers 
  # i.e. answers prefixed with '~' 
  # 
  # An extension in this implementation is the ability to have weights to the short answers
  # If all the answers have weights then it's treated as a multiple short answer question.
  # Multiple short answer questions require several of the answers adding up to 100% to be present.
  # For example: Name the three priamry colors{=%33.3%red =%33.3%blue =%33.3%yellow}
  #
  # Gift Example:
  #   Who's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant} 
  # 
  # Answer format: 
  #     [{:feedback => nil, :value => "Grant", :correct => true}, 
  #     {:feedback => nil, :value => "Ulysses S. Grant", :correct => true}, 
  #     {:feedback => nil, :value => "Ulysses Grant" , :correct => true}] 
  #
  class ShortAnswerQuestion < Question 
    
    def answers
      answer_list.elements.map{ |e| e.answer}
    end
  end
  
  # A question requiring a numeric answer
  # Can have a tolerance or range or multiple answers with weights.
  #
  # Gift Examples:
  #   When was Ulysses S. Grant born? {#
  #    =1822:0
  #    =%50%1822:2
  #   }
  #
  #   What is the value of pi (to 3 decimal places)? {#3.141..3.142}
  #
  # Answer format:
  #   [{:minimum => "1822", :maximum => "1822"}]
  # 
  class NumericQuestion < Question
    
    def answers
       answer_list.elements.map{|e| e.answer}
    end
  end
  
  # A questions where items have to be matched up one to one.
  # 
  # Gift Example: 
  #   Match the following countries with their corresponding capitals. {
  #     =Canada -> Ottawa
  #     =Italy  -> Rome
  #     =Japan  -> Tokyo
  #     =India  -> New Delhi
  #     }
  #
  # Answer format: 
  #   {'Canada' => 'Ottowa','Italy' => 'Rome'}
  #              
  class MatchQuestion < Question
     def answers
       answer_list.elements.inject({}){ |ans, e| ans.merge e.answer}
     end
     
     def mark_answer(response)
      response == answers ? 100 : 0
     end
     
  end
  
  # A questions requiring a blank to be filled in.
  # It is like the multiple choice but has text after the answers.
  # 
  # The question text will have %% in it where the answer is to be placed.
  #
  # Gift example: 
  #   The American holiday of Thanksgiving is celebrated on the {
  #    ~second
  #    ~third
  #    =fourth
  #   } Thursday of November.
  #
  # text: 
  #  "The American holiday of Thanksgiving is celebrated on the %% Thursday of November"
  #   
  # Answer format: 
  #   [{:value => 'second', :correct => false}, {:value => 'third', :correct => false}, {:value => 'fourth', :correct => true}]
  #
  class FillInQuestion < Question
    # The question text will have the blank to be filled in represented with %%
    # In application this will probably be replaced with a text field or select control.
    def text
      question_text.text_value + "%%" + _suffix.text_value
    end
    
    def answers
      answer_list.elements.map{|e| e.answer}
    end
    
  end
  
  # Commands are simply parsed and stored for the 
  # application to process as it needs.
  #
  # Currently the only supported command is
  #  $CATEGORY: category
  # This command assigns the question to a category.
  class Command  < Treetop::Runtime::SyntaxNode
    @@category = ""
    
    def self.category
      @@category
    end
    
    def self.category=(new_category)
      @@category = new_category
    end
    
    def initialize(input, interval, elements)      
      if /^\$CATEGORY:.*/.match input[interval]
        @@category = input[interval].gsub(/^\$CATEGORY:/, '').strip
      end
      super(input,interval,elements)
    end
    
    def command_text
      elements[1].text_value
    end
    
  end
end