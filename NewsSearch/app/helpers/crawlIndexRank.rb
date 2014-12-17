require_relative 'indexer'
require_relative 'crawler'

num_pages = ARGV[0].to_f

traverse_links('http://news.google.com', num_pages, '../assets/crawler_files/pages/', 'bfs',
				'../assets/crawler_files/known_spam.txt', '../assets/crawler_files/known_notspam.txt')

index_documents('../assets/crawler_files/pages/', '../assets/crawler_files/index.dat',
				'../assets/crawler_files/stop.txt', '../assets/crawler_files/invindex.dat',
				'../assets/crawler_files/doc.dat')


docindex_path = "../assets/crawler_files/doc.dat"
rank_pages(docindex_path, 100)

docindex = load_docindex(docindex_path)

check_ranks(docindex)