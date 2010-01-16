class Payment < ActiveRecord::Base
  
  acts_as_restfulie
  
  media_type 'application/vnd.restbucks+xml'
  
  belongs_to :order
  
  def initialize(hash = {})
    super(hash)
    self.payment_date = Time.now unless self.payment_date
  end
  
end
