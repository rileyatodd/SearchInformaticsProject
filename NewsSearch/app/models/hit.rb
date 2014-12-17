class Hit < ActiveRecord::Base
	validates :pagerank, presence: true
end
