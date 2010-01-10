class OrdersController < ApplicationController
  
  include Restfulie::Server::Controller
  
  def index
    @orders = Order.all
  end
  
  def destroy
    @model = model_type.find(params[:id])
    if @model.can? :cancel
      @model.delete
      head :ok
    elsif @model.can? :retrieve
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
