#!/usr/bin/env ruby
# Tests for GIFT parser

# This only tests that the input is parsed.
# so far does not test output.

require 'rubygems'
require 'treetop'
require 'pp'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

system "tt #{File.expand_path('../../gift.treetop',  __FILE__)}"
require File.expand_path('../../gift',  __FILE__)
require File.expand_path('../GIFT-examples.rb', __FILE__)


class GiftSyntaxTest < Test::Unit::TestCase
  
  attr_accessor :parser
  
  def setup
    @parser = GiftParser.new
  end

  def assert_can_parse(string)
    string << "\n\n" # Insert a blank line at end of string
    assert !@parser.parse(string).nil?, "Failed on:\n#{string}\n Reason:\n#{@parser.failure_reason.inspect}\n"
  end
  
  def assert_cannot_parse(string)
    string << "\n\n"
    p = @parser.parse(string)
    assert p.nil?, "Failed on:\n#{string}\n Reason:\nThis should not be correctly parsed, but was.\nParser Output:\n#{p.inspect}"
  end
  
  def test_essay_question
    assert_can_parse("Write an essay about something.{}")
  end

  def test_description_question
   assert_can_parse("This is simply a description")
  end 

  def test_true_false_questions
    assert_can_parse("The sky is blue.{T}")
    assert_can_parse("The sky is blue.{TRUE}")
    assert_can_parse("The sky is green.{F}")
    assert_can_parse("The sky is blue.{FALSE}")
  end 
  
  def test_feedback
    assert_can_parse("Grant is buried in Grant's tomb.{FALSE#No one is buried in Grant's tomb.}")       
  end
  
  def test_multiple_choice_question
    assert_can_parse("What color is the sky?{ = Blue ~Green ~Red }")
  end
  
  def test_multiple_choice_question_with_feedback
    assert_can_parse('What color is the sky?{ = Blue#Right ~Green ~Red#Very wrong}')
  end                                                    
  
  def test_multiple_choice_on_multiple_lines
    test_text= <<EOS
    What color is the sky?{ 
    = Blue#Right 
    ~Green 
    ~Red
    #Very wrong
    }
EOS
    assert_can_parse(test_text)
  end
  
  def test_multiple_choice_with_weights
    assert_can_parse('Which of these are primary colors?{ ~%33%Blue ~%33%Yellow ~Beige ~%33%Red}')
  end
    
  def test_numeric_question
    assert_can_parse("How many pounds in a kilogram?{#2.2:0.1}")
  end
  
  def test_numeric_question_with_multiple_answer
    assert_can_parse("How many pounds in a kilogram?{# =2.2:0.1 =%50%2 }")
  end
  
  def test_numeric_range_question
    assert_can_parse("::Q5:: What is a number from 1 to 5? {#1..5}")
  end
 
  def test_short_answer
    assert_can_parse("Who's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}")
  end
  
  def test_matching_question
    test_text= <<EOS
    Match the following countries with their corresponding capitals. {
       =Canada -> Ottawa
       =Italy  -> Rome
       =Japan  -> Tokyo
       =India  -> New Delhi
       }
EOS
     assert_can_parse(test_text) 
  end
  
  def test_fill_in_question
    assert_can_parse("Little {~blue =red ~green } riding hood.\n") 
    assert_can_parse("Two plus two equals {=four =4}.\n")
  end
  
  def test_question_with_title
    assert_can_parse('::Colors 1:: Which of these are primary colors?{ ~%33%Blue ~%33%Yellow ~Beige ~%33%Red}')
  end
  
  def test_question_with_comment
    assert_can_parse("//This is an easy one\n Which of these are primary colors?{ ~%33%Blue ~%33%Yellow ~Beige ~%33%Red}")
  end
  
  def test_multiline_comments
     assert_can_parse("//This is an easy one\n//With more than one line of comment\nWhich of these are primary colors?{ ~%33%Blue ~%33%Yellow ~Beige ~%33%Red}")
  end
  
  def test_that_questions_must_be_separated 
    test_text = <<EOS
    Who's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}
    Which of these are primary colors?{ ~%33%Blue ~%33%Yellow ~Beige ~%33%Red}
EOS
    assert_cannot_parse(test_text)
    
    test_text = <<EOS
        Who's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}
        
        Which of these are primary colors?{ ~%33%Blue ~%33%Yellow ~Beige ~%33%Red}
EOS
     assert_can_parse(test_text)
  end
  
  def test_escape_left_bracket
    assert_can_parse('Can a \{ be escaped?{=Yes ~No}')
    assert_can_parse('Can a \{ be escaped?{=Yes ~No\{ }')
    
  end
  
  def test_escape_right_bracket
    assert_can_parse('Can a \} be escaped?{=Yes \} can be escaped. ~No}') 
    
  end
  
  def test_escape_tilde
    assert_can_parse('Can a \~ be escaped?{=Yes ~No \~ can\'t}')
  end
  
  def test_escape_hash
    assert_can_parse('Can a \# be escaped?{=Yes \# can ~No}')
  end 
  
  def test_escape_equals
    assert_can_parse('Can a \= be escaped?{=Yes ~No}')
  end
  
  def test_escape_colon
    assert_can_parse('Can a \: be escaped?{=Yes \: can be escaped. ~No}')
  end
  
  def test_escapes_in_title
    assert_can_parse('::\{This is in\: Brackets\}::Who\'s buried in Grant\'s tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}')
  end
  
  def test_escapes_in_comment
    assert_can_parse("//Escapes in comments are redundant \\: since they end in a \n Question?{}")
  end
  
  def test_crlf_support
    assert_can_parse("Can we have DOS style line breaks?{\r\n=yes \r\n~no}\r\n \r\n And is it seen as a line_break?{TRUE}")
  end
  
  def test_comment_line_break
     assert_can_parse("//Comment\nWho's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}")
     assert_can_parse("//Comment\r\nWho's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}")
  end
  
  def test_dealing_with_blank_lines_at_top_of_file
    assert_can_parse("\n    \n//Comment\nWho's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}")
  end
  
  def test_dealing_with_blank_lines_at_end_of_file
    assert_can_parse("//Comment\nWho's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}\n \n    \n ")
  end
  
  def test_title_line_breaks
   test_text= <<EOS
     ::Title::
     Match the following countries with their corresponding capitals. {
     =Canada -> Ottawa
     =Italy  -> Rome
     =Japan  -> Tokyo
     =India  -> New Delhi
     }
     
EOS
     assert_can_parse(test_text) 
  end
  
  
  def test_single_short_answer
   test_text = <<EOS
   // ===Short Answer===
   What is your favorite color?{=blue}
EOS
  assert_can_parse(test_text)
  end
  
  def test_multiple_short_answer
  test_text = <<EOS
       ::Multiple Short Answer::
       What are your four favorite colors?{
         =%25%Blue
         =%25% Red
         =%25% Green
         =%25% pink
         =%25% azure
         =%25% gold
         }
EOS
  assert_can_parse(test_text)
  end
  
  def test_moodle_examples
     GiftExamples.examples.each do |key, value|
       assert_can_parse value
     end                                                
  end

end

Test::Unit::UI::Console::TestRunner.run(GiftSyntaxTest)
    