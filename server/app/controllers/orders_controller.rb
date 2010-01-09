class OrdersController < ApplicationController
  
  include Restfulie::Server::Controller
  
  # GET /orders
  # GET /orders.xml
  def index
    @orders = Order.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orders }
    end
  end
  
  # show works just fine
  
  def create

    type = model_type
    return head(415) unless fits_content(type, request.headers['CONTENT_TYPE'])

    @model = type.from_xml request.body.string
    @model.items.each do |i|
      i.order = @model
    end
    if @model.save
      render_created @model
    else
      render :xml => @model.errors, :status => :unprocessable_entity
    end

  end

  def destroy
    @model = model_type.find(params[:id])
    if @model.can_cancel?
      @model.delete
      head :ok
    else
      head :status => 405
    end
  end
  
  def take
    @model = model_type.find(params[:id])
    if @model.status=="ready"
      @model.status = "taken"
      if @model.save
        head :ok
      else
        head :unable_to_save
      end
    else
      head :status => 405
    end
  end

end
