<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php 
    $layout_obj = new AdihaLayout();
	$namespace = 'ns_dice_item';
    
    $link_id = get_sanitized_value($_POST["link_id"] ?? 'NULL');
    $deal_id = get_sanitized_value($_POST["deal_id"] ?? 'NULL');
    $desc = get_sanitized_value($_POST["desc"] ?? 'NULL');
    $term_start = get_sanitized_value($_POST["term_start"] ?? 'NULL');
    $term_end = get_sanitized_value($_POST["term_end"] ?? 'NULL');
    $effective_date = get_sanitized_value($_POST["eff_date"] ?? 'NULL');

	$layout_json = '[{id: "a", header:false, height:200},{id: "b", header:true, text:"Deals"}]';
    $layout_name = 'layout_dice_item';
    echo $layout_obj->init_layout($layout_name, '', '2E', $layout_json, $namespace);
	
    
    $toolbar_obj = new AdihaToolbar();
    $toolbar_json = '[{id:"save", type:"button", img: "save.gif", img_disabled: "save_dis.gif", text:"Save", title: "Save"}]';
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $namespace . '.save_click');
    
    $form_obj = new AdihaForm();
    $form_json = '[{"type": "settings", position: "label-top", inputWidth:150, labelWidth:150},
    			   {"type": "block", blockOffset: 20, width:"auto", list: [
                       {"type":"input", name:"link_id" ,label:"link ID",disabled:true, value:" ' . $link_id . '"},
                       {"type": "newcolumn", offset:20},
                       {"type":"input", "name":"deal_id", "label": "Deal ID",disabled:true, value:" ' . $deal_id . '"}                       
                   ]},
                   {"type": "block", blockOffset: 20, width:"auto", list: [
                        {"type": "input", "name": "effective_date", "label": "Effective Date",disabled:true, value: "' . $effective_date . '"},
                        {"type": "newcolumn", offset:20},
                        {"type":"input", "name":"link_desc", "label": "Description",disabled:true, value:" ' . $desc . '"}
                        ]
                   },
                   {"type": "block", blockOffset: 20, width:"auto", list: [
                        {"type": "input", "name": "term_start", "label": "Entire Term Start",disabled:true, value: "' . $term_start . '"},
                        {"type": "newcolumn", offset:20},
                        {"type": "input", "name": "term_end", "label": "Entire Term End",disabled:true, value: "' . $term_end . '"},
                                               
                    ]}
                  ]';
                  
    $form_name = 'form_dice_item';
    echo $layout_obj->attach_form($form_name, 'a');    
    echo $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->load_form($form_json);
    
    
    
    $grid_obj = new AdihaGrid();
    $sp_url = "EXEC spa_fas_link_detail_dicing @flag='s', @link_id=" . $link_id . ", @source_deal_header_id=" . $deal_id;
    $grid_name = 'grid_dice_item';
    echo $layout_obj->attach_grid_cell($grid_name, 'b');  
    echo $grid_obj->init_by_attach($grid_name, $namespace);
    echo $grid_obj->set_header('#master_checkbox,Term Start,Percentage Included, Effective Date');
    echo $grid_obj->set_widths('50,100,120,100');
    //echo $grid_obj->split_grid(1);    
    echo $grid_obj->set_column_types('ch,ro,ed,dhxCalendarA');
    echo $grid_obj->set_sorting_preference('str,str,str');     
    echo $grid_obj->set_columns_ids('is_chk,term_start,percentage_included,effective_date');
    //echo $grid_obj->set_search_filter(false,"#text_filter,#text_filter");
    echo $grid_obj->set_column_visibility("false,false,false,false");
    echo $grid_obj->set_date_format("%n/%j/%Y","%Y-%m-%d");
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_data($sp_url);
    echo $grid_obj->load_grid_functions();
    
    echo $layout_obj->close_layout();
?>
</body>
<script type="text/javascript">
    $(function(){
        attached_obj = ns_dice_item.layout_dice_item.cells('b').getAttachedObject();
        attached_obj.setColAlign("center,center,center,center");
    });
    ns_dice_item.save_click = function() {
        var grid_xml = 'NULL';
        attached_obj = ns_dice_item.layout_dice_item.cells('b').getAttachedObject();
        
        if (attached_obj instanceof dhtmlXGridObject) {
            attached_obj.clearSelection();
            var row_no = attached_obj.getRowsNum();
            var col_no = attached_obj.getColumnsNum();
            grid_xml = "<Root>";
            var col_value, col_id;
            
            for(row_index = 0; row_index < row_no; row_index++) {
                if(attached_obj.cells2(row_index,0).getValue() == 1) {
                    grid_xml += "<PSRecordset ";
                    for(var cellIndex = 0; cellIndex < col_no; cellIndex++){
                        col_value = attached_obj.cells2(row_index,cellIndex).getValue();
                        col_id = attached_obj.getColumnId(cellIndex);                            
                        grid_xml += " " + col_id + '="' + col_value + '"';
                    }
                    grid_xml += '></PSRecordset> ';   
                }                            
            }
            grid_xml += "</Root>";
            
        }
       
        var deal_id = '<?php echo $deal_id; ?>';
        var link_id = '<?php echo $link_id; ?>';
        var data = {
                        "action": "spa_fas_link_detail_dicing",
                        "flag": 'u',
                        "source_deal_header_id": deal_id,
                        "link_id": link_id,
                        "xml": grid_xml
                    };
        
        adiha_post_data('array', data, '', '', 'post_item_dicing', '');
    }
    
    function post_item_dicing(result) {
        if (result[0].errorcode == 'Success') {
            var win_obj = window.parent.dice_window.window("w1");
            win_obj.close();
        } else {
            dhtmlx.alert({
                   title: 'Error',
                   type: "alert-error",
                   text: result[0].message
                });
        }
    }
    

</script>
</html>