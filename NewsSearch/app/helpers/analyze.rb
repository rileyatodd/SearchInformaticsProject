=begin
Part 1:  Syntax (runs without errors) (5):	5
Count words (5):	5
Count sentences (5):	5
Count proper names (5):	4
Count total number of syllables (5):	5
Compute FK scores (5):	5
Correct output on our hard test file (5):	4
Part 1 Total:	33
see code for comments.
=end
# I427 Fall 2014, Assignment 1
#   Code authors: Riley Todd and Chris Griffiths
#   
#   based on skeleton code by D Crandall
#


############
# function that takes a filename as a parameter, and returns an array
#   of all the `words' in the file. (By `word', we mean space-delimited
#   symbols -- there still might be punctuation, numbers, nonsense words,
#   etc.)
# and Chris Griffiths
# This function should mostly work as written but you may encounter bugs.
#  If so, feel free to modify it.
#
def read_file_into_list(filename)
  myfile = File.open(filename, "r")
  lines = myfile.readlines
  word_list = []
  empty_count = 0
  lines.each do |line|
    words = line.split(/[\s,\-\—]+/)
    words.each  { |w|  word_list.push(w) }
  end
  myfile.close()
  return word_list
end


############
# function that takes a list of words and counts the number of
#  words in the document
#
def count_words(word_list) 
    count = 0
    word_list.each do |word|
      if /\w/ =~ word
        count += 1
      end
    end
    return count
end

############
# function that takes a list of words and counts the number of
#  sentences in the document
#
def count_sentences(word_list) 
    count = 0
    word_list.each do |word|
      if /[!.?]\z/ =~ word #If the word ends with ?,!, or .
        count += 1
      end
    end
    return count
end

############
# function that takes a list of words and counts the number of
#  proper names in the document
#
def count_proper_nouns(word_list)
    count = 0
    prev = "." #This is a seed value as it is assumed that the first word of the file starts a sentence
    word_list.each do |word|
      if /[!.?]\z/ !~ prev && /\A[A-Z]/ =~ word #if the previous word didn't end with a sentence ending punctuation mark and the current word starts with a Capital letter
        count += 1
      end
      prev = word
    end
    return count
end

############
# function that takes a list of words and counts the number of
#  syllables in the document
#
def count_total_syllables(word_list)
    count = 0
    word_list.each do |word|
      num_syllables = 0
      syllables = word.scan(/[^aeiou]*([aeiou]+)[^aeiou]*/i)
      if syllables
        num_syllables = syllables.size
      end
      if /y\z/ =~ word
        num_syllables += 1
      end
      if /e\z/ =~ word && num_syllables > 1
        num_syllables -= 1
      end
      count += num_syllables
    end
    return count
end


#
# You'll likely need other functions. Feel free to add them here!
#


#################################################
# Main program. We expect the user to run the program like this:
#
#   ruby part1-skel.rb document.txt
#

# # check that the user gave us 1 command line parameters
# if ARGV.size != 1
#   abort "Command line should have 1 parameter."
# end

# # fetch filename from the command line
# filename = ARGV[0]

# # load in the document
# words = read_file_into_list(filename)

# print "Analyzing " + filename + "...\n"

# # count number of words, using function above.
# word_count = count_words(words)
# print "  Number of words: " + word_count.to_s + "\n"

# sentence_count = count_sentences(words)
# print "  Number of sentences: " + sentence_count.to_s + "\n"

# proper_noun_count = count_proper_nouns(words)
# print "  Number of proper nouns: " + proper_noun_count.to_s + "\n"

# syllable_count = count_total_syllables(words)
# print "  Number of syllables: " + syllable_count.to_s + "\n"

# fk_score = 0.39 * word_count / sentence_count + 11.8 * syllable_count / word_count - 15.59
# print "FK level: " + fk_score.to_s + "\n"
# #
# # add rest of main body of program here!
# #
