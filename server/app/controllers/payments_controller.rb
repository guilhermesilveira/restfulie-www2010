class PaymentsController < ApplicationController
  
  include Restfulie::Server::Controller
  
  def payment_url(p)
    show_payment_url(p.order)
  end

  def create

    type = model_type
    return head 415 unless fits_content(type, media_type_for(request.headers['CONTENT_TYPE']))

    @model = type.from_xml request.body.string
    @model.order = Order.find(params[:order_id])
    if @model.order.status != "unpaid"
      head 405
    elsif @model.amount != @model.order.cost
      head :bad_request
    else
      @model.order.status = "preparing"
      if @model.save && @model.order.save
        render_created @model
        # head 201, :location => payment_url(@model)
      else
        render :xml => @model.errors, :status => :unprocessable_entity
      end
    end

  end
  
  def show
    order = Order.find(params[:order_id])
    render_resource order.payment
  end
  
  # removes the charset, if present, extracting only the media type
  def media_type_for(content_type)
    content_type[/[^;]*/]
  end

end
