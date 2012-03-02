module ApplicationHelper
  
  def captcha_verified?
    return true if session[:captcha]
    return false
  end
  
  def title(page_title)
    content_for(:title) { page_title + " | " }
  end
  
  def capitalize_first_word(word)
    word.split(' ').map {|w| w.capitalize }.join(' ')
  end
  
end
