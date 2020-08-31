<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
    <?php
    include '../../../../adiha.php.scripts/components/include.file.v3.php';
    $php_script_loc = $app_php_script_loc;

    $rights_etag_view = 10163100;
    $rights_etag_detail_iu = 10163110;

    $has_rights_etag_view = false;
    $has_rights_etag_detail_iu = false;

    list (
        $has_rights_etag_view,
        $has_rights_etag_detail_iu
        )
        = build_security_rights(
        $rights_etag_view,
        $rights_etag_detail_iu
    );
    $form_namespace = "detail";
    $etag_id = $_GET['etag_id'];
	$oati_tag_id = $_GET['oati_tag_id'];
    
    $layout_json = '[{id: "a", header:false, height:60},{id: "b", header:false}]';
    
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('etag_details', '', '2E', $layout_json, $form_namespace);
    
	$form_json = '[
					{type: "settings", position: "label-left", labelWidth: 150, inputWidth: 130, position: "label-top", offsetLeft: 20},
					{type: "input", name: "tag_id", label: "Etag Id", disabled: true, value: "' . $etag_id . '"}, {type: "newcolumn"},
					{type: "input", name: "oati_tag_id", label: "Oati Tag Id", inputWidth: 600, disabled: true, value: "' . $oati_tag_id . '"}
				]';
	
	echo $layout_obj->attach_form('etag_detail_form', 'a');
    $etag_detail_form = new AdihaForm();
    echo $etag_detail_form->init_by_attach('etag_detail_form', $form_namespace);
    echo $etag_detail_form->load_form($form_json);
	
	/*
    $menu_name = 'detail_menu';
    $menu_json = '[
            {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif"},
            {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                {id:"add", text:"Add", img:"add.gif", imgdis: "add_dis.gif"}
            ]}
            ]';

    echo $layout_obj->attach_menu_layout_cell($menu_name, 'b', $menu_json, $form_namespace.'.menu_click');
    */
	echo $layout_obj->attach_grid_cell('etag_detail_grid', 'b');
    $grid_obj = new GridTable('etag_details');
    echo $grid_obj->init_grid_table('etag_detail_grid', $form_namespace);
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_data("exec spa_etag @flag='x',@etag_id=".$etag_id, '');
    echo $grid_obj->load_grid_functions();
	
    //echo $layout_obj->attach_url("b", "etag.detail.grid.php?etag_id=$etag_id");
    echo $layout_obj->close_layout();
    
    ?>
    
    <script type="text/javascript">
        
		$(function(){
			var etag_id = '<?php echo $etag_id; ?>';
			var param = {
							"flag": "a",
							"action": "spa_etag",
							"grid_type": "g",
							"etag_id": etag_id
						};
			
			param = $.param(param);
			var param_url = js_data_collector_url + "&" + param;
			detail.etag_detail_grid.clearAll();
			detail.etag_detail_grid.loadXML(param_url);			
		})
		
		/*
        detail.menu_click = function(id) {
    		var ifr_detail= detail.etag_details.cells("a").getFrame();
            
            switch(id) {
                case "add":
                    var new_id = (new Date()).valueOf();
                    detail.etag_detail_grid.addRow(new_id,'');
                    break;
                case "save":
                    save_detail();
                    break;
                default:
					break;
            }
    	}
        
        function save_detail() {
			var etag_id = '<?php echo $etag_id; ?>';
			var oati_tag_id = '<?php echo $oati_tag_id; ?>';
			var xml = '<Root>';
			detail.etag_detail_grid.forEachRow(function(id){
				xml += '<PSRecordset ';
				xml += 'etag_id ="' + etag_id + '" oati_tag_id="' + oati_tag_id + '"'; 
				detail.etag_detail_grid.forEachCell(id,function(cellObj,ind){
					if (ind > 1) {
						xml += ' ' + detail.etag_detail_grid.getColumnId(ind) + '="' + detail.etag_detail_grid.cells2(id,ind).getValue() + '"';
					}
				}); 
			})
			xml += '</Root>'
			
			var param = {
    	            "flag": "x",
    	            "action": "spa_etag_detail",
    	            "xml": xml
    	        };
                
            adiha_post_data('alert', param, '', '', '', '');
        }
		*/
    </script>
    <style>
        html, body {
            width: 100%;
            height: 100%;
            margin: 0px;
            padding: 0px;
            background-color: #ebebeb;
            overflow: hidden;
        }
    </style>