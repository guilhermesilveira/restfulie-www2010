class OrdersController < ApplicationController
  
  include Restfulie::Server::Controller
  
  def index
    @orders = Order.all
  end

  def create

    type = model_type
    return head 415 unless fits_content(type, request.headers['CONTENT_TYPE'])

    debugger
    request.body.string = '<?xml version="1.0" encoding="UTF-8"?>
    <order>
      <items>
        <item>
          <drink>latte</drink>
          <milk>DOUBLE</milk>
          <size>LARGE</size>
        </item>
        <item>
          <drink>latte</drink>
          <milk>DOUBLE</milk>
          <size>SMALL</size>
        </item>
      </items>
      <location>TO_TAKE</location>
    </order>'
    @model = type.from_xml request.body.string
    if @model.save
      render_created @model
    else
      render :xml => @model.errors, :status => :unprocessable_entity
    end

  end
  
  def destroy
    @model = model_type.find(params[:id])
    if @model.can? :cancel
      @model.delete
      head :ok
    elsif @model.can? :retrieve
      @model.status = "delivered"
      @model.save!
      head :ok
    else
      head :status => 405
    end
  end
  
  def pre_update(model)
    model[:status] = "unpaid"
    model["items"].map do |item|
      Item.new(item)
    end
  end

end
