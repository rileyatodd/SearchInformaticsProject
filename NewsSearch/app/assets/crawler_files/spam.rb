# I427 Fall 2014, Assignment 1
#   Code authors: [please fill in your name(s) here!]
#   
#   based on skeleton code by D Crandall
#

############
# function that takes a filename as a parameter, and returns an array
#   of all the `words' in the file. (By `word', we mean space-delimited
#   symbols -- there still might be punctuation, numbers, nonsense words,
#   etc.)
#
# This function should work as written but feel free to modify it.
#


def read_file_into_list(filename)
  myfile = File.open(filename, "r")
  lines = myfile.readlines
  word_list = []
  lines.each do |line|
    line.encode!('UTF-16be', :invalid=>:replace, :undef=>:replace, :replace=>'').encode!('UTF-8')
    words = line.split(/[ ,\-]/)
    words.each  { |w|  word_list.push(w) }
  end
  myfile.close()
  return word_list
end

###########
# function that takes a list of strings, and returns a new list where:
#   (1) punctuation has been removed
#   (2) text has been converted to lowercase
#   (3) any blank strings or strings with only whitespace have been removed
#   (4) newline characters are removed from end of each word
#
# This function should more or less work as written, but feel free to modify
#  it if you want.
#
def clean_string_list(word_list)
  new_list = []
  word_list.each do |word|
    new_word = word.delete("<>()[]{}\\-*&^%$#@!~`':\\\\|;\"?/., \t").downcase.chomp
    new_list.push(new_word) if ! (new_word =~ /^$/)
  end
  return new_list
end

#
# You'll likely need other functions. Feel free to add them here!
#
def count_occurrences(list)
  hash = Hash.new
  list.each do |item|
    if hash[item]
      hash[item] += 1
    else
      hash[item] = 1
    end
  end
  return hash
end

#################################################
# Main program. We expect the user to run the program like this:
#
#   ruby spam.rb test_document.txt
#

# check that the user gave us 1 command line parameter
if ARGV.size != 1
  abort "Command line should have 1 parameter."
end

# fetch command line parameters and load document
document = ARGV[0]
docWordList = read_file_into_list(document)

# load training files
spam = "documents/known_spam.txt"
notSpam = "documents/known_notspam.txt"
spamWords = count_occurrences(clean_string_list(read_file_into_list(spam)))
nonspamWords = count_occurrences(clean_string_list(read_file_into_list(notSpam)))

#
# add main body of program here!
#

score = 0.0
docWordList.each do |word|
  spamScore = spamWords[word]
  nonspamScore = nonspamWords[word]
  if (spamScore && nonspamScore)
    score += Math.log(spamScore) - Math.log(nonspamScore)
  end
end
puts(ARGV[0])
puts(score)
if (score > 0)
  puts("Probably SPAM")
else
  puts("Probably NOT spam")
end


