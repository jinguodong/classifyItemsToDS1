class RecommendController < ApplicationController
	before_filter :get_params, :only=>[:show, :sub_show, :sub_show_rec, :compare]
	def index
		@fulfil_type = [["", -1], ["DropShip", 1], ["Vendor Flex", 2], ["3PL", 3]]
		@market_place = [["", -1], ["www.amazon.com", 1], ["www.amazon.co.uk", 3],
			["www.amazon.de", 4], ["www.amazon.fr", 5], ["www.amazon.es", 44551],
			["www.amazon.in", 44571], ["www.amazon.it", 35691], ["www.amazon.co.jp", 6],
			["www.amazon.ca", 7], ["www.amazon.cn", 3240], ["www.amazon.com.br", 526970],
			["www.amazon.com.mx", 771770], ["www.amazon.com.au", 111172],
			["www.amazon.ru", 111162], ["www.amazon.nl", 328451]
		]
		@gl_product_group = [
			["", -1], ["gl_outdoors", 468], ["gl_tools", 469], ["gl_pantry", 467],
			["gl_unassigned",0],
			["gl_book",14],
			["gl_music",15],
			["gl_gift",20],
			["gl_toy",21],
			["gl_game",22],
			["gl_electronics",23],
			["gl_video",27],
			["gl_unknown",31],
			["gl_batteries",44],
			["gl_shops",50],
			["gl_universal_catalog",53],
			["gl_home_improvement",60],
			["gl_video_games",63],
			["gl_software",65],
			["gl_dvd",74],
			["gl_baby_product",75],
			["gl_kitchen",79],
			["gl_lawn_and_garden",86],
			["gl_wireless",107],
			["gl_ebooks",111],
			["gl_photo",114],
			["gl_drugstore",121],
			["gl_slots",123],
			["gl_catalog_of_the_world",125],
			["gl_audible",129],
			["gl_downloadable_software",136],
			["gl_pc",147],
			["gl_magazine",153],
			["gl_target",158],
			["gl_target_gift_card",160],
			["gl_paper_catalog",171],
			["gl_restaurant_menu",180],
			["gl_apparel",193],
			["gl_beauty",194],
			["gl_food_and_beverage",195],
			["gl_furniture",196],
			["gl_jewelry",197],
			["gl_luggage",198],
			["gl_pet_products",199],
			["gl_sports",200],
			["gl_home",201],
			["gl_cadillac",219],
			["gl_pets",224],
			["gl_food",225],
			["gl_media",226],
			["gl_gift_card",228],
			["gl_office_product",229],
			["gl_travel_store",234],
			["gl_sdp_misc",236],
			["gl_watch",241],
			["gl_loose_stones",246],
			["gl_gourmet",251],
			["gl_local_directories",256],
			["gl_posters",258],
			["gl_sports_memorabilia",259],
			["gl_school_supplies",260],
			["gl_art_craft_supplies",261],
			["gl_medical_lab_supplies",262],
			["gl_automotive",263],
			["gl_art",264],
			["gl_major_appliances",265],
			["gl_antiques",266],
			["gl_musical_instruments",267],
			["gl_gift_certificates",279],
			["gl_tires",293],
			["gl_digital_short_lit",297],
			["gl_digital_documents",298],
			["gl_philanthropy",304],
			["gl_authority_non_buyable",307],
			["gl_shoes",309],
			["gl_free_gift_card",311],
			["gl_webservices",313],
			["gl_library_services",316],
			["gl_digital_video_download",318],
			["gl_grocery",325],
			["gl_biss",328],
			["gl_digital_book_service",334],
			["gl_electronic_gift_certificate",336],
			["gl_digital_music_purchase",340],
			["gl_digital_text",349],
			["gl_digital_periodicals",350],
			["gl_digital_ebook_purchase",351],
			["gl_data_activity_plans",356],
			["gl_advertising",360],
			["gl_personal_care_appliances",364],
			["gl_digital_software",366],
			["gl_digital_video_games",367],
			["gl_wine",370],
			["gl_consumables_physical_gift_cards",396],
			["gl_digital_accessories",400],
			["gl_mobile_apps",405],
			["gl_deal_sourcer",416],
			["gl_amazon_sourced",417],
			["gl_camera",421],
			["gl_mobile_electronics",422],
			["gl_digital_text_2",424],
			["gl_digital_accessories_2",425],
			["gl_amazon_points",437],
			["gl_entertainment_collectibles",441]
		]
		@sub_gl_product_group = [
			["", -1], ["bags", 1], ["balls", 2]
		]
	end

	def factor
	end

	def setting
		'''Setting Decision Tree from UE

		Which basket of ASIN in a vendor subset shall we place where? Which are the criteria.
		The function just for mockup, none have been done.'''
		@market_place = params['market_place']
		@fulfil_type = params['fulfil_type']
		@gl_product_group = params['gl_product_group']
		@sub_gl_product_group = params['sub_gl_product_group']

		@fulfil_name = "Items Should not in FC"
		case @fulfil_type
			when '1'
				@fulfil_name = "DropShip"
			when '2'
				@fulfil_name = "Vflex"
			when '3'
				@fulfil_name = "3PL"
		end

	end

	def show

		items_per_page = 15
		@id = params['id'].to_i
		@pre_id = @id - 5

		@bottom_id = @id - 4 >= 0 ? @id - 4 : 0;
		@top_id = @bottom_id + 8;
		@pre_flag = 0
		@next_flag = 0
		if @pre_id >= 2
			@pre_id = 1
			@pre_flag = 1
		end
		@next_id = @id + 5
		
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
		if @next_id <= @page_cnt-3
			@next_id = @page_cnt-2
			@next_flag = 1
		end
		if @top_id > @page_cnt-1
			@top_id = @page_cnt-1
			if @top_id - 8 >= 0
				@bottom_id = @top_id - 8
			end
		end
	end

	def sub_show
		get_input = params["id"]
		arr_input = get_input.split("&")
		@hash_input = {}
		arr_input.each do |ele|
			arr_ele = ele.split("=")
			@hash_input[arr_ele[0]] = arr_ele[1]
		end

		class_id = @hash_input["class_id"]
		exp_id = @hash_input["exp_id"]
		asin = @hash_input['asin']
		name = @hash_input['name']
		img_url = @hash_input['img_url']
		cogs = @hash_input['cogs']
		velocity = @hash_input['velocity']
		weight = @hash_input['weight']
		
		@reced_class_id = class_id
		@reced_exp_id = exp_id
		@reced_asin = asin
		@reced_name = name
		@reced_img_url = img_url
		@reced_cogs = cogs
		@reced_velocity = velocity
		@reced_weight = weight

		@physical_attrs = get_physical_attrs(asin)
		# Prepare all info of the shipment ratio
		@shipment_ratio_graph_per_week = get_weekly_shipment_ratio(asin)
		@shipment_ratio_math = cal_math(@shipment_ratio_graph_per_week)

		@low_weekly_volumes = get_weekly_volumes(asin)

		@high_peakiness = get_high_peakiness(asin)

		@high_customer_returns = get_customer_returns(asin)
		@high_customer_returns_math = cal_math(@high_customer_returns)

		@high_vendor_returns = get_vendor_returns(asin)
		@high_vendor_returns_math = cal_math(@high_vendor_returns)


		@item = get_info_by_asin(asin)
		@shipments = get_history_by_asin(asin)
		# Special: quantity info
		@sum_quantity = get_history_of_quantity_by_asin(asin)
		# Format @sum_quantity to Displayable struct;
		@week_sum_quantity = get_display_info_quantity_weekly(@sum_quantity, 'sum_q', (9..27).to_a)
		# Format @shipments to Displayable struct;
		@low_weekly_volumes = @week_sum_quantity
		@low_weekly_volumes_math = cal_math(@low_weekly_volumes)
		
		@date_list_price = get_need_info(@shipments, 'list_price')
		@date_list_price_math = cal_daily_math(@date_list_price)

		@date_our_price = get_need_info(@shipments, 'our_price')
		@date_ship_charge = get_need_info(@shipments, 'ship_charge')
		@date_ship_charge_math = cal_daily_math(@date_ship_charge)
		@date_cogs = get_need_info(@shipments, 'cogs')
		@date_cogs_math = cal_daily_math(@date_cogs)


	end

	def sub_show_rec
		get_input = params["id"]
		arr_input = get_input.split("&")
		@hash_input = {}
		arr_input.each do |ele|
			arr_ele = ele.split("=")
			@hash_input[arr_ele[0]] = arr_ele[1]
		end

		class_id = @hash_input["class_id"]
		exp_id = @hash_input["exp_id"]
		asin = @hash_input['asin']
		name = @hash_input['name']
		img_url = @hash_input['img_url']
		cogs = @hash_input['cogs']
		velocity = @hash_input['velocity']
		weight = @hash_input['weight']
		
		@reced_class_id = class_id
		@reced_exp_id = exp_id
		@reced_asin = asin
		@reced_name = name
		@reced_img_url = img_url
		@reced_cogs = cogs
		@reced_velocity = velocity
		@reced_weight = weight

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
		# Special: quantity info
		@ds_sum_quantity = get_history_of_quantity_by_asin(ds_asin)
		@other_sum_quantity = get_history_of_quantity_by_asin(other_asin)
		# Format @ds_sum_quantity to Displayable struct;
		@ds_week_sum_quantity = get_display_info_quantity_weekly(@ds_sum_quantity, 'sum_q', (9..27).to_a)
		# Format @other_sum_quantity to Displayable struct;
		@other_week_sum_quantity = get_display_info_quantity_weekly(@other_sum_quantity, 'sum_q', (9..27).to_a)
		
		
		# Format @other_shipments to Displayable struct;
		@other_date_list_price = get_need_info(@other_shipments, 'list_price')
		@other_date_list_price_math = cal_daily_math(@other_date_list_price)

		@other_date_our_price = get_need_info(@other_shipments, 'our_price')
		@other_date_ship_charge = get_need_info(@other_shipments, 'ship_charge')
		@other_date_ship_charge_math = cal_daily_math(@other_date_ship_charge)

		@other_date_cogs = get_need_info(@other_shipments, 'cogs')
		@other_date_cogs_math = cal_daily_math(@other_date_cogs)
		
		
		# Format @ds_shipments to Displayable struct;
		@ds_date_list_price = get_need_info(@ds_shipments, 'list_price')
		@ds_date_list_price_math = cal_daily_math(@ds_date_list_price)

		@ds_date_our_price = get_need_info(@ds_shipments, 'our_price')
		@ds_date_ship_charge = get_need_info(@ds_shipments, 'ship_charge')
		@ds_date_ship_charge_math = cal_daily_math(@ds_date_ship_charge)

		@ds_date_cogs = get_need_info(@ds_shipments, 'cogs')
		@ds_date_cogs_math = cal_daily_math(@ds_date_cogs)

		@ds_physical_attrs = get_physical_attrs(ds_asin)
		@ds_shipment_ratio_graph_per_week = get_weekly_shipment_ratio(ds_asin)
		@ds_shipment_ratio_graph_per_week_math = cal_math(@ds_shipment_ratio_graph_per_week)

		# @ds_low_weekly_volumes equals to @ds_week_sum_quantity
		# @ds_low_weekly_volumes = get_weekly_volumes(ds_asin)
		@ds_low_weekly_volumes = @ds_week_sum_quantity
		@ds_low_weekly_volumes_math = cal_math(@ds_low_weekly_volumes)

		@ds_high_peakiness = get_high_peakiness(ds_asin)
		@ds_high_customer_returns = get_customer_returns(ds_asin)
		@ds_high_customer_returns_math = cal_math(@ds_high_customer_returns)

		@ds_high_vendor_returns = get_vendor_returns(ds_asin)
		@ds_high_vendor_returns_math = cal_math(@ds_high_vendor_returns)


		@other_physical_attrs = get_physical_attrs(other_asin)
		@other_shipment_ratio_graph_per_week = get_weekly_shipment_ratio(other_asin)
		@other_shipment_ratio_graph_per_week_math = cal_math(@other_shipment_ratio_graph_per_week)

		# @other_low_weekly_volumes equals to @other_week_sum_quantity
		# @other_low_weekly_volumes = get_weekly_volumes(other_asin)
		@other_low_weekly_volumes = @other_week_sum_quantity
		@other_low_weekly_volumes_math = cal_math(@other_low_weekly_volumes)

		@other_high_peakiness = get_high_peakiness(other_asin)
		@other_high_customer_returns = get_customer_returns(other_asin)
		@other_high_customer_returns_math = cal_math(@other_high_customer_returns)

		@other_high_vendor_returns = get_vendor_returns(other_asin)
		@other_high_vendor_returns_math = cal_math(@other_high_vendor_returns)

	end

	def certificate
		@result = params
		@factors = ["list_price", "our_price", "ship_charge", "velocity_week", "cost_of_goods"]
	end

	def deal
		# @result = params
		redirect_to :action => "show", :id => 0, :local_params=>params
	end

	protected
	def get_params
		@local_params = params['local_params']
	end
	def cal_math(num_hash)
		_max = cal_max(num_hash)
		_min = cal_min(num_hash)
		_avg = cal_avg(num_hash)
		_dev = cal_dev(num_hash)
		_coe = _dev/_avg
		
		_avg = format("%0.3f", _avg)
		_dev = format("%0.3f", _dev)
		_coe = format("%0.3f", _coe)
		
		_res = [_max, _min, _avg, _dev, _coe]
		return _res
	end
	def cal_avg(num_hash)
		_count = 0
		_sum = 0.0
		num_hash.each do |k, v|
			_sum = _sum + v
			_count = _count + 1
		end
		return (_sum/_count)
	end
	def cal_dev(num_hash)
		_count = 0
		_sum_dev = 0.0
		_avg = cal_avg(num_hash)
		num_hash.each do |k, v|
			_sum_dev = _sum_dev + (v-_avg)*(v-_avg)
			_count = _count + 1
		end
		_dev = Math.sqrt(_sum_dev)/_count
		return _dev
	end
	def cal_max(num_hash)
	end
	def cal_min(num_hash)
	end
	def cal_daily_math(num_arr)
		_max = 0
		_min = 0
		_avg = cal_daily_avg(num_arr)
		_dev = cal_daily_dev(num_arr)
		_coe = _dev/_avg
		
		_avg = format("%0.3f", _avg)
		_dev = format("%0.3f", _dev)
		_coe = format("%0.3f", _coe)
		
		_res = [_max, _min, _avg, _dev, _coe]
		return _res
	end
	def cal_daily_avg(num_arr)
		_count = 0
		_sum = 0.0
		num_arr.each do |v|
			_sum = _sum + v[3]
			_count = _count + 1
		end
		return _sum/_count
	end
	def cal_daily_dev(num_arr)
		_count = 0
		_sum = 0.0
		_avg = cal_daily_avg(num_arr)
		num_arr.each do |v|
			_sum = _sum + (v[3]-_avg)*(v[3]-_avg)
			_count = _count + 1
		end
		_dev = Math.sqrt(_sum) / _count
		return _dev
	end

	def get_physical_attrs(asin)
		_attrs = {}
		_attrs['shipment_ratio'] = "1.1"
		_attrs['multiple_units_per_order'] = "1"
		_attrs['low_weekly_volumes'] = "3"
		_attrs['high_variability_of_demand_weekly'] = "10"
		_attrs['high_peakiness'] = "1"
		_attrs['cube_length'] = "12"
		_attrs['cube_width'] = "11"
		_attrs['cube_height'] = "9"
		_attrs['hazmat_compatibility'] = "1"
		_attrs['overbox_gift_wrap'] = "1"
		_attrs['multibox'] = "1"
		_attrs['sioc'] = "1"
		_attrs['high_risk_of_unhealthy_stock'] = "1"
		_attrs['high_customer_returns'] = "0.19"
		_attrs['high_vendor_returns'] = "0.12"
		_attrs['average_list_price'] = "110"
		_attrs['average_cost_of_goods'] = "90"
		_attrs['average_ship_charge'] = "3.2"
		return _attrs
	end

	def get_weekly_shipment_ratio(asin)
		_res = get_rand_hash((9..27))
		return _res
	end
	def get_weekly_volumes(asin)
		_res = get_rand_hash((9..27))
		return _res
	end
	def get_high_peakiness(asin)
		_peakiness = rand()/3 * 1000;
		_peakiness = _peakiness.to_i
		_peakiness_other = 1000-_peakiness
		_res = [_peakiness/1000.0, _peakiness_other/1000.0]
		return _res
	end
	def get_customer_returns(asin)
		_res = get_rand_hash((9..27))
		return _res
	end
	def get_vendor_returns(asin)
		_res = get_rand_hash((9..27))
		return _res
	end
	def get_rand_hash(arr)
		res = {}
		arr.each do |i|
			_num = 1.0 + rand()/2;
			_num = format("%0.3f", _num).to_f
			res[i] = _num
		end
		return res
	end
	
	def write_to_txt_file(items, file_name="")
		_file_name = "#{file_name}"
		File.open(_file_name, "a") do |f|
			items.each do |item|
				f.puts "#{item['asin']}"
			end
		end
	end

	def get_info_by_asin(asin)
		# Get infos of the input ASIN.

		# Result: {}
		# => Get infos: name, cogs, velocity, weight, img_url', asin.
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
		reced_item_all['weight'] = "#{_item_shipping_weight}kg"
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
		# Get history infos of the input ASIN.

		# Result: shipments = []
		# => Each element in shpments is consist of : 
		# => asin, ship_day, list_price, our_price, ship_charge, cogs, velocity
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

	def get_history_of_quantity_by_asin(asin)
		# From table: AsinCostShipPrice and Get history of quantity infos of the input ASIN.

		# Result: shipment_quantities = []
		# => Each element in shpments is consist of : 
		# => asin, week, sum_q(sum(quantity)/week)
		shipment_quantities = []
		_item_asin = asin
		_item_quantity_res = AsinCostShipPrice.select("asin, week, SUM(quantity) as sum_q").where( ["ASIN = ?", _item_asin] ).group("week").order("week").all
		if _item_quantity_res == nil
			return nil
		end

		_shipment_quantity = {}
		_item_quantity_res.each do |_item|
			_shipment_quantity["asin"] = _item['asin']
			_shipment_quantity['week'] = _item['week']
			_shipment_quantity['sum_q'] = _item['sum_q']
			shipment_quantities << Marshal.load(Marshal.dump(_shipment_quantity))
		end
		return shipment_quantities
	end

	def get_need_info(shipments, column)
		# Get need info from history infos in shipments.

		# Result: _need_infos = []
		# => Each element in shpments is consist of : 
		# => [ship_day_year, ship_day_month, ship_day_day, column_value] and all element are number.
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

	def get_display_info_quantity_weekly(shipment_quantities, column, week_scope)
		# Get display format structure from history infos in shipment_quantities.

		# week_scope: here will be 9..27([9,27])
		# Result: display_infos = {}
		# => Each element in display_infos is consist of : 
		# => (week => sum_q(sum(quantity)/week))
		display_infos = {}
		shipment_quantities.each do |shipment_quantity|
			_week = shipment_quantity['week']
			_sum_q = shipment_quantity[column]
			display_infos[_week] = _sum_q
		end
		week_scope.each do |_week|
			if display_infos[_week] == nil
				display_infos[_week] = 0
			end
		end
		return display_infos
	end
end
