module Common

  attr_accessor :code
  attr_accessor :web_site 
  attr_accessor :url #源地址
  attr_accessor :charset  #编码
  attr_accessor :only_content  #是否一张一页

  def self.extended(base)
    base.code = base.to_s.underscore
    base.web_site = WebSite.find_by(code: base.code)
    base.url = base.web_site.url
    base.charset = "utf-8"
    base.only_content = true
  end

  def categories(opts={})
    categories_block.each do |attrs|
      wc = web_site.web_attrsgories.find_or_initialize_by(code: attrs[:code])
      wc.name = attrs[:name]
      wc.url = attrs[:url]
      wc.parent = attrs[:parent]
      wc.save
    end
  end

  #web_book: 来源网站图书。 根据url，获取某一本书籍
  #[{name: name, chapter_url: chapter_url, cover_url: cover_url, depcit: depcit, cate: {name: cate_name}, author: {name: author_name, url: author_link}}]
  def book(web_book, opts={})
    attrs = book_block(web_book)
    web_book.name = attrs[:name]
    web_book.chapter_url = attrs[:chapter_url]
    web_book.cover_url = attrs[:cover_url]
    web_book.depcit = attrs[:depcit]
    web_book.find_web_category(attrs[:cate])  #获取网站类别
    web_book.find_web_author(attrs[:author])  #获取网站作者
    web_book.save
  end

  #获取某一本书的所有章节
  #[{title: title, url: url, code: :code}]
  def chapters(web_book, opts={})
    chapters_block(web_book, opts).each do |attrs|
      wc = web_book.chapters.find_or_initialize_by(code: attrs[:code])
      wc.web_site_id = web_book.web_site_id
      wc.url = attrs[:url]
      wc.title = attrs[:title]
      wc.save
    end
  end

  #获取图书所有内容
  def contents(web_book, opts={})
    web_book.chapters.each do |web_chapter|
      next false if web_chapter.contents.exists?
      contents_block(web_chapter, opts).each do |c|
        wbc = WebBookContent.find_or_initialize_by(web_chapter_id: web_chapter.id, position: c[:position])
        wbc.content = c[:content]
        wbc.save
      end
    end
  end

  #源网站图书下载，返回下载URL
  # r   只读模式。文件指针被放置在文件的开头。这是默认模式。
  # r+  读写模式。文件指针被放置在文件的开头。
  # w   只写模式。如果文件存在，则重写文件。如果文件不存在，则创建一个新文件用于写入。
  # w+  读写模式。如果文件存在，则重写已存在的文件。如果文件不存在，则创建一个新文件用于读写。
  # a   只写模式。如果文件存在，则文件指针被放置在文件的末尾。也就是说，文件是追加模式。如果文件不存在，则创建一个新文件用于写入。
  # a+  读写模式。如果文件存在，则文件指针被放置在文件的末尾。也就是说，文件是追加模式。如果文件不存在，则创建一个新文件用于读写。
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
            next if web_content.content.blank?
            content += web_content.content + "\r\n"
          end
          txt.syswrite(web_chapter.title+"\r\n")
          content = content.to_s.gsub("<br></br>", "<br>")
          content = content.to_s.gsub("<br>\n<br>\n", "<br>")
          content = content.to_s.gsub("<br>", "\r\n")
          txt.syswrite(content+"\r\n")
        end
      end
    end
    return nil
  end

end