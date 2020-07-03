class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    #角色
    create_table :roles do |t|
      t.string :name, comment: "角色名称"
      t.text :desc, comment: "角色描述"
      t.integer :usable, default: 1, limit: 4, comment: "使用状态 1 可用"
      t.integer :rtype, default: 1, limit: 4, comment: "角色类别"
      t.integer :users_count, default: 0, comment: "用户数量"
      t.integer :parent_id, comment: "上级ID"
      t.timestamps
    end
    create_table :role_hierarchies, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
      t.index [:ancestor_id, :descendant_id, :generations], name: "cate_anc_desc_idx", unique: true
      t.index :descendant_id, name: "cate_desc_idx"
    end
    #角色-用户
    create_table :role_users do |t|
      t.integer :role_id, comment: "角色ID"
      t.integer :user_id, comment: "用户ID"
      t.timestamps
      t.index [:user_id, :role_id], unique: true
      t.index :user_id
    end
    #菜单-角色
    create_table :menu_roles do |t|
      t.integer :menu_id, comment: "菜单ID"
      t.integer :role_id, comment: "角色ID"
      t.timestamps
      t.index [:role_id, :menu_id], unique: true
      t.index :role_id
    end
    #权限组名称
    create_table :permision_groups do |t|
      t.integer :menu_id, comment: "菜单ID"
      t.string :name, comment: "权限组名称"
      t.text :desc, comment: "权限描述"
      t.integer :parent_id
      t.timestamps
    end
    create_table :permision_group_hierarchies, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
      t.index [:ancestor_id, :descendant_id, :generations], name: "cate_anc_desc_idx", unique: true
      t.index :descendant_id, name: "cate_desc_idx"
    end
    #权限list
    create_table :permisions do |t|
      t.integer :group_id, comment: "权限组外键"
      t.string :action_path, comment: "权限路径"
    end
    #角色权限
    create_table :permision_roles do |t|
      t.integer :permision_group_id
      t.integer :role_id
      t.timestamps
      t.index [:permision_group_id, :role_id], unique: true, name: "permision_group_role"
      t.index :role_id
    end

    add_column :users, :current_role_id, :integer, comment: "当前角色"
    add_column :users, :roles_count, :integer, default: 0, comment: "角色数量"
  end
end
