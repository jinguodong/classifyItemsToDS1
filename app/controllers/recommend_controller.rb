class RecommendController < ApplicationController
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
			["", -1], ["bags", 1]
		]
	end

	def factor

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
		weight = hash_input['weight']
		
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
		@other_date_our_price = get_need_info(@other_shipments, 'our_price')
		@other_date_ship_charge = get_need_info(@other_shipments, 'ship_charge')
		@other_date_cogs = get_need_info(@other_shipments, 'cogs')
		
		
		# Format @ds_shipments to Displayable struct;
		@ds_date_list_price = get_need_info(@ds_shipments, 'list_price')
		@ds_date_our_price = get_need_info(@ds_shipments, 'our_price')
		@ds_date_ship_charge = get_need_info(@ds_shipments, 'ship_charge')
		@ds_date_cogs = get_need_info(@ds_shipments, 'cogs')
	end

	def certificate
		@result = params
		@factors = ["list_price", "our_price", "ship_charge", "velocity_week", "cost_of_goods"]
	end

	def deal
		# @result = params
		redirect_to :action => "show", :id => 0
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
		# From table: AsinCostShipPrice
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
