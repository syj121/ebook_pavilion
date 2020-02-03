module FormHelper

  def new_checkbox(f, arrs, opts={})
    label_name  = opts[:label_name]

    input_block = lambda { |ib| 

    }

    %Q|
      <div class="layui-form-item">
        <label class="layui-form-label"><span class="x-red">*</span>#{label_name}</label>
        <div class="layui-input-block">
          
        </div>
      </div>
    |.html_safe
  end

end