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
      t = elements[1].text_value.gsub("::", "")
      t.blank? ? self.text : t
    end
     
    # Any comment text before the question.
    def comment
      elements[0].text_value.gsub("//", "").rstrip
    end
    
    def markup
      question_text.markup.text_value.gsub(/[\[\]]/, '')
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
  #     <tt>Write 2000 words on parser generators{}</tt>
  # 
  # Answer format: none.
  class EssayQuestion < Question
    
  end
  
  # Purely a description or informative phrase.
  # Gift example:
  #      <tt>This is a description only</tt>
  #
  # Answer format: none
  class DescriptionQuestion < Question
  
  end

  # A question with a true or false boolean answer
  # Gift examples:
  #    <tt>Is the sky blue?{T}</tt>
  #    <tt>Is the sky up?{TRUE}</tt>
  #    <tt>Is the sea made of stone?{FALSE#It's made of water.}</tt>
  #
  # Answer format: 
  #  <tt>[{:value => true, :correct => true, :feedback => "Feedback string"}]  </tt>
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
  #   <tt>// question: 1 name: Grants tomb
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
  #   }</tt>
  # 
  # Answer format: 
  # <tt>[{:value => "Grant", :correct=> true, :feedback=> nil}, 
  #      {:value => "No one", :correct => false, :feedback => "Was true for 12 years, but Grant's remains were buried in the tomb in 1897"}] </tt>                         
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
  # For example: <tt>Name the three priamry colors{=%33.3%red =%33.3%blue =%33.3%yellow}</tt>
  #
  # Gift Example:
  # <tt>Who's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant} </tt>
  # 
  # Answer format: 
  # <tt>[{:feedback => nil, :value => "Grant", :correct => true}, 
  #     {:feedback => nil, :value => "Ulysses S. Grant", :correct => true}, 
  #     {:feedback => nil, :value => "Ulysses Grant" , :correct => true}] </tt>
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
  # <tt>When was Ulysses S. Grant born? {#
  #    =1822:0
  #    =%50%1822:2
  # }</tt>
  #
  # What is the value of pi (to 3 decimal places)? {#3.141..3.142}
  #
  # Answer format:
  # [{:minimum => "1822", :maximum => "1822"}]
  # 
  class NumericQuestion < Question
    
    def answers
       answer_list.elements.map{|e| e.answer}
    end
  end
  
  # A questions where items have to be matched up one to one.
  # 
  # Gift Example: 
  #  <tt>Match the following countries with their corresponding capitals. {
  #     =Canada -> Ottawa
  #     =Italy  -> Rome
  #     =Japan  -> Tokyo
  #     =India  -> New Delhi
  #     }  </tt>
  #
  # Answer format: 
  # {'Canada' => 'Ottowa','Italy' => 'Rome'}</tt>
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
  # <tt>The American holiday of Thanksgiving is celebrated on the {
  #    ~second
  #    ~third
  #    =fourth
  # } Thursday of November.</tt>
  #
  # text: <tt>"The American holiday of Thanksgiving is celebrated on the %% Thursday of November"</tt>
  #   
  # Answer format: 
  # <tt>[{:value => 'second', :correct => false}, {:value => 'third', :correct => false}, {:value => 'fourth', :correct => true}]
  #
  class FillInQuestion < Question
    def text
      question_text.text_value + "%%" + elements[9].text_value
    end
    
    def answers
      answer_list.elements.map{|e| e.answer}
    end
  end
  
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