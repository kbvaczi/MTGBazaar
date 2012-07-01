module ApplicationHelper

  def captcha_verified?
    return true if session[:captcha]
    return false
  end
  
  def title(page_title)
    provide :title, " | #{page_title}"
  end
  
  def capitalize_first_word(word)
    word.split(' ').map {|w| w.capitalize }.join(' ')
  end
  
  def back_path
    return session[:return_to]
  end
  
  def display_time(time)
    time.strftime("%d-%b %Y") 
  end
end
