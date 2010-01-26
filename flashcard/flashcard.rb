
$right = 0
$wrong = 0


class Flashcard

  def self.[](q,a)
    Flashcard.new(q,a)
  end
    
  attr :question
  attr :answer
    
  def initialize( question, answer )
    @question = question.strip
    @answer = answer.strip
  end

  def ask
    puts `figlet -f small #{@question}`
    str = ''
    until ans = gets ; end
    ans.strip!
    check( ans )
  end

  def check( ans )
    if ans.downcase == @answer.downcase
      puts "Right smarty pants! The answer is #{@answer}."
      $right += 1
    else
      puts "Wrong dumb-dumb head! The answer is #{@answer}."
      $wrong += 1
    end
    ans
  end

end

flashset = {}
flashcards = flashset['Crazy Questions'] = []

flashcards << Flashcard["How old is Jena?", "11"]
flashcards << Flashcard["Is Uncky a Monkey?", "Yes"] 
flashcards << Flashcard["Unlce Toms first middle name?", "Robert"] 
flashcards << Flashcard["Captial of United States?", "Washington"] 
flashcards << Flashcard["Do farts stink?", "Miltons do!"]
flashcards << Flashcard["How old is Jesus?", "2005"]
flashcards << Flashcard["First color of rainbow?", "Red"]
flashcards << Flashcard["Last color of rainbow?", "Violet"]
flashcards << Flashcard["Zebra is a horse?", "No"]
flashcards << Flashcard["Jena wants a ___?", "Dog"]
flashcards << Flashcard["Humes first name?", "David"]
flashcards << Flashcard["Do you eat green eggs and ham?", "No"]
flashcards << Flashcard["Is the storm over?", "Yes"]
flashcards << Flashcard["Are you smart?", "Yes"]
flashcards << Flashcard["Can you know base-six?", "Yes"]

# Base 6 questions

fashcards = flashset['Base6 Multiplication'] = []

base6_multiplication_table = [
  [ 0, 0,  0,  0,  0,  0 ],
  [ 0, 1,  2,  3,  4,  5 ],
  [ 0, 2,  4, 10, 12, 14 ],
  [ 0, 3, 10, 13, 20, 23 ],  
  [ 0, 4, 12, 20, 24, 32 ], 
  [ 0, 5, 14, 23, 32, 41 ]
]

base6_multiplication_table.each_with_index { |row, a|
  row.each_with_index{ |ans, b|
    flashcards << Flashcard["#{a} x #{b} = ?", ans.to_s]
  }
}


r = nil
while r != "q"
  i = rand(flashcards.size).to_i
  r = flashcards[i].ask
end

puts "You got #{$right} right and #{$wrong} wrong out of #{$right+$wrong}"
puts "Thanks for playing!"

