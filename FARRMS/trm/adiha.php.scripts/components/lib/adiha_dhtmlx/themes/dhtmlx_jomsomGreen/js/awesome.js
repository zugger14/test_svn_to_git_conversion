//#### EXTRA FUNCTIONS ##
var showGirdFilter = function(){
// console.log('in');
	$('.gridbox .xhdr > table tbody tr:nth-child(3)').addClass('tableRow');
	// $('.gridbox  .xhdr > table tbody tr:nth-child(2)').unbind('mouseover');

	clearTimeout();

}

var hideGridFilter = function()
{
// console.log('out');
				$('.gridbox .xhdr > table tbody tr:nth-child(3)').removeClass('tableRow');
}



function tabbarScrollCheck(){
	if(parseInt($('.dhxtabbar_tabs.dhxtabbar_tabs_top .dhxtabbar_tab').length)<4)
{
$('.dhxtabbar_tabs.dhxtabbar_tabs_top .dhxtabbar_tabs_ar_left').hide();
$('.dhxtabbar_tabs.dhxtabbar_tabs_top .dhxtabbar_tabs_ar_right').hide();
// $('.dhxtabbar_tabs.dhxtabbar_tabs_top .dhxtabbar_tabs_ar_right').hide();

}
else{
	$('.dhxtabbar_tabs.dhxtabbar_tabs_top .dhxtabbar_tabs_ar_left').show();
$('.dhxtabbar_tabs.dhxtabbar_tabs_top .dhxtabbar_tabs_ar_right').show();
}

}


function tabbarScrollCheckBottom(){
	// console.log("Bottom : " + parseInt($('.dhxtabbar_tabs.dhxtabbar_tabs_bottom .dhxtabbar_tab').length))
if(parseInt($('.dhxtabbar_tabs.dhxtabbar_tabs_bottom .dhxtabbar_tab').length)<20)
{
$('.dhxtabbar_tabs.dhxtabbar_tabs_bottom .dhxtabbar_tabs_ar_left').hide();
$('.dhxtabbar_tabs.dhxtabbar_tabs_bottom .dhxtabbar_tabs_ar_right').hide();
// $('.dhxtabbar_tabs.dhxtabbar_tabs_top .dhxtabbar_tabs_ar_right').hide();

}
else{
	$('.dhxtabbar_tabs.dhxtabbar_tabs_bottom .dhxtabbar_tabs_ar_left').show();
$('.dhxtabbar_tabs.dhxtabbar_tabs_bottom .dhxtabbar_tabs_ar_right').show();
}

}







