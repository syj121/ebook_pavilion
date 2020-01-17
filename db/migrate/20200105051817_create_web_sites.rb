class CreateWebSites < ActiveRecord::Migration[5.2]
  def change
    #图书类别
    create_table :categories do |t|
      t.string :name, null: false, default: "", unique: true, comment: "类被名称"
      t.string :code, null: false, default: "", unique: true, comment: "类被编号"
      t.integer :parent_id
      t.timestamps
    end
    create_table :category_hierarchies, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
      t.index [:ancestor_id, :descendant_id, :generations], name: "cate_anc_desc_idx", unique: true
      t.index :descendant_id, name: "cate_desc_idx"
    end
    #图书作者
    create_table :authors do |t|
      t.string :name, null: false, default: "", unique: true, comment: "作者"
      t.text :depict, comment: "描述"
      t.timestamps
    end
    #图书作者标签
    create_table :author_categories do |t|
      t.references :author, foreign_key: true
      t.references :category, foreign_key: true
      t.timestamps
      t.index [:author_id, :category_id], unique: true
    end
    #图书
    create_table :books do |t|
      t.string :name, null: false, default: "", unique: true, comment: "书名"
      t.references :author, foreign_key: true, comment: "作者"
      t.text :depcit, comment: "描述"
      t.timestamps
    end
    #图书标签
    create_table :book_categories do |t|
      t.references :book, foreign_key: true, comment: "图书"
      t.references :category, foreign_key: true, comment: "类别"
      t.index [:book_id, :category_id], unique: true
      t.timestamps
    end

    #来源网站
    create_table :web_sites do |t|
      t.string :name, null: false, default: "", unique: true, comment: "来源网站"
      t.string :code, null: false, default: "", unique: true, comment: "网站编号"
      t.string :url, comment: "网站地址"
      t.string :remark, comment: "网站说明"
      t.timestamps
    end
    #来源网站-图数类别
    create_table :web_categories do |t|
      t.string :name, null: false, default: "", unique: true, comment: "类被名称"
      t.string :code, null: false, default: "", unique: true, comment: "类被编号"
      t.string :url, null: false, default: "", comment: "链接"
      t.references :web_site, foreign_key: true, comment: "来源网站"
      t.integer :parent_id
      t.integer :category_id, default: 0, index: true, comment: "平台类别"
      t.timestamps
      t.index [:web_site_id, :name], unique: true
    end
    create_table :web_category_hierarchies, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
      t.index [:ancestor_id, :descendant_id, :generations], name: "cate_anc_desc_idx", unique: true
      t.index :descendant_id, name: "cate_desc_idx"
    end
    # #来源网站-作者
    create_table :web_authors do |t|
      t.string :name, null: false, default: "", unique: true, comment: "作者"
      t.references :web_site, foreign_key: true, comment: "来源网站"
      t.text :depcit, comment: "来源网站-作者说明"
      t.integer :author_id, index: true, comment: "平台作者"
      t.string :url, comment: "网站作者URL"
      t.timestamps
      t.index [:web_site_id, :name], unique: true
    end
    #来源网站-图书
    create_table :web_books do |t|
      t.string :name, null: false, default: "", unique: true, comment: "书名"
      t.string :code, null: false, default: "", comment: "来源网站-图书唯一标识"
      t.references :web_site, foreign_key: true, comment: "来源网站"
      t.integer :web_author_id, index: true, comment: "来源网站-图书作者"
      t.integer :web_category_id, index: true, comment: "来源网站-图书类别"
      t.integer :author_id, default: 0, index: true, comment: "平台作者"
      t.integer :category_id, default: 0, index: true, comment: "平台类别"
      t.integer :book_id, default: 0, index: true, comment: "平台图书"
      t.string :url, null: false, default: "", comment: "图书链接"
      t.string :chapter_url, comment: "章节列表url"
      t.string :cover_url, comment: "封面图URL"
      t.text :depcit, comment: "来源网站-摘要"
      t.timestamps
      t.index [:web_site_id, :code], unique: true
    end
    #来源网站-图书章节
    create_table :web_chapters do |t|
      t.string :title, default: "未命名", null: :false, index: true, comment: "章节名称"
      t.references :web_book, foreign_key: true, comment: "来源网站-书籍"
      t.references :web_site, foreign_key: true, comment: "来源网站"
      t.string :url, null: false, default: "", comment: "地址"
      t.string :code, comment: "唯一标识"
      t.integer :parent_id
      t.timestamps
    end
    create_table :web_chapter_hierarchies, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
      t.index ["ancestor_id", "descendant_id", "generations"], name: "chapter_anc_desc_idx", unique: true
      t.index ["descendant_id"], name: "chapter_desc_idx"
    end

    create_table :web_book_contents do |t|
      t.references :web_chapter, foreign_key: true, comment: "来源网站-章节"
      t.longtext :content
      t.timestamps
    end

  end
end
