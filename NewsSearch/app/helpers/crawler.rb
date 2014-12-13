# I427 Fall 2014, Assignment 2 Part 2
#   Code authors: [please fill in your name(s) here!]
#   
#   based on skeleton code by D Crandall
#
require 'mechanize.rb'
require 'uri'
require 'timeout'

$index = {}
$agent= Mechanize.new
$agent.keep_alive = false
$agent.open_timeout = 5
$agent.read_timeout = 5
$agent.user_agent = 'IUB-I427-rilatodd'
$agent.robots = 'enabled'

# function that takes a URL as a parameter, retrieves that URL from the network, 
# and returns a mechanize page object or nil if the URL inaccessable
#
def retrieve_page(url)
  begin 
    page = Timeout::timeout(5) {$agent.get(url)}
    if page.is_a?(Mechanize::Page)
      return page
    else
      return nil
    end
  rescue
    return nil
  end
end


# function that takes a mechanize page object as a parameter, and then 
# returns a list of that page's hyperlinks as strings
#
def find_links(page)
  links = []
  for link in page.links
    canonical = ""
    if /\Ahttps?/.match(link.href.to_s)
      canonical = canonical + link.href.to_s
    else
      base = page.uri.scheme + "://" + page.uri.host
      base.chomp!
      begin
        if !link.uri
          next
        end
        canonical = URI.join(base, link.uri.path.to_s).to_s
      rescue URI::InvalidURIError
        next
      end
    end
    canonical.gsub!(/\/\z/, "")
    links.push(canonical)
  end
  return links
end


#Returns an array where the first item is the Mechanize page object for 
#the provided link and the second item is the spam score for that page
def process_link(link, dir, spamCalc, index)
  page = retrieve_page(link)
  if page
    fileName = index.to_s + '.html'
    page.save(dir + fileName)
    scoreAndFilename = []
    score = spamCalc.evaluate_document(page.body)
    scoreAndFilename.push(score)
    scoreAndFilename.push(fileName)
    $index[link] = scoreAndFilename
    return [page, score]
  else
    return nil
  end
end

# This is where you'll add code to compute the spam score, by
# recycling relevant parts of Part 1. I suggest using a class
# to do this because it will help group all of your spam code
# together. 
#
class SpamCalculator
  
  @s = {}
  @n = {}

  def initialize
    # Here is where you can put initialization code that you only need
    #  to run once. For instance, you'll probably want to load in the
    #  training files (known spam and non-spam documents) here!

    spam = "../part1/documents/known_spam.txt"
    notSpam = "../part1/documents/known_notspam.txt"
    @s = count_occurrences(clean_string_list(read_file_into_list(spam)))
    @n = count_occurrences(clean_string_list(read_file_into_list(notSpam)))

  end

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

  def clean_string_list(word_list)
    new_list = []
    word_list.each do |word|
      new_word = word.delete("<>()[]{}\\-*&^%$#@!~`':\\\\|;\"?/., \t").downcase.chomp
      new_list.push(new_word) if ! (new_word =~ /^$/)
    end
    return new_list
  end

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

  def evaluate_document(html_code)
    # Here is where you would actually compute the spamminess of a 
    # particular document
    if !html_code
      puts "nil page body"
    end
    strippedCode = html_code.gsub(/<.+?>/, "")
    if !strippedCode
      #puts strippedCode
    end
    d = strippedCode.split(/[ ,\-]/)

    score = 0.0
    d.each do |word|
      if (@s[word] && @n[word])
        score += Math.log(@s[word]) - Math.log(@n[word])
      end
    end
    return score
  end

end

#################################################
# Main program. We expect the user to run the program like this:
#
#   ruby crawl.rb seed_url max_pages output_directory algorithm
#

def traverse_links(seed_url, max_pages, output_dir, algo)
  spamCalc = SpamCalculator.new
  #contains [link, spamScore] arrays for the sake of bestfirst
  links_to_visit = []
  links_to_visit.push([seed_url, 0])
  pages_visited = 0
  time_of_last_get = Time.now.to_f
  while (links_to_visit.length != 0 && pages_visited < max_pages)
    time_difference = Time.now.to_f - time_of_last_get
    if time_difference < 1
      sleep(1-time_difference)
    end
    time_of_last_get = Time.now.to_i
    link = links_to_visit.pop[0]
    puts "link: " + link
    process_results = process_link(link, output_dir, spamCalc, pages_visited)
    if !process_results
      puts "error retrieving page at " + link
      next
    end
    currentPage = process_results[0]
    currentScore = process_results[1]
    pages_visited += 1
    puts "size: " + $index.size.to_s
    links = find_links(process_results[0])
    for link in links
      if !link.is_a?("".class)
        abort "Non-string in link queue"
      end
      if $index.has_key?(link) || links_to_visit.include?(link)
        next
      end
      if (algo == 'dfs' || algo == 'bestfirst')
        links_to_visit.push([link, currentScore])
      elsif (algo == 'bfs')
        links_to_visit.unshift([link, currentScore])
      else
        abort "Not a valid algorithm name"
      end
    end
    if (algo == 'bestfirst')
        links_to_visit.sort_by!{|item| -item[1]}
    end
  end
  output = File.new("index.dat", "w+")
  for key in $index.keys
    scoreAndFilename = $index[key]
    output_line = scoreAndFilename[1] + "\t" + scoreAndFilename[0].to_s + "\t" + key + "\n"
    output.write(output_line)
  end
  output.close
end