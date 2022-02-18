<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="cache-control" content="max-age=0" />
    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <?php  require('../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<style type="text/css">
	body{
		margin: 0px;
		padding: 0px;
	}
	.objbox{
		overflow-x:hidden !important;
	}
</style>
    
<body>
<?php
global $image_path;

if (isset($_GET['type'])) {
	$type = get_sanitized_value($_GET['type']);
}

$layout = new AdihaLayout();
$form_obj = new AdihaForm();

$layout_name = 'message_board_layout';
$layout_json = '[
            {
                id:             "a",
                text:           "Message Board",
                width:          720,
                height:         160,
                header:         false,
                collapse:       false,
                fix_size:       [true,true]
            },

        ]';

$name_space = 'message_board';

echo $layout->init_layout($layout_name, '', '1C', $layout_json, $name_space);
$toolbar_name = 'message_board_toolbar';

echo $layout->attach_toolbar_cell($toolbar_name, 'a');

$toolbar_obj = new AdihaToolbar();
echo $toolbar_obj->init_by_attach($toolbar_name, $name_space);
echo $toolbar_obj->load_toolbar('[
									{id: "refresh", type: "button", text:"Refresh", img: "refresh.gif", title:"Refresh"},
									{id: "delete", type: "button", text:"Delete", img: "delete.gif", title:"Delete"},
									{id: "forward", type: "button", text:"Forward", img: "email.gif", title:"Forward"},
                                    {id: "read", type: "button", text:"Mark as Read", img: "mark_as_read.png", title:"Mark as Read"},
                                    {id: "unread", type: "button", text:"Mark as Unread", img: "mark_as_unread.png", title:"Mark as Unread"}
									]');

echo $toolbar_obj->attach_event('', 'onClick', 'messagebox_menu_click');
echo $layout->close_layout();  
?>
</body>

