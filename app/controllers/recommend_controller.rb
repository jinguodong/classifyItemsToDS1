class RecommendController < ApplicationController
	def index
		redirect_to :action => 'show', :id => 0
	end

	def show
		items_per_page = 15
		@id = params['id'].to_i
		_start = @id * items_per_page
		_end = _start + items_per_page
		# centers = CftdExperimentsClassCenterResult.all
		centers = CftdCenterResultCnt.order("ds_cnt DESC").all
		@item_all_cnt = 0
		@item_rec_cnt = 0
		res_n = CftdExperimentsItemsResult.select("COUNT(*) as cnt").where( ["1 = ? and is_dropship = 0", 1] ).all
		@item_all_cnt = res_n[0]['cnt']
		@rec_items_all = []
		centers.each do |cent|
			class_id = cent['CLASS_ID']
			exp_id = cent['EXPERIMENT_ID']
			attributes = ""
			ds_m = CftdExperimentsItemsResult.select("COUNT(*) as cnt").where( ["CLASS_ID = ? and EXPERIMENT_ID = ? and is_dropship=1", class_id, exp_id] ).all
			
			@ds_m_num = 0
			@ds_m_num = ds_m[0]['cnt'].to_i
			# puts @ds_m_num
			k = (@ds_m_num*0.1).to_i
			if k==0 && @ds_m_num!=0
				k = 1
			end
			# k = k > 5 ? 5 : k
			rec_items = CftdExperimentsItemsResult.select("ASIN").where( ["CLASS_ID = ? and EXPERIMENT_ID = ? and is_dropship=0", class_id, exp_id] ).order("DISTANCE_TO_CENTER").limit(k).all
			rec_items_asin_str = ""
			
			rec_item_all = {}
			@item_rec_cnt = @item_rec_cnt + rec_items.size()
			rec_items.each do |item|
				if rec_items_asin_str != ""
					rec_items_asin_str = rec_items_asin_str + ","
				end
				rec_items_asin_str = rec_items_asin_str + item['ASIN']
				_item_asin = item['ASIN'];
				rec_item_all = get_info_by_asin(_item_asin)
				if rec_item_all == nil
					next
				end
				rec_item_all['class_id'] = class_id
				rec_item_all['exp_id'] = exp_id

				_tem_item = Marshal.load(Marshal.dump(rec_item_all))
				@rec_items_all << _tem_item
			end
			# puts rec_items_asin_str
			# puts "#{@rec_items_all}"
		end

		# write_to_txt_file(@rec_items_all, "items_reced.txt")

		@rec_items_final = []
		@page_cnt = (@rec_items_all.size()+items_per_page-1)/items_per_page
		puts "all len #{@rec_items_all.size()} : id :#{_start} : #{_end}"
		for i in (_start..._end)
			if i < @rec_items_all.size()
				@rec_items_final << Marshal.load(Marshal.dump(@rec_items_all[i]))
			end
		end
	end

	def sub_show
		get_input = params["id"]
		arr_input = get_input.split("&")
		hash_input = {}
		arr_input.each do |ele|
			arr_ele = ele.split("=")
			hash_input[arr_ele[0]] = arr_ele[1]
		end

		class_id = hash_input["class_id"]
		exp_id = hash_input["exp_id"]
		asin = hash_input['asin']
		name = hash_input['name']
		img_url = hash_input['img_url']
		cogs = hash_input['cogs']
		velocity = hash_input['velocity']
		
		@reced_class_id = class_id
		@reced_exp_id = exp_id
		@reced_asin = asin
		@reced_name = name
		@reced_img_url = img_url
		@reced_cogs = cogs
		@reced_velocity = velocity

		k = 5
		reced_reason_ds_res = CftdExperimentsItemsResult.select("ASIN").where( ["CLASS_ID = ? and EXPERIMENT_ID = ? and is_dropship = 1", class_id, exp_id] ).order("DISTANCE_TO_CENTER").limit(k).all
		reced_item_all = {}
		@reced_reason_ds_res_items_all = []
		reced_reason_ds_res.each do |item|

			_item_asin = item['ASIN']
			reced_item_all = get_info_by_asin(_item_asin)
			if reced_item_all == nil
				next
			end

			_tem_item = Marshal.load(Marshal.dump(reced_item_all))
			@reced_reason_ds_res_items_all << _tem_item
		end
	end

	def compare
		get_input = params["id"]
		arr_input = get_input.split("&")
		hash_input = {}
		arr_input.each do |ele|
			arr_ele = ele.split("=")
			hash_input[arr_ele[0]] = arr_ele[1]
		end
		ds_asin = hash_input['ds']
		other_asin = hash_input['other']

		@ds_item = get_info_by_asin(ds_asin)
		@other_item = get_info_by_asin(other_asin)
		@ds_shipments = get_history_by_asin(ds_asin)
		@other_shipments = get_history_by_asin(other_asin)
		# p @other_shipments
		# p @ds_shipments
		# @other_date_list_price = []
		@other_date_list_price = get_need_info(@other_shipments, 'list_price')
		@other_date_our_price = get_need_info(@other_shipments, 'our_price')
		@other_date_ship_charge = get_need_info(@other_shipments, 'ship_charge')
		@other_date_cogs = get_need_info(@other_shipments, 'cogs')

		@ds_date_list_price = []
		@ds_date_list_price = get_need_info(@ds_shipments, 'list_price')
		@ds_date_our_price = get_need_info(@ds_shipments, 'our_price')
		@ds_date_ship_charge = get_need_info(@ds_shipments, 'ship_charge')
		@ds_date_cogs = get_need_info(@ds_shipments, 'cogs')

	end

	protected
	def write_to_txt_file(items, file_name="")
		_file_name = "#{file_name}"
		File.open(_file_name, "a") do |f|
			items.each do |item|
				f.puts "#{item['asin']}"
			end
		end
	end

	def get_info_by_asin(asin)
		reced_item_all = {}
		_item_asin = asin
		_item_name_res = AsinName.where( ["ASIN = ?", _item_asin] ).first
		if _item_name_res == nil
			return nil
		end
		_item_name = _item_name_res['ITEM_NAME']
		_item_gl = _item_name_res['GL_PRODUCT_GROUP']
		_item_msrp = _item_name_res['MSRP']
		_item_shipping_weight = _item_name_res['SHIPPING_WEIGHT']
		reced_item_all['name'] = _item_name
		reced_item_all['cogs'] = "#{_item_msrp}"
		reced_item_all['velocity'] = "#{_item_shipping_weight}kg"
		_item_url_res = AsinUrl.where( ["ASIN = ?", _item_asin] ).first
		if _item_url_res == nil
			return nil
		end
		_item_img_url = _item_url_res["img_url2"]
		reced_item_all['img_url'] = "#{_item_img_url}"
		reced_item_all['asin'] = _item_asin
		return reced_item_all
	end

	def get_history_by_asin(asin)
		shipments = []
		_item_asin = asin
		_item_name_res = AsinCostShipPrice.where( ["ASIN = ?", _item_asin] ).order("ship_day").all
		if _item_name_res == nil
			return nil
		end

		_shipment = {}
		_item_name_res.each do |_item|
			_shipment["asin"] = _item['asin']
			_shipment['ship_day'] = DateTime.parse(_item['ship_day'].to_s).strftime('%Y,%m,%d').to_s
			_shipment['list_price'] = _item['list_price']
			_shipment['our_price'] = _item['our_price']
			
			_shipment['ship_charge'] = _item['per_item_ship_charge']
			_shipment['cogs'] = _item['item_fifo_cost']
			_shipment['velocity'] = _item['quantity']
			shipments << Marshal.load(Marshal.dump(_shipment))
		end
		return shipments
	end

	def get_need_info(shipments, column)
		_need_infos = []
		shipments.each do |shipment|
			_date = shipment['ship_day']
			_one_row = _date.split(',')
			_one_row.collect! {|x| x.to_i}
			_another_attr = shipment[column]
			_one_row << _another_attr
			_need_infos << Marshal.load(Marshal.dump(_one_row))
		end
		return _need_infos
	end
end
