require 'pp'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

require File.expand_path('../../lib/gift',  __FILE__)

class GiftTest < Test::Unit::TestCase          

  def test_create_from_string
    gift = Gift::Gift.new("This is a description")
    assert gift.questions.length == 1
    assert gift.questions.first.class == Gift::DescriptionQuestion
    assert gift.questions.first.text == "This is a description"
  end
  
  def test_create_from_file
    gift = Gift::Gift.new(File.open(File.expand_path("../GIFT-examples.txt", __FILE__))) 
    assert !gift.root.nil?, "Cannot parse the file."    
    assert gift.questions.length == 8, "Expected 8 questions got: #{gift.questions.length}"
  end
  
  def test_raising_error_when_input_is_bad
    assert_raises ArgumentError do
      Gift::Gift.new("This is bad gift{}..")
    end
  end
  
  def test_true_false_question_answers
    g = Gift::Gift.new(File.open(File.expand_path("../GIFT-examples.txt", __FILE__))) 
    assert g.questions[0].mark_answer(true) == 100
    assert g.questions[0].mark_answer(false) == 0
  end
  
  def test_multiple_choice_answers
    g = Gift::Gift.new(File.open(File.expand_path("../GIFT-examples.txt", __FILE__))) 
    assert g.questions[1].mark_answer("yellow") == 100
    assert g.questions[1].mark_answer("red") == 0
    assert g.questions[1].mark_answer("blue") == 0
  end
  
  def test_fill_in_the_blank
    g = Gift::Gift.new(File.open(File.expand_path("../GIFT-examples.txt", __FILE__))) 
    assert g.questions[2].mark_answer("two") == 100
    assert g.questions[2].mark_answer("2") == 100
    assert g.questions[2].mark_answer("red") == 0
  end
  
  def test_matching_question
    g = Gift::Gift.new(File.open(File.expand_path("../GIFT-examples.txt", __FILE__))) 
    assert g.questions[3].mark_answer({"cat" => "cat food", "dog" => "dog food"}) == 100
    assert g.questions[3].mark_answer({"cat" => "dog food", "dog" => "cat food"}) == 0
  end
end 

Test::Unit::UI::Console::TestRunner.run(GiftTest)   