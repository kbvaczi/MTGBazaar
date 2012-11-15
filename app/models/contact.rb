class Contact
  include ActiveModel::Validations


  validates_presence_of :support_type, :content 
  
  validates :sender_name,   :presence => true, 
                            :length => {:maximum => 30}

  validates :email,         :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}
                    
  # to deal with form, you must have an id attribute
  attr_accessor :id, :email, :sender_name, :support_type, :content, :ip, :username, :city, :state, :country

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
    @attributes = attributes
  end

  def read_attribute_for_validation(key)
    @attributes[key]
  end

  def to_key; end

  def save
    if self.valid?
      #self.username = User.find(session["warden.user.user.key"][1]).first rescue nil
      ContactMailer.send_mail(self).deliver
      return true
    end
    return false
  end
  
end