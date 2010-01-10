require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

context Restfulie do

  def new_order
    {:location => "TO_TAKE", :items => [
                {:drink => "latte", :milk => "DOUBLE", :size => "LARGE"},
                {:drink => "latte", :milk => "DOUBLE", :size => "SMALL"}
                    ]}.to_xml(:root => "order")
  end

  def payment(value)
    {:amount => value, :cardholder_name => "Guilherme Silveira", :card_number => "4004", :expiry_month => 10, :expiry_year => 12}.to_xml(:root => "payment")
  end
  
  def create_order
    Restfulie.at('http://localhost:3000/orders').as('application/vnd.restbucks+xml').create(new_order)
  end
    
  it "should cancel an order and delete it from the database" do
    order = create_order
    order.web_response.is_successful?.should be_true
    cancelled = order.cancel
    cancelled.web_response.is_successful?.should be_true
    order.self.web_response.code.should eql("404")
  end
  
  it "should complain if partially paying" do
    order = create_order
    order.request.as('application/vnd.restbucks+xml').pay(payment(1)).web_response.code.should eql("400")
  end  
  
  it "should allow to pay" do
    order = create_order
    order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost)).web_response.code.should eql("200")
    order.self.status.should eql("preparing")
  end
  
  it "should not allow cancel an order if already paid" do
    order = create_order
    order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost)).web_response.code.should eql("200")
    order.cancel.web_response.code.should eql("405")
  end
  
  it "should not allow to pay twice" do
    order = create_order
    order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost)).web_response.code.should eql("200")
    order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost)).web_response.code.should eql("405")
  end
    
  it "should allow to take out and receive receipt" do
    order = create_order
    order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost), :method => :post).web_response.code.should eql("200")
    sleep 20
    order = order.self
    order.status.should eql("ready")
    order.retrieve(:method => :delete)
    order = order.self
    order.status.should eql("delivered")
    receipt = order.receipt
    receipt.amount.should eql("10.0")
  end

end
