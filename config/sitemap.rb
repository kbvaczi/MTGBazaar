# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host  = "http://www.MTGBazaar.com"
SitemapGenerator::Sitemap.sitemaps_host = "http://s3.amazonaws.com/mtgbazaar-public"
SitemapGenerator::Sitemap.public_path   = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.adapter       = SitemapGenerator::WaveAdapter.new

SitemapGenerator::Sitemap.create do
  
  # Basic Pages
  add contact_path,   :priority => 0.4
  add terms_path,     :priority => 0.4  
  add privacy_path,   :priority => 0.4
  add condition_path, :priority => 0.4
  add copyright_path, :priority => 0.4
  add faq_path,       :priority => 0.6
  add about_path,     :priority => 0.6

  # MTG Cards Links
  add mtg_cards_path
  Mtg::Set.active.find_each do |set|
    add mtg_cards_path(:set => set.code)
  end
  Mtg::Card.active.find_each do |card|
    add mtg_card_path(card)
  end
  
  # Seller Profiles
  User.active.find_each do |user|
    add user_path(user.username), :priority => 0.3
  end
  
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.zone.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  
end
