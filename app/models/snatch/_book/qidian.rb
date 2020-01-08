module Qidian

  def self.web_site
    @web_site ||= WebSite.find_by(code: "qidian")   
  end

  def self.categories(opts={})
    doc = Snatch.rc "https://www.qidian.com/"
    doc.css("#classify-list dd a").each do |a|
      code = a.attr("href").split("/").last
      url = "https://www.qidian.com/#{code}"
      name = a.css("span i").text.strip 
      yield(opts, code: code, url: url, name: name)
    end
  end

  def self.book(web_book, opts={})
    doc = Snatch.rc web_book.url
    name = doc.css(".book-info h1 em").text().strip
    chapter_url = web_book.url
    cover_url = doc.css(".book-img a img").attr("src").value
    depcit = doc.css(".book-intro p").text.strip
    yield(opts, name: name, chapter_url: chapter_url, cover_url: cover_url, depcit: depcit)
  end

  def self.chapters(web_book, opts={})
    doc = RestClient.get "https://book.qidian.com/ajax/book/category?_csrfToken=mLaVBQFNd6OUuOLbbzqpXPtWCLMf99E670KKliTz&bookId=#{web_book.sku}"
    re = JSON.parse(doc.body)
    re["data"]["vs"].each do |vs|
      next if vs["cs"].blank?
      vs["cs"].each do |l|
        title = l["cN"]
        code = l["uuid"]
        url = "https://read.qidian.com/chapter/#{l['cU']}"
        yield(opts, title: title, code: code, url: url)
      end
    end
  end

  def self.contents(chapter, opts={})
    doc = Snatch.rc chapter.url
    content = doc.css(".j_readContent").inner_html()
    yield(opts, content: content)
  end

end