<script type="text/javascript">

	var message_board_type = '<?php echo $type; ?>';
    var read_color = '#ffffff';
    var unread_color = '#fffbef';
        
	$(document).ready(function(){    
        //Check if the current URL contains '#'
        if (document.URL.indexOf("#")==-1){
            // Set the URL to whatever it was plus "#".
            url = document.URL+"#";
            location = "#";
    
            //Reload the page
            //location.reload(true);
        }
        load_messageboard_grid_data();      
    });
    
	function load_messageboard_grid_data(type) {
        var message_board_url;
        var message_board_param;
        var id_count_message;
        var flag = "";
        var message_board_type_name;
        if ( message_board_type == "message" ) {
            flag = "o";
            id_count_message = "filter_msg_counts_message";
            message_board_type_name = "Messages";
        } else {
            flag = "l";
            id_count_message = "filter_msg_counts_alert";
            message_board_type_name = "Notifications";
        }



        message_board.message_board_grid = message_board.message_board_layout.cells('a').attachGrid();
        
        message_board.message_board_layout.cells('a').attachStatusBar({
                            height: 30,
                            text: '<div id="pagingArea_a"></div>'
                        });  
        
        message_board.message_board_grid.setHeader(get_locale_value("ID,#master_checkbox,Type,Message,Date,State", true));
        message_board.message_board_grid.attachHeader("#text_filter, ,#text_filter,#text_filter,#text_filter,");
        message_board.message_board_grid.setInitWidths("0,40,158,*,150,0");
        message_board.message_board_grid.setColumnMinWidth("0,40,210,300,148,0");
        message_board.message_board_grid.setColAlign("left,left,left,left,left,left");
        message_board.message_board_grid.setColTypes("ro,ch,ro,ro,ro,ro");            
        //message_board.message_board_grid.setImagePath(js_image_path + "dhxgrid_web/");
        message_board.message_board_grid.setImagePath(js_image_path + "dhxgrid_web/");
        message_board.message_board_grid.enableMultiline(true);
        message_board.message_board_grid.setPagingWTMode(true,true,true,[30,60,90,120]);
        message_board.message_board_grid.enablePaging(true, 30, 0, "pagingArea_a"); 
        message_board.message_board_grid.setPagingSkin('toolbar');
        message_board.message_board_grid.enableMultiselect(true);
        message_board.message_board_grid.init();
        message_board.message_board_grid.attachEvent("onRowSelect", message_board.mark_msg_read);
        message_board.message_board_grid.attachEvent("onCheck", message_board.check_marked);

        
        message_board_param = {
            "action": "spa_message_board",
            "flag": flag,
            "user_login_id": "<?php echo $app_user_name; ?>"
            };
            
        message_board_param = $.param(message_board_param);
        message_board_url = js_data_collector_url + "&" + message_board_param;

        //clear_message_board_grid(); 
        //message_board.message_board_grid.loadXML(message_board_url);
        
        message_board.message_board_grid.clearAndLoad(message_board_url, function() {
            var count = message_board.message_board_grid.getRowsNum() + " " + message_board_type_name ;
            parent.updateMessageNumber(id_count_message,count);
            
            message_board.message_board_grid.forEachRow(function(id) {
                var is_read = message_board.message_board_grid.cells(id, 5).getValue();
                if (is_read == 0)
                    message_board.message_board_grid.setRowColor(id, unread_color);
            })
        });       
    }

    message_board.mark_msg_read = function(id, ind) {
        message_board.message_board_grid.clearSelection();
        mark_check(id, ind);
        var user_id = '<?php echo $app_user_name; ?>';
        var is_alert = (message_board_type == 'message') ? 0 : 1;
        var msg_id = message_board.message_board_grid.cells(id, 0).getValue();
        
        var data = {"action": "spa_message_board", "message_id":msg_id, "flag": "f", "user_login_id":user_id, "message_filter":is_alert};
        if(message_board.message_board_grid.cells(id, 1).isChecked()) {
            adiha_post_data('return_json', data, '', '', 'grid_read_unread_callback');
        } else {
            adiha_post_data('return_array', data, '', '', '', '', '');
        }
    }

    function grid_read_unread_callback(result) {
        result = JSON.parse(result);
        if (result[0].errorcode == 'Success') { 
            if (result[0].message_count > 0 && result[0].message_count < 100) {
                parent.updateMessageNumber("message-count", result[0].message_count);
            }  else if (result[0].message_count > 99) {            
                parent.updateMessageNumber("message-count", '99+');  
            }   

            if (result[0].alert_count > 0 && result[0].alert_count < 100) {
                parent.updateMessageNumber("alert-count", result[0].alert_count);
            }  else if (result[0].alert_count > 99) {            
                parent.updateMessageNumber("alert-count", '99+');
            }
        }
    }
        
    function read_unread(flag) {
        var message_filter = (message_board_type == 'message') ? 0 : 1;
        var checked = message_board.message_board_grid.getCheckedRows(1);
        var message_id = "";
        
        if (checked == "" ) {
            show_messagebox("Please select the message.");
        } else {
            var partsOfStr = checked.split(',');
            for (i = 0; i < partsOfStr.length; i++) {
                selected_value_id = message_board.message_board_grid.cells(partsOfStr[i], 0).getValue();
                if(i != 0){
                        message_id += ','  
                }
                message_id += selected_value_id ;
            }
            
            data = {
                        "action": "spa_message_board",
                        "flag": flag,
                        "message_id": message_id, 
                        "user_login_id": js_user_name,
                        "message_filter": message_filter                                       
                    }
            adiha_post_data('alert', data, '', '', 'read_unread_callback');
        }
    }
    
    function read_unread_callback(result) {
        if (result[0].errorcode == 'Success') {
            var message_id = result[0].recommendation;
            var message_id_split = message_id.split(",");
            var message = result[0].message;
            var row_color = (message.indexOf("Read") != -1) ? read_color : unread_color;
            
            for (i = 0; i < message_id_split.length; i++) {
                var row_id = message_board.message_board_grid.findCell(message_id_split[i], 0);
                var row_id = row_id[0][0];
                message_board.message_board_grid.setRowColor(row_id, row_color);
                row_id = null;
            }
            
            if (result[0].message_count > 0 && result[0].message_count < 100) {
                parent.updateMessageNumber("message-count", result[0].message_count);
            }  else if (result[0].message_count > 99) {            
                parent.updateMessageNumber("message-count", '99+');  
            }   

            if (result[0].alert_count > 0 && result[0].alert_count < 100) {
                parent.updateMessageNumber("alert-count", result[0].alert_count);
            }  else if (result[0].alert_count > 99) {            
                parent.updateMessageNumber("alert-count", '99+');
            }
            
        }
    }
    
    function clear_message_board_grid() {
        //message_board.message_board_grid.clearAll();
    }

    function messagebox_menu_click(id){
        switch ( id ) {
            case 'refresh':
                load_messageboard_grid_data(message_board_type); 
                break;
            case "delete" :
                delete_row_selected_message(message_board_type);
                break;
            case 'forward' :
                if (message_board.message_board_grid.getCheckedRows(1)){
                    var message_id = message_board.message_board_grid.cells(message_board.message_board_grid.getCheckedRows(1), 0).getValue();
                    forward_messages(message_id);
                } else {
                    show_messagebox("Please select the message.");
                }
                break;
            case 'read':
                read_unread('f');
                break;
            case 'unread':
                read_unread('g');
                break;
        }
    }
    
    
    /**/
    function forward_messages(selected_id) {
        var split_id = selected_id.split(',');
        
        if (selected_id == '' || selected_id == 'NULL') {
            show_messagebox("Please select the message.");
            return;
        }
        
        if (split_id.length > 1) {
            show_messagebox("Please select one message only.");
            return;
        } 


        unload_foward_message_window();
        
        if (!create_foward_message_window) {
            create_foward_message_window = new dhtmlXWindows();
        }
        
        var new_win = create_foward_message_window.createWindow('w2', 0, 0, 680, 520);
    
        var url = '<?php echo $app_php_script_loc; ?>' +  '../main.menu/scripts/send.message.container.php?selected_id=' + selected_id; 
        
        
        new_win.setText("Forward Message");  
        new_win.centerOnScreen();
        new_win.setModal(true); 
        new_win.attachURL(url, false, true); 
    }
    
    var create_foward_message_window;
    
    function unload_foward_message_window() {        
        if (create_foward_message_window != null && create_foward_message_window.unload != null) {
            create_foward_message_window.unload();
            create_foward_message_window = w2 = null;
        }
    }
    
    function close_forward_box() {
    
        var win_obj = create_foward_message_window.window('w2');
        win_obj.close();
    } 
    /**/
    function delete_row_selected_message(type) {
        var grid_type = type;
        var message_filter = (grid_type == 'message') ? 0 : 1;
        var checked="";
        checked=message_board.message_board_grid.getCheckedRows(1);
        var message_id = "";
        
        if ( checked == "" ) {
            show_messagebox("Please mark message to delete.");
        } else {
            var msg = "Are you sure you want to delete?";
            confirm_messagebox(msg, function(result) {
                var partsOfStr = checked.split(',');
                for (i = 0; i < partsOfStr.length; i++) {
                    selected_value_id = message_board.message_board_grid.cells(partsOfStr[i], 0).getValue();
                    if (i != 0) {
                        message_id += ',';
                    }
                    message_id += selected_value_id;
                }

                delete_grid_value_param = {
                                            "action": "spa_message_board",
                                            "flag": "d",
                                            "message_id": message_id, 
                                            "user_login_id": js_user_name,
                                            "message_filter": message_filter                                       
                                            }
                
                adiha_post_data('alert', delete_grid_value_param, '', '', 'delete_success_message');
            });
        }

    }

    function delete_success_message(result) {
        if(result[0]['status'] == "Success") {
            load_messageboard_grid_data(message_board_type); 
            if (message_board_type == 'alert') {
                if (result[0]['recommendation'] > 0 && result[0]['recommendation'] < 100) {
                    parent.updateMessageNumber("alert-count", result[0]['recommendation']);
                }  else if (result[0]['recommendation'] > 99) {                    
                    parent.updateMessageNumber("alert-count", '99+');
                }   
            } else {
                if (result[0]['recommendation'] > 0 && result[0]['recommendation'] < 100) {
                    parent.updateMessageNumber("message-count", result[0]['recommendation']);
                }  else if (result[0]['recommendation'] > 99) {                    
                    parent.updateMessageNumber("message-count", '99+');
                }   
                
            }
            
        
        }
    }

    /*
            Parent function call 
            tweak 
        */

    /*
        mark_check works when row is selected, to set check box value and to set the row selected
        */
    function mark_check(id, ind){
        var row_id = message_board.message_board_grid.cells(id, 1).isChecked();
        if(row_id == true){
            message_board.message_board_grid.cells(id, 1).setValue(0);
            message_board.message_board_grid.setRowColor(id,'');
        }
        if(row_id == false){
            message_board.message_board_grid.cells(id, 1).setValue(1);
            (function($){
                var color_rgb = $('.gridbox_dhx_web.gridbox table.hdr td').css("background-color");
                var hex_color = rgb2hex(color_rgb);
                message_board.message_board_grid.setRowColor(id, hex_color);
            })(jQuery);
        }
        function rgb2hex(rgb){
            rgb = rgb.match(/^rgba?[\s+]?\([\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?/i);
            return (rgb && rgb.length === 4) ? "#" +
                ("0" + parseInt(rgb[1],10).toString(16)).slice(-2) +
                ("0" + parseInt(rgb[2],10).toString(16)).slice(-2) +
                ("0" + parseInt(rgb[3],10).toString(16)).slice(-2) : '';
        }
    }

    /*
        check_marked checks the value of checkbox value and do as mark_check
        */
    message_board.check_marked = function(rid, cind, state) {
        if (state) {
            (function($){
                var color_rgb = $('.gridbox_dhx_web.gridbox table.hdr td').css("background-color");
                var hex_color = rgb2hex(color_rgb);
                message_board.message_board_grid.setRowColor(rid, hex_color);
            })(jQuery);
        } else if (!state) {
            message_board.message_board_grid.cells(rid, 1).setValue(0);
            message_board.message_board_grid.setRowColor(rid,'');
        }

        function rgb2hex(rgb){
        rgb = rgb.match(/^rgba?[\s+]?\([\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?/i);
        return (rgb && rgb.length === 4) ? "#" +
            ("0" + parseInt(rgb[1],10).toString(16)).slice(-2) +
            ("0" + parseInt(rgb[2],10).toString(16)).slice(-2) +
            ("0" + parseInt(rgb[3],10).toString(16)).slice(-2) : '';
        }
    }

    function message_pop_up_drill(id){
            //parent.message_pop_up_drill(id);
    }

    function TRMHyperlink(func_id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 , asofdate, asofdate_to) {
        parent.TRMHyperlink(func_id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 , asofdate, asofdate_to)
    }

</script>
</html>