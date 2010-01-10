class Order < ActiveRecord::Base
  
  acts_as_restfulie do |order, t|
    t << [:self, {:action => :show}]
    t << [:cancel, {:action => :destroy}] if order.status=="unpaid"
    t << [:take, {:id => order}] if order.status=="ready"
    t << [:pay, {:action => :create, :controller => :payments, :order_id => order.id}] if order.status == "unpaid"
    t << [:receipt, {:order_id => order, :controller => :payments, :action => :receipt}] if order.status=="delivered"
  end
  
  def can_cancel?
    can? :cancel
  end
  
  media_type 'application/vnd.restbucks+xml'
  has_many :items
  has_one :payment
  
  def initialize(hash)
    super(hash)
    self.status = "unpaid" unless self.status
  end
  
  def to_xml(options = {})
    options[:include] = [:items, :payment]
    options[:methods] = [:cost]
    super(options)
  end
  
  def cost
    items.size * 10
  end
  
end
