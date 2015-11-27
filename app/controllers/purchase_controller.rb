class PurchaseController < ApplicationController
  def strawberry

  end

  def confirm
    find_data = Customer.where(:phone_number => params[:cell_phone]).take
    if find_data.nil?
      find_data = Customer.create!(phone_number: params[:cell_phone], name: params[:buyer_name])
      
    end
    session[:user_id] = find_data.phone_number
    od = Order.create!(progress: 'IN PROGRESS', prod_index: params[:product], prod_volume: params[:volume], prod_price: params[:total],
                  address: params[:address], detail_address: params[:detail_address], order_date: DateTime.now, 
                  customer_id: find_data.id, order_index: DateTime.now.to_s(:number), phone_number: params[:cell_phone],
                  customer_name: params[:buyer_name])
    
    if od.order_date.between?(Date.today.beginning_of_week, Date.today.end_of_week - 3)
      od.delivery_date = Date.today.next_week(:monday)
      od.save
    else
      od.delivery_date = Date.today.next_week(:thursday)
      od.save
    end
    redirect_to '/purchase/save_data'
  end

  def save_data
    @b=Customer.all
    @b.each do |x|
      x.ord_count = x.orders.count
      x.ord_total = x.orders.sum(:prod_price)
      x.last_order = x.orders.reverse[0].order_date
      if x.orders.count >= 2
         x.repurchase = (x.orders.reverse[0].order_date-x.orders.reverse[1].order_date).to_i
      end
      x.save
    end
    redirect_to '/purchase/complete'
  end

  def complete
    buy=Customer.where(:phone_number => session[:user_id]).take
    @confirm = buy.orders.last
    @username = buy.name
  end

  def search
  end

  def find
  end
end
