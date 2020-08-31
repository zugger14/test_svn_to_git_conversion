<?php
/**
* Formula editor screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <link rel="stylesheet" href="<?php echo $app_php_script_loc; ?>components/jQuery/jquery-ui.css"/>
    <script src="<?php echo $app_php_script_loc; ?>components/jQuery/jquery-ui.js"></script>
    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/formula_parser.js"></script>
    <!-- load ace -->
	<script src="../../../adiha.php.scripts/components/lib/ace/ace.js"></script>
	<!-- load ace language tools -->
	<script src="../../../adiha.php.scripts/components/lib/ace/ext-language_tools.js"></script>
    <style type="text/css">
    .dhxform_obj_dhx_web div.disabled div.dhxform_btn { border:none!important; }
    .dhxform_obj_dhx_web div.browse_clear.dhxform_item_label_left, .dhxform_obj_dhx_web div.browse_open.dhxform_item_label_left{
        top:-10px;
    }
	
    </style>
</head>
<body class = "bfix">
    <?php
        $form_name = 'frm_formula_editor';
        $formula_id = (isset($_GET['formula_id']) ? get_sanitized_value($_GET['formula_id']) : -1);
        $formula_id = ($formula_id == -1 || $formula_id == '') ? 'NULL' : $formula_id;        
        $enable_disable_button = ($formula_id == 'NULL') ? 'true' : 'false';        
        $system_formula = get_sanitized_value($_GET['system_formula'] ?? 'NULL');
        $system_enable = get_sanitized_value($_GET['system_enable'] ?? 'NULL');
        $ems_model_name = get_sanitized_value($_GET['ems_model_name'] ?? 'NULL');
        $formula_type = isset($_GET['formula_type']) ? get_sanitized_value($_GET['formula_type']) : 'd';
        $formula_group_id = get_sanitized_value($_GET['formula_group_id'] ?? 'NULL');
        $sequence_number = get_sanitized_value($_GET['sequence_number'] ?? 'NULL');
        $formula_nested_id = get_sanitized_value($_GET['formula_nested_id'] ?? 'NULL');
        $is_rate_schedule = get_sanitized_value($_GET['is_rate_schedule'] ?? 'NULL');
        $rate_category_grid = get_sanitized_value($_GET['rate_category_grid'] ?? 'NULL');
        $row_id = get_sanitized_value($_GET['row_id'] ?? 'NULL');
        $php_script_loc = $app_php_script_loc;

        $checked_status = '';

        /* For Formula Editor as browse */
        $browse_form = get_sanitized_value($_GET['form_name'] ?? ''); 
        $browse_name = get_sanitized_value($_GET['browse_name'] ?? '');
        $is_browse = isset($_GET['is_browse']) ? get_sanitized_value($_GET['is_browse']) : 'n';

        $call_from = get_sanitized_value($_GET['call_from'] ?? ''); 

        if (isset($_GET['insert_or_details']) && get_sanitized_value($_GET['insert_or_details']) == 'insert') {
            $deal_insert_or_delete = 'insert';
        } else if (isset($_GET['insert_or_details']) && get_sanitized_value($_GET['insert_or_details']) == 'details') {
            $deal_insert_or_delete = 'details';
        } else {
            $deal_insert_or_delete = 'NULL';
        }

        $rights_formula_editor = 10211017;
        list (
            $has_right_formula_editor
        ) = build_security_rights (
            $rights_formula_editor
        );
        $stat_data_value = '';
        $txt_formula = '';
        $formula_name = '';
        $formula_string = '';
        $formula_string_title = '';
        $is_template = 'NULL';
        $formula_source_type = '';
        $enable_edit = true;
        $js_enable_edit = 'true';
        $edit_img = 'edit';
        $edit_tips = 'Click to Disable Edit';
        $formula_html = '';

        if ($formula_id != 'NULL') {
            $sp_url = "EXEC spa_formula_editor @flag=a, @formula_id='" . $formula_id ."'";
            $result_set = readXMLURL($sp_url);
            $txt_formula = $result_set[0][1];
            $formula_string = $result_set[0][1];
            $formula_string_title = $result_set[0][2]; // formula_name from SettlementTracker is formula_string here. formula_name has a different meaning.
            $formula_name = $result_set[0][3];
            $stat_data_value = $result_set[0][4];
            $is_template = $result_set[0][5];
            $formula_source_type = $result_set[0][6];
            $formula_html = $result_set[0][7];
			$formula_html = str_replace("''", "'", $formula_html);
            $enable_edit = false;
            $js_enable_edit = 'false';
            $edit_img = 'unedit';
            $edit_tips = 'Click to Edit Formula';
        }
        
        $formula_string = urlencode($formula_string);
        $formula_string_title = urlencode($formula_string_title);
        $txt_formula = urlencode($txt_formula);

        $select_template = ($call_from == 'formula_builder') ? 1 : 0;
        $select_template = ($call_from == 'other' || $call_from == 'deal') ? 0 : $select_template;    

        $enable_edit_template = ($call_from == 'formula_builder') ? 0 : 1;
        $enable_edit_template = ($call_from == 'other' || $call_from == 'deal') ? 1 : $enable_edit_template;

        $formula_source_type = ($formula_source_type == '') ? 'f' : $formula_source_type;

        $enable_edit_formula_browse = ($call_from == 'formula_builder') ? 0 : 1;

        if ($call_from == 'formula_builder') {
            $enable_edit_formula_name = 1;
        } else {
            $enable_edit_formula_name = ($select_template == 1) ? 0 : 1;
        } 

        $layout_json = '[
                            {
                                id:             "a",
                                text:           "Functions",
                                header:         true,
                                width:          200,
                                collapse:       false,
                                fix_size:       [false,null]
                            },
                            {
                                id:             "b",
                                text:           "Formula",
                                height:         160,
                                header:         true,
                                collapse:       false,
                                fix_size:       [false,null]
                            },
                            {
                                id:             "c",
                                text:           "Editor",
                                header:         true,
                                collapse:       false,
                                fix_size:       [false,null]
                            }
                        ]';

        $tree_toolbar_json = '[
                            {id:"search_text", type:"buttonInput", text:"Search...", title:"Search Formula", width:160}
                        ]';

        $formula_toolbar_json = '[
                            {id:"verify", type:"button", img:"verify.png",imgdis:"verify_dis.gif", text:"Verify", title:"Verify"},                                                        
                            {id:"clear", type:"button", img:"clear.gif", text:"Clear", title:"Clear" },
                            {id:"enable_disable_edit", type:"buttonTwoState", img:"edit.gif", imgdis:"edit_dis.gif", text:"Enable/Disable", title:"Enable/Disable", disabled: "'. $enable_disable_button .'"},
                            {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled: "'.$has_right_formula_editor.'"},
                            {id:"remove", type:"button", img:"trash.gif", imgdis:"trash_dis.gif", text:"Remove", title:"Remove Formula"}
                        ]';
        $name_space = 'formula_editor';

        //Creating Layout
        $formula_layout = new AdihaLayout();
        echo $formula_layout->init_layout('formula_layout', '', '3L', $layout_json, $name_space);

        //Attaching Tree
        $tree_name = 'formula_tree';
        echo $formula_layout->attach_tree_cell($tree_name, 'a');
        $tree_obj = new AdihaTree();
        echo $tree_obj->init_by_attach($tree_name, $name_space);
        echo $tree_obj->enable_external_drag('formula_tags', 'formula_draghandler');
        echo $tree_obj->attach_event('', 'onXLE', 'formula_tree_onload');
        echo $tree_obj->load_tree_functions();

        //Attaching toolbar for tree
        $toolbar_tree = 'tree_toolbar';
        echo $formula_layout->attach_toolbar_cell($toolbar_tree, 'a');
        $toolbar_tree_obj = new AdihaToolbar();
        echo $toolbar_tree_obj->init_by_attach($toolbar_tree, $name_space);
        echo $toolbar_tree_obj->load_toolbar($tree_toolbar_json);

        //Attaching formula editor textarea
        echo $formula_layout->attach_html_object('c', 'div_formula_builder');

        //Attaching toolbar for formula editor textarea
        $toolbar_formula = 'formula_textarea_toolbar';
        echo $formula_layout->attach_toolbar_cell($toolbar_formula, 'c');
        $toolbar_formula_obj = new AdihaToolbar();
        echo $toolbar_formula_obj->init_by_attach($toolbar_formula, $name_space);
        echo $toolbar_formula_obj->load_toolbar($formula_toolbar_json);
        echo $toolbar_formula_obj->attach_event('', 'onClick', 'formula_textarea_toolbar_click');
        echo $toolbar_formula_obj->attach_event('', 'onStateChange', 'formula_edit_click');

        //Attaching Formula form
        $xml_file = "EXEC spa_create_application_ui_json 'j','10211017','formula editor',''";
        $return_value1 = readXMLURL($xml_file);
        $form_json = $return_value1[0][2];
        echo $formula_layout->attach_form('formula_form', 'b');
        $formula_form_obj = new AdihaForm();
        echo $formula_form_obj->init_by_attach('formula_form', $name_space);
        echo $formula_form_obj->load_form($form_json);
        echo $formula_form_obj->attach_event('', 'onChange', 'formula_form_onchange');

        //Closing Layout
        echo $formula_layout->close_layout();
        if ($formula_source_type == 'u') {
            $formula_string_title_f = '';
        } else {
            $formula_string_title_f = $formula_string_title;
        }
			
    ?>
    
    <form name="<?php echo $form_name; ?>">
        <div id="div_formula_builder" style="float: left;">
            <div id="div_param_form"></div>
            <div id="formula_tags" class="formula-textdiv" contentEditable="true" style="cursor:pointer;"></div> 
            
            <div class="clear"></div>
            <div class="component-container">
                <?php
                $enable_edit_1 = $call_from == 'formula_builder' ? true : $enable_edit;
                if($enable_edit_1==1){
                    $read_only = true;
                } else {
                    $read_only = false;
                } 
                
                if (!isset($formula_string_title)) {
                    $formula_string_title = $formula_string;
                }
                ?>
                <div id="div_formulabox">
                    <?php 
                        $formula_obj = new AdihaFormulaTextbox();
                        echo $formula_obj->init_formula_textbox('formula', 20, 30, 'formula_editor');
                        echo $formula_obj->load_formula_textbox();
                    ?>
                </div>
            </div>
        </div>
        <div>
            <span id="textarea" style="display: none;"> 
                <input type="hidden" name="session_id" value="<?php echo $session_id; ?>" />
                <textarea name="formula_xml" cols="" rows=""></textarea>
                <textarea name="formula_text" cols="" rows=""></textarea>
            </span>
        </div>
        <textarea style="display:none" name="___browse_formula_id___" id="___browse_formula_id___"><?php echo $formula_id;?></textarea>
        <textarea style="display:none" name="___browse_formula_text___" id="___browse_formula_text___"><?php echo urldecode($formula_string_title); ?></textarea>
    </form>
