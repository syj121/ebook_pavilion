# 抓取的通用方法
class Snatch

  #code: 网站编号
  def self.categories(code, opts={})
    web_site = WebSite.find_by(code: code)
    lot_number = "#{Time.now.to_s(:number)}-categories"
    obj_mod = code.classify.constantize rescue nil
    return "网站：#{code}，未配置抓取类别" if !obj_mod.respond_to?"categories"
    scheduler = Rufus::Scheduler.new
    scheduler.in '3s' do
      ActiveRecord::Base.connection_pool.with_connection do
        log_p lot_number, "categories", code, "本次抓取开始，批次号为：#{lot_number}。"
        @num,@new_num,@update_num,@error_num=0,0,0,0
        obj_mod.categories(opts) do |*args, attrs|
          opts = args.extract_options!
          wc = web_site.web_categories.find_or_initialize_by(code: attrs[:code])
          #记录每次解析的日志
          gen_attrs_log(lot_number, "categories", code, wc, attrs) do |obj|
            obj.name = attrs[:name]
            obj.url = attrs[:url]
            obj
          end
        end
        log_p lot_number, "categories", "#{code}", "本次抓取结束，一共处理：#{@num}条数据，其中，新增：#{@new_num}条，更新：#{@update_num}条，处理失败：#{@error_num}。本次抓取结束，批次号为：#{lot_number}"
      end
    end
    #本次日志
    return "网站：#{web_site.name}，正在获取类别，请稍后"
  end

  #同步网站所有的图书
  def self.books(code, opts={})
    web_site = WebSite.find_by(code: code)
    lot_number = "#{Time.now.to_s(:number)}---books"
    web_site.web_books.find_each do |web_book|
      book(web_book, {lot_number: lot_number})
    end
  end

  #web_book: 来源网站图书。 根据url，获取某一本书籍
  def self.book(web_book, opts={})
    web_site = web_book.web_site
    code = web_site.code
    lot_number = opts[:lot_number] || "#{Time.now.to_s(:number)}-book"
    obj_mod = code.classify.constantize rescue nil
    return "网站：#{web_site.name}，未配置抓取书籍" if !obj_mod.respond_to?"book"
    @num,@new_num,@update_num,@error_num=0,0,0,0
    obj_mod.book(web_book, opts) do |*args, attrs|
      opts = args.extract_options!
      #记录每次解析的日志
      gen_attrs_log(lot_number, "book", code, web_book, attrs) do |obj|
        obj.name = attrs[:name]
        obj.chapter_url = attrs[:chapter_url]
        obj.cover_url = attrs[:cover_url]
        obj.depcit = attrs[:depcit]
        obj.find_web_category(attrs[:cate])  #获取网站类别
        obj.find_web_author(attrs[:author])  #获取网站作者
        obj
      end
    end
    #chapters(web_book, {lot_number: lot_number}.merge(opts))
    log_p lot_number, "book", code, "本次抓取结束。"
    #本次日志
    return "网站：#{web_site.name}，正在获取书籍，请稍后"
  end

  #获取某一本书的所有章节
  def self.chapters(web_book, opts={})
    code = web_book.web_site.code
    obj_mod = code.classify.constantize rescue nil
    return "网站：#{code}，未配置抓取章节" if !obj_mod.respond_to?"chapters"
    lot_number = opts[:lot_number] || "#{Time.now.to_s(:number)}-chapters"
    scheduler = Rufus::Scheduler.new
    scheduler.in '3s' do
      ActiveRecord::Base.connection_pool.with_connection do 
        log_p lot_number, "chapters", code, "本次抓取开始，批次号为：#{lot_number}。"
        @num,@new_num,@update_num,@error_num=0,0,0,0
        obj_mod.chapters(web_book, opts) do |*args, attrs|
          opts = args.extract_options!
          wc = web_book.chapters.find_or_initialize_by(code: attrs[:code])
          wc.web_site_id = web_book.web_site_id
          #记录每次解析的日志
          gen_attrs_log(lot_number, "chapters", code, wc, attrs) do |obj|
            obj.title = attrs[:title]
            obj.url = attrs[:url]
            obj
          end
        end
        contents(web_book, {lot_number: lot_number}.merge(opts))
        log_p lot_number, "chapters", "#{code}", "本次抓取结束，一共处理：#{@num}条数据，其中，新增：#{@new_num}条，更新：#{@update_num}条，处理失败：#{@error_num}。本次抓取结束，批次号为：#{lot_number}"
      end
    end
    return "网站：#{code}，正在获取章节，请稍后"
  end

  #获取某一章节内容
  def self.contents(web_book, opts={})
    code = web_book.web_site.code
    web_chapters = web_book.chapters
    if opts[:wcid].present?
      web_chapters = web_chapters.where(id: opts[:wcid])
    end
    obj_mod = code.classify.constantize rescue nil
    return "网站：#{code}，未配置抓取章节内容" if !obj_mod.respond_to?"contents"
    lot_number = opts[:lot_number] || "#{Time.now.to_s(:number)}-contents"
    only_content = obj_mod.only_content
    scheduler = Rufus::Scheduler.new
    scheduler.in '3s' do
      ActiveRecord::Base.connection_pool.with_connection do 
        log_p lot_number, "contents", code, "本次抓取开始，批次号为：#{lot_number}。"
        @num,@new_num,@update_num,@error_num=0,0,0,0
        web_chapters.includes(:contents).each do |web_chapter|
          next if only_content && web_chapter.contents.present?
          #sleep rand(5)
          obj_mod.contents(web_chapter, opts.merge({position: 1})) do |*args, attrs|
            opts = args.extract_options!
            c = WebBookContent.find_or_initialize_by(web_chapter_id: web_chapter.id, position: 1)
            #记录每次解析的日志
            gen_attrs_log(lot_number, "contents", code, c, attrs) do |obj|
              obj.content = attrs[:content]
              obj
            end
          end
        end
        log_p lot_number, "contents", "#{code}", "本次抓取结束，一共处理：#{@num}条数据，其中，新增：#{@new_num}条，更新：#{@update_num}条，处理失败：#{@error_num}。本次抓取结束，批次号为：#{lot_number}"
      end
    end
    return "网站：#{code}，正在获取章节内容，请稍后"
  end

  def self.rc(url, opts = {})
    puts url
    sleep rand(5)
    begin
      opts[:method] ||= "get"
      opts[:cookie] ||= false

      # co = "thw=cn; cna=rT2GD3ttshkCAXki8ZYnvOIh; miid=8532411275201208031; ubn=p; ucn=center; _tb_token_=5bb3e7e6a6613; uc2=wuf=https%3A%2F%2Ftuikuan.tmall.com%2Frefund%2Fview_detail.htm%3Fouter_id%3D98886428142267%26refund_type%3D200; uss=AiSgAIGa%2FUmV7NyFmgNc%2FA4%2BRS%2BPI%2ByqhbKEJjUAEaCfUA55hVH9Wkug6w%3D%3D; cookie2=1ce30c4bd3f1d03ae84f1237c85c7961; t=bdd469d11ffe6ef99d0a797cae2f7bc3; _cc_=VFC%2FuZ9ajQ%3D%3D; tg=0; uc3=sg2=UUtN0d4b2gW7w2regLAWTx%2BVJjcXocB3M0A%2FhI%2BuSb4%3D&nk2=&id2=&lg2=; tracknick=; mt=ci=0_0; v=0; l=Ai4uChGe0/QoTf3ZlPQdjMsc/o7wL/Ip; isg=ApaWPei73cyLXOlBRBGS9bpC50oL1dpxh18SRgD_gnkUwzZdaMcqgfyzLejV; linezing_session=Y9gBH0HDEpTjeHizEMCgc7es_1471010741927SY4T_1"
      co = "cna=rT2GD3ttshkCAXki8ZYnvOIh; spider=baidu; _med=dw:1440&dh:900&pw:2880&ph:1800&ist:0; _m_user_unitinfo_=center; _m_h5_tk=3d7171313a9e6b97328b2a00ec2e739c_1474177419536; _m_h5_tk_enc=7cb7d1f41ec02b06f704974f9a1c01ba; _tb_token_=Zmvtfw119Oaa; ck1=; uc3=sg2=UUtN0d4b2gW7w2regLAWTx%2BVJjcXocB3M0A%2FhI%2BuSb4%3D&nk2=CdKRV9JmSg%3D%3D&id2=UoewCLKrN59y5w%3D%3D&vt3=F8dAS1Ho802qxBEKKLE%3D&lg2=V32FPkk%2Fw0dUvg%3D%3D; lgc=jacob%5Cu5468; tracknick=jacob%5Cu5468; cookie2=7e4463a48cbb69badea5948402bd13f7; t=26645ba27b98e7707f3c66e21174b3d0; skt=36543d2af2b7c2d5; hng=; uss=BqJmy4%2B5XltVt8nJSZuPWK75gy%2FwAJ3JbWX%2FGBRSi%2F87bK59aRqTxchEzA%3D%3D; pnm_cku822=229UW5TcyMNYQwiAiwQRHhBfEF8QXtHcklnMWc%3D%7CUm5OcktxSHBEfUZ8SXJNdCI%3D%7CU2xMHDJ7G2AHYg8hAS8XKQcnCU4nTGI0Yg%3D%3D%7CVGhXd1llXGZfZ1NqUWteZVpjVGlLdUt2QntBfEJ%2FSnJGc0l0SGYw%7CVWldfS0QMAs%2FCioUNBomGDIcShw%3D%7CVmhIGCcZOQQkGCYdJgY5Bz0AIBwlHCEBNQg1FSkXIx09CDIIXgg%3D%7CV25Tbk5zU2xMcEl1VWtTaUlwJg%3D%3D; res=scroll%3A1366*2370-client%3A1366*803-offset%3A1366*2370-screen%3A1440*900; cq=ccp%3D1; l=AqOjl0FLNl0X/EMNMRw41u4zs-1NmDfa; isg=AkBAP518A-fx6v-zX5Pfsx0fEchLsSSTbh6Mu7rRDNvuNeBfYtn0IxYHOyoP"
      ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36"
      # re = "https://detail.tmall.com/item.htm?id=532179570493&skuId=3174724439281&cat_id=50047396&rn=bc32eb73cb007e8a261cc879893608a2&standard=1&user_id=2120923048&is_b=1"
      re = "http://www.baidu.com"

      response = case opts[:method]
        when "get", :get
          if opts[:cookie]
            RestClient.get(url, {"cookie" => co, "referer" => re, "user-agent" => ua})
          elsif opts[:ua]
            RestClient.get(url, "user-agent" => opts[:ua])
          else
            RestClient.get(url, "user-agent" => ua)
          end
        when "post", :post
          if opts[:code] == "hnsc"
            RestClient.post(url, opts[:params], opts[:headers])
          elsif opts[:code] == "szzfcg"
            RestClient.post(url, opts[:params])
          else
            RestClient.post(url, opts[:params], {"cookie" => co, "referer" => re, "user-agent" => ua})
          end
        end
      html = if opts[:encoding]
        response.to_str.force_encoding(opts[:encoding]).to_utf8
      else
        response.to_str
      end

      doc = Nokogiri::HTML.parse(html)
    rescue Exception => e
      nil
    end
  end

  private
  #0 未变化
  #1 有新增
  #2 有更新
  #3 有错误
  def self.gen_attrs_log(lot_number, method_name, code, obj, attrs={})
    log_p(lot_number, method_name, code, "返回：#{attrs}")
    yield(obj)
    return 0 if method_name != "contents" && !obj.changed?

    #记录处理解析结果的日志
    @num += 1
    flag = 1
    new_record = obj.new_record?
    if obj.save
      new_record ? (@new_num+=1) : (@update_num+=1)
      flag = new_record ? 1 : 2
    else
      @error_num += 1
      @errors = obj.error_msgs
      flag = 3
    end
    if @errors.present?
      log_p(lot_number, method_name, code, "处理：#{attrs}失败，原因：#{@errors}")
      return 3
    end
    if new_record
      log_p(lot_number, method_name, code, "新增成功，id：#{obj.id}，attrs：#{attrs}，保存属性如下：#{obj.attributes}")
    end
    return flag
  end

  def self.log_p(lot_number, method_name, code, msg)
    msg = "【#{lot_number}】 —— 【#{code.classify}】.#{method_name}  #{msg}"
    begin
     @logger ||= Logger.new("log/ebook/snatch/#{Time.now.strftime("%Y%m%d")}.log")
     @logger.info msg
     puts msg
    rescue => e
     ExceptionNotifier.notify_exception(e) rescue nil
    end
  end
end