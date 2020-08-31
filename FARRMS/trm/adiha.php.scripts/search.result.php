<?php
/**
 * Screen to show the result of the search located in the main screen nav bar. 
 * @copyright Pioneer Solutions
 */
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
    	require_once('components/include.file.v3.php'); 
		require_once('components/include.ssrs.reporting.files.php');
		
        $search_text = (isset($_GET["search_text"]) && $_GET["search_text"] != '') ? $_GET["search_text"] : '';
        $search_text = str_replace("'", "^", $search_text);
        $search_objects = (isset($_GET["search_objects"]) && $_GET["search_objects"] != '') ? $_GET["search_objects"] : '';
        $form_namespace = 'searchResult';
	    $layout_json = '[
            {
                id: "a",
                header:false,
                height:100, 
            },
            {
                id: "b",
                header:false
            }
        ]';
	    $layout_obj = new AdihaLayout(); 
	    echo $layout_obj->init_layout('search_layout', 'search_container', '2E', $layout_json, $form_namespace);
	    $url = "search.result.detail.php?search_text=" . $search_text . "&search_objects=" . $search_objects;
	    echo $layout_obj->attach_url('b', $url);
        echo $layout_obj->attach_html_object('a', 'search_bar');
	    echo $layout_obj->close_layout();        
        $search_text = str_replace("^", "'", $search_text);
    ?>    
    <link href="<?php echo $main_menu_path; ?>bootstrap-3.3.1/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <script src="<?php echo $main_menu_path; ?>bootstrap-3.3.1/dist/js/bootstrap.js" type="text/javascript"></script>
    <style type="text/css">    	
    	html, body {
	        width: 100%;
	        height: 100%;
	        margin: 0px;
	        padding: 0px;
	        overflow: hidden;
	    }

	    div#search_container {
			position: relative;
			margin-top: 5px;
			width: 100%;
	        height: 100%;
		}

    	.dropdown.dropdown-lg .dropdown-menu {
		    margin-top: -1px;
		    padding: 6px 20px;
		}
		.input-group-btn .btn-group {
		    display: flex !important;
		}
		.btn-group .btn {
		    border-radius: 0;
		    margin-left: -1px;
		}
		.btn-group .btn:last-child {
		    border-top-right-radius: 4px;
		    border-bottom-right-radius: 4px;
		}
		.btn-group .form-horizontal .btn[type="submit"] {
		  border-top-left-radius: 4px;
		  border-bottom-left-radius: 4px;
		}
		.form-horizontal .form-group {
		    margin-left: 0;
		    margin-right: 0;
		}
		.form-group .form-control:last-child {
		    border-top-left-radius: 4px;
		    border-bottom-left-radius: 4px;
		}

		@media screen and (min-width: 768px) {
		    #adv-search {
		        width: 700px;
		        margin: 0 auto;
		    }
		    .dropdown.dropdown-lg {
		        position: static !important;
		    }
		    .dropdown.dropdown-lg .dropdown-menu {
		        min-width: 700px;
		    }
		}
	    
    </style>
