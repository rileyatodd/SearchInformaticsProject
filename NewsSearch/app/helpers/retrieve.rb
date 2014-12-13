#!/usr/bin/ruby
# I427 Fall 2014, Assignment 4
#   Code authors: Riley Todd and Chris Griffiths
#   
#   based on skeleton code by D Crandall

require 'fast-stemmer'
# This function writes out a hash or an array (list) to a file.
#  You can modify this function if you want, but it should already work as-is.
# 
# write_data("file1",my_hash)
# 
def write_data(filename, data)
  file = File.open(filename, "w")
  file.puts(data)
  file.close
end

# This function reads in a hash or an array (list) from a file produced by write_file().
#  You can modify this function if you want, but it should already work as-is.
# 
# my_list=read_data("file1")
# my_hash=read_data("file2")
def read_data(file_name)
  file = File.open(file_name,"r")
  object = eval(file.gets)
  file.close()
  return object
end



#
# You'll likely need other functions. Add them here!
#

# function that takes a list of tokens, and a list (or hash) of stop words,
#  and returns a new list with all of the stop words removed
#
def remove_stop_tokens(tokens, stop_words)
    # add code here!

  tokens.each do |word|
    if stop_words.include?(word)
      tokens.delete(word)
    end
  end

    # for now, just returning the list of tokens without actually removing stop words -- change this!
  return tokens
end

# function that takes a list of tokens, runs a stemmer on each token,
#  and then returns a new list with the stems
#
def stem_tokens(tokens)
  stemmed_tokens = []
  for token in tokens
    stemmed_tokens.push(token.stem)
  end
  return stemmed_tokens
end

def import_index(filename)
  index_hash = {}
  file = File.open(filename, "r")
  lines = file.readlines
  for line in lines
    items = line.split(/\s/)
    index_hash[items[0]] = [items[1], items[2]]
  end
  return index_hash
end

# function that takes the name of a file and loads in the stop words from the file.
#  You could return a list from this function, but a hash might be easier and more efficient.
#  (Why? Hint: think about how you'll use the stop words.)
#
def load_stopwords_file(file_name) 
  stop_file = File.open(file_name, "r")
  lines = stop_file.readlines
  stop_words_hash = Hash.new
  for line in lines
    line.chomp!
    stop_words_hash[line] = 1
  end
  return stop_words_hash
end


#Finds list of documents that contain all terms in the query 
#and return them as list of 2 item [doc, TFIDF] pairs
# sorted in decreasing order by TFIDF
def find_hit_list(invindex, query, docindex)
	hit_list = invindex[query[0]]
	for term in query
		frequency_by_doc = invindex[term]
		if frequency_by_doc
			for doc in hit_list.keys
				if !frequency_by_doc[doc]
					hit_list.delete(doc)
				end
			end
		end
	end

	#hit_list currently is a hash that relates documents to some frequency of some term
	#pretty much a trash value at this point. This code replaces these so that it 
	#maps documents to their TFIDF
	for doc in hit_list.keys
		hit_list[doc] = compute_TFIDF(doc, query, invindex, docindex)
	end

	hit_list = hit_list.sort_by {|doc, tfidf| tfidf}.reverse

	return hit_list
end


def compute_TFIDF(doc, query, invindex, docindex)
	# ntf = normalized term frequency in document
	# df = # of documents query is in / Total # of documents
	# idf = 1 / (1 + log(df))

	total_score = 0
	for term in query 
		tf = invindex[term][doc]
		doc_stats = docindex[doc]
		doc_length = doc_stats[0]
		ntf = tf / doc_length
		df = invindex[term].size
		idf = 1 / (1 + Math.log(df))
		score = tf * idf
		total_score += score
	end
	return total_score
end


#################################################
# Main program. We expect the user to run the program like this:
#
#   ./retrieve.rb doc.dat invindex.dat stop.txt kw1 kw2 kw3 .. kwn
#


# # check that the user gave us correct command line parameters
# abort "Command line should have at least 4 parameters." if ARGV.size<4

# (doc_file, invindex_file, stopwords_file) = ARGV[0..2]
# keyword_list = ARGV[3..ARGV.size]
# stop_words_hash = load_stopwords_file(stopwords_file)
# keyword_list = remove_stop_tokens(keyword_list, stop_words_hash)
# keyword_list = stem_tokens(keyword_list)
# # read in the index file produced by the crawler from Assignment 2 (mapping URLs to filenames).
# docindex=read_data(doc_file)

# # read in the inverted index produced by the indexer. 
# invindex=read_data(invindex_file)

# # find the hitlist
# hit_list = find_hit_list(invindex, keyword_list, docindex)

# i = 0
# while i < hit_list.length
# 	(doc, score) = hit_list[i]
# 	(length, title, canonicalURLs, uRL, spam_score) = docindex[doc]
# 	puts "score: " + 
# 	score.to_s + "\nurl: " + 
# 	uRL + "\ntitle: " + 
# 	title + "\nspam score: " + 
# 	spam_score.to_s
# 	print "\n"
# 	i += 1
# end
