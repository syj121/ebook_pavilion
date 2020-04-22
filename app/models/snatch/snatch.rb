class Snatch

  def self.rc(url, opts = {})
    p "(Snatch.rc)url: #{url}"
    case 
    when opts[:method_type] == "selenium"
      rc_selenium(url, opts)
    else
      rc_restclient(url, opts)
    end
  end

  def self.rc_selenium(url, opts={})
    chrome_options = ["--headless", "--no-sandbox", "--disable-gpu", "--disable-dev-shm-usage"]
    caps = Selenium::WebDriver::Remote::Capabilities.chrome({'platform' => :LINUX, "chromeOptions" => {"args" => chrome_options}})
    driver = Selenium::WebDriver.for(:remote,:desired_capabilities => caps)
    driver.navigate.to url
    sleep(2)
    html = driver.page_source
    item_doc = Nokogiri::HTML.parse(html)
    {item_doc: item_doc, driver: driver}
  end

  def self.rc_restclient(url, opts={})
    referer = opts[:referer] = "http://www.baidu.com"
    user_agent =  opts[:user_agent] || "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36"

    response = RestClient.get(url, {"referer": referer, "user-agent" => user_agent})
    html = if opts[:encoding]
      response.to_str.force_encoding(opts[:encoding]).to_utf8
    else
      response.to_str
    end
    doc = Nokogiri::HTML.parse(html)
  end

  def self.rc_json(url)
    JSON.parse RestClient.get(url).body
  end

end