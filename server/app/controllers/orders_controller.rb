class OrdersController < ApplicationController
  
  include Restfulie::Server::Controller
  
  def index
    @orders = Order.all
  end
  
  def destroy
    @model = model_type.find(params[:id])
    if @model.can? :cancel
      @model.delete
      puts "IVE DELETED THIS GUY!!! #{@model.id}"
      # head :ok
    elsif @model.can? :retrieve
      @model.status = "delivered"
      @model.save!
      head :ok
    else
      head :status => 405
    end
  end
  
  def pre_update(model)
    debugger
    model[:status] = "unpaid"
    model["items"] = []
    # model["items"].map do |item|
      # Item.new(item)
    # end
  end

  def update
    @loaded = model_type.find(params[:id])
    return head :status => 405 unless @loaded.can? :update

    type = model_type
    return head 415 unless fits_content(type, request.headers['CONTENT_TYPE'])

    debugger
    @model = Hash.from_xml(request.body.string)[model_name]
    pre_update(@model) if self.respond_to?(:pre_update)
    
    if @loaded.update_attributes(@model)
      render_resource @loaded
    else
      render :xml => @loaded.errors, :status => :unprocessable_entity
    end
  end

end
