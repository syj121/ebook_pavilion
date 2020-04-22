# 棉花糖小说网 https://www.mht.tw
module Mht

  extend Common

  #抓取类别，返回参数
  def self.categories(opts={})
  end

  def self.book_block(web_book, opts={})
    book_url = web_book.url
    doc = Snatch.rc(book_url,{ encoding: charset})
    name = doc.css("#info h1")[0].text
    chapter_url = book_url
    code = book_url.split("/").compact.last
    cover_url = "https://www.mht.tw" + doc.css("#fmimg img").attr("src").value
    depcit = doc.css("#intro").text.strip
    cate_name = doc.css(".con_top").text.split(">")[1].strip

    #作者
    author_name = doc.css("#info p")[0].text.split("：").last
    author_link = "https://www.mht.tw"
    
    {name: name, chapter_url: chapter_url, cover_url: cover_url, depcit: depcit, cate: {name: cate_name}, author: {name: author_name, author_link: author_link}}
  end

  def self.chapters_block(web_book, opts={})
    chapter_url = web_book.chapter_url
    doc = Snatch.rc chapter_url, {encoding: charset}
    cs = []
    doc.css("dl dt:eq(2) ~dd a").each_with_index do |a, index|
      title = a.text.strip
      href = a.attr("href")
      code = href.split(".html").first.split("/").compact.last
      url = "#{chapter_url}#{code}.html"
      cs << {title: title, url: url, code: code}
    end
    cs
  end

  def self.contents_block(web_chapter, opts = {})
    cs = []
    cblock = lambda { |chapter_url|  
      doc = Snatch.rc chapter_url
      position = chapter_url.find(/_(.*).html/).to_i
      content = doc.css("#content").inner_html().split("\t").first
      content.delete!("... ...") if content.last(7) == "... ..."
      cs << {content: content, position: position}
      doc.css("#content a").attr("href").text.strip rescue ""
    }
    chapter_url = cblock.call(web_chapter.url)
    while chapter_url.present?
      chapter_url = "https://www.mht.tw#{chapter_url}"
      chapter_url = cblock.call(chapter_url)
    end
    cs
  end

  def download(web_book, opts={})
    dir_path = "#{Rails.root}/ebooks/web_books/#{web_book.web_site_id}"
    url = "#{dir_path}/#{web_book.name}.txt"
    #return url if File.exists?url
    FileUtils.mkdir_p(dir_path) unless File.exists?dir_path
    scheduler = Rufus::Scheduler.new
    scheduler.in '3s' do
      File.open(url, "w+") do |txt|
        web_book.chapters.includes(:contents).each do |web_chapter, index|
          content = ""
          web_chapter.contents.each do |web_content|
            content += web_content.content + "\r\n"
          end
          txt.syswrite(web_chapter.title+"\r\n")
          content = "\r\t  #{content}" 
          content = content.to_s.gsub("<br>", "\r\n")
          txt.syswrite(content+"\r\n")
        end
      end
    end
    return nil
  end

end