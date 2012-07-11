# encoding: UTF-8
# make this module available to be included in other areas by using "include Mtg::CardsHelper"
module Mtg::CardsHelper

  ARTIST_LIST = Array.new(["Aaron Boyd", "Adam Paquette", "Adam Rex", "Adi Granov", "Adrian Smith", "Ai Desheng", "Al Davidson", "Alan Pollack", "Alan Rabinowitz", "Aleksi Briclot", "Alex Horley-Orlandelli", "Allan Pollack", "Allen Williams", "Alton Lawson", "Amy Weber", "Amy Weberänerstrand", "Andi Rusu", "Andrew Goldhawk", "Andrew Murray", "Andrew Robinson", "Anson Maddocks", "Anthony Francisco", "Anthony Jones", "Anthony Palumbo", "Anthony S. Waters", "Anthony Waters", "April Lee", "Ariel Olivetti", "Arnie Swekel", "Ash Wood", "Austin Hsu", "Ben Thompson", "Ben Wootten", "Berry", 
                "Bill Sienkiewicz", "Blackie del Rio", "Bob Eggleton", "Bob Petillo", "Brad Rigney", "Brad Williams", "Bradley Williams", "Brandon Dorman", "Brandon Kitkouski", "Brian Despain", "Brian Durfee", "Brian Hagan", "Brian Horton", "Brian Snoddy", "Brom", "Bryan Talbot", "Bryon Wackwitz", "Bud Cook", "Cai Tingting", "Cara Mitten", "Carl Critchlow", "Carl Frank", "Carol Heyer", "Cecil Fernando", "Charles Gillespie", "Charles Urbach", "Chen Weidong", "Chengo McFlingers", "Chippy", "Chris Appelhans", "Chris Dien", "Chris J. Anderson", "Chris Rahn", "Christoper Rush", 
                "Christopher Moeller", "Christopher Rush", "Chuck Lukacs", "Ciruelo", "Claymore J. Flapdoodle", "Cliff Childs", "Cliff Nielsen", "Clint Cearley", "Clint Langley", "Clyde Caldwell", "Cole Eastburn", "Colin MacNeil", "Corey D. Macourek", "Cornelius Brudi", "Cos Koniotis", "Craig Hooper", "Craig Mullins", "Cris Dornaus", "Cynthia Sheppard", "Cyril Van Der Haegen", "D. Alexander Gregory", "D. J. Cleland-Hura", "Daarken", "Dameon Willich", "Dan Dos Santos", "Dan Frazier", "Dan Scott", "Dan Seagrave", "Dana Knutson", "Daniel Gelon", "Daniel Ljunggren", "Daniel R. Horne", 
                "Dany Orizio", "Darbury Stenderu", "Daren Bader", "Darrell Riche", "Dave Allsop", "Dave DeVries", "Dave Dorman", "Dave Kendall", "Dave Seeley", "DavidMartin", "David A. Cherry", "David Day", "David Ho", "David Horne", "David Hudnut", "David Martin", "David Monette", "David O'Connor", "David Palumbo", "David Rapoza", "David Seeley", "Dennis Detwiller", "Dermot Power", "DiTerlizzi", "Diana Vick", "Diane Vick", "Ding Songjian", "Dom", "Dom!", "Dominick Domingo", "Don Hazeltine", "Don Thompson", "Donato Giancola", "Doug Chaffee", "Doug Keith", "Douglas Schuler", "Douglas Shuler", 
                "Drew Baker", "Drew Tucker", "Dylan Martens", "E. M. Gist", "Edward Beard, Jr.", "Edward P.Beard, Jr.", "Edward P. Beard, Jr", "Edward P. Beard, Jr.", "Edward P. Beard, Jr.. Beard, Jr.", "Efrem Palacios", "Eric David Anderson", "Eric Deschamps", "Eric Fortune", "Eric Peterson", "Eric Polak", "Erica Gassalasca-Jape", "Erica Yang", "Esad Ribic", "Evkay Alkerway", "Eytan Zana", "Fang Yue", "Fay Jones", "Francis Tsai", "Frank Kelly Freas", "Franz Vohwinkel", "Fred Fields", "Fred Harper", "Fred Hooper", "Fred Rahmqvist", "G. Darrow. Rabarot", "Gao Jianzhang", "Gao Yan", 
                "Gary Gianni", "Gary Leach", "Gary Ruddell", "Geofrey Darrow", "George Pratt", "Gerry Grace", "Glen Angus", "Glenn Fabry", "Goran Josic", "Greg Staples", "Greg", "Greg Hildebrandt", "Greg Simanson", "Greg Spalenka", "Hannibal King", "Harold McNeill", "Hazeltine", "He Jiancheng", "Heather Hudson", "Henry G. Higgenbotham", "Henry Van Der Linde", "Hideaki Takamura", "Hiro Izawa", "Hiroshi Tanigawa", "Hong Yan", "Howard Lyon", "Huang Qishi", "Hugh Jamieson", "Iain McCaig", "Ian Edward Ameling", "Ian Miller", "Igor Kieryluk", "Inoue Junichi", "Ironbrush", "Ittoku", "Izzy", 
                "J. W. Frost", "Jack Wei", "Jacques Bredy", "Jaime Jones", "James Allen", "James Bernardin", "James Ernest", "James Kei", "James Paick", "James Ryman", "James Wong", "Jana Schirmer", "Janet Aulisio", "Janine Johnston", "Jarreau Wimberley", "Jarreau Wimberly", "Jason A. Engle", "Jason Alexander Behnke", "Jason Chan", "Jason Felix", "Jean-Sébastien Rossbach", "Jeff A. Menges", "Jeff Easley", "Jeff Laubenstein", "Jeff Miracola", "Jeff Nentrup", "Jeff Reitz", "Jeff Remmer", "Jeffrey R. Busch", "Jen Page", "Jennifer Law", "Jeremy Enecio", "Jeremy Jarvis", "Jerry Tiritilli", 
                "Jesper Ejsing", "Jesper Myrfors", "Ji Yong", "Jiaming", "Jiang Zhuqing", "JimPavelec", "Jim Murray", "Jim Nelson", "Jim Pavelec", "Jock", "Joel Biske", "Joel Thomas", "Johann Bodin", "John Avon", "John Bolton", "John Coulthart", "John Donahue", "John Gallagher", "John Howe", "John J. Muth", "John Malloy", "John Matson", "John Stanko", "John Zeleznik", "Jon Foster", "Jon J Muth", "Jon J. Muth", "Joshua Hagler", "Julie Baroh", "Jung Park", "Junichi Inoue", "Junior Tomlin", "Junko Taguchi", "Justin Hampton", "Justin Murray", "Justin Norman", "Justin Sweet", "Kaja", "Kaja Foglio", 
                "Kang Yu", "Kari Johnson", "Karl Kopinski", "Kathryn Rathke", "Keith Garletts", "Keith Parkinson", "Kekai Kotaki", "Ken Meyer Jr.", "Ken Meyer, Jr.", "Kensuke Okabayashi", "Kersten Kaman", "Kerstin Kaman", "Kev Brockschmidt", "Kev Walker", "Kevin Dobler", "Kevin McCann", "Kevin Murphy", "Kevin Walker", "Khang Le", "Kieran Yanner", "Kipling West", "Koji", "Kristen Bishop", "Ku Xueming", "Kuang Sheng", "Kunio Hagio", "L. A. Williams", "LHQ", "Larry Elmore", "Larry MacDougall", "Lars Grant-West", "Lars Grant-West", "Lawrence Snelly", "Li Tie", "Li Wang", "Li Xiaohua", "Li Youliang", 
                "Li Yousong", "Liam Sharp", "Lin Yan", "Liu Jianjian", "Liu Shangying", "Liz Danforth", "Lou Harrison", "Lubov", "Luca Zontini", "Lucas Graciano", "Lucio Parrillo", "Lucio Patrillo", "M. W. Kaluta", "Marc Fishman", "Marc Simonetti", "Marcelo Vignali", "Margaret Organ-Kean", "Mark A. Nelson", "Mark Brill", "Mark Evans", "Mark Harrison", "Mark Hyzer", "Mark It’s teh-DEEN Tedin", "Mark Nelson", "Mark Poole", "Mark Romanoski", "Mark Rosewater", "Mark Tedin", "Mark Zug", "Martin McKenna", "Martina Pilcerova", "Massimilano Frezzato", "Matt Cavotta", "Matt Stawicki", "Matt Steward", 
                "Matt Stewart", "Matt Thompson", "Matthew D. Wilson", "Matthew Mitchell", "Matthew Wilson", "Melissa A. Benson", "Melissa Benson", "Miao Aili", "Michael Bruinsma", "Michael C. Hayes", "Michael Danza", "Michael Koelsch", "Michael Komarck", "Michael Phillippi", "Michael Ryan", "Michael Sutfin", "Michael Weaver", "Michael Whelan", "Mike Bierek", "Mike Dringenberg", "Mike Kerr", "Mike Kimble", "Mike Ploog", "Mike Raabe", "Mike Sass", "Min Yum", "Mitch Cotie", "Mitsuaki Sagiri", "Monique Thirifay", "Monte Michael Moore", "Nathalie Hertz", "Nelson DeCastro", "Nic Klein", "Nick Percival", 
                "Nicola Leonard", "Nils Hamm", "Nils Hanim", "Nottsuo", "NéNé Thomas", "Okera", "Omaha Perez", "Omar Rayyan", "Orizio Daniele", "Paolo Parente", "Parente", "Pat Lee", "Pat Morrissey", "Patrick Beel", "Patrick Faricy", "Patrick Ho", "Patrick Kochakji", "Paul Bonner", "Paul Chadwick", "Paul Lee", "PeteVenters", "Pete Venters", "Peter Bollinger", "Peter Mohrbacher", "Phil Foglio", "Philip Straub", "Puddnhead", "Qi Baocheng", "Qiao Dafu", "Qin Jun", "Qu Xin", "Quan Xuejun", "Quinton Hoover", "Ralph Horsley", "Randis Albion", "Randy Asplund", "Randy Asplund-Faith", "Randy Elliott", 
                "Randy Gallegos", "Ray Lago", "Raymond Swanland", "Rebecca Guay", "Rebekah Lynn", "Richard Kane Ferguson", "Richard Sardinha", "Richard Thomas", "Richard Whitters", "Richard Wright", "Rick Emond", "Rick Farrell", "Rob Alexander", "Robert Bliss", "Robh Ruppel", "Robot Chicken", "Roger Raupp", "Rogério Vilela", "Romas", "Romas Kukalis", "Ron Spears", "Ron Brown", "Ron Chironna", "Ron Lemen", "Ron Spencer", "Ron Walotsky", "Ruth Thompson", "Ryan Pancoast", "Ryan Yee", "Sal Villagran", "Sam Burley", "Sam Wood", "Sandra Everingham", "Scott Altmann", "Scott Bailey", "Scott Chou", 
                "Scott Hampton", "Scott Kirschner", "Scott M. Fischer", "Sean McConnell", "Shang Huitong", "Shelly Wan", "Shishizaru", "Simon Bisley", "Slawomir Maniak", "Solomon Au Yeung", "Song Shikai", "Stephan Martiniere", "Stephanie Law", "Stephen Daniele", "Stephen L. Walsh", "Stephen Tappin", "Steve Argyle", "Steve Belledin", "Steve Ellis", "Steve Firchow", "Steve Luke", "Steve Prescott", "Steve White", "Steven Argyle", "Steven Belledin", "Steven White", "Stuart Griffin", "Sue Ellen Brown", "Sun Nan", "Susan Garfield", "Susan Van Camp", "Svetlin Velinov", "Syuichi Obata", "Tang Xiaogu", 
                "Ted Galaday", "Ted Naifeh", "Terese Nielsen", "Terry Springer", "Thomas Denmark", "Thomas Gianni", "Thomas M. Baxa", "Thomas Manning", "Tim Hildebrandt", "Todd Lockwood", "Tom Fleming", "Tom Kyffin", "Tom Wänerstrand", "Tom Wärnerstrand", "Tomas Giorello", "Tomasz Jedruszek", "Tony DiTerlizzi", "Tony Roberts", "Tony Szczudlo", "Trevor Claxton", "Trevor Hairsine", "Tristan Elwell", "Tsutomu Kawade", "Una Fricker", "Val Mayerik", "Vance Kovacs", "Vincent Evans", "Vincent Proce", "Volkan Baga", "Véronique Meignaud", "Wang Chuxiong", "Wang Feng", "Wang Yuqun", "Warren Mahy", 
                "WayneEngland", "Wayne England", "Wayne Reynolds", "Whit Brachna", "William Donohoe", "William O'Connor", "William Simpson", "Winona Nelson", "Xu Tan", "Xu Xiaoming", "Yang Guangmai", "Yang Hong", "Yang Jun Kwon", "Yeong-Hao Han", "Yokota Katsumi", "Z. Plucinski.A. Gregory", "Zak Plucinski", "Zhang Jiazhen", "Zhao Dafu", "Zhao Tan", "Zina Saunders", "Zoltan Boros", "jD", "rk post"]).sort!
  
  ABILITY_LIST = ['Absorb',	'Affinity',	'Amplify',	'Annihilator',	'Attach',	'Aura swap',	'Banding',	'Bands with other',	'Battle cry',	'Bloodthirst',	'Bury',	'Bushido',	'Buyback',	'Cascade',	'Champion',	'Changeling',	'Channel',	'Chroma',	'Clash',	'Conspire',	'Convoke',	'Counter',	'Cumulative upkeep',	'Cycling',	'Deathtouch',	'Defender',	'Delve',	'Devour',	'Domain',	'Double strike',	'Dredge',	'Echo',	'Enchant',	'Entwine',	'Epic',	'Equip',	'Evoke',	'Exalted',	'Exile',	'Fading',	'Fateful hour',	'Fateseal',	'Fear',	'Fight',	'First strike',	'Flanking',	'Flash',	'Flashback',
                  'Flip',	'Flying',	'Forecast',	'Fortify',	'Frenzy',	'Graft',	'Grandeur',	'Gravestorm',	'Haste',	'Haunt',	'Hellbent',	'Hexproof',	'Hideaway',	'Horsemanship',	'Imprint',	'Infect',	'Intimidate',	'Join forces',	'Kicker',	'Kinship',	'Landfall',	'Landhome',	'Landwalk',	'Level up',	'Lifelink',	'Living weapon',	'Madness',	'Metalcraft',	'Modular',	'Morbid',	'Morph',	'Multikicker',	'Ninjutsu',	'Offering',	'Persist',	'Phasing',	'Poisonous',	'Proliferate',	'Protection',	'Provoke',	'Prowl',	'Radiance',	'Rampage',	'Reach',	'Rebound',	'Recover',	'Regenerate',	'Reinforce',
                  'Replicate',	'Retrace',	'Ripple',	'Sacrifice',	'Scry',	'Shadow',	'Shroud',	'Soulshift',	'Splice',	'Split second',	'Storm',	'Substance',	'Sunburst',	'Suspend',	'Sweep',	'Tap/Untap',	'Threshold',	'Totem armor',	'Trample',	'Transfigure',	'Transform',	'Transmute',	'Typecycling',	'Undying',	'Unearth',	'Vanishing',	'Vigilance',	'Wither'].sort!
  
  def self.camelcase_to_spaced(word)
    word.gsub(/([A-Z])/, " \\1").strip
  end
  
  # display only first 30 characters of a name"
  def display_name(name)
    name.truncate(30, :omission => "...")
  end
  
  # display only first 30 characters of a name"
  def display_type(type, subtype)
    if subtype.length > 1
      "#{type} - #{subtype}"
    else
      "#{type}"
    end
  end  
  
  # Converts mana string to a series of corresponding image links to be displayed
  def display_symbols(string)
    if string.empty?
      return "None"
    else
      string.gsub(/[{]([a-zA-Z0-9]+)[}]/) do |letter| #find the pattern "{xy}" where xy are any letters or numbers
          letter = letter.gsub(/[{](.+)[}]/, '\1').downcase #strip the {} and lowercase the letters
          if letter == "t" #if the letters are t, create tap image
            image_tag('/assets/mtg/various_symbols/tap.jpg', :class => "mtg_symbol")         
          else #else the symbol must be a mana symbol, create corresponding mana symbol 
            image_tag("/assets/mtg/mana_symbols/mana_#{letter}.jpg", :class => "mtg_symbol")
          end
      end.html_safe
      #return_string = string
      #return_string = return_string.gsub(/[{][T][}]/, image_tag("/assets/mtg/various_symbols/tap.jpg")) # display tap symbol, overwrite string
      #return_string = return_string.gsub(/[{]([a-zA-Z0-9]+)[}]/, '<img alt=\'mana_\1\' src=\'/assets/mtg/mana_symbols/mana_\1.jpg\' class=\'mtg_symbol\'>') # display everything else
      #return return_string.html_safe # tells rails it's OK to render HTML tags
    end
  end
  
  def display_color(string)
    case string
      when /[a-zA-Z ]+[(]O[)] \/\/ [a-zA-Z ]+[(]O[)]/ # contains "XYZ (O) // XYZ (O)", XYZ is any letter combination/length
        return "Split / Gold"
      when /[(]O[)]/ # contains "(O)"
        return "Multicolor"
      when /[A]+/  # contains "A"
        return "Artifact"        
      when /[(]H[)]/ # contains "(H)"
        return "Hybrid"
      when /\/\// # contains "//"
        return "Split"
      when /L/ #contains "L"
        return "Land"        
      when /\AU\z/ #equals "U"
        return "Blue"
      when /\AB\z/ #equals "B"
        return "Black"
      when /\AW\z/ #equals "W"
        return "White"
      when /\AR\z/ #equals "R"
        return "Red"                        
      when /\AG\z/ #equals "G"
        return "Green"       
      when /\AS\z/ #equals "S"
        return "Scheme"        
      when /\AC\z/ #equals "C"
        return "Colorless"     
      when /\AP\z/ #equals "P"
        return "Plane"
      when /[a-zA-Z]{2}+/ #longer than 1 letter
        return "Multicolor"
      else return "Unknown"                   
    end
  end
  
  def display_rarity(string)
    case string
      when /C/ #contains "C" 
        return "Common"
      when /U/ #contains "U" 
        return "Uncommon"
      when /R/ #contains "R" 
        return "Rare"
      when /M/ #contains "M" 
        return "Mythic"
      when /T/ #contains "T" 
        return "Timeshifted"
      else return "Unknown"
    end
  end
  
  # defines an array containing all conditions for select boxes
  def condition_list
    Array.new([["Near Mint", "1"], ["Slightly Played", "2"], ["Moderately Played", "3"]])
  end
  
  def display_condition(string)
     case string
       when /1/ 
         return "NM"
       when /2/ 
         return "SP"
       when /3/ 
         return "MP"
       else return "Unknown"
     end
   end
     
  # Defines an array containing all the card types for select boxes
  def card_type_list
    Array.new(["Artifact", "Creature", "Enchantment", "Instant", "Interrupt", "Land", "Plane", "Planeswalker", "Scheme", "Sorcery", "Summon", "Tribal"])
  end
  
  # Defines an array containing all the card types for select boxes
  def card_subtype_list
    Array.new(["Ajani", "Alara", "Angel", "Angel Horror", "Angel Spirit", "Angel Warrior", "Anteater Beast", "Antelope", "Antelope Beast", "Ape", "Ape Berserker", "Ape Shaman", "Ape Spirit", "Ape Warrior", "Arcane", "Archon", "Arkhos", "Artificer", "Assembly-Worker", "Atog", "Aura", "Aura Curse", "Aurochs", "Avatar", "Avatar Incarnation", "Avatar Praetor", "Badger", "Badger Beast", "Barbarian Zombie", "Basilisk", "Basilisk Mutant", "Bat", "Bear", "Bear Illusion", "Bear Spirit", "Beast", "Beast Mutant", "Beast Warrior", "Beeble", "Berserker", "Bird", "Bird Ally", "Bird Beast", "Bird Cleric", "Bird Horror", "Bird Mercenary", "Bird Rebel Soldier", "Bird Scout", "Bird Shaman", "Bird Skeleton", "Bird Soldier", "Bird Soldier Archer", "Bird Soldier Horror", "Bird Soldier Spirit", "Bird Soldier Warrior", "Bird Soldier Wizard", "Bird Spirit", "Bird Warrior", "Bird Wizard", "Boar", "Boar Beast", "Boar Monger", "Bolas", "Bolas’s Meditation Realm", "Bringer", "Brushwagg", "Camel", "Camel Beast", "Carrier", "Cat", "Cat Ally", "Cat Beast", "Cat Beast Spirit", "Cat Beast Warrior", "Cat Cleric", "Cat Giant", "Cat Knight", "Cat Monk", "Cat Rebel", "Cat Scout", "Cat Soldier", "Cat Spirit", "Cat Warrior", "Cat Wizard", "Centaur", "Centaur Archer", "Centaur Berserker", "Centaur Druid", "Centaur Druid Scout Archer", "Centaur Horror", "Centaur Shaman", "Centaur Spellshaper", "Centaur Spirit", "Centaur Warrior", "Cephalid", "Cephalid Rogue", "Cephalid Wizard", "Cephalid Wizard Scout", "Chandra", "Chicken", "Chicken Construct", "Chimera", "Clamfolk", "Cleric", "Cleric Avatar", "Cleric Knight", "Cockatrice", "Construct", "Cow", "Crab", "Crab Beast", "Crocodile", "Crocodile Skeleton", "Cyclops", "Cyclops Giant", "Cyclops Warrior", "Dauthi Horror", "Dauthi Hound", "Dauthi Knight Mercenary", "Dauthi Minion", "Dauthi Soldier", "Dauthi Zombie", "Demon", "Demon Beast", "Demon Child", "Demon Dragon", "Demon Hound", "Demon Illusion", "Demon Minion", "Demon Spirit", "Desert", "Devil", "Dinosaur", "Djinn", "Dominaria", "Donkey Barbarian", "Donkey Lord", "Donkey Shaman", "Donkey Townsfolk", "Donkey Wizard", "Donkey Zombie", "Dragon", "Dragon Avatar", "Dragon Illusion", "Dragon Skeleton", "Dragon Spirit", "Dragon Wizard", "Dragon Wurm", "Drake", "Dreadnought", "Drone", "Dryad", "Dryad Shaman", "Dryad Spellshaper", "Dwarf", "Dwarf Artificer", "Dwarf Barbarian", "Dwarf Berserker", "Dwarf Nomad", "Dwarf Shaman", "Dwarf Soldier", "Dwarf Warrior", "Dwarf Wizard", "Efreet", "Egg", "Elder Dragon", "Eldrazi", "Eldrazi Aura", "Eldrazi Drone", "Elemental", "Elemental Beast", "Elemental Berserker", "Elemental Bird", "Elemental Boar", "Elemental Boar Beast", "Elemental Cat", "Elemental Horror", "Elemental Horse", "Elemental Hound", "Elemental Incarnation", "Elemental Insect", "Elemental Knight", "Elemental Lizard", "Elemental Minion", "Elemental Mutant", "Elemental Ox", "Elemental Ox Beast", "Elemental Rogue", "Elemental Scout", "Elemental Serpent", "Elemental Shaman", "Elemental Shapeshifter", "Elemental Skeleton", "Elemental Spellshaper", "Elemental Spirit", "Elemental Warrior", "Elemental Warrior Shaman", "Elephant", "Elephant Cleric", "Elephant Monk", "Elephant Rogue", "Elephant Soldier", "Elephant Townsfolk", "Elephant Wizard", "Elephant Wurm", "Elf", "Elf Archer", "Elf Archer Ally", "Elf Artificer", "Elf Assassin", "Elf Avatar", "Elf Barbarian", "Elf Berserker", "Elf Cleric", "Elf Cleric Druid", "Elf Druid", "Elf Druid Archer", "Elf Druid Scout", "Elf Druid Shaman", "Elf Druid Warrior", "Elf Knight", "Elf Merfolk", "Elf Mutant", "Elf Nomad", "Elf Rogue", "Elf Rogue Ally", "Elf Scout", "Elf Scout Ally", "Elf Shaman", "Elf Shaman Ally", "Elf Soldier", "Elf Spellshaper", "Elf Spirit", "Elf Warrior", "Elf Warrior Druid", "Elf Warrior Scout", "Elf Warrior Shaman", "Elf Wizard", "Elf Wizard Shaman", "Elk", "Elk Beast", "Elspeth", "Elves", "Equilor", "Equipment", "Eye", "Faerie", "Faerie Artificer", "Faerie Assassin", "Faerie Druid", "Faerie Knight", "Faerie Rogue", "Faerie Scout", "Faerie Soldier", "Faerie Spellshaper", "Faerie Wizard", "Ferret", "Fish", "Fish Beast", "Forest", "Forest Dryad", "Forest Island", "Forest Plains", "Fortification", "Fox", "Fox Cleric", "Fox Monk", "Fox Samurai", "Fox Wizard", "Frog", "Frog Beast", "Frog Mutant", "Fungus", "Fungus Beast", "Fungus Demon", "Fungus Elemental", "Fungus Lizard", "Fungus Shaman", "Fungus Sliver", "Fungus Snake", "Fungus Wall", "Gargoyle", "Garruk", "Giant", "Giant Berserker", "Giant Cleric", "Giant Druid", "Giant Minion", "Giant Rogue", "Giant Scout", "Giant Shaman", "Giant Soldier", "Giant Warrior", "Giant Wizard", "Gideon", "Gnome", "Goat", "Goat Beast", "Goblin", "Goblin Advisor", "Goblin Artificer", "Goblin Artificer Ally", "Goblin Assassin", "Goblin Avatar", "Goblin Berserker", "Goblin Knight", "Goblin Mercenary", "Goblin Mime", "Goblin Mutant", "Goblin Rigger", "Goblin Rogue", "Goblin Rogue Shaman", "Goblin Scout", "Goblin Shaman", "Goblin Soldier", "Goblin Spellshaper", "Goblin Waiter", "Goblin Warrior", "Goblin Warrior Ally", "Goblin Warrior Shaman", "Goblin Wizard", "Goblin Zombie", "Goblins", "Golem", "Golem Construct", "Golem Warrior", "Gorgon", "Gorgon Wizard", "Gremlin", "Griffin", "Gus", "Hag", "Hag Shaman", "Hag Wizard", "Harpy Beast", "Harpy Mercenary", "Hellion", "Hellion Beast", "Hellion Hydra", "Hippo", "Hippogriff", "Homarid", "Homarid Drone", "Homarid Shaman", "Homarid Warrior", "Homunculus", "Homunculus Illusion", "Horror", "Horror Mercenary", "Horror Spellshaper", "Horror Spirit", "Horse", "Horse Rebel", "Hound", "Hound Spirit", "Human", "Human Advisor", "Human Advisor Mutant", "Human Advisor Werewolf", "Human Archer", "Human Archer Minion", "Human Archer Werewolf", "Human Artificer", "Human Assassin", "Human Barbarian", "Human Barbarian Beast", "Human Barbarian Horror", "Human Barbarian Shaman", "Human Barbarian Soldier", "Human Barbarian Warrior", "Human Bear Druid", "Human Beast Soldier", "Human Berserker", "Human Berserker Ally", "Human Bird", "Human Bureaucrat", "Human Child", "Human Cleric", "Human Cleric Ally", "Human Cleric Archer", "Human Cleric Avatar", "Human Cleric Druid", "Human Cleric Knight", "Human Cleric Mercenary", "Human Cleric Minion", "Human Cleric Mutant", "Human Cleric Shaman", "Human Cleric Soldier", "Human Cleric Wizard", "Human Designer", "Human Druid", "Human Druid Ally", "Human Druid Knight", "Human Druid Shaman", "Human Druid Warrior", "Human Druid Wizard", "Human Flagbearer", "Human Gamer", "Human Hero", "Human Horror", "Human Insect", "Human Knight", "Human Knight Ally", "Human Mercenary", "Human Mercenary Assassin", "Human Mercenary Knight", "Human Mercenary Rebel", "Human Minion", "Human Monger", "Human Monk", "Human Monk Cleric", "Human Mutant", "Human Mystic", "Human Nightmare Barbarian", "Human Ninja", "Human Nomad", "Human Nomad Cleric", "Human Nomad Horror", "Human Nomad Mystic", "Human Pirate", "Human Pirate Scout", "Human Pirate Warrior", "Human Pirate Wizard", "Human Rat Minion", "Human Rebel", "Human Rebel Assassin", "Human Rebel Cleric", "Human Rebel Knight", "Human Rebel Mercenary", "Human Rebel Rogue", "Human Rebel Scout", "Human Rebel Warrior", "Human Rogue", "Human Rogue Ally", "Human Rogue Mercenary", "Human Rogue Rigger", "Human Rogue Werewolf", "Human Samurai", "Human Samurai Archer", "Human Scout", "Human Shaman", "Human Shaman Ally", "Human Shaman Werewolf", "Human Soldier", "Human Soldier Ally", "Human Soldier Archer", "Human Soldier Assassin", "Human Soldier Berserker", "Human Soldier Knight", "Human Soldier Rebel", "Human Soldier Rogue", "Human Soldier Scout", "Human Soldier Warrior", "Human Spellshaper", "Human Spellshaper Assassin", "Human Spellshaper Warrior", "Human Warrior", "Human Warrior Ally", "Human Warrior Werewolf", "Human Werewolf", "Human Wizard", "Human Wizard Ally", "Human Wizard Artificer", "Human Wizard Mutant", "Hydra", "Hydra Avatar", "Hydra Beast", "Hyena", "Igpay", "Illusion", "Illusion Beast", "Illusion Dragon", "Illusion Horse", "Illusion Hound", "Illusion Mutant", "Illusion Sliver", "Illusion Spirit", "Illusion Wall", "Illusion Warrior", "Imp", "Imp Rebel", "Incarnation", "Insect", "Insect Beast", "Insect Druid", "Insect Druid Mutant", "Insect Horror", "Insect Monk Cleric", "Insect Shade", "Insect Shaman", "Insect Spirit", "Insect Wizard", "Insect Worm", "Iquatana", "Ir", "Island", "Island Mountain", "Island Swamp", "Jace", "Jellyfish", "Jellyfish Beast", "Juggernaut", "Kaldheim", "Kamigawa", "Karn", "Kavu", "Kavu Scout", "Kirin Spirit", "Kithkin", "Kithkin Advisor", "Kithkin Archer", "Kithkin Cleric", "Kithkin Knight", "Kithkin Rebel", "Kithkin Rebel Scout", "Kithkin Rogue", "Kithkin Scout", "Kithkin Soldier", "Kithkin Soldier Wizard", "Kithkin Spellshaper", "Kithkin Wizard", "Knight", "Kobold", "Kobold Soldier", "Kor Artificer", "Kor Cleric", "Kor Cleric Ally", "Kor Knight", "Kor Monk", "Kor Nomad Soldier", "Kor Rebel", "Kor Rebel Knight", "Kor Rogue", "Kor Rogue Minion", "Kor Scout", "Kor Shaman Cleric", "Kor Soldier", "Kor Soldier Ally", "Kor Spirit", "Kor Warrior Knight", "Kor Wizard", "Koth", "Kraken", "Lady of Proper Etiquette", "Lair", "Lammasu", "Leech", "Legend", "Leviathan", "Leviathan Horror", "Lhurgoyf", "Licid", "Liliana", "Lizard", "Lizard Beast", "Lizard Horror", "Lizard Mercenary", "Lizard Warrior", "Locus", "Lorwyn", "Manticore", "Masticore", "Mercadia", "Merfolk", "Merfolk Archer", "Merfolk Assassin", "Merfolk Cleric", "Merfolk Goblin", "Merfolk Knight", "Merfolk Rogue", "Merfolk Rogue Warrior", "Merfolk Scout", "Merfolk Shaman", "Merfolk Soldier", "Merfolk Spellshaper", "Merfolk Warrior", "Merfolk Wizard", "Merfolk Wizard Ally", "Merfolk Zombie", "Metathran", "Metathran Soldier", "Metathran Wizard", "Metathran Zombie", "Minion", "Minotaur", "Minotaur Berserker", "Minotaur Monger", "Minotaur Monk", "Minotaur Scout", "Minotaur Shaman", "Minotaur Soldier", "Minotaur Spirit", "Minotaur Warrior", "Minotaur Warrior Ally", "Minotaur Wizard", "Mirrodin", "Moag", "Monger", "Mongoose", "Moonfolk Monk", "Moonfolk Rogue", "Moonfolk Wizard", "Mountain", "Mountain Forest", "Mountain Plains", "Mummy", "Muraganda", "Myr", "Myr Construct", "Nautilus Beast", "Nephilim", "Nightmare Beast", "Nightmare Crab", "Nightmare Dragon", "Nightmare Drake", "Nightmare Fish Beast", "Nightmare Horror", "Nightmare Horse", "Nightmare Orgg", "Nightmare Salamander Beast", "Nightmare Turtle Beast", "Nightstalker", "Nightstalker Cat", "Nissa", "Noggle Rogue", "Noggle Wizard", "Nomad Giant", "Octopus", "Ogre", "Ogre Berserker", "Ogre Monk", "Ogre Mutant", "Ogre Rebel", "Ogre Rogue", "Ogre Samurai Mercenary", "Ogre Samurai Shaman", "Ogre Shaman", "Ogre Shaman Ally", "Ogre Warrior", "Ogre Warrior Shaman", "Ogre Wizard", "Ooze", "Ooze Mutant", "Orc", "Orc Cleric", "Orc Paratrooper", "Orc Rogue", "Orc Scout", "Orc Shaman", "Orc Warrior", "Orgg", "Ouphe", "Ouphe Rogue", "Ox", "Oyster", "Pegasus", "Pest", "Phelddagrif", "Phoenix", "Phyrexia", "Plains", "Plains Island", "Plains Swamp", "Plant", "Plant Elemental", "Plant Elephant", "Plant Fungus", "Plant Hound", "Plant Hydra", "Plant Mutant", "Plant Wall", "Plant Zombie", "Praetor", "Rabbit", "Rabbit Beast", "Rabiah", "Rat", "Rat Ninja", "Rat Rogue", "Rat Samurai", "Rat Shaman", "Rat Warrior", "Rath", "Ravnica", "Rebel Aura", "Rebel Bird", "Rhino", "Rhino Beast", "Rhino Monk", "Rhino Monk Soldier", "Rhino Soldier", "Rhino Warrior", "Rogue", "Rogue Equipment", "Salamander", "Salamander Rogue", "Sarkhan", "Satyr", "Satyr Beast", "Scarecrow", "Scarecrow Soldier", "Scorpion", "Segovia", "Serpent", "Serra’s Realm", "Shade", "Shade Horror", "Shade Knight", "Shade Spirit", "Shadowmoor", "Shaman", "Shaman Equipment", "Shandalar", "Shapeshifter", "Shapeshifter Ally", "Shapeshifter Spirit", "Sheep", "Ship", "Shrine", "Siren", "Skeleton", "Skeleton Troll", "Skeleton Wall", "Skeleton Warrior", "Skeleton Wizard", "Skeleton Wurm", "Slith", "Sliver", "Sliver Mutant", "Sliver Spirit", "Slug", "Slug Beast", "Snake", "Snake Assassin", "Snake Elf Druid", "Snake Monk", "Snake Shaman", "Snake Shaman Scout", "Snake Skeleton", "Snake Wall", "Snake Warrior", "Snake Warrior Archer", "Soldier", "Soldier Equipment", "Soltari Cleric", "Soltari Knight", "Soltari Monk Cleric", "Soltari Soldier", "Sorin", "Spawn", "Specter", "Specter Spirit", "Spellshaper", "Sphinx", "Spider", "Spider Mutant", "Spike", "Spike Drone", "Spike Soldier", "Spirit", "Spirit Avatar", "Spirit Bear", "Spirit Bird", "Spirit Cleric", "Spirit Giant", "Spirit Horror", "Spirit Knight", "Spirit Minion", "Spirit Nomad", "Spirit Soldier", "Spirit Spellshaper", "Spirit Wall", "Sponge", "Squid Beast", "Squirrel", "Squirrel Beast", "Starfish", "Surrakar", "Swamp", "Swamp Forest", "Swamp Mountain", "Tezzeret", "Thalakos", "Thalakos Illusion", "Thalakos Soldier", "Thalakos Soldier Scout", "Thalakos Wizard", "Thopter", "Thrull", "Thrull Cleric", "Thrull Wizard", "Trap", "Treefolk", "Treefolk Assassin", "Treefolk Aura", "Treefolk Cleric", "Treefolk Druid", "Treefolk Horror", "Treefolk Shaman", "Treefolk Warrior", "Troll", "Troll Cleric", "Troll Giant", "Troll Mutant", "Troll Shaman", "Troll Warrior", "Turtle", "Ulgrotha", "Unicorn", "Unicorn Monger", "Urza's", "Urza’s", "Urza’s Mine", "Urza’s Power-Plant", "Urza’s Tower", "Valla", "Vampire", "Vampire Assassin", "Vampire Cat", "Vampire Dragon", "Vampire Dwarf", "Vampire Hound", "Vampire Knight", "Vampire Rogue", "Vampire Scout", "Vampire Shade", "Vampire Shaman", "Vampire Skeleton", "Vampire Soldier", "Vampire Spirit", "Vampire Warrior", "Vampire Wizard", "Vedalken Artificer", "Vedalken Knight", "Vedalken Rogue", "Vedalken Scout", "Vedalken Wizard", "Vedalken Wizard Mutant", "Vedalken Zombie", "Venser", "Viashino", "Viashino Berserker", "Viashino Scout", "Viashino Shaman", "Viashino Skeleton", "Viashino Soldier", "Viashino Warrior", "Volver", "Wall", "Warrior", "Warrior Equipment", "Weird", "Werewolf", "Werewolf Minion", "Whale", "Wildfire", "Wizard", "Wizard Avatar", "Wizard Equipment", "Wolf", "Wolverine", "Wolverine Beast", "Wombat", "Worm", "Worm Beast", "Worm Horror", "Worm Mercenary", "Wraith", "Wurm", "Wurm Spirit", "Yeti", "Yeti Mutant", "Zendikar", "Zombie", "Zombie Assassin", "Zombie Avatar", "Zombie Barbarian", "Zombie Beast", "Zombie Berserker", "Zombie Bird", "Zombie Cat", "Zombie Centaur", "Zombie Cleric", "Zombie Crocodile", "Zombie Cyclops", "Zombie Dragon", "Zombie Drake", "Zombie Druid", "Zombie Dwarf", "Zombie Elemental", "Zombie Elf", "Zombie Frog Beast", "Zombie Fungus", "Zombie Gamer", "Zombie Giant", "Zombie Goblin", "Zombie Horror", "Zombie Hound", "Zombie Imp", "Zombie Insect", "Zombie Knight", "Zombie Leech", "Zombie Lizard", "Zombie Lizard Beast", "Zombie Mercenary", "Zombie Mercenary Assassin", "Zombie Minion", "Zombie Mutant", "Zombie Ogre", "Zombie Ogre Warrior", "Zombie Pirate", "Zombie Rat", "Zombie Scout", "Zombie Shaman", "Zombie Snake", "Zombie Soldier Warrior", "Zombie Spellshaper", "Zombie Spirit", "Zombie Warrior", "Zombie Wizard", "Zombie Wolf", "Zombie Wurm", "Zubera Spirit"])
  end  

  # lists all available rarities for select boxes
  def rarity_list
    Array.new([["Common","C"], ["Uncommon","U"], ["Rare","R"], ["Mythic","M"], ["Timeshifted","T"]])
  end
  
  # lists all available artists for select boxes
  def artist_list
    Array.new(["Aaron Boyd", "Adam Paquette", "Adam Rex", "Adi Granov", "Adrian Smith", "Ai Desheng", "Al Davidson", "Alan Pollack", "Alan Rabinowitz", "Aleksi Briclot", "Alex Horley-Orlandelli", "Allan Pollack", "Allen Williams", "Alton Lawson", "Amy Weber", "Amy Weberänerstrand", "Andi Rusu", "Andrew Goldhawk", "Andrew Murray", "Andrew Robinson", "Anson Maddocks", "Anthony Francisco", "Anthony Jones", "Anthony Palumbo", "Anthony S. Waters", "Anthony Waters", "April Lee", "Ariel Olivetti", "Arnie Swekel", "Ash Wood", "Austin Hsu", "Ben Thompson", "Ben Wootten", "Berry", "Bill Sienkiewicz", "Blackie del Rio", "Bob Eggleton", "Bob Petillo", "Brad Rigney", "Brad Williams", "Bradley Williams", "Brandon Dorman", "Brandon Kitkouski", "Brian Despain", "Brian Durfee", "Brian Hagan", "Brian Horton", "Brian Snoddy", "Brom", "Bryan Talbot", "Bryon Wackwitz", "Bud Cook", "Cai Tingting", "Cara Mitten", "Carl Critchlow", "Carl Frank", "Carol Heyer", "Cecil Fernando", "Charles Gillespie", "Charles Urbach", "Chen Weidong", "Chengo McFlingers", "Chippy", "Chris Appelhans", "Chris Dien", "Chris J. Anderson", "Chris Rahn", "Christoper Rush", "Christopher Moeller", "Christopher Rush", "Chuck Lukacs", "Ciruelo", "Claymore J. Flapdoodle", "Cliff Childs", "Cliff Nielsen", "Clint Cearley", "Clint Langley", "Clyde Caldwell", "Cole Eastburn", "Colin MacNeil", "Corey D. Macourek", "Cornelius Brudi", "Cos Koniotis", "Craig Hooper", "Craig Mullins", "Cris Dornaus", "Cynthia Sheppard", "Cyril Van Der Haegen", "D. Alexander Gregory", "D. J. Cleland-Hura", "Daarken", "Dameon Willich", "Dan Dos Santos", "Dan Frazier", "Dan Scott", "Dan Seagrave", "Dana Knutson", "Daniel Gelon", "Daniel Ljunggren", "Daniel R. Horne", "Dany Orizio", "Darbury Stenderu", "Daren Bader", "Darrell Riche", "Dave Allsop", "Dave DeVries", "Dave Dorman", "Dave Kendall", "Dave Seeley", "DavidMartin", "David A. Cherry", "David Day", "David Ho", "David Horne", "David Hudnut", "David Martin", "David Monette", "David O'Connor", "David Palumbo", "David Rapoza", "David Seeley", "Dennis Detwiller", "Dermot Power", "DiTerlizzi", "Diana Vick", "Diane Vick", "Ding Songjian", "Dom", "Dom!", "Dominick Domingo", "Don Hazeltine", "Don Thompson", "Donato Giancola", "Doug Chaffee", "Doug Keith", "Douglas Schuler", "Douglas Shuler", "Drew Baker", "Drew Tucker", "Dylan Martens", "E. M. Gist", "Edward Beard, Jr.", "Edward P.Beard, Jr.", "Edward P. Beard, Jr", "Edward P. Beard, Jr.", "Edward P. Beard, Jr.. Beard, Jr.", "Efrem Palacios", "Eric David Anderson", "Eric Deschamps", "Eric Fortune", "Eric Peterson", "Eric Polak", "Erica Gassalasca-Jape", "Erica Yang", "Esad Ribic", "Evkay Alkerway", "Eytan Zana", "Fang Yue", "Fay Jones", "Francis Tsai", "Frank Kelly Freas", "Franz Vohwinkel", "Fred Fields", "Fred Harper", "Fred Hooper", "Fred Rahmqvist", "G. Darrow. Rabarot", "Gao Jianzhang", "Gao Yan", "Gary Gianni", "Gary Leach", "Gary Ruddell", "Geofrey Darrow", "George Pratt", "Gerry Grace", "Glen Angus", "Glenn Fabry", "Goran Josic", "Greg Staples", "Greg", "Greg Hildebrandt", "Greg Simanson", "Greg Spalenka", "Hannibal King", "Harold McNeill", "Hazeltine", "He Jiancheng", "Heather Hudson", "Henry G. Higgenbotham", "Henry Van Der Linde", "Hideaki Takamura", "Hiro Izawa", "Hiroshi Tanigawa", "Hong Yan", "Howard Lyon", "Huang Qishi", "Hugh Jamieson", "Iain McCaig", "Ian Edward Ameling", "Ian Miller", "Igor Kieryluk", "Inoue Junichi", "Ironbrush", "Ittoku", "Izzy", "J. W. Frost", "Jack Wei", "Jacques Bredy", "Jaime Jones", "James Allen", "James Bernardin", "James Ernest", "James Kei", "James Paick", "James Ryman", "James Wong", "Jana Schirmer", "Janet Aulisio", "Janine Johnston", "Jarreau Wimberley", "Jarreau Wimberly", "Jason A. Engle", "Jason Alexander Behnke", "Jason Chan", "Jason Felix", "Jean-Sébastien Rossbach", "Jeff A. Menges", "Jeff Easley", "Jeff Laubenstein", "Jeff Miracola", "Jeff Nentrup", "Jeff Reitz", "Jeff Remmer", "Jeffrey R. Busch", "Jen Page", "Jennifer Law", "Jeremy Enecio", "Jeremy Jarvis", "Jerry Tiritilli", "Jesper Ejsing", "Jesper Myrfors", "Ji Yong", "Jiaming", "Jiang Zhuqing", "JimPavelec", "Jim Murray", "Jim Nelson", "Jim Pavelec", "Jock", "Joel Biske", "Joel Thomas", "Johann Bodin", "John Avon", "John Bolton", "John Coulthart", "John Donahue", "John Gallagher", "John Howe", "John J. Muth", "John Malloy", "John Matson", "John Stanko", "John Zeleznik", "Jon Foster", "Jon J Muth", "Jon J. Muth", "Joshua Hagler", "Julie Baroh", "Jung Park", "Junichi Inoue", "Junior Tomlin", "Junko Taguchi", "Justin Hampton", "Justin Murray", "Justin Norman", "Justin Sweet", "Kaja", "Kaja Foglio", "Kang Yu", "Kari Johnson", "Karl Kopinski", "Kathryn Rathke", "Keith Garletts", "Keith Parkinson", "Kekai Kotaki", "Ken Meyer Jr.", "Ken Meyer, Jr.", "Kensuke Okabayashi", "Kersten Kaman", "Kerstin Kaman", "Kev Brockschmidt", "Kev Walker", "Kevin Dobler", "Kevin McCann", "Kevin Murphy", "Kevin Walker", "Khang Le", "Kieran Yanner", "Kipling West", "Koji", "Kristen Bishop", "Ku Xueming", "Kuang Sheng", "Kunio Hagio", "L. A. Williams", "LHQ", "Larry Elmore", "Larry MacDougall", "Lars Grant-West", "Lars Grant-West", "Lawrence Snelly", "Li Tie", "Li Wang", "Li Xiaohua", "Li Youliang", "Li Yousong", "Liam Sharp", "Lin Yan", "Liu Jianjian", "Liu Shangying", "Liz Danforth", "Lou Harrison", "Lubov", "Luca Zontini", "Lucas Graciano", "Lucio Parrillo", "Lucio Patrillo", "M. W. Kaluta", "Marc Fishman", "Marc Simonetti", "Marcelo Vignali", "Margaret Organ-Kean", "Mark A. Nelson", "Mark Brill", "Mark Evans", "Mark Harrison", "Mark Hyzer", "Mark It’s teh-DEEN Tedin", "Mark Nelson", "Mark Poole", "Mark Romanoski", "Mark Rosewater", "Mark Tedin", "Mark Zug", "Martin McKenna", "Martina Pilcerova", "Massimilano Frezzato", "Matt Cavotta", "Matt Stawicki", "Matt Steward", "Matt Stewart", "Matt Thompson", "Matthew D. Wilson", "Matthew Mitchell", "Matthew Wilson", "Melissa A. Benson", "Melissa Benson", "Miao Aili", "Michael Bruinsma", "Michael C. Hayes", "Michael Danza", "Michael Koelsch", "Michael Komarck", "Michael Phillippi", "Michael Ryan", "Michael Sutfin", "Michael Weaver", "Michael Whelan", "Mike Bierek", "Mike Dringenberg", "Mike Kerr", "Mike Kimble", "Mike Ploog", "Mike Raabe", "Mike Sass", "Min Yum", "Mitch Cotie", "Mitsuaki Sagiri", "Monique Thirifay", "Monte Michael Moore", "Nathalie Hertz", "Nelson DeCastro", "Nic Klein", "Nick Percival", "Nicola Leonard", "Nils Hamm", "Nils Hanim", "Nottsuo", "NéNé Thomas", "Okera", "Omaha Perez", "Omar Rayyan", "Orizio Daniele", "Paolo Parente", "Parente", "Pat Lee", "Pat Morrissey", "Patrick Beel", "Patrick Faricy", "Patrick Ho", "Patrick Kochakji", "Paul Bonner", "Paul Chadwick", "Paul Lee", "PeteVenters", "Pete Venters", "Peter Bollinger", "Peter Mohrbacher", "Phil Foglio", "Philip Straub", "Puddnhead", "Qi Baocheng", "Qiao Dafu", "Qin Jun", "Qu Xin", "Quan Xuejun", "Quinton Hoover", "Ralph Horsley", "Randis Albion", "Randy Asplund", "Randy Asplund-Faith", "Randy Elliott", "Randy Gallegos", "Ray Lago", "Raymond Swanland", "Rebecca Guay", "Rebekah Lynn", "Richard Kane Ferguson", "Richard Sardinha", "Richard Thomas", "Richard Whitters", "Richard Wright", "Rick Emond", "Rick Farrell", "Rob Alexander", "Robert Bliss", "Robh Ruppel", "Robot Chicken", "Roger Raupp", "Rogério Vilela", "Romas", "Romas Kukalis", "Ron Spears", "Ron Brown", "Ron Chironna", "Ron Lemen", "Ron Spencer", "Ron Walotsky", "Ruth Thompson", "Ryan Pancoast", "Ryan Yee", "Sal Villagran", "Sam Burley", "Sam Wood", "Sandra Everingham", "Scott Altmann", "Scott Bailey", "Scott Chou", "Scott Hampton", "Scott Kirschner", "Scott M. Fischer", "Sean McConnell", "Shang Huitong", "Shelly Wan", "Shishizaru", "Simon Bisley", "Slawomir Maniak", "Solomon Au Yeung", "Song Shikai", "Stephan Martiniere", "Stephanie Law", "Stephen Daniele", "Stephen L. Walsh", "Stephen Tappin", "Steve Argyle", "Steve Belledin", "Steve Ellis", "Steve Firchow", "Steve Luke", "Steve Prescott", "Steve White", "Steven Argyle", "Steven Belledin", "Steven White", "Stuart Griffin", "Sue Ellen Brown", "Sun Nan", "Susan Garfield", "Susan Van Camp", "Svetlin Velinov", "Syuichi Obata", "Tang Xiaogu", "Ted Galaday", "Ted Naifeh", "Terese Nielsen", "Terry Springer", "Thomas Denmark", "Thomas Gianni", "Thomas M. Baxa", "Thomas Manning", "Tim Hildebrandt", "Todd Lockwood", "Tom Fleming", "Tom Kyffin", "Tom Wänerstrand", "Tom Wärnerstrand", "Tomas Giorello", "Tomasz Jedruszek", "Tony DiTerlizzi", "Tony Roberts", "Tony Szczudlo", "Trevor Claxton", "Trevor Hairsine", "Tristan Elwell", "Tsutomu Kawade", "Una Fricker", "Val Mayerik", "Vance Kovacs", "Vincent Evans", "Vincent Proce", "Volkan Baga", "Véronique Meignaud", "Wang Chuxiong", "Wang Feng", "Wang Yuqun", "Warren Mahy", "WayneEngland", "Wayne England", "Wayne Reynolds", "Whit Brachna", "William Donohoe", "William O'Connor", "William Simpson", "Winona Nelson", "Xu Tan", "Xu Xiaoming", "Yang Guangmai", "Yang Hong", "Yang Jun Kwon", "Yeong-Hao Han", "Yokota Katsumi", "Z. Plucinski.A. Gregory", "Zak Plucinski", "Zhang Jiazhen", "Zhao Dafu", "Zhao Tan", "Zina Saunders", "Zoltan Boros", "jD", "rk post"])
  end
  
  # lists all available languages for select boxes
  def language_list
    return [["English","EN"], ["Russian","RU"], ["French","FR"], ["Japanese","JN"], ["Chinese","CN"], ["Korean","KO"], ["German","GN"], ["Portuguese", "PG"], ["Spanish", "SP"], ["Italian", "IT"]]
  end
  
  def active_set_list
    sets = Mtg::Set.where(:active => true).order("release_date DESC").to_a
    return sets.collect(&:name).zip(sets.collect(&:code))
  end

  # displays set symbol for a given set code
  def display_set_symbol(set, options = {})
    if options[:width].present?
      dimension = "width:#{options[:width]}"
    else
      dimension = "height:#{options[:height] || "15px"}"
    end
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/set_symbols/#{set.code}.jpg", :title => "#{set.name}", :style => "#{dimension};vertical-align:bottom;padding-bottom:5px;")         
  end
  
  # displays set symbol for a given set code
  def display_flag_symbol(language_code, options = {})
    case language_code
      when "EN"
        language = "English"
      when "RU"
        language = "Russian"
      when "FR"
        language = "French"
      when "JN"
        language = "Japanese"
      when "CN"
        language = "Chinese"
      when "KO"
        language = "Korean"
      when "GN"
        language = "German"                              
      when "PG"
        language = "Portuguese"        
      when "SP"
        language = "Spanish"
      when "IT"
        language = "Italian"                
    end
    height = options[:height] || "20px"
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/flags/#{language.downcase}.png", :title => "#{language}", :style => "height:#{height};vertical-align:bottom;")         
  end  
  
  def listing_option_foil_icon
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/foil.png", :title => "Foil", :style => "float:left;height:20px;vertical-align:bottom;")         
  end

  def listing_option_altart_icon
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/alt.png", :title => "Alternate art", :style => "float:left;height:20px;vertical-align:bottom;")         
  end

  def listing_option_misprint_icon
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/miscut.png", :title => "Misprint", :style => "float:left;height:20px;vertical-align:bottom;")         
  end

  def listing_option_scan_icon(listing)
    link_to image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/scan.png", :title => "Click to view scan", :style => "float:left;height:20px;vertical-align:bottom;"), listing.scan_url, :target => "_blank"         
  end      

  def listing_option_signed_icon
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/signed.png", :title => "Signed by artist", :style => "float:left;height:20px;vertical-align:bottom;")         
  end  
  
  def listing_option_description_icon(listing)
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/description.png", :title => "Description: #{listing.description}", :style => "float:left;height:20px;vertical-align:bottom;")         
  end
  
end
