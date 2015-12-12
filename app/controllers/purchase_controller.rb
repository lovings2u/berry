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
    message = "라이크딸기청을 주문해주셔서 감사합니다!! 주문번호는" + od.order_index.to_s + "입니다~ 신한 110-209-493870 이정석으로" + od.prod_price.to_s + "원! 입금 부탁드릴게요^.^"
    Unirest.post("http://api.openapi.io/ppurio/1/message/sms/skyhan1106",
    headers:{:"x-waple-authorization" => "MzI4Ni0xNDQ1NjY2Nzg5OTE4LWRiZGZhOTYwLWVjNWUtNDJhZS05ZmE5LTYwZWM1ZTUyYWU5NQ=="},
    parameters:{ 
    :dest_phone => od.phone_number , 
    :send_phone => "01027655429" , 
    :send_name => "like ddalgi" , 
    :subject => "주문완료" , 
    :msg_body =>  message, 
    :apiVersion => "1" , 
    :id => "skyhan1106" })

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
