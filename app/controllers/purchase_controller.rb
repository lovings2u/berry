class PurchaseController < ApplicationController
  require 'unirest'
  def strawberry
    reset_session
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
    if session[:user_id].nil?
      redirect_to '/purchase/nosession'
    else
      buy=Customer.where(:phone_number => session[:user_id]).take
      @confirm = buy.orders.last
      @username = buy.name
    end
  end

  def nosession
  end
  def check
    @sendlist = Unirest.post("http://api.openapi.io/ppurio/1//sendnumber/list/skyhan1106",
    headers:{:"x-waple-authorization" => "MzI4Ni0xNDQ1NjY2Nzg5OTE4LWRiZGZhOTYwLWVjNWUtNDJhZS05ZmE5LTYwZWM1ZTUyYWU5NQ=="},
    parameters:{})
  end
  def message
    @savedata = Unirest.post("http://api.openapi.io/ppurio/1//sendnumber/save/skyhan1106",
    headers:{:"x-waple-authorization" => "MzI4Ni0xNDQ1NjY2Nzg5OTE4LWRiZGZhOTYwLWVjNWUtNDJhZS05ZmE5LTYwZWM1ZTUyYWU5NQ=="},
    parameters:{
    :sendnumber => "01052489085",
    :comment => "전민호"})
    @response = Unirest.post("http://api.openapi.io/ppurio/1/message/sms/skyhan1106",
    headers:{:"x-waple-authorization" => "MzI4Ni0xNDQ1NjY2Nzg5OTE4LWRiZGZhOTYwLWVjNWUtNDJhZS05ZmE5LTYwZWM1ZTUyYWU5NQ=="},
    parameters:{ 
    :dest_phone => "01052489085" , 
    :dest_name => "홍길동" , 
    :send_phone => "01052489085" , 
    :send_name => "홍길순" , 
    :subject => "제목" , 
    :msg_body => "문자메시지테스트중" , 
    :apiVersion => "1" , 
    :id => "skyhan1106" })
  end
end
