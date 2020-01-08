# 2K小说 https://www.fpzw.com/
module Fpzw

  def self.web_site
    @web_site ||= WebSite.find_by(code: "fpzw")   
  end

  #抓取类别，返回参数
  def self.categories(opts={})
    yield(opts, code: "code", url: "url", name: "name")
    doc = Snatch.rc "https://www.fpzw.com/"
    doc.css(".nav2 a.book_sort").each do |a|
      code = a.attr("href").split("/").last
      url = "https://www.fpzw.com/#{code}"
      name = a.text.strip
      yield(opts, code: code, url: url, name: name)
    end
  end

  def self.book(web_book, opts={})
    url = web_book.url
    doc = Snatch.rc(url)
    a = doc.css("#title h2 a")
    name = a.text.strip
    chapter_url = a.attr("href").value
    code = url.gsub("https://www.fpzw.com/xiaoshuo/", "")
    cover_url = "https://www.fpzw.com#{doc.css(".bortable img")[0].attr("src")}" rescue nil
    depcit = doc.css(".wright p.Txt").text.strip
    yield(opts, name: name, chapter_url: chapter_url, cover_url: cover_url, depcit: depcit)
  end

  def self.chapters(web_book, opts={})
    chapter_url = web_book.chapter_url
    doc = Snatch.rc chapter_url
    doc.css(".book > dd a").each_with_index do |a, index|
      next if index < 4
      title = a.text.strip
      href = a.attr("href")
      code = href.split("html").first
      url = "#{chapter_url}#{href}"
      yield(opts, title: title, code: code, url: url)
    end
  end

  def self.contents(chapter, opts={})
    doc = Snatch.rc(chapter.url, {encoding: "gbk"})
    content = doc.css(".Text").inner_html()
    yield(opts, content: content)
  end

end