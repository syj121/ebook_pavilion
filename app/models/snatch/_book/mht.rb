# 棉花糖小说网 https://www.mht.tw
module Mht

  extend Configuration

  #抓取类别，返回参数
  def self.categories(opts={})
  end

  def self.book(web_book, opts={})
    book_url = web_book.url
    doc = Snatch.rc(book_url,{ encoding: charset})
    name = doc.css("#info h1")[0].text
    chapter_url = book_url
    code = book_url.split("/").compact.last
    cover_url = "https://www.mht.tw" + doc.css("#fmimg img").attr("src")
    depcit = doc.css("#intro").text.strip
    cate_name = doc.css(".con_top").text.split(" > ")[1]

    #作者
    author_name = doc.css("#info p")[0].text.split("：").last
    author_link = "https://www.mht.tw"
    yield(opts, name: name, chapter_url: chapter_url, cover_url: cover_url, depcit: depcit, cate: {name: cate_name}, author: {name: author_name, author_link: author_link})
  end

  def self.chapters(web_book, opts={})
    chapter_url = web_book.chapter_url
    doc = Snatch.rc chapter_url, {encoding: charset}
    doc.css("dt:nth-child(n+2) ~ dd a").each do |a|
      title = a.text.strip
      href = a.attr("href")
      code = href.split(".html").first.split("/").compact.last
      url = "#{chapter_url}#{code}.html"
      yield(opts, title: title, code: code, url: url)
    end
  end

  #一章分几页，所以，需要进行对应的分页
  def self.contents(chapter, opts={})
    chapter_url = save_content(chapter, chapter.url, opts)
    while chapter_url.end_with?(".html")
      chapter_url = "https://www.mht.tw#{chapter_url}"
      chapter_url = save_content(chapter, chapter_url, opts)
    end
  end

  def self.save_content(chapter, chapter_url, opts={})
    return true if chapter_url.blank?
    position = chapter_url.scan(/_(.*).html/) || 1
    c = WebBookContent.find_or_initialize_by(web_chapter_id: chapter.id, position: position)
    return true if c.id.present?
    doc = Snatch.rc chapter_url
    content = doc.css("#content").inner_html().split("\t").first
    content.delete!("... ...")
    c.content = content
    c.save
    #本章节，下一页的连接
    next_href = doc.css("#content a").attr("href").text.strip rescue ""

    lot_number = opts[:lot_number]
    log_p(lot_number, "contents", "mht", content)
    
    next_href.to_s
  end

  def self.log_p(lot_number, method_name, code, msg)
    msg = "【#{lot_number}】 —— 【#{code.classify}】.#{method_name}  #{msg}"
    begin
     @logger ||= Logger.new("log/ebook/snatch/#{Time.now.strftime("%Y%m%d")}.log")
     @logger.info msg
     puts msg
    rescue => e
     ExceptionNotifier.notify_exception(e) rescue nil
    end
  end

end