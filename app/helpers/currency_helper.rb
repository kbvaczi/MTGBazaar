module CurrencyHelper
  
  def display_currency(cents)
    return ("%0.2gx" % (cents / 100.0)).gsub(/\.?0+x$/,'x')
  end

end
