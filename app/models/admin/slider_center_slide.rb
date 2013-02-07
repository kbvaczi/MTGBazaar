class Admin::SliderCenterSlide < ActiveRecord::Base

  self.table_name = 'admin_slider_center_slides'  

  mount_uploader :image,  SliderCenterImageUploader
  
  validates_presence_of  :image, :title, :link, :link_type
  
  after_commit :clear_view_cache
  before_save  :push_down_other_slides
  
  def clear_view_cache
    Rails.cache.clear "#{Admin::SliderCenterSlide.cache_key}"
  end
  
  def push_down_other_slides
    other_slide = Admin::SliderCenterSlide.where(:slide_number => self.slide_number).first
    if other_slide.present?
      if other_slide.slide_number < 5
        other_slide.slide_number += 1
      else
        other_slide.slide_number = nil
      end
      other_slide.save
    end
  end
  
  def self.viewable
    Admin::SliderCenterSlide.where("slide_number IS NOT NULL")
                            .order('slide_number DESC')
                            .limit(5)
  end

  def self.cache_key
    'content_center_slider'
  end

end