</head>
<body>
	<div class="container" id="search_bar" style="display: none;">
		<div class="row">
	        <div class="input-group" id="adv-search" style="">
            	<input type="text" name="txt_search" id="txt_search" value="<?php echo $search_text; ?>" class="form-control" onkeypress="if (event.keyCode==13) {search_text();}" />                
                <div class="input-group-btn">
                    <div class="btn-group" role="group">
                        <div class="dropdown dropdown-lg">
                            <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><span class="caret"></span></button>
                            <div class="dropdown-menu dropdown-menu-right" role="menu" style="color:black;padding:5px 0px 5px 10px;">
                                 
                                    <label><?php echo get_locale_value('Search objects'); ?></label><div class="clear"></div>
                                    <div class="checkbox-nice checkbox-inline">
                                        <input type="checkbox" name="search_objects" id="contract" value="contract" />
                                        <label for="contract"><?php echo get_locale_value('Contract'); ?></label>
                                    </div>
                                    <div class="checkbox-nice checkbox-inline">
                                        <input type="checkbox"  name="search_objects" id="counterparty" value="counterparty" />
                                        <label for="counterparty"><?php echo get_locale_value('Counterparty'); ?></label>
                                    </div>
									<div class="checkbox-nice checkbox-inline">
                                        <input type="checkbox" name="search_objects" id="creditinfo" value="credit info" />
                                        <label for="contract"><?php echo get_locale_value('Credit Info'); ?></label>
                                    </div>
									<div class="checkbox-nice checkbox-inline">
                                        <input type="checkbox" name="search_objects" id="deal" value="deal" />
                                        <label for="deal"><?php echo get_locale_value('Deal'); ?></label>
                                    </div>
                                    <div class="checkbox-nice checkbox-inline">
                                        <input type="checkbox"  name="search_objects" id="document" value="document" />
                                        <label for="document"><?php echo get_locale_value('Document'); ?></label>
                                    </div>
                                 	<div class="checkbox-nice checkbox-inline">
	                                    <input type="checkbox"  name="search_objects" id="shipment" value="Shipment" />
	                                    <label for="document"><?php echo get_locale_value('Shipment'); ?></label>
	                                </div>
	                                <div class="checkbox-nice checkbox-inline">
	                                    <input type="checkbox"  name="search_objects" id="email" value="email" />
	                                    <label for="email"><?php echo get_locale_value('Email'); ?></label>
	                                </div>
									<div class="checkbox-nice checkbox-inline">
	                                    <input type="checkbox"  name="search_objects" id="incident_log" value="incident log" />
	                                    <label for="incident_log"><?php echo get_locale_value('Incident Log'); ?></label>
	                                </div>
                            </div>
                        </div>
                        <button type="button" class="btn btn-primary" onclick="search_text();"><i class="fa fa-search "></i></button>
                    </div>
                </div>
            </div>
             
        </div>
	</div>

	<div id="search_container"></div>
</body>
<script type="text/javascript">
	$(function() {
		var search_objects = '<?php echo $search_objects;?>';
		var obj_arr = search_objects.split(',');

		for (var i = 0; i < obj_arr.length; i++) {
		   $("#"+obj_arr[i]).attr('checked', true);
		}
	})
	
	/**
	 * [search_text search function]
	 */
	search_text = function() {
		var search_text = $('#txt_search').val();
 
		if (window.parent.dhx_wins) {
			var self_win_obj = window.parent.dhx_wins.window("GLOBAL_SEARCH_WINDOW");
			self_win_obj.setText('Search results for "<i>' + search_text + '</i>"');
		}
        
        var search_text = search_text.replace(/'/gi, "''''");
		var search_objects = $("input[name=search_objects]:checked").map(function () {
                                return this.value;
                        }).get().join(',');
		
		var url = "search.result.detail.php?search_text="  + search_text + "&search_objects=" + search_objects;
		searchResult.search_layout.cells('b').attachURL(url); 
	}

	var deal_report_wins;
	/**
	 * [open_deal_summary_report Open Deal Summary Reprot - called on double click on deal grid - placed here to open window in main window level]
	 * @param  {[type]} deal_id [deal_id]
	 */
	searchResult.open_deal_summary_report = function(deal_id) {
		if (deal_report_wins != null && deal_report_wins.unload != null) {
            deal_report_wins.unload();
            deal_report_wins = w1 = null;
        }

        if (!deal_report_wins) {
            deal_report_wins = new dhtmlXWindows();
        }

        var win_title = 'Deal Summary - ' + deal_id;
        var win_url = app_form_path + '_deal_capture/maintain_deals/deal.summary.report.php';
        var win = deal_report_wins.createWindow('w1', 0, 0, 400, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(win_url, false, {deal_id:deal_id});

        win.attachEvent('onClose', function(w) {            
            return true;
        });
	}
</script>
</html>