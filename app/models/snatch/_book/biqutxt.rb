# 笔趣阁 https://www.biqutxt.com/
module Biqutxt

  extend Configuration

  self.charset = "gbk"

  #抓取类别，返回参数
  def self.categories(opts={})
    doc = Snatch.rc "https://www.biqutxt.com/"
    doc.css(".nav li a").each do |a|
      code = a.attr("href").gsub("/","")
      url = "https://www.biqutxt.com#{code}"
      name = a.text.strip
      next unless name.include?("小说")
      break if name.include?"其他"
      yield(opts, code: code, url: url, name: name)
    end
  end

  def self.book(web_book, opts={})
    book_url = web_book.url
    doc = Snatch.rc(book_url,{ encoding: charset})
    name = doc.css("#info h1")[0].text
    chapter_url = book_url
    code = book_url.split("/").compact.last
    cover_url = doc.css("#fmimg img").attr("src")
    depcit = doc.css("#intro p").text.strip
    cate_name = doc.css(".con_top").text.split(" > ")[1]

    #作者
    author_name = doc.css("#info p")[0].text.split("：").last
    author_link = book_url
    yield(opts, name: name, chapter_url: chapter_url, cover_url: cover_url, depcit: depcit, cate: {name: cate_name}, author: {name: author_name, author_link: author_link})
  end

  def self.chapters(web_book, opts={})
    chapter_url = web_book.chapter_url
    doc = Snatch.rc chapter_url, {encoding: charset}
    doc.css("._chapter li a").each_with_index do |a, index|
      title = a.text.strip
      href = a.attr("href")
      code = href.split("html").first
      url = "#{chapter_url}#{href}"
      yield(opts, title: title, code: code, url: url)
    end
  end

  def self.contents(chapter, opts={})
    doc = Snatch.rc(chapter.url, {encoding: "gbk"})
    content = doc.css("#content").inner_html()
    yield(opts, content: content)
  end

end