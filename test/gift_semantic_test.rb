#!/usr/bin/env ruby
# Tests for GIFT parser

# This only tests that the input is parsed.
# so far does not test output.

require 'pp'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

require File.expand_path('../../gift',  __FILE__)

class GiftSemanticTest < Test::Unit::TestCase
  
  attr_accessor :parser

  def setup
    @parser = GiftParser.new
  end

  def assert_can_parse(string)
    string << "\n\n" # Insert a blank line at end of string
    assert !@parser.parse(string).nil?, "Failed on:\n#{string}\n Reason:\n#{@parser.failure_reason.inspect}\n"
  end
  
  def assert_cannot_parse(string)
    string << "\n\n" # Insert a blank line at end of string
    p = @parser.parse(string)
    assert p.nil?, "Failed on:\n#{string}\n Reason:\nThis should not be correctly parsed, but was.\nParser Output:\n#{p.inspect}"
  end
  
  def test_description_question
    q = @parser.parse("This is a description.\n\n").questions[0]
    assert q.class == Gift::DescriptionQuestion
    assert q.text == "This is a description."
  end

  def test_essay_question
    q = @parser.parse("Write an essay on the toic of your choice{ }\n\n").questions[0]
    assert q.class == Gift::EssayQuestion
    assert q.text == "Write an essay on the toic of your choice"
  end
  
  def test_true_false_question_true
    q = @parser.parse("Is the sky blue?{T}\n\n").questions[0]
    assert q.class == Gift::TrueFalseQuestion
    assert q.text == "Is the sky blue?"
    assert q.answers == [{:value => true, :correct => true, :feedback => nil}]
  end
  
  def test_true_false_question_false
    q = @parser.parse("Is the sky green?{F}\n\n").questions[0]
    assert q.text == "Is the sky green?"
    assert q.answers == [{:value => false, :correct => true, :feedback => nil}]
  end
  
  def test_tf_with_feedback
    q = @parser.parse("Is the sky green?{F#No It's blue.}\n\n").questions[0]
    assert q.text == "Is the sky green?"
    assert q.answers == [{:value => false, :correct => true, :feedback => "No It's blue."}]
  end
  
  def test_multiple_choice_question
    q = @parser.parse("What color is the sky?{=blue ~green ~red}\n\n").questions[0]
    assert q.class == Gift::MultipleChoiceQuestion
    assert q.text == "What color is the sky?"
    assert q.answers ==  [{:value => "blue", :correct => true, :feedback => nil}, 
                         {:value => "green", :correct => false, :feedback => nil},
                         {:value => "red", :correct => false, :feedback => nil}]
    
  end
  
  def test_multiple_choice_question_with_feedback
    q = @parser.parse("What color is the sky?{=blue#Correct ~green#Wrong! ~red}\n\n").questions[0]
    assert q.answers ==  [{:value => "blue", :correct => true, :feedback => "Correct"}, 
                         {:value => "green", :correct => false, :feedback => "Wrong!"},
                         {:value => "red", :correct => false, :feedback => nil}]
    
  end
  
  def test_multiple_choice_question_with_weights
    q = @parser.parse("What color is the sky?{=blue#Correct ~%50%green#Wrong! ~red}\n\n").questions[0]
    assert q.answers ==  [{:value => "blue", :correct => true, :feedback => "Correct"}, 
                         {:value => "green", :correct => false, :feedback => "Wrong!", :weight => 50.0},
                         {:value => "red", :correct => false, :feedback => nil}]
  end
  
  def test_short_answer_question
    q = @parser.parse("Who's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}\n\n").questions[0]
    assert q.class == Gift::ShortAnswerQuestion
    assert q.text == "Who's buried in Grant's tomb?"
    assert q.answers == [{:feedback => nil, :value => "Grant", :correct => true}, 
                         {:feedback => nil, :value => "Ulysses S. Grant", :correct => true}, 
                         {:feedback => nil, :value => "Ulysses Grant" , :correct => true}]
  end
  
  def test_short_answer_question_with_weights
    q = @parser.parse("Name three colors of the rainbow?{=%33.3%red =%33.3%orange =%33.3%yellow =%33.3%green =%33.3%blue =%33.3%indigo =%33.3%violet }\n\n").questions[0]
    q.answers.each do |a|
      assert a[:weight] == 33.3
    end
  end
  
  def test_numeric_question
    q = @parser.parse("What is 3 + 4?{#7}\n\n").questions[0]
    assert q.class == Gift::NumericQuestion
    assert q.answers == [{:maximum => 7.0, :minimum => 7.0}]
  end
  
  def test_numeric_with_tolerance
    q = @parser.parse("What is the value of PI?{#3.1:0.5}\n\n").questions[0]
    assert q.answers == [{:maximum => 3.6, :minimum => 2.6}]
  end
  
  def test_numeric_range
    q = @parser.parse("What is a number from 1 to 5? {#1..5}\n\n").questions[0]
    assert q.answers == [{:maximum => 1.0, :minimum => 5.0}]
  end
  
  def test_numeric_multiple_answers
    q = @parser.parse("What is the value of PI?{#3.1415 =%50%3.1 =%25%3 }\n\n").questions[0]
    assert q.answers == [{:maximum => 3.1415, :minimum => 3.1415}, 
                         {:maximum => 3.1, :minimum => 3.1},
                         {:maximum => 3.0, :minimum => 3.0}]
  end
  
  def test_numeric_neagitve_numbers
    q = @parser.parse("Calculate 2 - 6.{#-4.0}\n\n").questions[0]
    assert q.answers == [{:maximum => -4.0, :minimum => -4.0}]
  end
  
  def test_matching_question
    q = @parser.parse("Match the names. { =Charlie -> Chaplin =Groucho -> Marx =Buster -> Keaton  =Stan -> Laurel }\n\n").questions[0]
    assert q.class == Gift::MatchQuestion 
    assert q.text == "Match the names."
    assert q.answers == {'Charlie' => 'Chaplin', 'Groucho' => 'Marx', 'Buster' => 'Keaton', 'Stan' => 'Laurel'}
  end
  
  def test_fill_in_question
    q = @parser.parse("There were {=three} little pigs.\n\n").questions[0]
    assert q.class == Gift::FillInQuestion
    assert q.text == "There were %% little pigs."
    assert q.answers == [{:value => 'three', :correct => true, :feedback => nil}]
  end
  
  def test_title
    q = @parser.parse("::Essay One:: Write an essay on the toic of your choice{ }\n\n").questions[0]
    assert q.title == "Essay One"
  end 
  
  def test_title_from_question
    q = @parser.parse("Write an essay on the toic of your choice{ }\n\n").questions[0]
    assert q.title == q.text
  end
  
  def test_comment
    q = @parser.parse("//Here's an easy one\nWrite an essay on the toic of your choice{ }\n\n").questions[0]
    assert q.comment == "Here's an easy one"
  end
  
  def test_command
    q = @parser.parse("$COMMAND=1\n\nQuestion{}\n\n")
    assert q.commands == ["COMMAND=1"]
  end
 
  def test_category_setting
    q = @parser.parse("$CATEGORY: food \n\nIs apple a food?{T}\n\n$CATEGORY: drink \n\nIs water drinkable?{T}\n\n" )
    assert q.questions[0].category == "food"
    assert q.questions[1].category == "drink"
  end
  
  def test_markup_type
    q = @parser.parse("[textile] This *essay* is marked up in textile.{}\n\n").questions[0]
    assert q.markup == "textile"
  end
  
end

Test::Unit::UI::Console::TestRunner.run(GiftSemanticTest)
