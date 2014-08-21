$(document).ready(function(){
	// $("input[type='checkbox']").change(function(){
	// 	_recommended_name = "#recommended_item_" + this.value;
	// 	_ds_name = "#ds_reason_item_" + this.value;
	// 	if(this.checked){
	// 		$(_recommended_name).show();
	// 		$(_ds_name).show();
	// 		$(_recommended_name).parent().show();
	// 	}
	// 	else{
	// 		$(_recommended_name).hide();
	// 		$(_ds_name).hide();
	// 		$(_recommended_name).parent().hide();
	// 	}
	// });
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

	$("a[flag='nav']").click(function(){
		relate_content = $(this).attr("relate");
		session_contents = $(".session_content").hide();
		session_content = $(".session_content[id="+relate_content+"]")
		$("a[flag='nav']").attr('class', '');
		$(this).attr('class', 'bg_eee');
		session_content.show();
	});

	$("input[attr='next_button']").click(function(){
		relate = $(this).attr("relate");
		next = $(this).attr("next");
		$("#"+relate).hide();
		$("a[relate="+relate+"]").attr('class', '');
		$("#"+next).show();
		$("a[relate="+next+"]").attr('class', 'bg_eee');
		return 0;
	});
	$("input[attr='pre_button']").click(function(){
		relate = $(this).attr("relate");
		pre = $(this).attr("pre");
		$("#"+relate).hide();
		$("a[relate="+relate+"]").attr('class', '');
		$("#"+pre).show();
		$("a[relate="+pre+"]").attr('class', 'bg_eee');
		return 0;
	});
	$(".item").click(function(){
		_href = $(this);
		_href = $(this.firstChild.nextSibling.getElementsByTagName('a')).attr('href');
		if(_href){
			window.location.href=_href;
		}
	});

	$(".mwui-switch-btn span[change='OFF']").click(function(){
		_this = $(this)
		_this.parent().prev().val(0);
		_this.parent().next().show();
		_this.parent().hide();
	});
	$(".mwui-switch-btn span[change='ON']").click(function(){
		_this = $(this)
		_this.parent().prev().prev().val(1);
		_this.parent().prev().show();
		_this.parent().hide();
	});
	
});

