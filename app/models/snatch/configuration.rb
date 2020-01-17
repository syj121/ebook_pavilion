module Configuration

  attr_accessor :web_site 
  attr_accessor :url #源地址
  attr_accessor :charset  #编码

  def self.extended(base)
    code = base.to_s.underscore
    base.web_site = WebSite.find_by(code: code)
    base.url = base.web_site.url
    base.charset = "utf-8"
  end

end