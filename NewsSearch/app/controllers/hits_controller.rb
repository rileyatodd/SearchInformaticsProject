class HitsController < ApplicationController
	def index
		@hits = Hit.all.sort_by {|hit| 
			puts "tfidf"
			puts hit.tfidf
			puts "pagerank"
			puts hit.pagerank
			puts "spamscore"
			puts hit.spamscore
			hit.tfidf * hit.pagerank
		}.reverse
	end
end
