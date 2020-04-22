# 笔趣阁 https://www.biqutxt.com/
module Biqutxt

  extend Common

  self.charset = "gbk"

  #抓取类别，返回参数
  def self.categories_block(opts={})
    doc = Snatch.rc web_site.url
    cs = []
    doc.css(".nav li a").each_with_index do |a, index|
      next if index < 2
      code = a.attr("href").gsub("/","")
      url = "https://www.biqutxt.com#{code}"
      name = a.text.strip
      cs << {code: code, url: url, name: name}
    end
    cs
  end

  def self.book_block(web_book, opts={})
    book_url = web_book.url
    doc = Snatch.rc(book_url,{ encoding: charset})
    name = doc.css("#info h1")[0].text
    chapter_url = book_url
    cover_url = doc.css("#fmimg img").attr("src")
    depcit = doc.css("#intro p").text.strip
    cate_name = doc.css(".con_top").text.split(" > ")[1]

    #作者
    author_name = doc.css("#info p")[0].text.split("：").last
    author_link = book_url

    {name: name, chapter_url: chapter_url, cover_url: cover_url, depcit: depcit, cate: {name: cate_name}, author: {name: author_name, url: author_link}}
  end

  def self.chapters_block(web_book, opts={})
    chapter_url = web_book.chapter_url
    doc = Snatch.rc chapter_url, {encoding: charset}
    cs = []
    doc.css("._chapter li a").each_with_index do |a, index|
      title = a.text.strip
      href = a.attr("href")
      code = href.split("html").first
      url = "#{chapter_url}#{href}"
      cs << {title: title, url: url, code: code}
    end
    cs
  end

  def self.contents_block(chapter, opts={})
    doc = Snatch.rc(chapter.url, {encoding: "gbk"})
    content = doc.css("#content").inner_html()
    content.delete!("富品中文手机阅读地址：m.biqutxt.com")
    [{position: 1, content: content}]
  end
end