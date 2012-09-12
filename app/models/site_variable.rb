class SiteVariable < ActiveRecord::Base

  validates_presence_of :name, :value
                      
  attr_accessible :name, :value, :active, :start_at, :end_at
  
  before_save :set_start_at!
  after_save :update_variable_cache!
  
  def set_start_at!
    self.start_at = Time.now unless self.start_at
  end
  
  def update_variable_cache!
    SiteVariable.where(:name => name, :active => true).order("start_at DESC").each do |v|
      if v.start_at < Time.now && (v.end_at == nil || v.end_at > Time.now)
        Rails.cache.write("site_variable_#{name}", v.value, :timeToLive => 30.minutes)
        break
      end
    end
    
  end
  
  def self.get(name = "")
    Rails.cache.fetch "site_variable_#{name}", :expires_in => 30.minutes do
      SiteVariable.where(:name => name, :active => true).order("start_at DESC").each do |v|
        if v.start_at < Time.now && (v.end_at == nil || v.end_at > Time.now)
          v.value.html_safe
          break
        end
      end
    end
    
  end
  
end

