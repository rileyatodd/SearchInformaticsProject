require 'retriever'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  $path_to_pages = Rails.root.join('app','assets','crawler_files','pages/').to_s
  $path_to_index = Rails.root.join('app','assets','crawler_files','index.dat').to_s
  $path_to_stopwords = Rails.root.join('app','assets','crawler_files','stop.txt').to_s
  $path_to_invindex = Rails.root.join('app','assets','crawler_files','invindex.dat').to_s
  $path_to_docindex = Rails.root.join('app','assets','crawler_files','doc.dat').to_s
  $docindex = {}
  $invindex = {}
  $hits = {}

  def crawl
    spamPath = Rails.root.join('app','assets','crawler_files','known_spam.txt')
    nonSpamPath = Rails.root.join('app','assets','crawler_files','known_notspam.txt')
    output_dir = Rails.root.join('app','assets','crawler_files','pages').to_s
  	traverse_links("https://news.google.com", 200, output_dir, 'bfs', spamPath, nonSpamPath)
    redirect_to("/")
  end

  def index_pages
    index_documents($path_to_pages, $path_to_index, $path_to_stopwords, $path_to_invindex, $path_to_docindex)
    rank_pages($path_to_docindex, 100)
    redirect_to("/")
  end

	def search
    $docindex = load_docindex($path_to_docindex)
    Hit.all.map(&:destroy)
		query = params[:q]
    session[:q] = query
		$hits = retrieve($path_to_docindex, $path_to_invindex, $path_to_stopwords, query)
    if ($hits and $hits.size > 0)
      for hit in $hits 
        (docpath, tfidf) = hit
        doc_stats = $docindex[docpath]
        if doc_stats.pageRank == nil
          puts "nil rank for"
          puts doc_stats.uRL
        end
        hit_record = Hit.new(tfidf: tfidf, spamscore: doc_stats.spamScore,
                            url: doc_stats.uRL, pagerank: doc_stats.pageRank)
        hit_record.save
      end
    end
    redirect_to("/hits")
	end
end
