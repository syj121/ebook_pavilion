class CreateMenus < ActiveRecord::Migration[5.2]
  def change
    create_table :menus do |t|
      t.string :name, null: false, default: "", index: true, comment: "菜单名"
      t.string :url, comment: "菜单地址"
      t.integer :parent_id, comment: "上级菜单id"
      t.integer :status, default: 1, comment: "状态"
      t.float :position, default: 1.0, comment: "排序"
      t.string :icon, comment: "图标"
      t.timestamps
    end

    create_table :menu_hierarchies, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
      t.index [:ancestor_id, :descendant_id, :generations], name: "menu_anc_desc_idx", unique: true
      t.index :descendant_id, name: "menu_desc_idx"
    end
  end
end
