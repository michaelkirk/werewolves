
namespace 'werewolves' do
  desc "crawl known articles to files"
  task :crawl_all => :environment do
    Dir.mkdir(Issue::FILE_ROOT) unless Dir.exists?(Issue::FILE_ROOT)
    Issue.crawl_all
  end
end
