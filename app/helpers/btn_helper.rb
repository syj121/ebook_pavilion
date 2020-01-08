module BtnHelper

  def search_form_btn
    "/background/all_shared/#{$settings.frame}/btn_search"
  end

  def form_btn(namespace="background")
    "/#{namespace}/all_shared/#{$settings.frame}/form_btn"
  end

end