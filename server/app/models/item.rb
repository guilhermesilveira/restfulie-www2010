class Item < ActiveRecord::Base
  belongs_to :order
  
  # acts_as_restfulie do |item, t|
    # t << [:self, {:action => :show}]
  # end
  
end
