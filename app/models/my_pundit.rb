class MyPundit

  # [{
  #   name: "统一后台首页"
  #   groups: [{
  #     name: "菜单管理",
  #     groups: [{
  #       name: "新增",
  #       group: ["new,create,show"]
  #     },{
  #       name: "修改",
  #       group: ["edit,update,show"]
  #     }]
  #   }]
  # }]
  def self.groups
    file_path = "#{Rails.root}/config/permissions"
    permissions = []
    Dir.foreach(file_path) do |file|
      next if file == "." || file == ".."
      name = file.gsub(".yml", "")
      menu_yml = YAML::load_file "#{Rails.root}/config/permissions/#{name}.yml"
      menu_name = menu_yml[name]["name"]
      menu_h = {name: menu_name, groups: []}
      menu_yml[name]["controllers"].each do |k,v|
        group = {name: v["name"], groups: []}
        v["groups"].each do |gk,gv|
          group[:groups] << {
            name: gk,
            group: gv
          }
        end
        menu_h[:groups] << group
      end
      permissions << menu_h
    end
    permissions
  end

end