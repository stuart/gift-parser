require 'pp'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

require File.expand_path('../../gift',  __FILE__)

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
  
end 

Test::Unit::UI::Console::TestRunner.run(GiftTest)   