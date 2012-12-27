# encoding: UTF-8
# make this module available to be included in other areas by using "include Mtg::TransactionsHelper"
module Mtg::TransactionsHelper

  def display_shipping_type(transaction)    
    if transaction.shipping_options[:shipping_type] == 'pickup'
      'In-Store Pickup'
    elsif transaction.shipping_options[:shipping_type] == 'usps'
      shipping_params = Mtg::Transactions::ShippingLabel.calculate_shipping_parameters(:card_count => transaction.cards_quantity)
      case shipping_params[:service_type]
        when 'US-FC'
          'USPS First Class'
        when 'US-PM'
          if shipping_params[:package_type].include?('Flat Rate Box')
            'USPS' + shipping_params[:package_type]
          else
            'USPS Priority Class'
          end
        else
          "unknown"
      end
    else
      "unknown"
    end
  end
  
  def display_shipping_options(transaction)
    shipping_charges = transaction.shipping_options[:shipping_charges]
    if shipping_charges.present? && shipping_charges.length > 1
      display_string = ""
      separator      = ",<br/>"
      shipping_charges.each { |key, value| display_string += capitalize_first_letters(key.to_s.gsub('_',' ')) + separator unless key == :basic_shipping || value == nil }
      display_string[0..-(separator.length + 1)].html_safe
    else  
      'none'
    end
  end  
  
  def display_ship_date(transaction)
    if transaction.seller_shipped_at.present?
      display_time(@transaction.seller_shipped_at)
    elsif transaction.shipping_options[:shipping_type] == 'pickup'
      'N/A'
    else
      'not shipped yet'
    end
  end
  
  def display_delivery_date(transaction)
    if transaction.seller_delivered_at.present? and transaction.status == 'delivered'
      display_time transaction.seller_delivered_at
    elsif not transaction.seller_shipped_at.present?
      if transaction.shipping_options[:shipping_type] == 'pickup'
        'awaiting pickup'
      else
        'not shipped yet'
      end
    else
      'in transit'
    end
  end
  
  def shipment_trackable?(transaction)
    if transaction.shipping_options[:shipping_type] == 'pickup'
      return false
    end
    return true
  end


end