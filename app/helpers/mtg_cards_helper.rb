module MtgCardsHelper
  
  def display_name (name)
    name.truncate(30, :omission => "...")
  end
  
  # Converts mana string to a series of corresponding image links to be displayed
  def display_mana (mana_string)
    mana_string.gsub(/[{](?<var>[a-zA-Z0-9]+)[}]/, '<img alt=\'mana_\k<var>\' src=\'/assets/mtg/mana_symbols/mana\k<var>.jpg\' height=\'15px\' width=\'15px\'>').html_safe    
  end
end