$(function(){
// var interval;
	

//GridBox Filter	
// $('.dhxwin_active').on('DOMNodeInserted', '.gridbox', function(){
$('body_').on('DOMNodeInserted', '.gridbox', function(){

// console.log('i');
//GridBox Filter
		$('.gridbox  .xhdr').unbind('hover');
		$('.gridbox  .xhdr').unbind('mouseout');
		$('.gridbox  .xhdr').hover(function(){
			setTimeout(showGirdFilter,500);
		})
		$('.dhx_cell_hdr').hover(hideGridFilter);
		$('.dhx_cell_menu_def').hover(hideGridFilter);
		$('.objbox').hover(hideGridFilter);


//Pagination




})

// eo DOMNodeInserted


//#################################


$('body').on('DOMNodeInserted', '#pagingArea_b', function(){
		
// 	if(parseInt($('.btn_sel_text:contains(Page 2)').length)== 0 ){
// 			// console.log($(this));
// 	// $(this).parent().addClass('yo');
// 	console.log('Only One Page')
// }
// else if(parseInt($('.btn_sel_text:contains(Page 2)').length)==1 ){


// 	$(this).parent().addClass('po');
// 		console.log('More Than 1 Page');
// }
$('#pagingArea_b').parent().addClass('popo');
$('.popo').closest('.dhx_cell_layout').addClass('popoInside');
//Case with Multi Pages
if((parseInt($('.btn_sel_text:contains(Page 2)').length)== 1 ) && (parseInt($('.btn_sel_text:contains(Page 1)').length)== 1 )) {
		$(this).parent().removeClass('popo');
		$(this).closest('.dhx_cell_layout').removeClass('popoInside');
		$('.popo').closest('').addClass('hide');
}
//Dimesion check

$('.popoInside .dhx_cell_cont_layout').height(parseInt($('.popo').closest('.dhx_cell_layout').height() - $('.dhx_cell_hdr').height() - $('.dhx_cell_menu_def').height()));



});



//#################################


$('body').on('DOMNodeInserted', '#pagingArea_a', function(){
		
// 	if(parseInt($('.btn_sel_text:contains(Page 2)').length)== 0 ){
// 			// console.log($(this));
// 	// $(this).parent().addClass('yo');
// 	console.log('Only One Page')
// }
// else if(parseInt($('.btn_sel_text:contains(Page 2)').length)==1 ){


// 	$(this).parent().addClass('po');
// 		console.log('More Than 1 Page');
// }
$('#pagingArea_a').parent().addClass('popo');
$('.popo').closest('.dhx_cell_layout').addClass('popoInside');
//Case with Multi Pages
if((parseInt($('.btn_sel_text:contains(Page 2)').length)== 1 ) && (parseInt($('.btn_sel_text:contains(Page 1)').length)== 1 )) {
		$(this).parent().removeClass('popo');
		$(this).closest('.dhx_cell_layout').removeClass('popoInside');
		$('.popo').closest('').addClass('hide');
}
//Dimesion check

$('.popoInside .dhx_cell_cont_layout').height(parseInt($('.popo').closest('.dhx_cell_layout').height() - $('.dhx_cell_hdr').height() - $('.dhx_cell_menu_def').height()));



});



//####################
//TABBAR

$('body').on('DOMNodeInserted', '.dhxtabbar_tab', function(){
tabbarScrollCheck();
// tabbarScrollCheckBottom();
// alert('yo@')
});
$('body').on('DOMNodeInserted', '.dhxtabbar_cont', function(){
tabbarScrollCheck();
tabbarScrollCheckBottom();

$('.dhxtabbar_tab_close').mousedown(function(){
		tabbarScrollCheck();
		// tabbarScrollCheckBottom();
	// 	alert('yo')
});
});
// eo dhxtabbar_tab




// $('bbody').on('DOMNodeInserted', '.dhxwin_active', function(){

$('_body').mousemove(function(){
	// alert('yo');
//Window Parking btn
if($('.dhxwin_button_park ~ .dhxwin_button_close').parent().prop('className') != 'pioneer-awesome-window-actions'){
$('.dhxwin_button_park, .dhxwin_button_close, .dhxwin_button_minmaxed ').wrapAll('<div class="pioneer-awesome-window-actions" />');
// console.log('tnb-added');


//detach attach
var parent = $('.pioneer-awesome-window-actions').parent().parent();
var btns = $('.pioneer-awesome-window-actions').detach();
$(parent).append(btns);
}


});


$('body').on('DOMNodeInserted', '#hdr-toggle-btn', function(){

// $('#hdr-toggle-btn').addClass('filter-off');

// $('#hdr-toggle-btn').mousemove(function(){
$('#hdr-toggle-btn').click(function(){
		if( $('.xhdr table tbody tr:nth-child(3)').css('display')=="table-row"){
			hideGridFilter();
		}
		else{
			showGirdFilter();
		}

    $('#hdr-toggle-btn').delay(500).fadeOut();


	// alert('yo!');
	// console.log('+++++');


});
// eo hdr click
$('#hdr-toggle-btn').mouseover(function(){
		clearInterval(interval);

	// alert('yo!');
	// console.log('+++++');


});

// console.log($('#hdr-toggle-btn'));
});




});
// eo $()''\

