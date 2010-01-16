require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

context Restfulie do
  
  # how to process an order
  #
  # order = create_order
  # order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost), :method => :post)
  # sleep 20
  # order.self.retrieve(:method => :delete)
  # receipt = order.self.receipt

  def new_order(where)
    {:location => where, :items => [
                {:drink => "latte", :milk => "DOUBLE", :size => "LARGE"},
                {:drink => "latte", :milk => "DOUBLE", :size => "SMALL"}
                    ]}.to_xml(:root => "order")
  end

  def payment(value)
    {:amount => value, :cardholder_name => "Guilherme Silveira", :card_number => "4004", :expiry_month => 10, :expiry_year => 12}.to_xml(:root => "payment")
  end
  
  def create_order(where = "TO_TAKE")
    Restfulie.at('http://localhost:3000/orders').as('application/vnd.restbucks+xml').create(new_order(where))
  end
      
  # it "should cancel an order and delete it from the database" do
  #   order = create_order
  #   order.web_response.is_successful?.should be_true
  #   cancelled = order.cancel
  #   cancelled.web_response.should be_is_successful
  #   order.self.web_response.code.should == "404"
  # end
  
  # it "should update an order while possible" do
  #   order = create_order
  #   order = order.update(new_order("EAT_IN"), :method => :put)
  #   order.web_response.is_successful?.should be_true
  #   order.location.should == "EAT_IN"
  # end
  # 
  it "should complain if partially paying" do
    order = create_order
    order.request.as('application/vnd.restbucks+xml').pay(payment(1)).web_response.code.should == "400"
  end  
  
  it "should allow to pay" do
    order = create_order
    order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost)).web_response.code.should == "200"
    order = order.self
    order.web_response.code.should == "200"
    order.status.should == "preparing"
  end
  #   
  #   it "should not allow cancel an order if already paid" do
  #     order = create_order
  #     order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost))
  #     order.cancel.web_response.code.should == "405"
  #   end
  #   
  #   it "should not allow to pay twice" do
  #     order = create_order
  #     order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost))
  #     order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost)).web_response.code.should == "405"
  #   end
  #     
  #   it "should allow to take out and receive receipt" do
  #     order = create_order
  #     order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost), :method => :post)
  #     sleep 20
  #     order = order.self
  #     order.status.should == "ready"
  #     order.retrieve(:method => :delete)
  #     order = order.self
  #     order.status.should == "delivered"
  #     receipt = order.receipt
  #     receipt.amount.should == "20.0"
  #   end
  #   
  #   it "should work with twitter" do
  #     statuses = Restfulie.at("http://twitter.com/statuses/public_timeline.xml").get
  #     statuses.each do |status|
  #       puts "#{status.user.screen_name}: #{status.text}, #{status.created_at}"
  #     end
  #   end

end
