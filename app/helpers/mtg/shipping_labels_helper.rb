# encoding: UTF-8
# make this module available to be included in other areas by using "include Mtg::ShippingLabelsHelper"
module Mtg::ShippingLabelsHelper
  
  def display_add_on(addon)
    case addon
      when 'US-A-DC'
        'Delivery Confirmation'
      when 'SC-A-HP'
        'Hidden Postage'
      when 'US-A-CM'
        'Certified Mail'
      when 'US-A-SC'
        'Signature Confirmation'        
      when 'SC-A-INS'
        'Insurance'
    end
  end
  
end