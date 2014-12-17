=begin
Part 2: Syntax (runs without errors) (5):	0
Remove punctuations (5):	2
Remove any blank strings (5):	0
Convert to lower cases (5):	5
Remove new line characters (5):	0
Auto-completion based on simple method in step 2 (10):	9
Compute the probability in step 3 (10):	9
Compute the probability in step 4 (10):	2
Part 2 Total:	27
Report (10):	9
On-time submission (1 for on-time, 0 for late):	1
see code for comments.
=end
# I427 Fall 2014, Assignment 1
#   Code authors: Riley Todd Chris Griffiths
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
  word_list = myfile.readlines
  myfile.close()
  return word_list
end


###########
# function that takes a list of strings, and returns a new hash where:
#   (1) punctuation has been removed
#   (2) text has been converted to lowercase
#   (3) any blank strings or strings with only whitespace have been removed
#   (4) newline characters are removed from end of each word
#   (5) The value associated with each word in the hash is the number of times that word appears
#
def clean_string_list(list)
  word_hash = Hash.new # items in the hash are key value pairs where the key is the word and the value is the number of times it occurs
  list.each do |word|
    word.gsub!(/[[:punct:]`]/, "") #remove punctuation
    word.gsub!(/\s/, "") #remove newline characters
    word.downcase! #make lowercase
    if word !~ /\A(\s)*\z/ #If the string isn't empty or composed of only whitespace
      if word_hash[word] # If there is already an entry in the word_hash for this word
        word_hash[word] += 1
      else               # Else we need to make a new entry for this word
        word_hash[word] = 1
      end
    end
  end
  return word_hash
end


##########
# function that auto-completes a given stem with five matching words
#  from a given hash of words (using approach of Step 2 of the assignment).
#
def simple_complete(stem, hash)
  completions = []
  hash.keys.each do |key|
    if completions.size < 5 && key =~ /\A#{stem}/
      completions.push(key)
    end
  end
  print "Possible completions according to simple method:\n"
  completions.each { |word|  puts word }
  puts "---"
end

##########
# function that auto-completes a given stem with five matching words
#  from a given hash of words, returning the *most likely* words
#  as defined in Step 3 of the assignment.
#
def mostlikely_complete(stem, hash)
  total_words = 0 #Find the total number of words by adding the values of each key in the hash
  hash.keys.each do |key|
    total_words += hash[key]
  end
  completions = Hash.new #Make a new hash to put potential completions into
  hash.keys.each do |key| #Check the keys of the hash for matches against the stem
    if key =~ /\A#{stem}/
      completions[key] = hash[key]
    end
  end
  puts "Most likely completions according to most likely method:\n"
  most_likely_completions = get_top_5(completions)
  most_likely_completions.each do |item|
    puts item[0] + " - p = " + (item[1].to_f/total_words).to_s + "\n"
  end
  puts "---"
end

##########
# function that auto-completes a given stem with five matching words
#  from a given list of words, using Step 4 of the assignment to balance
#  between typos and most common words.
#
def best_complete(stem, hash)
  p = 0.95 #probability that each letter was correctly inputted
  completions = Hash.new
  hash.keys.each do |key|
    num_sim_letters = sim(key, stem)
    completions[key] = hash[key] * nCr(stem.length, num_sim_letters) * (p ** num_sim_letters) * ((1-p) ** (stem.length - num_sim_letters))
  end
  puts "Most likely completions according to best method:\n"
  most_likely_completions = get_top_5(completions)
  most_likely_completions.each do |item|
    puts item[0] + "\t\t" + item[1].to_s + "\n"
  end
  puts "---"
  return most_likely_completions
end




#
# You'll likely need other functions. Feel free to add them here!
#

def nCr(n,r) #Calculates n choose r (binomial equation)
  return 1 if r == 0
  return 1 if n == r
  return n if r == 1
  return 1 if n == 0 
  nCr(n-1,r) + nCr(n-1,r-1)
end

#
# Takes two strings and returns the number of letters that they have in common
#
def sim(str1, str2)
  longer = [str1, str2].max
  same = str1.each_char.zip(str2.each_char).select {|str1,str2| str1 == str2}.size
  return same
end


#
# Takes a hash and returns an array containing the top 5 (k,v) pairs sorted by v
#
def get_top_5(hash)
  sorted_array = hash.sort_by {|k,v| v}
  top_5 = []
  size = sorted_array.size
  i = 1
  while i < 6 && i < size
    top_5.push(sorted_array[size - i])
    i += 1
  end
  return top_5
end

#
# Takes a list and returns a hash that contains each unique item in the list
# as the keys and the number of times they occur as their values
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
#   ruby complete.rb wordlist.txt
#
#  where wordlist.txt is a list of words.
#

# # check that the user gave us 1 command line parameters
# if ARGV.size != 1
#   abort "Command line should have 1 parameter."
# end

# # fetch filename from the command line
# filename = ARGV[0]

# #
# # this is a very simple main body -- feel free to modify!
# #

# # load in the document
# print "Processing word list, please wait... "
# words = read_file_into_list(filename)

# # clean up wordlist using your cleaning function defined above
# words = clean_string_list(words)
# print "done!\n\n"

# # read a stem from the keyboard
# print "Please enter a stem: "
# stem = $stdin.gets().chomp

# # Figure out suggestions and print them out
# simple_complete(stem, words)
# mostlikely_complete(stem, words)
# best_complete(stem, words)

