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
    elsif @model.is_ready?
      @model.status = "delivered"
      if @model.save
        head :ok
      else
        head :unable_to_save
      end
    else
      head :status => 405
    end
  end
  
  def update
    # try {
    #     OrderRepresentation responseRepresentation = new UpdateOrderActivity().update(OrderRepresentation.fromXmlString(orderRepresentation).getOrder(), new RestbucksUri(uriInfo.getRequestUri()));
    #     return Response.ok().entity(responseRepresentation).build();
    # } catch (InvalidOrderException ioe) {
    #     return Response.status(Status.BAD_REQUEST).build();
    # } catch (NoSuchOrderException nsoe) {
    #     return Response.status(Status.NOT_FOUND).build();
    # } catch(UpdateException ue) {
    #     return Response.status(Status.CONFLICT).build();
    # } catch (Exception ex) {
    #     return Response.serverError().build();
  end

end
