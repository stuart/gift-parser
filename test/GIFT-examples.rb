# Examples of the GIFT fromat from the Moodle Docs.

class GiftExamples


def self.examples

examples = {}

examples[:description] = <<EOS
//  EXAMPLE QUESTIONS for the GIFT import filter
//  by Paul Tsuchido Shew, January 2004.

//-----------------------------------------//
//        EXAMPLES FROM DOCUMENTATION
//-----------------------------------------//

Who's buried in Grant's tomb?{~Grant ~Jefferson =no one}

Grant is {~buried =entombed ~living} in Grant's tomb.

Grant is buried in Grant's tomb.{FALSE}

Who's buried in Grant's tomb?{=no one =nobody}

When was Ulysses S. Grant born?{#1822:1}
EOS

examples[:multi] = <<EOS
//-----------------------------------------//
//       EXAMPLES FROM DOCUMENTATION
//-----------------------------------------//

// ===Multiple Choice===

Who's buried in Grant's tomb?{~Grant ~Jefferson =no one}

Grant is {~buried =entombed ~living} in Grant's tomb.

The American holiday of Thanksgiving is celebrated on the {
    ~second
    ~third
    =fourth
} Thursday of November.

Japanese characters originally came from what country? {
    ~India
    =China
    ~Korea
    ~Egypt}
EOS

examples[:short] = <<EOS 
// ===Short Answer===

Who's buried in Grant's tomb?{=no one =nobody}

Two plus two equals {=four =4}.
EOS

examples[:tf] = <<EOS
// ===True-False===

Grant is buried in Grant's tomb.{F}

The sun rises in the east.{T}
EOS

examples[:numerical] = <<EOS 
// ===Numerical===

Matching Question. {
    =subquestion1 -> subanswer1
    =subquestion2 -> subanswer2
    =subquestion3 -> subanswer3
    }
    
Match the following countries with their corresponding capitals. {
    =Canada -> Ottawa
    =Italy  -> Rome
    =Japan  -> Tokyo
    =India  -> New Delhi
    }

// ===Numerical===

When was Ulysses S. Grant born? {#1822}

What is the value of pi (to 3 decimal places)? {#3.1415:0.0005}

What is the value of pi (to 3 decimal places)? {#3.141..3.142}

When was Ulysses S. Grant born? {#
    =1822:0
    =%50%1822:2}
EOS

examples[:line_comments] = <<EOS
// OPTIONS 

// ===Line Comments===

// Subheading: Numerical questions below
What's 2 plus 2? {#4}

EOS

examples[:question_name] = <<EOS 
// ===Question Name===

::Kanji Origins::Japanese characters originally came from what country? {=China}

::Thanksgiving Date::The American holiday of Thanksgiving is celebrated on the {~second ~third =fourth} Thursday of November.
EOS

examples[:feedback] = <<EOS
// ===Feedback===

What's the answer to this multiple-choice question?{
~wrong answer#feedback comment on the wrong answer
~another wrong answer#feedback comment on this wrong answer
=right answer#Very good!}
    
Who's buried in Grant's tomb?{
=no one#excellent answer!
=nobody#excellent answer!}
EOS

examples[:weights] = <<EOS
// ===Percentage Answer Weights===
Grant is buried in Grant's tomb.{FALSE#No one is buried in Grant's tomb.}

Difficult question.{~wrong answer ~%50%half credit answer =full credit answer}
         
::Jesus' hometown::Jesus Christ was from {
    ~Jerusalem#This was an important city, but the wrong answer.
    ~%25%Bethlehem#He was born here, but not raised here.
    ~%50%Galilee#You need to be more specific.
    =Nazareth#Yes! That's right!}
    
::Jesus' hometown:: Jesus Christ was from {
    =Nazareth#Yes! That's right!
    =%75%Nazereth#Right, but misspelled.
    =%25%Bethlehem#He was born here, but not raised here.}
EOS

examples[:multiple] = <<EOS
// ===Multiple Answers===

What two people are entombed in Grant's tomb? {
	~No one
	~%50%Grant
	~%50%Grant's wife
	~Grant's father }

What two people are entombed in Grant's tomb? {
	~%-50%No one
	~%50%Grant
	~%50%Grant's wife
	~%-50%Grant's father }
EOS

examples[:format] = <<EOS
//-----------------------------------------//
//     EXAMPLES FROM gift/format.php
//-----------------------------------------//

Who's buried in Grant's tomb?{~Grant ~Jefferson =no one}

Grant is {~buried =entombed ~living} in Grant's tomb.

Grant is buried in Grant's tomb.{FALSE}

Who's buried in Grant's tomb?{=no one =nobody}

When was Ulysses S. Grant born?{#1822:5}

Match the following countries with their corresponding
capitals.{=Canada->Ottawa =Italy->Rome =Japan->Tokyo}
EOS

examples[:complicated] = <<EOS
//-----------------------------------------//
//     MORE COMPLICATED EXAMPLES
//-----------------------------------------//

::Grant's Tomb::Grant is {
      ~buried#No one is buried there.
      =entombed#Right answer!
      ~living#We hope not!
} in Grant's tomb.

Difficult multiple choice question.{
     ~wrong answer           #comment on wrong answer
     ~%50%half credit answer #comment on answer
     =full credit answer     #well done!}

::Jesus' hometown (Short answer ex.):: Jesus Christ was from {
     =Nazareth#Yes! That's right!
     =%75%Nazereth#Right, but misspelled.
     =%25%Bethlehem#He was born here, but not raised here.
}

//this comment will be ignored by the filter
::Numerical example::
When was Ulysses S. Grant born? {#
     =1822:0      #Correct! 100% credit
     =%50%1822:2  #He was born in 1822.
                  You get 50% credit for being close.
}
EOS

examples[:all] = <<EOS
//  EXAMPLE QUESTIONS for the GIFT import filter
//  by Paul Tsuchido Shew, January 2004.

//-----------------------------------------//
//        EXAMPLES FROM DESCRIPTION
//-----------------------------------------//

Who's buried in Grant's tomb?{~Grant ~Jefferson =no one}

Grant is {~buried =entombed ~living} in Grant's tomb.

Grant is buried in Grant's tomb.{FALSE}

Who's buried in Grant's tomb?{=no one =nobody}

When was Ulysses S. Grant born?{#1822:1}


//-----------------------------------------//
//       EXAMPLES FROM DOCUMENTATION
//-----------------------------------------//

// ===Multiple Choice===

Who's buried in Grant's tomb?{~Grant ~Jefferson =no one}

Grant is {~buried =entombed ~living} in Grant's tomb.

The American holiday of Thanksgiving is celebrated on the {
    ~second
    ~third
    =fourth
} Thursday of November.

Japanese characters originally came from what country? {
    ~India
    =China
    ~Korea
    ~Egypt}

// ===Short Answer===

Who's buried in Grant's tomb?{=no one =nobody}

Two plus two equals {=four =4}.

// ===True-False===

Grant is buried in Grant's tomb.{F}

The sun rises in the east.{T}

// ===Numerical===

Matching Question. {
    =subquestion1 -> subanswer1
    =subquestion2 -> subanswer2
    =subquestion3 -> subanswer3
    }
    
Match the following countries with their corresponding capitals. {
    =Canada -> Ottawa
    =Italy  -> Rome
    =Japan  -> Tokyo
    =India  -> New Delhi
    }

// ===Numerical===

When was Ulysses S. Grant born? {#1822}

What is the value of pi (to 3 decimal places)? {#3.1415:0.0005}

What is the value of pi (to 3 decimal places)? {#3.141..3.142}

When was Ulysses S. Grant born? {#
    =1822:0
    =%50%1822:2}

// OPTIONS 

// ===Line Comments===

// Subheading: Numerical questions below
What's 2 plus 2? {#4}


// ===Question Name===

::Kanji Origins::Japanese characters originally
came from what country? {=China}

::Thanksgiving Date::The American holiday of Thanksgiving is 
celebrated on the {~second ~third =fourth} Thursday of November.

// ===Feedback===

What's the answer to this multiple-choice question?{
~wrong answer#feedback comment on the wrong answer
~another wrong answer#feedback comment on this wrong answer
=right answer#Very good!}
    
Who's buried in Grant's tomb?{
=no one#excellent answer!
=nobody#excellent answer!}

// ===Percentage Answer Weights===
Grant is buried in Grant's tomb.{FALSE#No one is buried in Grant's tomb.}

Difficult question.{~wrong answer ~%50%half credit answer =full credit answer}
         
::Jesus' hometown::Jesus Christ was from {
    ~Jerusalem#This was an important city, but the wrong answer.
    ~%25%Bethlehem#He was born here, but not raised here.
    ~%50%Galilee#You need to be more specific.
    =Nazareth#Yes! That's right!}.
    
::Jesus' hometown:: Jesus Christ was from {
    =Nazareth#Yes! That's right!
    =%75%Nazereth#Right, but misspelled.
    =%25%Bethlehem#He was born here, but not raised here.}

// ===Multiple Answers===

What two people are entombed in Grant's tomb? {
	~No one
	~%50%Grant
	~%50%Grant's wife
	~Grant's father }

What two people are entombed in Grant's tomb? {
	~%-50%No one
	~%50%Grant
	~%50%Grant's wife
	~%-50%Grant's father }

//-----------------------------------------//
//     EXAMPLES FROM gift/format.php
//-----------------------------------------//

Who's buried in Grant's tomb?{~Grant ~Jefferson =no one}

Grant is {~buried =entombed ~living} in Grant's tomb.

Grant is buried in Grant's tomb.{FALSE}

Who's buried in Grant's tomb?{=no one =nobody}

When was Ulysses S. Grant born?{#1822:5}

Match the following countries with their corresponding
capitals.{=Canada->Ottawa =Italy->Rome =Japan->Tokyo}

//-----------------------------------------//
//     MORE COMPLICATED EXAMPLES
//-----------------------------------------//

::Grant's Tomb::Grant is {
      ~buried#No one is buried there.
      =entombed#Right answer!
      ~living#We hope not!
} in Grant's tomb.

Difficult multiple choice question.{
     ~wrong answer           #comment on wrong answer
     ~%50%half credit answer #comment on answer
     =full credit answer     #well done!}

::Jesus' hometown (Short answer ex.):: Jesus Christ was from {
     =Nazareth#Yes! That's right!
     =%75%Nazereth#Right, but misspelled.
     =%25%Bethlehem#He was born here, but not raised here.
}

//this comment will be ignored by the filter
::Numerical example::
When was Ulysses S. Grant born? {#
     =1822:0      #Correct! 100% credit
     =%50%1822:2  #He was born in 1822.
                  You get 50% credit for being close.
}

EOS
return examples
end

end