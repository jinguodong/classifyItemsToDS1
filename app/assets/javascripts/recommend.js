$(document).ready(function(){
	$("input[type='checkbox']").change(function(){
		_recommended_name = "#recommended_item_" + this.value;
		_ds_name = "#ds_reason_item_" + this.value;
		if(this.checked){
			$(_recommended_name).show();
			$(_ds_name).show();
			$(_recommended_name).parent().show();
		}
		else{
			$(_recommended_name).hide();
			$(_ds_name).hide();
			$(_recommended_name).parent().hide();
		}
	});
});

$(document).ready(function(){
	$("img").hide();
	$("img").load(function(){
		parent_img = this.parentNode;
		img_height = this.height;
		div_height = parseInt($(this).parent().css('height').slice(0,-2));
		dif = ( div_height - img_height);
		this.style.paddingTop = String(dif/2)+'px';
		$(this).show();
	});

	$("select").change(function(){
		_res = "";
		_select = $("select");
		for(var i=0; i<_select.length; i++){
		   _res = _res + _select[i].id+"("+_select[i].value+")";
		}
		$("#input_scope_show").html(_res);
	});

	$("input[type='text']").change(function(){
		_res = "";
		_input_text = $("input[type='text']");
		for(var i=0; i<_input_text.length; i++){
		   _res = _res + _input_text[i].id+"("+_input_text[i].value+")";
		}
		$("#input_factors_show").html(_res);
	});
});
