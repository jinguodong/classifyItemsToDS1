class RecommendController < ApplicationController
	def index
		redirect_to :action => 'show', :id => 0
	end

	def show
		items_per_page = 15
		@id = params['id'].to_i
		_start = @id * items_per_page
		_end = _start + items_per_page
		centers = CftdExperimentsClassCenterResult.all
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
				rec_item_all['name'] = item['ASIN']
				rec_item_all['cogs'] = "#{45.6}"
				rec_item_all['velocity'] = "#{123}"
				rec_item_all['img_url'] = "http://ecx.images-amazon.com/images/I/410aTNdwfFL._SL500_SX150_.jpg"
				rec_item_all['asin'] = item['ASIN']
				rec_item_all['class_id'] = class_id
				rec_item_all['exp_id'] = exp_id
				_tem_item = Marshal.load(Marshal.dump(rec_item_all))
				@rec_items_all << _tem_item
			end
			# puts rec_items_asin_str
			# puts "#{@rec_items_all}"
		end
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
			reced_item_all['name'] = item['ASIN']
			reced_item_all['cogs'] = "#{45.6}"
			reced_item_all['velocity'] = "#{123}"
			reced_item_all['img_url'] = "http://ecx.images-amazon.com/images/I/410aTNdwfFL._SL500_SX150_.jpg"
			reced_item_all['asin'] = item['ASIN']
			reced_item_all['class_id'] = class_id
			reced_item_all['exp_id'] = exp_id
			_tem_item = Marshal.load(Marshal.dump(reced_item_all))
			@reced_reason_ds_res_items_all << _tem_item
		end
	end
end
