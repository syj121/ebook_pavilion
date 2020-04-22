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

  #抓取源网站图书
  def snatch_book(opts = {})
    code = self.web_site.code
    code.const!.book(self, opts)
  end

  #抓取原网站图书内容
  #opts[:force_save]  true 强制更新
  def snatch_contents(opts = {})
    code = self.web_site.code
    const_mod = code.const!
    chapters.map { |chapter| 
      #next if chapter.contents.exists? && opts[:force_update].blank?
      #sleep rand(3)
      const_mod.contents(chapter) 
    }
  end
end