class WebCategory < ApplicationRecord
  
  belongs_to :web_site
  belongs_to :category, optional: true
  has_many :web_books

  has_closure_tree

  before_save do 
    #匹配标准类别
    self.match_category if self.name_changed?
  end

  after_save do 
    #类别修改，对应的书籍更新标准类别
    if self.category_id_changed?
      self.web_books.update_all(category_id: self.category_id)
    end
  end

  #匹配标准的分类
  def match_category(do_save=false, opts={})
    catename = self.name.split("").first(2).join("")
    cate = Category.find_by(name: catename)
    self.category = cate
    self.is_init = cate.blank?
    if do_save
      self.save
    end
    cate
  end

end
