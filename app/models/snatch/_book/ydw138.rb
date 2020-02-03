# 138阅读网 https://www.138txt.com/
module Ydw138

  extend Configuration

  #抓取类别，返回参数
  def self.categories(opts={})
    doc = Snatch.rc url
    doc.css(".nav li a").each_with_index do |a, index|
      next if index < 2
      code = a.attr("href").gsub("/","")
      url = "#{url}#{code}"
      name = a.text.strip
      break if !name.include?("小说")
      yield(opts, code: code, url: url, name: name)
    end
  end

  def self.book(web_book, opts={})
    book_url = web_book.url
    doc = Snatch.rc(book_url)
    name = doc.css("#info h1")[0].text
    chapter_url = book_url
    code = book_url.split("/").compact.last
    cover_url = doc.css("#fmimg img").attr("src")
    depcit = doc.css("#intro").text.strip
    cate_name = doc.css(".con_top").text.split(" > ")[1]
    #作者
    author_name = doc.css("#info p")[0].text.split("：").last
    author_link = book_url
    yield(opts, name: name, chapter_url: chapter_url, cover_url: cover_url, depcit: depcit, cate: {name: cate_name}, author: {name: author_name, url: author_link})
  end

  def self.chapters(web_book, opts={})
    chapter_url = web_book.chapter_url
    doc = Snatch.rc chapter_url
    doc.css("dt:nth-child(n+2) ~ dd a").each do |a|
      title = a.text.strip
      href = a.attr("href")
      code = href.split(".html").first.split("/").compact.last
      url = "#{chapter_url}#{code}.html"
      yield(opts, title: title, code: code, url: url)
    end
  end

  def self.contents(chapter, opts={})
    doc = Snatch.rc(chapter.url)
    content = doc.css("#content").inner_html()
    errors_words = ["正在手打中", "0┻手机访问"]
    content = "" if errors_words.any?{|e|e.include?(content)}
    yield(opts, content: content)
  end

end