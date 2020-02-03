class WebBook < ApplicationRecord

  belongs_to :author, optional: true
  belongs_to :book, optional: true
  belongs_to :category, optional: true
  belongs_to :web_author, optional: true
  belongs_to :web_category, optional: true
  belongs_to :web_site
  has_many :chapters, class_name: "WebChapter"

  #查询网站分类
  def find_web_category(cate={}, do_save=false)
    return "查询分类：分类为空" if cate.blank?
    cate_name = cate[:name]
    return "查询分类：没有分类名称" if cate_name.blank?
    cate = web_site.web_categories.find_by(name: cate_name)
    return "查询分类：没有查到对应的分类（#{cate_name}）" if cate.blank?
    self.web_category_id = cate.id
    self.category_id = cate.category_id
    do_save ? self.save : cate
    cate
  end

  #查询网站作者
  def find_web_author(wauthor={}, do_save=false)
    return "查询作者：作者为空" if wauthor.blank?
    author_name = wauthor[:name]
    return "查询作者：没有作者名称" if author_name.blank?
    wau = web_site.web_authors.find_or_initialize_by(name: author_name)
    wau.url ||= wauthor[:url]
    wau.save if wau.changed?
    self.web_author_id = wau.id
    self.author_id = wau.author_id
    do_save ? self.save : wau
    wau
  end

  #源网站图书下载，返回下载URL
  # r   只读模式。文件指针被放置在文件的开头。这是默认模式。
  # r+  读写模式。文件指针被放置在文件的开头。
  # w   只写模式。如果文件存在，则重写文件。如果文件不存在，则创建一个新文件用于写入。
  # w+  读写模式。如果文件存在，则重写已存在的文件。如果文件不存在，则创建一个新文件用于读写。
  # a   只写模式。如果文件存在，则文件指针被放置在文件的末尾。也就是说，文件是追加模式。如果文件不存在，则创建一个新文件用于写入。
  # a+  读写模式。如果文件存在，则文件指针被放置在文件的末尾。也就是说，文件是追加模式。如果文件不存在，则创建一个新文件用于读写。
  def download(opts={})
    dir_path = "#{Rails.root}/ebooks/web_books/#{self.web_site_id}"
    url = "#{dir_path}/#{self.name}.txt"
    return url if File.exists?url
    FileUtils.mkdir_p(dir_path) unless File.exists?dir_path
    scheduler = Rufus::Scheduler.new
    scheduler.in '3s' do
      File.open(url, "w") do |txt|
        self.chapters.includes(:contents).unscope(:order).each do |web_chapter, index|
          content = ""
          web_chapter.contents.unscope(:order).where(position: :asc).each do |web_content|
            next if web_content.blank?
            content += web_content.content + "\r\n"
          end
          txt.syswrite(web_chapter.title+"\r\n")
          content = content.to_s.gsub("<br></br>", "<br>")
          content = content.to_s.gsub("<br>", "\r\n")
          txt.syswrite(content+"\r\n")
        end
      end
    end
    return nil
  end

end