</body>

<style>
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        overflow: hidden;
    }

    .ui-autocomplete {
        max-height: 100px;
        max-width: 200px;
        overflow-y: auto;
        overflow-x: hidden;
        font-size: 12px;
    }

    #formula_tags {
        margin: 0 auto;
        height:183px; 
        width:638px; 
        background-color: white; 
        padding:5px;
        float: left;
        overflow: auto;
        font-size: 12px;
    }


    .param_span {
        color: blue;
    }

    .formula_span {
        color: green;
        font-weight: bold; 
    }

    .dhtmlx-custom_css_error{
          background-color:red !important;
          opacity:.8;
          border-radius:20px;
          position:absolute;
          text-align:center;
          font-weight:bold;
          font-size:16px;
          min-width:300px;
          border:5px solid #FFF;
          top: 50px;
          right: 10px;
    }
    .dhtmlx-custom_css_success{
          opacity:.8;
          border-radius:20px;
          position:absolute;
          text-align:center;
          font-weight:bold;
          font-size:16px;
          min-width:300px;
          top: 50px;
          right: 10px;
          border:5px solid #FFF;
    }
        
    .browser_label_disable {
        pointer-events: auto !important; 
    }
    
</style>
    
    <script type="text/javascript">
        var checked_status ='<?php echo (($checked_status) ? $checked_status : '0'); ?>';
		var formula_parameter_seperator = ';';
						
        /* Auto Complete logic start */
        $(function() {
            //Populating Data for the autocomplete dropdown
            data = {"action": "spa_formula_editor",
                        "flag": "w"
                    };
            
            var result_array = adiha_post_data('return_array', data, '', '', 'callback_autocomplete_arr'); //Array for dropdown build in call back function   
            
            /* For Autocomplete */
            function split(val) {
                return val.split(/@\s*/);
            }
            
            function split1(val) {
                val = val.replace(/\u00a0/g, " "); //&nbsp replaced by space
                var res = val.split(" ");
                return res[0];
            }
            
            function split_pre(val) {
                var res = val.split(/@\s*/);
                var p_val = res[0];
                var p_val_arr = p_val.split(" ");
                return p_val_arr[p_val_arr.length - 1];
            }
            
            var arg1 = '';
            var arg2 = '';
            //Return the value for matching in autocomplete dropdown
            function extractLast(term) {
                var s_val = 'abcdefgh';

                if(term.indexOf('@') > -1) {
                    var all_val = split(term).pop();
                    arg1 = split_pre(term);
                    
                    if (term != '@') {
                       s_val = split1(all_val);
                    } 
                }
                arg2 = s_val;
                return s_val;
            }
         
            $( "#formula_tags" )
              // don't navigate away from the field on tab when selecting an item
            .bind( "keydown", function(event) {
            if ( event.keyCode === $.ui.keyCode.TAB &&
                $(this).autocomplete("instance").menu.active) {
                    event.preventDefault();
                }
            })
            
            .autocomplete({
                minLength: 1,
                source: function(request, response) {
                    // delegate back to autocomplete, but extract the last term
                    response( $.ui.autocomplete.filter(
                        available_formula, extractLast(request.term) 
                    ));
                },
                
                focus: function() {
                    // prevent value inserted on focus
                    return false;
                },

                select: function(event, ui) {
                    //$('#formula_tags').addClass('formula_tag_margin');
                    var find_current = $(this).find('.current').attr('class'); // Current class to identify the recently selected formula
                    if (find_current == 'current') {
                        $(this).find('.current').remove();
                    }
                    
                    //Breakdown the formula textarea content into two part when dropdown is selected, First-Content untill the selected, Second-Content after the selected
                    var arr = split($(this).html());
                    var pop_item = arr.pop();
                    var pop_arr = pop_item.split(' ');
                    var new_pop_arr = '';
                    
                    for (i = 1; i < pop_arr.length; i++) {
                        new_pop_arr = new_pop_arr + ' ' + pop_arr[i];
                    }
                    
                    replace_text = '<a href="mailto:' + arg1 + ',' + arg2 + '">';
                    arr = arr.toString().replace(replace_text, '');
                    //Append the content untill the selected
                    //arr += '<span class="for_nested"></span>';
                    $(this).html(arr);
                    //$(this).find('.for_nested').remove();
                    
                    //Append the selected formula
                    var formula_name = ui.item.value
                    formula_function(formula_name);
                    create_formula_param(this, formula_name, 'onload');
                    
                    //Append the content after selected
                    $(this).append(new_pop_arr);
                    var html = $('#formula_tags').html();
                    html = html.replace('contenteditable="false"&gt;', '');
                    html = html.replace('class="formula_span"&gt;', '');
                    html = html.replace('class="param_span"&gt;', '');
                    $('#formula_tags').html(html);
                    setEndOfContenteditable(this); //Set text cursor to end
                    return false;
                }
            });
            /* End for Autocomplete */
            
            $("#formula_tags" ).autocomplete( "option", "position", { 
                    my: "left top", 
                    at: "left+" + 5000 + " top+" + 5000
            });
            
            //For positioning of the autocomplete dropdowm
            $('#formula_tags').keydown(function(event){
                if (event.which == 46) return;
                if (event.which != 37 && event.which != 38 && event.which != 39 && event.which != 16) {
                    if (!event.ctrlKey) {
                        html_at_caret('<span class="for_offset">T</span>', false); // for_offset class to find the offset position for autocomplete dropdown
                        x_offset = $('.for_offset').offset().left;
                        y_offset = $('.for_offset').offset().top;
                        x_offset = (x_offset - $(this).offset().left) * 0.70;
                        y_offset = y_offset - $(this).offset().top + 20;

                        $("#formula_tags" ).autocomplete( "option", "position", { 
                            my: "left top", 
                            at: "left+" + x_offset + " top+" + y_offset 
                        });

                        $('#formula_tags').find('.for_offset').remove();
                    }
                }
            });
            
            
            /*
            $("#formula_tags").keydown(function(e) {   
                e = e || window.event;
            	var keyCode = e.keyCode || e.which; 
            	
                //For Tab Alignment
//            	if (e.shiftKey && keyCode == 9) {
//            		e.preventDefault();
//            		document.execCommand("outdent", true, null);
//            	} else if (keyCode == 9) {
//            		e.preventDefault();
//            		document.execCommand('indent',true, null);
//            	} 
            	
                //Remove the empty span
                $('#formula_tags span').each(function(){
                    var span_id = $(this).attr('class');
                    if (span_id == 'param_span' || span_id == 'current') {
                    } else {
                        if($(this).html() == '') {
                            $(this).remove();
                        }
                    }
                });
                
                if ($('#formula_tags').html() == '') {
                    $('#formula_tags').addClass('formula_tag_margin');
                }
                
                //First line margin when enter is pressed.
                if(keyCode == 13) {
                   if(first_line_flag != 1) { 
                        $('#formula_tags').removeClass('formula_tag_margin');
                   }
                   first_line_flag = 0;
                }
            });
            
            $("#formula_tags").keyup(function(e) {  
                e = e || window.event;
            	var keyCode = e.keyCode || e.which; 
                
                //Maintain margin when all content is deleted.
                if(keyCode == 46) {
                    
                    if ($('#formula_tags').html() == '') {
                        $('#formula_tags').addClass('formula_tag_margin');
                    }
                }
            });
            */
        });
        /* Auto complete Logic End */    
    </script>

    
    <script type="text/javascript">
        var formula_id = '<?php echo $formula_id; ?>';
        var before_update_formula_id = formula_id; 
        var after_update_formula_id = formula_id;
        var js_enable_edit = <?php echo $js_enable_edit; ?>;
        var deal_insert_or_delete = '<?php echo $deal_insert_or_delete; ?>';
        var txt_formula = '';
        var formula_name = '<?php echo $formula_name ?>';
        var call_from = '<?php echo $call_from; ?>';
        var is_rate_schedule = '<?php echo $is_rate_schedule; ?>';
        var row_id = '<?php echo $row_id; ?>';
        var rate_category_grid = '<?php echo $rate_category_grid; ?>';
        var ems_model_name = '<?php echo $ems_model_name; ?>';
        var is_template = '<?php echo $is_template; ?>';
        
        var select_template = '<?php echo $select_template; ?>';
        var edit_template = '<?php echo $enable_edit_template; ?>';
        var formula_source_type = '<?php echo $formula_source_type; ?>';
        var edit_formula_browse = '<?php echo $enable_edit_formula_browse; ?>';
        var edit_formula_name = '<?php echo $enable_edit_formula_name ?>';
        
        var browse_form = '<?php echo $browse_form; ?>';
        var browse_name = '<?php echo $browse_name; ?>';
        var is_browse = '<?php echo $is_browse; ?>';
        
        var formula_string_title = "<?php echo $formula_string_title; ?>";
        
        var tree_expand_flag = 0;
        
        function changed_to_readonly(){
            if (edit_formula_browse == 1){
                setEnabled(false);
            } else{
                setEnabled(true);    
            }
        }
    
        $(function(){
            enable_formula_name(false);
            refresh_tree();
            var formula_string = "<?php echo $formula_string; ?>";
            set_formula_form_value('txt_formula_string', formula_string);
            var formula_html = "<?php echo urlencode($formula_html); ?>";
            set_formula_form_value('txt_formula_html', formula_html);
            var txt_formula = "<?php echo $txt_formula; ?>";
            set_formula_form_value('txt_formula', txt_formula);
            init();
            attach_browse_event('formula_editor.formula_form');
            changed_to_readonly();
            set_formula_height_width();
            
            //Onchange event when the size of layout is changed.
            formula_editor.formula_layout.attachEvent("onPanelResizeFinish", function(){
                set_formula_height_width();
            });
            
            formula_editor.formula_layout.attachEvent("onResizeFinish", function(){
                set_formula_height_width();
            });
            
            load_copy_formula();
            load_formula_search();
        });
        
        //Set the height and width of the formula editor according to size of layout cell.
        function set_formula_height_width() {
            var height = formula_editor.formula_layout.cells('c').getHeight();
            var width = formula_editor.formula_layout.cells('c').getWidth();
            // Resize ace editor
            formula_editor.resize();
            
            $('#formula_tags').css("width", width-12);
            $('#formula_tags').css("height", height-92);
        }
        
        //Initialization function [Called after form is build]
        function init() {
            //refresh_tree();
            
            enable_formula_name(edit_formula_name);
            enable_browse_button(edit_formula_browse);
            enable_template(edit_template);
            set_formula_form_value('chk_template', select_template);

            var formula_source_type = '<?php echo $formula_source_type; ?>';
            set_formula_form_value('rdo_formula_type', formula_source_type);
            set_formula_form_value('formula', formula_id);
            set_formula_form_value('label_formula', formula_name);
            var formula_string =  get_formula_form_value('txt_formula_string');
            
            enable_formula_name(false);

            if (call_from == 'formula_builder') {
                enable_remove_formula(false);
            }
            
            if (is_template == '')
                is_template = 'NULL';
        
            if (formula_id == 'NULL') {}
        
            if ((call_from == 'formula_builder')) {
                get_formula_id();
                
                enable_formula_name(true);
                enable_browse_button(false);
            }

            if (call_from != 'formula_builder') {
                
                enable_browse_button(true);
                //formula_editor.formula_textarea_toolbar.disableItem('clear');
                formula_editor.formula_textarea_toolbar.disableItem('remove');
                if (formula_id == 'NULL') {
                    $('#formula_tags').html('');
                } else {
                    enable_save_button(false);
                    enable_browse_button(false);
                    $("#formula_tags").attr('contentEditable',false);
                    formula_editor.formula_textarea_toolbar.disableItem('verify');
                    if (formula_source_type == 'u') {
                        formula_editor.set_formula_textbox_value(formula_string_title.replace(/\+/g, ' '));
                    } else if (formula_source_type == 'f') {
                        $('#formula_tags').html("<?php echo urldecode($formula_string_title_f); ?>");
                    }
                }
                
                enable_template(false);
            }

            if (is_template == 'y') {
                edit_click(1);
                
                set_formula_form_value('chk_template', true);
                enable_template(false);
            }
            
            formula_type_click();
            
            var copy_ref_flag = get_formula_form_value('txt_copy_ref_flag');
            
            if (copy_ref_flag == 'r' || call_from == 'formula_builder' || (is_template == 'y' && copy_ref_flag != 'c')) {
                enable_edit_button(false);
            }

            if (call_from == 'browser') {
                enable_remove_formula(true);
            }
        }
        
        function load_copy_formula() {
            formula_context_menu = new dhtmlXMenuObject();
            formula_context_menu.renderAsContextMenu();
            var menu_obj = [{id:"copy_formula", text:"Copy Formula"},
                            {id:"copy_formula_template", text:"Copy Formula from Template"}
                            ];
            formula_context_menu.loadStruct(menu_obj);
            formula_context_menu.addContextZone("formula_tags");
            
            formula_context_menu.attachEvent("onClick", function(menuitemId, zoneId) {
                switch(menuitemId){
                    case 'copy_formula':
                        html_at_caret('<span class="for_formula_copy"><br></span>');
                        copy_window = new dhtmlXWindows();
                        var js_path_trm = '<?php echo $app_adiha_loc; ?>';
            
                        param = js_path_trm +  'adiha.html.forms/_setup/formula_builder/formula.copy.php?call_from=copy_formula'; 

                        $('#formula_tags').blur();
                        var is_win = copy_window.isWindow('w1');

                        if (is_win == true) {
                            w1.close();
                        }    

                        w1 = copy_window.createWindow("w1", 70, 30, 800, 400);
                        w1.setText("Formula Copy");
                        w1.attachURL(param, false, true);
                        break;
                    case 'copy_formula_template':
                        html_at_caret('<span class="for_formula_copy"><br></span>');
                        copy_window = new dhtmlXWindows();
                        var js_path_trm = '<?php echo $app_adiha_loc; ?>';
            
                        param = js_path_trm +  'adiha.html.forms/_setup/formula_builder/formula.copy.php?call_from=copy_formula_template'; 

                        $('#formula_tags').blur();
                        var is_win = copy_window.isWindow('w1');

                        if (is_win == true) {
                            w1.close();
                        }    

                        w1 = copy_window.createWindow("w1", 70, 30, 800, 400);
                        w1.setText("Formula Copy");
                        w1.attachURL(param, false, true);
                        break;
                }
            });
        }
        
        function append_copy_formula(formula) {
            var formula_val = $('#formula_tags').html();
            formula_val = formula_val.replace('<span class="for_formula_copy"><br></span>', formula);
            $('#formula_tags').html(formula_val);
        }
        
        /****************************************** Form Function Start *******************************************/
        
        function formula_form_onchange(name, value) {
            if (name == 'rdo_formula_type') {
                formula_type_click();
                set_formula_height_width();
            }
        }
        
        //Function when formula type radio button is changed.
        function formula_type_click() {
            var formula_type = get_formula_form_value('rdo_formula_type');
            
            if (formula_type == 'u') {
                $('#div_formulabox').css('display', 'block');
                $('#formula_tags').css('display', 'none');
            } else if (formula_type == 'f') {
                $('#div_formulabox').css('display', 'none');
                $('#formula_tags').css('display', 'block');
            }
        }
        
        function open_formula_window_callback(return_value) {
            var formula_type = get_formula_form_value('rdo_formula_type');
            var formula_name = '';
            var formula_id = '';
            
            if (return_value[1] == 'btnOk') {
                formula_id = return_value[0];
                after_update_formula_id = formula_id;
                formula_name = return_value[2];
                var formula_string = return_value[3];
                var copy_ref_flag = return_value[4];
                
                if (copy_ref_flag == 'r') {
                    edit_click(1);

                    set_formula_form_value('chk_template', '1');
                    enable_formula_name(false);
                    enable_template(false); 

                    enable_edit_button(false);
                    $("#formula_tags").attr('contentEditable',false);                     
                } else {
                    $("#formula_tags").attr('contentEditable',true);
                    set_formula_form_value('chk_template', '0');
                    enable_formula_name(true);

                    enable_edit_button(false);                    
                }
                
                formula_editor.set_formula_textbox_value(formula_string);
                set_formula_form_value('txt_formula', formula_string);
                set_formula_form_value('txt_copy_ref_flag', copy_ref_flag);
                set_formula_form_value('txt_new_formula', 'new');

                set_formula_form_value('label_formula', formula_name);
                set_formula_form_value('formula', formula_id);

                if (formula_type == 'f') {
                    $('#formula_tags').html(formula_string);
                }

                if (formula_id != 'NULL') {
                    //set_Deletebutton_enabled(true);
                }
                if (copy_ref_flag == 'r') {
                    $('#formula_tags').attr('disabled', 'disabled');
                } else {
                    $('#formula_tags').removeAttr('disabled');
                }
            }
        }
        
        /**
        * Return the value of parameter item
        * @param    item    [Id of the form component]
        */
        function get_formula_form_value(item) {
            var item_value = formula_editor.formula_form.getItemValue(item);
            return item_value;
        }
        
        /**
        * Return the value of parameter checkbox
        * @param    item    [Id of the form component]
        */
        function get_formula_form_checked(item) {
            var item_value = formula_editor.formula_form.isItemChecked(item);
            return item_value;
        }
        
        /**
        * Set the value of parameter item
        * @param    item    [Id of the form component]
        * @param    value   [New value to be set]
        */
        function set_formula_form_value(item, value) {
            formula_editor.formula_form.setItemValue(item, value);
        }
        
        /**
        * Enable/Disable the formula name textbox
        * @param    True    [Enables the Formula Textbox]
        *           False   [Disable the Formula Textbox]
        */
        function enable_formula_name(state) {
            if (state == true) {
                formula_editor.formula_form.setReadonly("label_formula", false);
            } else if (state == false) {
                formula_editor.formula_form.setReadonly("label_formula", true);
            }
        }
        
        /**
        * Enable/Disable the template checkbox
        * @param    True    [Enables the Template Checkbox]
        *           False   [Disable the Template Checkbox]
        */
        function enable_template(state) {
            if (state == true) {
                formula_editor.formula_form.enableItem('chk_template');
            } else if (state == false) {
                formula_editor.formula_form.disableItem('chk_template');
            }
        }
        
        /**
        * Enable/Disable the browse button
        * @param    True    [Enables the browse button]
        *           False   [Disable the browse button]
        */
        function enable_browse_button(state) {
            if (state == true) {
                formula_editor.formula_form.enableItem('browse_formula');
            } else if (state == false) {
                formula_editor.formula_form.disableItem('browse_formula');
            }
        }
        
        /************************************************** Form Function End **************************************/
        
        /************************************************* Tree Function Start *************************************/
        
        function refresh_tree() {
            formula_editor.refresh_tree('spa_formula_editor', 'formula_id:formula', 'category_id:category', 'flag=r');
        }
        
        function formula_tree_onload() {
            if (tree_expand_flag == 0) {
                formula_editor.tree_collapse_all();
            } else {
                formula_editor.tree_expand_all();
            }
        }
        
        /********************************************** Tree Function End ******************************************/
        
        /******************************************* Toolbar Function Start ****************************************/
         
		function load_formula_search() {
            search_obj = formula_editor.tree_toolbar.getInput("search_text");
            dhtmlxEvent(search_obj, "focus", function(ev){
                search_obj.value = "";
            });

            dhtmlxEvent(search_obj, "blur", function(ev){
                if(search_obj.value == "") {
                    filter_formula();
                    search_obj.value = "Search...";
                }
            });

            dhtmlxEvent(search_obj, "keyup", function(ev){
               filter_formula();
            });
            
        }
        
        function filter_formula() {
            var search_formula = search_obj.value;
            var all_nodes = formula_editor.formula_tree.getAllSubItems(0);
            var all_nodes_arr = all_nodes.split(',');
            
            for (i=0; i<all_nodes.length; i++) {
                var tree_level = formula_editor.formula_tree.getLevel(all_nodes_arr[i]);
                if (tree_level == 1) {
                    formula_editor.formula_tree._idpull[all_nodes_arr[i]].htmlNode.parentNode.parentNode.style.display="";
                    var child_nodes = formula_editor.formula_tree.getAllSubItems(all_nodes_arr[i]);
                    var child_nodes_arr = child_nodes.split(',');
                    var child_exist_flag = 0;
                    
                    for (j=0; j<child_nodes_arr.length; j++) {
                        if (formula_editor.formula_tree.getItemText(child_nodes_arr[j]).toString().toLowerCase().indexOf(search_formula.toLowerCase()) > -1){
                            child_exist_flag = 1;
                            formula_editor.formula_tree._idpull[child_nodes_arr[j]].htmlNode.parentNode.parentNode.style.display="";
                        } else {
                            formula_editor.formula_tree._idpull[child_nodes_arr[j]].htmlNode.parentNode.parentNode.style.display="none";
                        }
                    }
                    
                    if (child_exist_flag == 0) {
                         formula_editor.formula_tree._idpull[all_nodes_arr[i]].htmlNode.parentNode.parentNode.style.display="none";
                    }
                }
            }
            
            if(search_formula == '') {
                formula_editor.tree_collapse_all();
            } 
        }
        
        //Function when verify and clear button is clicked.
        function formula_textarea_toolbar_click(id) {
            if (id == 'verify') {
                test_click();
            } else if (id == 'clear') {
                reset_click();
            } else if (id == 'save') {
                btn_save_click();
            } else if (id == 'remove') {
                btn_remove_formula_click();
                            
            }
        }
        
        //Function when enable/disable edit is clicked.
        function formula_edit_click(id, state) {
            if (id == 'enable_disable_edit') {
                var formula_string_title = '<?php echo $formula_string_title; ?>';
                var formula_string = "<?php echo $formula_string; ?>";
                
                edit_click(0);
                
                if (formula_source_type == 'f') {
                    if (state == true) {
                        var f_html = get_formula_form_value('txt_formula_html');
                        f_html = decodeURIComponent(f_html);
                        var formula_html = f_html.split('+').join(' ');
                        formula_html = formula_html.replace(/\%plus%/g, '+');
                        //$('#formula_tags').html(decodeURIComponent(formula_string));
                        $('#formula_tags').html(formula_html);
                    } else {
                        $('#formula_tags').html("<?php echo urldecode($formula_string_title_f); ?>");
                    }
                }
            }
        }
        
        /**
        * Enable/Disable the save button
        * @param    True    [Enables the browse button]
        *           False   [Disable the browse button]
        */
        function enable_save_button(state) {
            if (state == true) {
                if(!checked_status || checked_status == 0)
                formula_editor.formula_textarea_toolbar.enableItem('save');
            } else if (state == false) {
                formula_editor.formula_textarea_toolbar.disableItem('save');
            }
        }
        
        /**
        * Enable/Disable the remove button
        * @param    True    [Enables the browse button]
        *           False   [Disable the browse button]
        */
        function enable_remove_formula(state) {
            if (state == true) {
                formula_editor.formula_textarea_toolbar.enableItem('remove');
            } else if (state == false) {
                formula_editor.formula_textarea_toolbar.disableItem('remove');
            }
        }
        
        /**
        * Enable/Disable the edit button
        * @param    True    [Enables the browse button]
        *           False   [Disable the browse button]
        */
        function enable_edit_button(state) {
            if (state == true) {
                formula_editor.formula_textarea_toolbar.enableItem('enable_disable_edit');
            } else if (state == false) {
                formula_editor.formula_textarea_toolbar.disableItem('enable_disable_edit');
            }
        }
        
        /*************************************** Toolbar Function End ********************************************/
        
        /********************************* Formula Parameter Function Start **************************************/
        
        var img_path = "../../../adiha.php.scripts/adiha_pm_html/process_controls/"
        
        var formula_operator_arr =  ['>', '=', '<>', '<=', '<', '+', '-', '*', '/', '(', ')'];
        var formula_logical_arr =   [   'MAX'
                                        , 'MIN'
                                        , 'IF Condition'
                                        , 'IsNull'
                                        , 'AVG'
                                        , 'POWER'
                                        , 'Round'
										, 'CEILING'
										, 'SQRT'
                                    ];
        
        $(function(){
            data = {"action": "spa_formula_editor",
                        "flag": "e"
                    };
            
            var result_array = adiha_post_data('return_array', data, '', '', 'set_formula_param_arr');
        });
        
        var formula_param_arr = new Array();
        var formula_arr = new Array();
        function set_formula_param_arr(result_array) {
            formula_param_arr[0] = result_array[0][0];
            
            for(count = 1; count < result_array.length; count++) {
                formula_param_arr[count] =  result_array[count][0];
            }
        }
                                  
        function formula_function(formula_name) {
            if(jQuery.inArray(formula_name, formula_param_arr) > -1) {
                formula_create = return_param_formula(formula_name);
            } 
            else if (jQuery.inArray(formula_name, formula_arr) > -1) {
                formula_create = return_formula(formula_name);
            } 
            else if (jQuery.inArray(formula_name, formula_operator_arr) > -1) {
                formula_create = return_operator(formula_name);
            } 
            else if (jQuery.inArray(formula_name, formula_logical_arr) > -1) {
                formula_create = return_logical(formula_name);
            } else {
                 formula_create = return_formula(formula_name);
            }
            $('#formula_tags').append(formula_create);
        }
        
        //Build the formula having parameter
        function return_param_formula(formula_name) {
            var return_formula = '<span class="formula_span">' + formula_name + '</span>';
            return_formula = return_formula + '(<span class="current"></span><span class="param_span"></span><span contenteditable="false"><img id="' + formula_name + '" class= "plus_img" src="' + img_path + 'TogglePlus.gif" onclick="create_formula_param(this, \'\', \'reopen\');" style="margin-left: 2px;"></img></span>)';
            return return_formula;
        }
        
        //Build the formula without parameter
        function return_formula(formula_name) {
            return '<span class="formula_span">' + formula_name + '</span>()';
        }
        
        //Build the operator
        function return_operator(formula_name) {
            return '<span class="current"></span>' + formula_name;
        }
        
        //Build the logical synatx
        function return_logical(formula_name) {
            var formula;
            var param;
            if(formula_name == 'IF Condition') {
                formula_name =  'IF';
                param = " ' condition ' ; true ; false ";
            } 
            if(formula_name == 'IsNull') {
                param = ' condition ; value ';
            } 
            if(formula_name == 'MAX' || formula_name == 'MIN' || formula_name == 'AVG' || formula_name == 'Round') {
                param = ' Arg1 ; Arg2 ';
            }
            if (formula_name == 'POWER') {
                param = ' value ; exponent ';
            }
			if (formula_name == 'CEILING') {
                param = ' Arg1';
            }
		
			if (formula_name == 'SQRT') {
                param = ' Arg1';
            }
			
            return '<span class="current"></span><span class="formula_span">' + formula_name + '</span>(<span class="param_span">' + param + '</span>)';
        }
        
        //Drag and Drop handler
        function formula_draghandler(formula_id, formula_name) {
            var level = formula_editor.formula_tree.getLevel(formula_id);
            if (level < 2) { return; }
            
            var f_val = $('#formula_tags').text();
            if (f_val == '') $('#formula_tags').focus();
            
            //formula_function(formula_name);
            html_at_caret('<span class="for_formula_copy"></span>');
            if(jQuery.inArray(formula_name, formula_param_arr) > -1) {
                formula_create = return_param_formula(formula_name);
            } 
            else if (jQuery.inArray(formula_name, formula_arr) > -1) {
                formula_create = return_formula(formula_name);
            } 
            else if (jQuery.inArray(formula_name, formula_operator_arr) > -1) {
                formula_create = return_operator(formula_name);
            } 
            else if (jQuery.inArray(formula_name, formula_logical_arr) > -1) {
                formula_create = return_logical(formula_name);
            } else {
                 formula_create = return_formula(formula_name);
            }
            
            
            var find_current = $('#formula_tags').find('.current').attr('class'); // Current class to identify the recently selected formula
            if (find_current == 'current') {
                $('#formula_tags').find('.current').remove();
            }
            
            //$('#formula_tags').append(formula_create);
            var formula_val = $('#formula_tags').html();
            formula_val = formula_val.replace('<span class="for_formula_copy"></span>', formula_create);
            $('#formula_tags').html(formula_val);
            setEndOfContenteditable(document.getElementById('formula_tags'));
            create_formula_param('', formula_name, 'ondrop');
        }
        
        //Building the DHTMLX popup for parameter 
        function create_formula_param(obj, formula_name, callfrom) {
            $('#div_param_form').html('');
			
            if (callfrom == 'reopen') {
                var formula_name = $(obj).attr('id');
            }
            
            var param_data = build_formula_param(formula_name); // Return JSON object for building parameter popup
            
            if (param_data != '') {
                param_form = new dhtmlXForm("div_param_form");
                param_form.load(param_data, function() {
                    if (formula_name == 'MeterVol' || formula_name == 'AverageQVol' || formula_name == 'GetMeteredVolm') {
                        var value = param_form.getItemValue('Recorder ID');
                        data = { "action": " ('SELECT channel, channel_description FROM recorder_properties where meter_id = " + value + "')"
                                    };
                            
                        adiha_post_data('return_array', data, '', '', 'reload_dropdown', 0);
                    }
                    if(formula_name == 'GetLogicalValue') {
                        var value = param_form.getItemValue('Mapping Table');
                        data = { "action": " ('SELECT DISTINCT clm3_value, clm3_value FROM generic_mapping_values WHERE mapping_table_id = " + value + "')"
                                    };
                            
                        adiha_post_data('return_array', data, '', '', 'reload_logical_name', 0);
                    }
                }); 
                if (formula_name == 'MeterVol'  || formula_name == 'AverageQVol' || formula_name == 'PrevEvents' || formula_name == 'GetMeteredVolm') {
                    param_form.attachEvent("onChange", function(name, value){
                        if (name == 'Recorder ID' || name == 'Meter ID') {
                            data = { "action": " ('SELECT channel, channel_description FROM recorder_properties where meter_id = " + value + "')"
                                    };
                            
                            adiha_post_data('return_array', data, '', '', 'reload_dropdown', 1);
                        }
                    });    
                }
                if (formula_name == 'GetLogicalValue') {
                    param_form.attachEvent("onChange", function(name, value){
                        if (name == 'Mapping Table') {
                            data = { "action": " ('SELECT DISTINCT clm3_value, clm3_value FROM generic_mapping_values WHERE mapping_table_id = " + value + "')"
                                    };
                            
                            adiha_post_data('return_array', data, '', '', 'reload_logical_name', 1);
                        }
                    });
                }                
                if (formula_name == 'ContractValue') {
                    param_form.attachEvent("onChange", function(name, value){
                        if (name == 'Contract') {
                            data = { "action": " ('SELECT sdv.value_id, sdv.code FROM contract_group cg INNER JOIN contract_group_detail cgd ON cg.contract_id = cgd.contract_id INNER JOIN static_data_value sdv ON sdv.value_id = cgd.invoice_line_item_id WHERE cg.contract_id = " + value + "')"
                                    };
                            
                            adiha_post_data('return_array', data, '', '', 'reload_dropdown_contract', 1);
                        }
                    });    
                }
                
                /* Set the value while popup is re-opened*/
                var default_value_array = [];
                if (callfrom == 'reopen') {
                    var result_text= $(obj).parent().prev('span').text();
                    var result_array = result_text.split(",");
                    var count = 0;
                    param_form.forEachItem(function(name){
                        var item_type = param_form.getItemType(name);
                        if (item_type == 'input' || item_type == 'select' || item_type == 'calendar') {
                            if (result_array[count] == "'NULL'")
                                result_array[count] = '';
                            if (name == 'Logical Name'){
                                if (result_array[count] != undefined && result_array[count] != '' )
                                    result_array[count] = result_array[count].replace(/'/g,"");
                            }
                            /* Load dependent combo if present*/
                            if ((name == 'Recorder ID' || name == 'Meter ID' || name == 'Mapping Table' || name == 'Contract') &&
                                (formula_name == 'MeterVol'  || formula_name == 'AverageQVol' || formula_name == 'PrevEvents' || formula_name == 'GetMeteredVolm' || formula_name == 'GetLogicalValue' || formula_name == 'ContractValue')) {
                                param_form.callEvent("onChange", [name,result_array[count]]);
                            }
                            default_value_array[name] = result_array[count]; // Save default value for each field in array
                            count++;
                        }
                    });
                }

                setTimeout(function() {
                    for( let key in default_value_array) {
                        if (default_value_array.hasOwnProperty(key)) {
                            param_form.setItemValue(key,default_value_array[key]);
                        }
                    }
                }, 100);
                /*End of value being set*/
                
                param_form.attachEvent("onButtonClick", function(){
                    if (param_form.validate() == true) {
                        var param_result = new Array();
                        //Getting the input value from the popup
        				param_form.forEachItem(function(name){
        				    var item_type = param_form.getItemType(name);
                            
                            if (item_type == 'input' || item_type == 'select' || item_type == 'calendar') {
                                var item_val = param_form.getItemValue(name, true);
                                if (item_val == '') {
                                    item_val = 'NULL';
                                } else if (formula_name == 'GetLogicalValue') {
									if(name == 'Logical Name'){
                                        item_val = "'" + item_val + "'"; //For quote in string
                                    }
								} else {
                                   if (item_type == 'input' || item_type == 'calendar') {
                                        item_val = item_val;
                                   }
                               }
                               param_result.push(item_val);
                               
                            }
                        });
						param_result = param_result.join(formula_parameter_seperator)
						
                        //Setting input value of the popup as parameter
                        if(callfrom == 'onload') {
                             $(obj).find('.current').next('span').text(param_result);
                        } else if (callfrom == 'ondrop') {
                             //$('#formula_tags').find('img:last').parent().prev('span').text(param_result);
                            $('#formula_tags').find('.current').next('span').text(param_result);
                        } else if (callfrom == 'reopen') {
                            $(obj).parent().prev('span').text(param_result);
                        }
                       
                        myPop.hide();
                        setEndOfContenteditable(document.getElementById('formula_tags')); //Set text cursor to end
                    } 
    			});
                
                // Setting the position of the parameter popup
                var myPop = new dhtmlXPopup();
                myPop.attachObject("div_param_form");
                
                if(callfrom == 'onload') {
                    x = $(obj).find('.current').next().next().find('img').offset().left;
                    y = $(obj).find('.current').next().next().find('img').offset().top + 10;
                } else if (callfrom == 'ondrop') {
                    //x = $('#formula_tags').find('img:last').offset().left;
                    //y = $('#formula_tags').find('img:last').offset().top + 10;
                    x = $('#formula_tags').find('.current').next().next().find('img').offset().left;
                    y = $('#formula_tags').find('.current').next().next().find('img').offset().top + 10;
                } else if (callfrom == 'reopen') {
                    x = $(obj).offset().left;
                    y = $(obj).offset().top + 10;
                }

                var width = div_param_form.offsetWidth;
                var height = div_param_form.offsetHeight;
                myPop.show(x,y,width,height);
                
                //Create another popup and show validation message on new pop up
                param_form.attachEvent("onFocus", function(id,value){
                    val_message = '';
    				var res = param_form.validateItem(id);
                   
                    if (res == false) {
                        var label = param_form.getItemLabel(id).replace('*','');
                        //val_message is set from the attached validation function.
                        if (val_message == '') {
                            attach_validation = label + ' must not be Empty';
                        } else {
                            attach_validation = val_message;
                        }
                        val_pop = new dhtmlXPopup({ form: param_form, id: [id]});
                        val_pop.attachHTML(attach_validation);
                        val_pop.show(id);
                    }
    			});
                
                //Remove validation
                param_form.attachEvent("onBlur", function(id,value){
    				var res = param_form.validateItem(id);
                    if (res == true) {
                        val_pop.hide();
                    }
                    reset_validation_message();
                });
            } 
        }
        
        function reload_dropdown(result_arr) {
            dropdown_arr = new Array();
            
            for (i = 0; i < result_arr.length; i++) {
                string_option = '{"text":"' + result_arr[i][1] + '","value":"' + result_arr[i][0] + '"}';
                dropdown_arr.push(string_option);
            }
            
            string_dropdown = "[" + dropdown_arr + "]";
            param_form.reloadOptions("Channel", JSON.parse(string_dropdown));
        }
        
        function reload_dropdown_contract(result_arr) {
            dropdown_arr = new Array();
            
            for (i = 0; i < result_arr.length; i++) {
                string_option = '{"text":"' + result_arr[i][1] + '","value":"' + result_arr[i][0] + '"}';
                dropdown_arr.push(string_option);
            }
            
            string_dropdown = "[" + dropdown_arr + "]";
            param_form.reloadOptions("Charge Type", JSON.parse(string_dropdown));
        }

        function reload_logical_name(result_arr) {
            dropdown_arr = new Array();
            
            for (i = 0; i < result_arr.length; i++) {
                string_option = '{"text":"' + result_arr[i][1] + '","value":"' + result_arr[i][0] + '"}';
                dropdown_arr.push(string_option);
            }
            
            string_dropdown = "[" + dropdown_arr + "]";
            param_form.reloadOptions("Logical Name", JSON.parse(string_dropdown));
        }        
        //Return the parameters from the backend
        function build_formula_param(formula_name) {
            let category = available_formula_category[formula_name];
            let flag = 's';
            if (category == 106501)
                flag = 'r';
            data = {"action": "spa_formula_editor_parameter",
                        "flag": flag,
                        "formula_name": formula_name
                    };
            
            adiha_post_data('return_array', data, '', '', 'callback_param', 0);
                
            return param_arr;
        }
        
        //Build the JSON for the parameter popup
        function callback_param(result_array) {
            param_arr = new Array();
            
            if (result_array != '') {
                var string = {type: "settings", position: "label-left", labelWidth: 100, inputWidth: 160};
                param_arr.push(string);
                
                for(counter = 0 ; counter < result_array.length; counter++) {
                    field_label = result_array[counter][1];
                    var field_type = result_array[counter][2];
                    var default_value = result_array[counter][3];
                    tooltip = result_array[counter][4];
                    field_size = result_array[counter][5];
                    var sql_query = result_array[counter][6];
                    is_required =  result_array[counter][7];
                    var is_numeric = result_array[counter][8];
                    var custom_validation = result_array[counter][9];
                    blank_option = result_array[counter][11];
                    var string_textbox;
                    
                    //For Textbox
                    if (field_type == 't') {
                        string_textbox = '{"type": "input", "label": "' + field_label + '"'; 
                        
                        if (default_value != '' && default_value != null) {
							string_textbox += ', "value" : "' + default_value + '"';
						}
                       
                        if (tooltip != '') {
                            string_textbox += ', "tooltip" : "' + tooltip + '"';
                        }
                        
                        if (is_required == 1 || is_numeric == 1 || custom_validation != '') {
                            var validation_arr = new Array();
                            string_textbox += ', "validate":"';
                            
                            if (is_required == 1) {
                                validation_arr.push('NotEmpty');
                            } 
                                
                            if (is_numeric == 1) {
                                validation_arr.push('numeric_validation');
                            }
                            
                            if (custom_validation != '') {
                                validation_arr.push(custom_validation);
                            }
                            
                            string_textbox +=  validation_arr;
                            string_textbox += '"';
                        }
                        
                        if (is_required == 1) {
                            string_textbox += ', "required" : "true"';
                        }
                        
                        if (field_size > 0) {
                            string_textbox += ', "width" : "' + field_size + '"';
                        } else {
                            string_textbox += ', "width" : "120"';
                        }
                                              
                        string_textbox += '}';
                        param_arr.push(JSON.parse(string_textbox));
                    //For Dropdown, calls callback_dropdown function for dropdown options    
                    } else if (field_type == 'd') {
                        var php_path = '<?php echo $php_script_loc; ?>';
                        if (sql_query != '') {
                            sql_val = htmlReplace(sql_query);
                            data = {"action": "spa_execute_query",
                                        "query": sql_val
                                    };
                            
                            adiha_post_data('return_array', data, '', '', 'callback_dropdown', 0);
                        } else {
                            string_textbox = '{"type": "input", "label": "' + field_label + '", "value": "", "width":"120"}'; 
                            param_arr.push(JSON.parse(string_textbox));
                        }
                    //For Date/Calender    
                    } else if (field_type == 'c') {
                        var string_date = '{"type": "calendar", "name": "' + field_label + '", "label": "' + field_label + '", "dateFormat": "%Y-%m-%d", "serverDateFormat": "%d-%m-%Y", "calendarPosition": "bottom"';
                        
                        if (default_value != '') {
                            string_date += ', "value" : "' + default_value + '"';
                        } else {
                            string_date += ', "value" : "01-01-2013"';
                        }
                        
                        if (tooltip != '') {
                            string_date += ', "tooltip" : "' + tooltip + '"';
                        }
                        
                        if (field_size > 0) {
                            string_date += ', "width" : "' + field_size + '"';
                        } else {
                            string_date += ', "width" : "120"';
                        }
                        
                        if (is_required == 1) {
                            string_date += ', "required" : "true"';
                        }
                        
                        string_date += '}';
                        param_arr.push(JSON.parse(string_date));
                    }
                }
                string = {type: "button", value: "OK", offsetLeft: 100};
                param_arr.push(string);
            }
        }
        
        //Build the options of the dropdown
        function callback_dropdown(result_arr) {
            dropdown_arr = new Array();
            var string_dropdown = '{"type":"select","label":"' + field_label + '","name":"' + field_label + '"' ;
            var string_option;
            
            if (field_size > 0) {
                string_dropdown += ', "width" : "' + field_size + '"';
            } else {
                string_dropdown += ', "width" : "120"';
            }
            
            if (tooltip != '') {
                string_dropdown += ', "tooltip" : "' + tooltip + '"';
            }
            
            if (is_required == 1) {
                string_dropdown += ', "required" : "true"';
            }
            
            string_dropdown += ',"options":[';
            
            if (blank_option == 1) {
                 dropdown_arr.push('{"text": "", "value": "NULL"}');
            }
            
            for (i = 0; i < result_arr.length; i++) {
                string_option = '{"text":"' + result_arr[i][1] + '","value":"' + result_arr[i][0] + '"}';
                dropdown_arr.push(string_option);
            }
            
            string_dropdown = string_dropdown + dropdown_arr + "]}";
            param_arr.push(JSON.parse(string_dropdown));
        }
        
        //Set validation message - Function is called from custom validation function
        function set_validation_message(msg) {
            val_message = msg;
        }
        
        function reset_validation_message() {
            val_message = '';
        }
        
        //Load the array for the autocomplete dropdown
        function callback_autocomplete_arr(result_array) {
            available_formula = new Array();
            available_formula_category = new Array();
            available_formula[0] = result_array[0][0];
            available_formula_category[result_array[0][0]] = result_array[0][1];
            for(count = 1; count < result_array.length; count++) {
                available_formula[count] =  htmlReplace(result_array[count][0]);
                available_formula_category[result_array[count][0]] = result_array[count][1];
                //available_formula[count] =  result_array[count][0];
            }
        }
        
        /***** Custom Validation Start *****/
        function greater_than_zero(data) {
            set_validation_message('Must be greater than 0 integer');
            return (data > 0 && (data%1) == 0);
        }
        
        function numeric_validation(data) {
            set_validation_message('Must be numeric value');
            return isNumber(data);
        }
        
        function isNumber(n) {
          return !isNaN(parseFloat(n)) && isFinite(n);
        }
        
        function non_negative(data) {
            set_validation_message('Prior Month must be 0 or greater with integer values.');
            return (data >= 0);
        }
        
        /***** Custom Validation End *****/
        
        //Place the cursor at the end of the content editor
        function setEndOfContenteditable(contentEditableElement) {
            var range,selection;
            if(document.createRange)//Firefox, Chrome, Opera, Safari, IE 9+
            {
            	range = document.createRange();//Create a range (a range is a like the selection but invisible)
            	range.selectNodeContents(contentEditableElement);//Select the entire contents of the element with the range
            	range.collapse(false);//collapse the range to the end point. false means collapse to end rather than the start
            	selection = window.getSelection();//get the selection object (allows you to change selection)
            	selection.removeAllRanges();//remove any selections already made
            	selection.addRange(range);//make the range you have just created the visible selection
            }
            else if(document.selection)//IE 8 and lower
            { 
                range = document.body.createTextRange();//Create a range (a range is a like the selection but invisible)
            	range.moveToElementText(contentEditableElement);//Select the entire contents of the element with the range
            	range.collapse(false);//collapse the range to the end point. false means collapse to end rather than the start
            	range.select();//Select the range (make it the visible selection
            }
        }
        
        //Add code at the text cursor position. Used to break the html - Before the text cursor and after the text cursor 
        function html_at_caret(html, selectPastedContent) {
            var sel, range;
            if (window.getSelection) {
                // IE9 and non-IE
                sel = window.getSelection();
                if (sel.getRangeAt && sel.rangeCount) {
                    range = sel.getRangeAt(0);
                    range.deleteContents();
        
                    // Range.createContextualFragment() would be useful here but is
                    // only relatively recently standardized and is not supported in
                    // some browsers (IE9, for one)
                    var el = document.createElement("div");
                    el.innerHTML = html;
                    var frag = document.createDocumentFragment(), node, lastNode;
                    while ( (node = el.firstChild) ) {
                        lastNode = frag.appendChild(node);
                    }
                    var firstNode = frag.firstChild;
                    range.insertNode(frag);
                    
                    // Preserve the selection
                    if (lastNode) {
                        range = range.cloneRange();
                        range.setStartAfter(lastNode);
                        if (selectPastedContent) {
                            range.setStartBefore(firstNode);
                        } else {
                            range.collapse(true);
                        }
                        sel.removeAllRanges();
                        sel.addRange(range);
                    }
                }
            } else if ( (sel = document.selection) && sel.type != "Control") {
                // IE < 9
                var originalRange = sel.createRange();
                originalRange.collapse(true);
                sel.createRange().pasteHTML(html);
                if (selectPastedContent) {
                    range = sel.createRange();
                    range.setEndPoint("StartToStart", originalRange);
                    range.select();
                }
            }
        }
        
        function htmlReplace(str) {
            return String(str).replace(/&eq;/gi, '=').replace(/&comma;/gi,',').replace(/&col;/gi, '\'').replace(/&lt;/gi, '<').replace(/&mul;/gi, '*').replace(/&le;/gi, '<=').replace(/&neq;/gi, '<>').replace(/&gt;/gi, '>');
            //return String(str).replace(/&eq;/gi, '=').replace(/&comma;/gi,',').replace(/&col;/gi, '\'\'');
        }
        
        /********************************* Formula Parameter Function End ****************************************/
        
        /************************************** Formula Logic Start **********************************************/
        
        function btn_remove_formula_click() {
            var return_value = new Array();
            return_value[0] = 'Remove';
            var call_from = '<?php echo $call_from;?>';

            if (call_from == 'other') {
                parent.formula_editor_callback(return_value);
                parent.dhxWins.window('w1').close();
            } else if (call_from == 'browser') {
                document.getElementById("___browse_formula_id___").value = '';
                document.getElementById("___browse_formula_text___").value = '';

                if (is_rate_schedule == 1) {
                    parent.set_formula_columns('', '', row_id, rate_category_grid);
                }
                
                var win_obj = window.parent.___browse_win_link_window.window("w1");
                win_obj.close();
            }
            
            return;
        }
        
        function btn_save_click() {
            var formula_type = get_formula_form_value('rdo_formula_type');
        
            if (formula_type == 'f') {
                var f_formula = $('#formula_tags').text();
                formula_editor.set_formula_textbox_value(f_formula);
            }
            
            var formula_id = '<?php echo $formula_id; ?>';
            var system_formula = '<?php echo $system_formula; ?>';
            var system_enable = '<?php echo $system_enable; ?>';
            
            if ((system_formula == 'n' && formula_id != 'NULL') && (system_enable == 'n')) {
                var message = get_message('EDIT_FORMULA');        
                show_messagebox(message);
                return;
            }
        
            var is_template = get_formula_form_checked('chk_template') ? 'y' : 'NULL';
            
            //added to resolve formula name
            var formula_name = get_formula_form_value('label_formula');
            var formula_id = get_formula_form_value('formula');

            if (is_browse == 'y' && formula_name != '' && call_from == 'grid_browser') {
                parent.new_browse.new_browse_value = {"value": formula_id, "text": formula_name}
                parent.new_browse.close();
                return ;
            }

            if (is_browse == 'y' && formula_name != '') {
                eval('var my_form = parent.' + browse_form + '.getForm()');
                my_form.setItemValue(browse_name.replace("label_", ""), formula_id);
                my_form.setItemValue(browse_name, formula_name);
                parent.browse_window.window('w1').close();
                return;
            }

            if (deal_insert_or_delete == 'details' && before_update_formula_id == after_update_formula_id) {
                if (is_template == 'y') {
                    var message = get_message('TEMPLATE_FORMULA');
                    show_messagebox(message);
                    return;
                } else {
                    if (js_enable_edit == false) {
                        var message = get_message('EDIT_SAVE_FORMULA');
                        show_messagebox(message);
                        return;
                    }
                }
            }
            
            test_click(false);
        }
        
        function change_cursor_position(arg){
            var error_line =  arg.split("-").pop();    
            set_cursor(parseInt(error_line));
        }
        
        function ok_btn_call_back(x) { 
            var call_from = '<?php echo $call_from; ?>';
            var formula_id = '<?php echo $formula_id; ?>';
            var formula_type = '<?php echo $formula_type; ?>';
            var formula_name = get_formula_form_value('label_formula');
            var formula_string = get_formula_form_value('txt_formula_string');
            var formula_box = unescape(formula_editor.get_formula_textbox_value());
            var f_html = $('#formula_tags').html();
            //var formula_html = f_html.replace(/'/gi, '\\\'\');
            //formula_html = formula_html.replace(/\+/gi, '%plus%');
            formula_html = f_html.replace(/\+/gi, '%plus%');
            formula_html = htmlReplace(formula_html.replace(/'/g, "''"));
            
            var rdo_formula_type = get_formula_form_value('rdo_formula_type');
            formula_box = unescape(formula_editor.get_formula_textbox_value());
            var template = get_formula_form_checked('chk_template') ? 'y' : 'NULL';
            
            if (rdo_formula_type == 'f') {
                formula_box = formula_box.replace(/\s+/g, '') ;/*replace whitespace )*/
            }
            
            if (template == 'y' && formula_name == 'NULL') {
                var message = get_message('FORMULA_NAME');        
                show_messagebox(message);
                return;
            }
        
            if (formula_box == 'NULL') {
                var message = get_message('FORMULA_BLANK');        
                show_messagebox(message);
                return;
            }
        
            close_var = true;
        
            if (x[0][0] == 'DB Error' || x[0][0] == 'Error') {
                var message = get_message('INVALID_SYNTAX'); ;        
                show_messagebox(message);
                return;
            }
        
            txt_formula_val = generate_formula();
			
            if (trim(txt_formula_val) == '') {
                window.returnValue = 'NULL';
                window.close();
                return;
            }
        
            var copy_ref_flag = get_formula_form_value('txt_copy_ref_flag');
            var new_formula =  get_formula_form_value('txt_new_formula');
        	
            if (rdo_formula_type == 'u') {
                var formula_control = 'UDSql()';
                var formula_xml = parseFormula(formula_control);
            } else if (rdo_formula_type == 'f') {
                var formula_control = document.getElementById('txt_formulabox');
                var value_formula = decodeURIComponent(formula_editor.get_formula_textbox_value());
                //var value_formula = formula_editor.get_formula_textbox_value();
                value_formula = (!isNaN(value_formula)) ? 'ConstantValue(' + value_formula + ')' : value_formula;
				value_formula = formula_resolve_param_seperator(value_formula,'s');
                var formula_xml = parseFormula(value_formula);
            }
            
            var formula_group_id = '<?php echo $formula_group_id; ?>';
            var sequence_number = '<?php echo $sequence_number; ?>';
            var formula_nested_id = '<?php echo $formula_nested_id; ?>';
            
            if (copy_ref_flag != 'r') {
              
                if (formula_id == 'NULL' || new_formula == 'new') {
                    system_defined = 'n';
                    var flag = 'i';
                } else {
                    var system_defined = 'n';
                    var flag = 'u';
                }
                
                var formula = unescape(txt_formula_val);
                var udf_query = '';
                
                if (rdo_formula_type == 'u') {
                    udf_query = formula;
                	formula = 'UDSql()';
                }

                data = {"action": "spa_formula_editor",
                        "flag": flag,
                        "formula_id": formula_id,
                        "formula": formula,
                        "formula_type": formula_type,
                        "formula_name": formula_name,
                        "system_defined": system_defined,
                        "template": template,
                        "formula_xmlValue": formula_xml,
                        "formula_group_id": formula_group_id,
                        "sequence_number": sequence_number,
                        "formula_nested_id": formula_nested_id,
                        "formula_source_type": rdo_formula_type,
                        "udf_query": udf_query,
                        "formula_html": formula_html
                    };
            
                adiha_post_data('return_array', data, '', '', 'formula_save_callback', '');
                    
            } else {
                
                var txt_formula = unescape(formula_editor.get_formula_textbox_value());

                var formula_id = get_formula_form_value('formula');
                var return_value = new Array();
                return_value[0] = formula_id;
                return_value[1] = txt_formula;
                return_value[2] = 'Success';

                if (is_browse == 'y') {
                    eval('var my_form = parent.' + browse_form + '.getForm()');
                    my_form.setItemValue(browse_name.replace("label_", ""), formula_id);
                    my_form.setItemValue(browse_name, txt_formula);
                    parent.browse_window.window('w1').close();
                } else {
                    if (call_from == 'other') {
                        parent.formula_editor_callback(return_value);
                        parent.dhxWins.window('w1').close();
                    } else if (call_from == 'browser') {
                        document.getElementById("___browse_formula_id___").value = formula_id;
                        document.getElementById("___browse_formula_text___").value = txt_formula;

                        if (is_rate_schedule == 1) {
                            parent.set_formula_columns(formula_id, txt_formula, row_id, rate_category_grid);
                        }

                        var win_obj = window.parent.___browse_win_link_window.window("w1");
                        win_obj.close();
                    }
                }
                
                hideHourGlass();
            }
        }
        
        function formula_save_callback(response_value) {
            var return_value = new Array();
            return_value[0] = response_value[0][3];
            return_value[1] = response_value[0][5];
            return_value[2] = response_value[0][1];
            var call_from = '<?php echo $call_from; ?>';

            if (is_browse == 'y' && call_from == 'grid_browser') {
                parent.new_browse.new_browse_value = {"value": response_value[0][3], "text": response_value[0][5]}
                parent.new_browse.close();
                return ;
            }

            if (is_browse == 'y') {
                eval('var my_form = parent.' + browse_form + '.getForm()');
                my_form.setItemValue(browse_name.replace("label_", ""), response_value[0][3]);
                my_form.setItemValue(browse_name, response_value[0][5]);
                parent.browse_window.window('w1').close();
            } else {
                if (call_from == 'other' || call_from == 'formula_builder') {
                    parent.formula_editor_callback(return_value);
                    parent.dhxWins.window('w1').close();
                } else if (call_from == 'browser') {
                    document.getElementById("___browse_formula_id___").value = response_value[0][3];
                    document.getElementById("___browse_formula_text___").value = response_value[0][5];

                    if (is_rate_schedule == 1) {
                        parent.set_formula_columns(response_value[0][3], response_value[0][5], row_id, rate_category_grid);
                    }
                    var win_obj = window.parent.___browse_win_link_window.window("w1");
                    win_obj.close();
                }
            }
        }

        function create_syntax(func, value_array, param) {
            ret_str = '';
            count_value = value_array.length;
        	
            if (count_value <= param) {
                ret_str = build_param(func, value_array[0], value_array[1]);
            } else {
                left_value = count_value
                for (var i = 0; i < count_value - 1; i++) {
                    if (left_value > param) {
                        ret_str = ret_str + func + '(' + value_array[i] + ', ';
                    } else {
                        ret_str = ret_str + build_param(func, value_array[i], value_array[i + 1])
                    }
                    left_value--;
                }
                for (var j = 0; j < count_value - 2; j++) {
                    ret_str = ret_str + ')';
                }
            }
        	
            return ret_str;
        }
    
        function build_param(func, val1, val2) {
            val = '';
            val = func + '( ' + val1 + ' , ' + val2 + ' )';
            return val;
        }
    
        function reset_click() {
        
            if (call_from == 'formula_builder') {
                formula_editor.set_formula_textbox_value('');
                $('#formula_tags').html('');
                //$('#formula_tags').addClass('formula_tag_margin');
            } else {
                if (get_formula_form_value('txt_copy_ref_flag') == 'r') {
                    formula_editor.set_formula_textbox_value('');
                    $('#formula_tags').html('');
                    return;
                }
                else if (get_formula_form_value('txt_copy_ref_flag') == 'c') {
                    if (js_enable_edit == false) {
                        message = get_message('FORMULA_EDITOR');
        				show_messagebox(message);
                        return;
                    }
                   
                    formula_editor.set_formula_textbox_value('');
                    $('#formula_tags').html('');
                }
        		
                if (is_template == 'NULL') {
                    if (js_enable_edit == false) {
                        message = get_message('FORMULA_EDITOR');
        				show_messagebox(message);
                        return;
                    }
                    
                    formula_editor.set_formula_textbox_value('');
                    $('#formula_tags').html('');
                } else if (is_template == 'y') {
                    formula_editor.set_formula_textbox_value('');
                    $('#formula_tags').html('');
                    return;
                }
            }
        }
    
        function test_click(display_msg) {
            var formula_type = get_formula_form_value('rdo_formula_type');
            
            if (formula_type == 'f') {
                var f_formula = $('#formula_tags').text();
                formula_editor.set_formula_textbox_value(f_formula);
            }
           
            var txt_formula_box = formula_editor.get_formula_textbox_value();
            set_formula_form_value('txt_formula', txt_formula_box);
             
            var formula_source_type = get_formula_form_value('rdo_formula_type');
            var txt_formula_val = generate_formula();
            
            if (formula_source_type == 'u') {
                txt_formula = get_formula_form_value('txt_formula');
                session_id = '<?php echo $session_id; ?>';
                var sql_query = formula_editor.get_formula_textbox_value();
    
            } else if (formula_source_type == 'f') {
                if (call_from == 'deal') {
                    get_formula_id();
                }     
                txt_index = txt_formula_val.split('`');
                j = 0;
                flag = 0;
    			
                for (var i = 0; j > -1; i++) {
                    j = txt_formula_val.indexOf('`', j + 1)
                    if ((i % 2) == 1) {
                        txt_index[i] = 1;
                    }
                    txt_formula = txt_formula + txt_index[i];
                }
              
                txt_formula_val_orig = decodeURIComponent(formula_editor.get_formula_textbox_value());
                if (txt_formula_val_orig.match(/[UDFCharges|UDFValue]\(^[\-]*(\d*\W+\d*)\)/)) {
                    show_messagebox('Invalid Syntax');
                    return;
                }
            }
    		if (txt_formula_box ==''|| txt_formula_box =='NULL'){
                show_messagebox('Please enter formula.');
                return;
            }
            
    		if (formula_source_type == 'u') {
                var formula_control = 'UDSql()';
                var formula_xml = parseFormula(formula_control);
    
            } else if (formula_source_type == 'f') {
                var formula_control = document.getElementById('txt_formulabox');
                var value_formula = decodeURIComponent(formula_editor.get_formula_textbox_value());
				value_formula = formula_resolve_param_seperator(value_formula,'s');
                var formula_xml = parseFormula(value_formula);
            }
            
        
           if (display_msg == false) {
               if (call_from == 'formula_builder') {
                   var for_name = formula_editor.formula_form.getItemValue('label_formula');
                   
                   if (for_name == '') {
                        show_messagebox('Please enter formula name.');
                        return;
                    }
               }
               
               if (formula_source_type == 'u') {
                    if (sql_query == 'NULL') {
                        var message = get_message('SQL_STATEMENT_VALIDATION');
                        show_messagebox(message);
                        return;
                    }
                    
                    var tsql = unescape(txt_formula_val);
                    
                    data = {"action": "spa_alert_sql",
                                "flag": "x",
                                "tsql": tsql
                            };
            
                    adiha_post_data('return_array', data, '', '', 'ok_btn_call_back', ''); 
                } else if (formula_source_type == 'f') {
                    
                    data = {"action": "spa_formula_editor",
                                "flag": "v",
                                "formula":txt_formula_val
                            };
            
                    adiha_post_data('return_array', data, '', '', 'ok_btn_call_back', '');
                    
                }
            } else {
                    
                    data = {"action": "spa_validate_sql_function",
                                "flag": formula_source_type,
                                "tsql": txt_formula_val
                            };
            
                    adiha_post_data('alert', data, '', '', '', '');
           }
        }    
        function generate_formula() {
            var txt_formula_val = decodeURIComponent(get_formula_form_value('txt_formula'));
            txt_formula_val = unescape(txt_formula_val);
			txt_formula_val = txt_formula_val.replace(/&#039;/g,"'");
			
            var formula_source_type = get_formula_form_value('rdo_formula_type');
    	        
    	//	if (formula_source_type == 'f') {
    //			txt_formula_val = txt_formula_val.replace(/\s+/g, '');
    //		}
    //		
            txt_formula = '';
        
            if (txt_formula_val == 'NULL') {
                txt_formula_val = '';
                return txt_formula_val;
            }
        	
            var value = 0;
        	
            while (value > -1) {
                value = txt_formula_val.indexOf('+');
                
                if (value > -1) {
                    txt_formula_val = txt_formula_val.replace('+', 'adiha_add');
                }
            }
            
            var space = 0;

            while (space > -1) {
                space = txt_formula_val.indexOf(' ');
                
                if (space > -1) {
                    txt_formula_val = txt_formula_val.replace(' ', 'adiha_space');
                }
            }

            return txt_formula_val;
        }
    
        function get_formula_id() {
            var formula_type = get_formula_form_value('rdo_formula_type');
            var value = 0;
            var txt_formula = get_formula_form_value('txt_formula');
            var f_html = get_formula_form_value('txt_formula_html');
            f_html = decodeURIComponent(f_html);
            var formula_html = f_html.split('+').join(' ');
            formula_html = formula_html.replace(/\%plus%/g, '+');
            if (txt_formula == 'NULL' || txt_formula == 'NULL') {
                txt_formula = '';
            }
        	
            /*
            while (value > -1) {
                value = txt_formula.indexOf('adiha_add');
        
                if (value > -1) {
                    txt_formula = txt_formula.replace('adiha_add', '+');
                }
            }
            */
            
            img_name = 'edit.jpg';
        
            if (call_from == 'formula_builder') {
                if (formula_type == 'f') {
                    if (formula_html != 'NULL') {
                        $('#formula_tags').html(formula_html);
                    } else if (txt_formula != 'NULL') {
                        $('#formula_tags').html(txt_formula);
                    }
                } else if (formula_type == 'u'){
                    formula_editor.set_formula_textbox_value(txt_formula.replace(/\+/g, ' '));
                }
            }
        }
    
        function edit_click(x) {
            var system_formula = '<?php echo $system_formula; ?>';
            var system_enable = '<?php echo $system_enable; ?>';
            var copy_ref_flag = get_formula_form_value('txt_copy_ref_flag');
        
            if (copy_ref_flag == 'r' || call_from == 'formula_builder' || (is_template == 'y' && copy_ref_flag != 'c')) {
                return;
            }
        
            if (x == '1') {
                js_enable_edit = false;
                setEnabled(false);
                enable_formula_name(false);
            } else {
                if (system_enable == 'n') {
                    js_enable_edit = false;
                    
                    enable_save_button(false);
                    enable_browse_button(false);
                    enable_formula_name(false);
                    $("#formula_tags").attr('contentEditable',false);
                    formula_editor.formula_textarea_toolbar.disableItem('verify');
                    
                    formula_name = get_formula_form_value('label_formula');
                    set_formula_form_value('txt_formula', formula_string);
                    formula_editor.set_formula_textbox_value(formula_string_title.replace(/\+/g, ' '));
                    setEnabled(false);
                                        
                } else {
                    if (js_enable_edit == true) {
                        $('#formula_tags').attr('disabled', 'disabled');
                        js_enable_edit = false;
                        
                        enable_save_button(false);
                        enable_browse_button(false);
                        enable_formula_name(false);
                        $("#formula_tags").attr('contentEditable',false);
                        formula_editor.formula_textarea_toolbar.disableItem('verify');
                        
                        var formula_string = get_formula_form_value('txt_formula_string');
                        
                        if (formula_string == 'NULL' || formula_string == 'NULL') {
                            formula_string = '';
                        }
        
                        set_formula_form_value('txt_formula', formula_string);
                        formula_editor.set_formula_textbox_value(formula_string_title.replace(/\+/g, ' '));
                        setEnabled(false);
                        $('#formula_tags').html("<?php echo urldecode($formula_string_title_f); ?>");
                    } else {
                        $('#formula_tags').removeAttr('disabled');
                        js_enable_edit = true;
                        
                        enable_save_button(true);
                        enable_browse_button(true);
                        $("#formula_tags").attr('contentEditable',true);
                        formula_editor.formula_textarea_toolbar.enableItem('verify');
                        
        				setEnabled(true);
                        var value = 0;
                        var space = 0;
                        var txt_formula = get_formula_form_value('txt_formula');
        
                        if (txt_formula == 'NULL' || txt_formula == 'NULL') {
                            txt_formula = '';
                        }
        				
                        while (value > -1) {
                            value = txt_formula.indexOf('adiha_add');
        
                            if (value > -1) {
                                txt_formula = txt_formula.replace('adiha_add', '+');
                            }
                        }
        
                        while (space > -1) {
                            space = txt_formula.indexOf('adiha_space');
        
                            if (space > -1) {
                                txt_formula = txt_formula.replace('adiha_space', ' ');
                            }
                        }
        
                        formula_editor.set_formula_textbox_value(txt_formula.replace(/\+/g, ' '));
                        set_formula_form_value('txt_formula', formula_editor.get_formula_textbox_value());
                        
                        var f_html = get_formula_form_value('txt_formula_html');
                        f_html = decodeURIComponent(f_html);
                        //f_html = f_html.replace(/\+\+\+/g, '+&plus;+');
                        var formula_html = f_html.split('+').join(' ');
                        formula_html = formula_html.replace(/\%plus%/g, '+');
                        
                        if(formula_html != 'NULL') {
                            $('#formula_tags').html(formula_html);
                        } else {
                            $('#formula_tags').html(txt_formula);
                        }
                    }
        
                }
            }
        }
    
        function store_position(ftext) {
            set_formula_form_value('txt_formula', ftext.value);
            if (ftext.createTextRange) {
                ftext.caretPos = document.selection.createRange().duplicate();
            }
            sel(ftext);
        }
        
        function store_position1() {
            var ftext = set_formula_form_value('txt_formula', formula_editor.get_formula_textbox_value());
        }
        
        function insert_text(txt_new) {
            var formula = document.<?php echo $form_name; ?>.txt_formulabox;
            if(formula_editor.get_formula_textbox_value() !='NULL'){
                formula.value = formula_editor.get_formula_textbox_value();    
               
            } else {
                formula.value = '';
            }
            
            if (formula.createTextRange && formula.caretPos) {
                var caretPos = formula.caretPos;
                caretPos.text = txt_new;
            } else {
                formula.value += txt_new;
            }
            formula_editor.set_formula_textbox_value(formula.value);
            set_formula_form_value('txt_formula', formula_editor.get_formula_textbox_value());
        }
        
        function sel(element) {
            if (!element.value) {
                return false;
            }
        
            if (document.selection) {
                var range = document.selection.createRange();
                var rangetwo = element.createTextRange();
                var stored_range = range.duplicate();
        		
                stored_range.moveToElementText(element);
                stored_range.setEndPoint('EndToEnd', range);
                element.selectionStart = stored_range.text.length - range.text.length;
                element.selectionEnd = element.selectionStart + range.text.length;
            }
        
            var all_text = element.value;
            var t_srt = -1;
            var t_end = all_text.indexOf('>', element.selectionStart);
        
            for (var x = t_end - 1; x > 0; x--) {
                if (all_text.charAt(x) == '<') {
                    var t_srt = x;
                    break;
                }
            }
        
            if (element.selectionStart < t_srt || t_srt == -1) {
                return;
            }
        	
            if (t_srt != 0)
                t_srt = t_srt;
        
            var indiv = all_text.substring(t_srt, t_end + 1);
        
            if (indiv.indexOf(' ') > 0 || indiv == '') {
                return;
            }
        
            rangetwo.findText(indiv);
            rangetwo.select();
        }
        
        function save_failed() {
            hideHourGlass();
            return;
        }
        
        function get_message(arg) {
            switch (arg) {
                case 'NO_FORMULA':
                    return 'No formula found.';
                case 'DELETE_CONFIRM':
                    return 'Are you sure you want to delete selected Formula?';
                case 'DELETE_SUCCESS':
                    return 'Formula Deleted Successfully.';
                case 'DELETE_FAILED':
                    return 'Failed Deleting Formula.';
                case 'EDIT_FORMULA':
                    return 'Cannot edit system formula.';
                case 'TEMPLATE_FORMULA':
                    return 'Template formula cannot be updated.';
                case 'EDIT_SAVE_FORMULA':
                    return 'Please check on edit button to save the formula.';
                case 'FORMULA_NAME':
                    return 'Formula Name cannot be blank for template formula.';
                case 'FORMULA_BLANK':
                    return 'Formula cannot be blank.';
                case 'INVALID_SYNTAX':
                    return 'Invalid Syntax';
                case 'FORMULA_EDITOR':
                    return 'Change the Formula Editor to Edit mode.';
                case 'SQL_STATEMENT':
                    return 'Please write sql statements.';
                case 'VALID_STATEMENT':
                    return 'SQL statement is valid.';
                case 'SQL_STATEMENT_VALIDATION':
                    return 'Please write SQL statements.';
                case 'CLEAR_TEXT':
                    return 'Clear the formula first.'
            }
        }   
        
        function set_formula(formula) {
             $('#formula_tags').html(formula);
        }
		
		function formula_resolve_param_seperator(formula, mode) {
			if ( mode == 's') {
				formula = formula.replace(/\,/g, '#####');
				formula = formula.replace(/\;/g, ',');
				formula = formula.replace(/\#####/g, '.');
			} else if (mode == 'v') {
				formula = formula.replace(/\./g, '#####');
				formula = formula.replace(/\,/g, ';');
				formula = formula.replace(/\#####/g, ',');
			}
			return formula;
		}
		
		
    </script> 