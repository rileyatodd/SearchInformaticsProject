# I427 Fall 2014, Assignment 3
#   Code authors: Riley Todd & Chris Griffiths
#   
#   based on skeleton code by D Crandall

require 'nokogiri'
require 'uri'
require 'fast-stemmer'

# This function writes out a hash or an array (list) to a file.
#
def write_data(filename, data)
  file = File.open(filename, "w")
  file.puts(data)
  file.close
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


# function that takes the name of a directory, and returns a list of all the filenames in that
# directory.
#
def list_files(dir)
  return Dir[dir + "*"]
end


# function that takes a string filled with HTML code, and returns a list of that page's hyperlinks
#  (outgoing URLs). The URLs should be canonical and absolute.
#
def find_links(html_code, base_url)
  rough_links = []
  html_code.scan(/<a.+?>/) {
    |anchor_tag|
    #remove everything before the link
    anchor_tag.gsub!(/.+href.*?=.*?"/, "")
    #remove everything after the link
    anchor_tag.gsub!(/".*/, "")
    #add to list of rough (not necessarily absolute and canonical) links
    rough_links.push(anchor_tag)
  }
  canonical_links = []
  #make the rough links canonical and absolute
  for link in rough_links
    full_link = ""
    if /\Ahttps?/.match(link)
      full_link = link
    else
      begin
        full_link = URI.join(base_url, link).to_s
      rescue URI::InvalidURIError
        next
      end
    end
    begin
      uri = URI.parse(full_link)
      canonical = URI.join(base_url, uri.path.to_s).to_s
    rescue URI::BadURIError
      next
    end
    canonical.gsub!(/\/\z/, "")
    canonical_links.push(canonical)
  end
  return canonical_links
end


# function that takes the *name of an html file stored on disk*, and returns a list
#  of tokens (words) in that file. 
#
def find_tokens(filename)
  returnList = []

  fileToParse = File.read(filename)
  #remove text of script tags
  fileToParse.gsub!(/<script.*?<\/script>/mi, " ")
  #remove text of style tags
  fileToParse.gsub!(/<style.*?<\/style>/mi, " ")
  #remove html comments
  fileToParse.gsub!(/<!--.*?-->/m, " ")
  #remove html tags
  fileToParse.gsub!(/<.*?>/m, " ")
  #split into tokens
  tokens = fileToParse.scan(/\w+/)

  return tokens
end

def get_title(filename)
  fileToParse = File.read(filename)
  title_tag = fileToParse.scan(/<title.*<\/title>/)
  title = title_tag[0].gsub!(/<\/?title.*?>/mi, "")
  if title != ""
    return title
  else
    return nil
  end
end

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



#
# You'll likely need other functions. Add them here!
#

#################################################
# Main program. We expect the user to run the program like this:
#
#   ruby index.rb pages_dir/ index.dat stop.txt 
#

class DocumentStats

  def to_s

    return "Document Length: #{length}\n" +
            "Document Title: #{title}\n" +
            "Document Canonical URLs: #{canonicalURLS}\n" +
            "Document URL: #{uRL}\n" +
            "Document Spam Score: #{spamScore}"
  end

  attr_accessor :spamScore, :title, :length, :uRL, :canonicalURLS

  @length = 0
  @title = ""
  @canonicalURLS = []
  @uRL = ""
  @spamScore = 0

end


# check that the user gave us 3 command line parameters
# if ARGV.size != 3
#   abort "Command line should have 3 parameters."
# end

# # fetch command line parameters
# (pages_dir, index_file, stop_file) = ARGV

# # read in list of stopwords from file
# stopwords = load_stopwords_file(stop_file)

# # get the list of files in the specified directory
# file_list = list_files(pages_dir)

# # create hash data structures to store inverted index and document index
# #  the inverted index, and the outgoing links

# index = import_index(index_file)
# invindex = {}
# docindex = {}

# # scan through the documents one-by-one
# for file in file_list
#   #the file name without pages/ on the front
#   filename = file.gsub(/\A.*\//, "")

#   print "Parsing HTML document: #{file} \n";

#   stats = DocumentStats.new

#   tokens = find_tokens(file)
#   tokens = remove_stop_tokens(tokens, stopwords)
#   tokens = stem_tokens(tokens)

#   stats.length = tokens.size
#   stats.title = get_title(file)
  
#   stats.uRL = index[filename][1]
#   stats.canonicalURLS = find_links(File.read(file), stats.uRL)
#   stats.spamScore = index[filename][0]

#   stats_list = [stats.length, stats.title, stats.canonicalURLS, stats.uRL, stats.spamScore]

#   docindex[file] = stats_list

#   for token in tokens
#     if invindex[token]
#       frequency_hash = invindex[token]
#       if frequency_hash[file]
#         frequency_hash[file] = frequency_hash[file] + 1
#       else
#         frequency_hash[file] = 1
#       end
#     else
#       invindex[token] = {file => 1}
#     end
#   end
# end

# # save the hashes to the correct files
# write_data("invindex.dat", invindex)
# write_data("doc.dat", docindex)

# # done!
# print "Indexing complete!\n";
 
