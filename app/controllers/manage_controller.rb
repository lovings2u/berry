class ManageController < ApplicationController
	def charged
		@deposit = Order.where(:progress => 'IN PROGRESS').all
	end
	def message

		Unirest.post("http://api.openapi.io/ppurio/1/message/sms/skyhan1106",
	    headers:{:"x-waple-authorization" => "MzI4Ni0xNDQ1NjY2Nzg5OTE4LWRiZGZhOTYwLWVjNWUtNDJhZS05ZmE5LTYwZWM1ZTUyYWU5NQ=="},
	    parameters:{ 
	    :dest_phone =>  params[:number_list], 
	    :send_phone => "01027655429" , 
	    :send_name => "like ddalgi" , 
	    :subject => "like ddalgi" , 
	    :msg_body => params[:message_body] , 
	    :apiVersion => "1" , 
	    :id => "skyhan1106" })

	    index = params[:id_list].split(',')
	    index.each do |x|
	    	charged=Order.where(:order_index => x).take
	    	if charged.progress == 'IN PROGRESS'
	    		charged.progress='CHARGED'
	    		if Date.today.between?(Date.today.beginning_of_week, Date.today.end_of_week - 3)
			      charged.delivery_date = Date.today.next_week(:monday)
			    else
			      charged.delivery_date = Date.today.next_week(:thursday)
			    end
	    	elsif charged.progress == 'CHARGED'
	    		charged.progress='COMPLETE'
	    	end
	    	charged.save
	    end

	    redirect_to '/manage/complete'
	end

	def test
		@name = params[:user]
		@list = params[:number_list]
		index = params[:id_list].split(',')
		index.each do |x|
	    	charged=Order.where(:order_index => x).take
	    	if charged.progress == 'IN PROGRESS'
	    		charged.progress='CHARGED'
	    		if Date.today.between?(Date.today.beginning_of_week, Date.today.end_of_week - 3)
			      charged.delivery_date = Date.today.next_week(:monday)
			    else
			      charged.delivery_date = Date.today.next_week(:thursday)
			    end
	    	elsif charged.progress == 'CHARGED'
	    		charged.progress='COMPLETE'
	    	end
	    	charged.save
	    end
	    @progress = Order.where(:progress => 'CHARGED').all
	    @deliver = Order.where(:progress => 'IN PROGRESS').all
		@body = params[:message_body]
	end
	def delivery
		@complete = Order.where(:progress => 'CHARGED').all

	end

end
