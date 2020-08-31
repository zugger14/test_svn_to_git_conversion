<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        overflow: hidden;
    }
</style>
<?php
    include 'components/include.file.v3.php';
    $form_name = 'form_deal_search';
    $name_space = 'deal_search';
    $parent_form_name = $_GET['form_name'];
    $browse_name = $_GET['browse_name'];
    
    //JSON for Layout
    $layout_json = '[
                        {
                            id:             "a",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            height:         60,
                            fix_size:       [true,true]
                        },
                        {
                            id:             "b",
                            text:           "Deal Search",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    //Creating Layout
    $deal_search_layout = new AdihaLayout();
    echo $deal_search_layout->init_layout('deal_search_layout', '', '2E', $layout_json, $name_space);
    
    $form_object = new AdihaForm();
    
    $general_form_structure = "[
        {type: 'input', name: 'txt_search_text', label: 'Search Deal By Word or Phrase', width: 185, position: 'absolute', inputLeft: 5, inputTop: 30, labelLeft: 5, labelTop: 5, labelWidth: 300, inputHeight: 29},
     ]"; 
        
    echo $deal_search_layout->attach_form($form_name, 'a');
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($general_form_structure);
    
    $deal_toolbar_json = '[
                        {id:"ok", type:"button", img:"tick.png", text:"Ok", title:"Ok"},
                        {id:"refresh", type:"button", img:"refresh.gif", imgdis:"excel_dis.gif", text:"Refresh", title:"Refresh"},
                        {id:"excel", type:"button", img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                        {id:"pdf", type:"button", img:"pdf.gif", text:"PDF", title:"PDF"}
                    ]';
  
    //Attaching toolbar for tree
    $toolbar_deal = 'formula_toolbar';
    echo $deal_search_layout->attach_toolbar_cell($toolbar_deal, 'b');
    $toolbar_deal_search = new AdihaToolbar();
    echo $toolbar_deal_search->init_by_attach($toolbar_deal, $name_space);
    echo $toolbar_deal_search->load_toolbar($deal_toolbar_json);
    echo $toolbar_deal_search->attach_event('', 'onClick', 'run_toolbar_click');
       
    //Closing Layout
    echo $deal_search_layout->close_layout();       
?>
<script type="text/javascript">
    $(function(){
        deal_search.form_deal_search.attachEvent("onKeyUp",function(inp, ev, name, value){
            if (ev.keyCode == 13 && (name == 'txt_search_text')) {
                run_toolbar_click('refresh');
            }
        }); 
    });
    
    function run_toolbar_click (args) {
        switch(args) {
            case 'refresh': 
                var search_string = deal_search.form_deal_search.getItemValue('txt_search_text');               
                var search_tables = "''master_deal_view''";
                
                if (search_string == '') {
                    show_messagebox('Please enter search keyword.');
                    return;
                }
                
                deal_search.grd_deal_search = deal_search.deal_search_layout.cells('b').attachGrid();
                deal_search.grd_deal_search.setImagePath(js_image_path + "dhxgrid_web/");
                deal_search.grd_deal_search.setHeader('Process Table,Deal ID,Details'); 
                deal_search.grd_deal_search.setColumnIds("ProcessTable,Deal ID,Details");
                deal_search.grd_deal_search.setColTypes("ro,ro,ro"); 
                deal_search.grd_deal_search.setInitWidths('150,150,470'); 
                deal_search.grd_deal_search.setColumnsVisibility('false,false,false'); 
                deal_search.grd_deal_search.enableMultiselect(true);
                deal_search.grd_deal_search.init();
                
                var sp_url_param = {                    
                    "flag":         's',
                    "searchString": search_string,
                    "searchTables": search_tables,
                    "callFrom":     'd',
                    "action":       "spa_search_engine"
                };
        
                sp_url_param  = $.param(sp_url_param );
                var sp_url  = js_data_collector_url + "&" + sp_url_param ;
                deal_search.grd_deal_search.loadXML(sp_url);
            break;
            case 'ok':
                var filter_id;
                
                if (deal_search.grd_deal_search != undefined) {
                    if (deal_search.grd_deal_search.getSelectedRowId() != null) { 
                        var deal_filter_id = deal_search.grd_deal_search.getSelectedRowId();
                        var selected_row_array_r = deal_filter_id.split(',');
                        
                        for(var j = 0; j < selected_row_array_r.length; j++) {
                    
                            if (j == 0) {
                                filter_id = deal_search.grd_deal_search.cells(selected_row_array_r[j], 1).getValue();
                            } else {
                                filter_id = filter_id + ',' + deal_search.grd_deal_search.cells(selected_row_array_r[j], 1).getValue();
                            }
                        }
                    } else {
                        show_messagebox('Please select the data from the grid.')
                        return;
                    }                
                } else {
                    show_messagebox('Please refresh the grid.')
                    return;
                }
                
                var data = {                    
                    "flag":         "i",
                    "deal_id":      filter_id,
                    "action":       "spa_populate_deal"
                };
        
                adiha_post_data("return_array", data, "", "", "filter_change_callback");
                break;
            case 'excel':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                deal_search.grd_deal_search.toExcel(path);
                break;
            case 'pdf':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                deal_search.grd_deal_search.toPDF(path);
                break;
        }
    }
    
    function filter_change_callback (result) {        
        var deal_filter_process_table = result[0][0];
        var filter_id = result[0][1];

        var parent_form_name = '<?php echo $parent_form_name; ?>';
        var browse_name = '<?php echo $browse_name; ?>';
        var input_id = browse_name.replace("browse_", "");
        var input_label = browse_name.replace("browse_", "label_");
            
        if (parent_form_name == '') {
            eval('var parent_form = parent.run_deal_settlement.form_run_deal_settlement.getForm()');
            parent_form.setItemValue('txt_process_table', deal_filter_process_table);
            parent_form.setItemValue('label_deal_filter', filter_id);
            parent_form.setItemValue('deal_filter', filter_id);
            parent.deal_search.close();
        } else {
            eval('var parent_form = parent.'+parent_form_name+'.getForm()');
            parent_form.setItemValue(input_id, deal_filter_process_table);
            parent_form.setItemValue(input_label, filter_id);
            parent.new_browse.close();    
        }
        
        
        
    }
</script>