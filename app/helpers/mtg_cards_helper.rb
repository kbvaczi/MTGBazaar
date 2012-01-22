module MtgCardsHelper
  
  # Converts mana string to a series of corresponding image links to be displayed
  def display_mana (mana_string)
    mana_string.gsub(/[{](?<var>[a-zA-Z0-9]+)[}]/, '\k<var>')
    
  end
end
