# I427 Fall 2014, Assignment 3
#   Code authors: Riley Todd & Chris Griffiths
#   
#   based on skeleton code by D Crandall

require 'nokogiri'
require 'uri'
require 'fast-stemmer'
require_relative 'retriever'

# Used to clean up the index_documents function
class DocumentStats
  attr_accessor :spamScore, :title, :length, :uRL, :canonicalURLS, :pageRank

  # Converts object into a hash used for saving as json
  def to_h
    hash = {"length"=>@length, "title"=>@title, "canonicalURLS"=>@canonicalURLS, "uRL"=>@uRL, "spamScore"=>@spamScore, "pageRank"=>@pageRank}
    return hash
  end

  def self.from_h(hash)
    doc_stats = DocumentStats.new
    doc_stats.length = hash["length"]
    doc_stats.title = hash["title"]
    doc_stats.canonicalURLS = hash["canonicalURLS"]
    doc_stats.uRL = hash["uRL"]
    doc_stats.spamScore = hash["spamScore"]
    doc_stats.pageRank = hash["pageRank"]
    return doc_stats
  end

  def to_s
    puts "CUSTOM TO_S CALLED"
    hash = to_h
    return hash.to_s
  end

  @length = 0
  @title = ""
  @canonicalURLS = []
  @uRL = ""
  @spamScore = 0
  @pageRank = nil

end

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

def write_docindex(path, docindex)
  for key in docindex.keys
    doc_stats = docindex[key]
    doc_stats_hash = doc_stats.to_h
    docindex[key] = doc_stats_hash
  end
  write_data(path, docindex)
end

def load_docindex(path)
  #each entry in docindex is still a hash and that needs to be parsed into a 
  #DocumentStats object
  docindex = read_data(path)
  for key in docindex.keys
    doc_stats_hash = docindex[key]
    doc_stats = DocumentStats.from_h(doc_stats_hash)
    docindex[key] = doc_stats
  end
  return docindex
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
def find_links_from_html(html_code, base_url)
  rough_links = []
  html_code.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
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
      rescue URI::InvalidURIError, URI::InvalidComponentError
        next
      end
    end
    begin
      uri = URI.parse(full_link)
      canonical = URI.join(base_url, uri.path.to_s).to_s
    rescue URI::BadURIError, URI::InvalidURIError
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
  # In ruby 2.0 encode is a no-op if it's already using that encoding
  # We encode into something else and back to UTF-8 in order to both force
  # encoding and remove invalid bytes
  fileToParse = File.read(filename)
  fileToParse.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
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
  fileToParse.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  title_tag = fileToParse.scan(/<title.*<\/title>/)
  if title_tag[0]
    title = title_tag[0].gsub!(/<\/?title.*?>/mi, "")
  end
  if !(title or (title == ""))
    return title
  else
    return nil
  end
end

# function that takes a list of tokens, and a list (or hash) of stop words,
#  and returns a new list with all of the stop words removed
#
def remove_stop_tokens(tokens, stop_words)
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


#Create the inverse index and document index
def index_documents(pages_dir, index_file, stop_file, invindex_path, docindex_path)
  docindex = {}
  invindex = {}

  # read in list of stopwords from file
  stopwords = load_stopwords_file(stop_file)

  # get the list of files in the specified directory
  file_list = list_files(pages_dir)

  # create hash data structures to store inverted index and document index
  #  the inverted index, and the outgoing links
  index = import_index(index_file)

  # scan through the documents one-by-one
  for file in file_list
    #the file name without pages/ on the front
    filename = file.gsub(/\A.*\//, "")

    print "Parsing HTML document: #{file} \n";

    stats = DocumentStats.new

    tokens = find_tokens(file)
    tokens = remove_stop_tokens(tokens, stopwords)
    tokens = stem_tokens(tokens)

    stats.length = tokens.size
    stats.title = get_title(file)
    
    puts filename
    index_array = index[filename]
    stats.uRL = index_array[1]
    stats.canonicalURLS = find_links_from_html(File.read(file), stats.uRL)
    stats.spamScore = index[filename][0]

    #stats_list = [stats.length, stats.title, stats.canonicalURLS, stats.uRL, stats.spamScore]

    # docindex[file] = stats_list
    docindex[file] = stats

    for token in tokens
      if invindex[token]
        frequency_hash = invindex[token]
        if frequency_hash[file]
          frequency_hash[file] = frequency_hash[file] + 1
        else
          frequency_hash[file] = 1
        end
      else
        invindex[token] = {file => 1}
      end
    end
  end

  # save the hashes to the correct files
  write_data(invindex_path, invindex)
  write_docindex(docindex_path, docindex)
end


# Takes a docindex {path => DocumentStats} and a paths hash {url => path}
# Completes one iteration of the pagerank algorithm, updating the pagerank field of
# each DocumentStats object
def calc_page_ranks(docindex, paths)
  new_ranks = {}
  # For each page in the docindex, distribute it's available pagerank to outbound
  # links that have been indexed
  for path in docindex.keys
    doc_stats = docindex[path]
    #Loop through outbound links determining the list of links that are indexed
    indexed_urls = []
    for url in doc_stats.canonicalURLS
      if paths[url]
        indexed_urls.push(url)
      end
    end
    # If the page has no outbound links, distribute it's pagerank evenly among
    # all documents
    if indexed_urls.size == 0
      contribution = doc_stats.pageRank / docindex.keys.size
      for url in paths.keys
        if new_ranks[url]
          new_ranks[url] += contribution
        else
          new_ranks[url] = contribution
        end
      end
    # Else loop through indexed_urls contributing to the rank of each one 
    else
      contribution = doc_stats.pageRank / indexed_urls.size
      for url in indexed_urls
        if new_ranks[url]
          new_ranks[url] += contribution
        else
          new_ranks[url] = contribution
        end
      end
    end
  end

  # Loop through the new_ranks applying the damping factor of .85 to pageranks
  for path in docindex.keys
    doc_stats = docindex[path]
    url = doc_stats.uRL
    if new_ranks[url]
      new_ranks[url] = (0.15 / docindex.keys.size) + 0.85 * new_ranks[url]
    else
      new_ranks[url] = (0.15/ docindex.keys.size)
    end
  end

  # loop through the docindex applying the new rankings
  for path in docindex.keys
    doc_stats = docindex[path]
    if new_ranks[doc_stats.uRL]
      doc_stats.pageRank = new_ranks[doc_stats.uRL]
    end
  end
  return new_ranks
end

#check page_rank correctness by summing page ranks (should = 1)
def check_ranks(docindex)
  sum = 0
  for key in docindex.keys
    sum += docindex[key].pageRank
  end
  puts sum
end

# Initializes the page_ranks hash and executes the page rank algorithm the 
# indicated number of iterations and return the page_ranks hash
def rank_pages(docindex_path, num_iterations)
  docindex = load_docindex(docindex_path)
  # create paths hash {url => path}
  paths = {}
  for path in docindex.keys
    doc_stats = docindex[path]
    paths[doc_stats.uRL] = path
  end
  #Initialize the page_ranks of every page to have an equal rank
  for path in docindex.keys
    doc_stats = docindex[path]
    doc_stats.pageRank = 1.0 / docindex.keys.size
  end
  # Apply the page rank algorithm the specified number of times
  while num_iterations > 0
    calc_page_ranks(docindex, paths)
    num_iterations -= 1
  end
  write_docindex(docindex_path, docindex)

end 
