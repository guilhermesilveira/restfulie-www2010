require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

context Restfulie do
  def payment(value)
    {:amount => value, :cardholder_name => "Guilherme Silveira", :card_number => "4004", :expiry_month => 10, :expiry_year => 12}.to_xml(:root => "payment")
  end

    # 
    # it "should cancel an order and delete it from the database" do
    #   order = {:location => "TO_TAKE", :items => [{:drink => "latte", :milk => "DOUBLE", :size => "LARGE"}]}
    #   content = order.to_xml(:root => "order")
    #   order = Restfulie.at('http://localhost:3000/orders').as('application/vnd.restbucks+xml').create(content)
    #   order.web_response.is_successful?.should be_true
    #   cancelled = order.cancel
    #   cancelled.web_response.is_successful?.should be_true
    #   order.self.web_response.code.should eql("404")
    # end
    # 
    # it "should pay partially an order complain" do
    #   order = {:location => "TO_TAKE", :items => [{:drink => "latte", :milk => "DOUBLE", :size => "LARGE"}]}
    #   content = order.to_xml(:root => "order")
    #   order = Restfulie.at('http://localhost:3000/orders').as('application/vnd.restbucks+xml').create(content)
    #   order.request.as('application/vnd.restbucks+xml').pay(payment(1)).web_response.code.should eql("400")
    # end
    # 
    # 
    # it "should allow to pay" do
    #   order = {:location => "TO_TAKE", :items => [{:drink => "latte", :milk => "DOUBLE", :size => "LARGE"}]}
    #   content = order.to_xml(:root => "order")
    #   order = Restfulie.at('http://localhost:3000/orders').as('application/vnd.restbucks+xml').create(content)
    #   order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost)).web_response.code.should eql("200")
    # end
    # 
    # it "should not allow cancel an order if already paid" do
    #   order = {:location => "TO_TAKE", :items => [{:drink => "latte", :milk => "DOUBLE", :size => "LARGE"}]}
    #   content = order.to_xml(:root => "order")
    #   order = Restfulie.at('http://localhost:3000/orders').as('application/vnd.restbucks+xml').create(content)
    #   order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost)).web_response.code.should eql("200")
    #   order.cancel.web_response.code.should eql("405")
    # end
    # 
    # 
    # it "should not allow to pay twice" do
    #   order = {:location => "TO_TAKE", :items => [{:drink => "latte", :milk => "DOUBLE", :size => "LARGE"}]}
    #   content = order.to_xml(:root => "order")
    #   order = Restfulie.at('http://localhost:3000/orders').as('application/vnd.restbucks+xml').create(content)
    #   order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost)).web_response.code.should eql("200")
    #   order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost)).web_response.code.should eql("405")
    # end
    # 
  it "should allow to take out and receive receipt" do
    order = {:location => "TO_TAKE", :items => [{:drink => "latte", :milk => "DOUBLE", :size => "LARGE"}]}
    content = order.to_xml(:root => "order")
    order = Restfulie.at('http://localhost:3000/orders').as('application/vnd.restbucks+xml').create(content)
    order.request.as('application/vnd.restbucks+xml').pay(payment(order.cost)).web_response.code.should eql("200")
    order = order.self
    order.status.should eql("ready")
    res = order.take(:method => :delete)
    order = order.self
    order.status.should eql("delivered")
    debugger
    receipt = order.receipt
    puts receipt.web_response.body
    puts receipt.web_response['Content-type']
    receipt.amount.should eql("10.0")
  end

end
