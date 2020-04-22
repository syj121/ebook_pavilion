# 七八中文网 https://www.jxleiyuan.com/
module Jxleiyuan

  extend Configuration

  #抓取类别，返回参数
  def self.categories(opts={})
  end

  def self.book_block(web_book, opts={})
    book_url = web_book.url
    doc = Snatch.rc(book_url)
    name = doc.css(".bookTitle a")[0].text
    chapter_url = "https://www.jxleiyuan.com/other/tpl/chapters/id/#{web_book.code}.html"
    cover_url = doc.css("img.img-thumbnail").attr("src")
    depcit = doc.css("#bookIntro").text.strip
    cate_name = doc.css(".breadcrumb li a").last.text

    #作者
    author_a = doc.css(".bookTitle a").last
    author_name = author_a.text
    
    {name: name, chapter_url: chapter_url, cover_url: cover_url, depcit: depcit, cate: {name: cate_name}, author: {name: author_name, author_link: author_link}}
  end

  def self.chapters_block(web_book, opts={})
    chapter_url = web_book.chapter_url
    doc = Snatch.rc chapter_url, {encoding: charset}
    cs = []
    doc.css("dl dt:eq(2) ~dd a").each_with_index do |a, index|
      title = a.text.strip
      href = a.attr("href")
      code = href.split("jxle1/").last.gsub(".html", "")
      url = href
      cs << {title: title, url: url, code: code}
    end
    cs
  end

  #一章分几页，所以，需要进行对应的分页
  def self.contents(chapter, opts={})
    origin_url = chapter.url
    chapter_url = save_content(chapter, chapter.url, opts)
    while chapter_url.include?("?page=")
      chapter_url = "#{origin_url}#{chapter_url}"
      chapter_url = save_content(chapter, chapter_url, opts)
    end
  end

  def self.save_content(chapter, chapter_url, opts={})
    return true if chapter_url.blank?
    position = chapter_url.scan(/page=(.*)/).flatten.first || 1
    c = WebBookContent.find_or_initialize_by(web_chapter_id: chapter.id, position: position)
    return true if c.id.present?
    doc = Snatch.rc chapter_url
    content = doc.css(".read-content").inner_html()
    content = doc.css("#txt").inner_html() if content.blank?
    content.delete!("天才一秒钟记住本网站《www.jxleiyuan.com  七八中文网》更新最快的小说网站!")
    c.content = content
    c.save
    #本章节，下一页的连接
    next_href = doc.css("a#j_chapterNext").attr("href")   
    next_href.to_s
  end

end