class CrawlTwitterTask
  @queue = :crawl_queue_twitter

  def self.perform()
    rake crawler:fetch
  end

end