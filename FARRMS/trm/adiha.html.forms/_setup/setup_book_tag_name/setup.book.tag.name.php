<?php
/**
* Setup book tag name screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <?php
        $namespace = 'book_tag_name';
        $function_id = 20010500; // function id of menu
        $rights_modify = 20010501; // function id for save/reset button privilege

        list (
            $has_rights_modify
        ) = build_security_rights (
            $rights_modify
        );

        $json = '[
                    {
                        id:             "a",
                        text:           "Book Tag Rename",
                        header:         false,
                        collapse:       false
                    }
                ]';
        $book_tag_layout = new AdihaLayout();
        echo $book_tag_layout->init_layout('book_tag_layout', '', '1C', $json, $namespace);

        // save/reset privilege
        if ($has_rights_modify == 1) {
            $has_rights_modify = 'true';
        } else {
            $has_rights_modify = 'false';
        }

        // Create toolbar for save and reset button
        $toolbar_obj = new AdihaToolbar();
        $toolbar_name = 'save_toolbar';
        $toolbar_json = '
                        [
                            {
                                id:         "save",
                                type:       "button",
                                text:       "Save",
                                img:        "save.gif",
                                imgdis:     "save_dis.gif",
                                enabled:    '.$has_rights_modify.'
                            },
                            {
                                id:         "reset",
                                type:       "button",
                                text:       "Reset",
                                img:        "redo.gif",
                                imgdis:     "redo_dis.gif",
                                enabled:    '.$has_rights_modify.'
                            }
                        ]';
        echo $book_tag_layout->attach_toolbar($toolbar_name);
        echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
        echo $toolbar_obj->load_toolbar($toolbar_json);
        echo $toolbar_obj->attach_event('', "onClick", $namespace.".save_or_reset");

        $form_value_sql = "EXEC spa_book_tag_name @flag='s', @xml = ''";
        $form_value_arr = readXMLURL($form_value_sql);
		
		$xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20010500', @template_name='SetupBookTagName', @group_name='General'";
		$return_value1 = readXMLURL($xml_file);
		$general_form_structure = $return_value1[0][2];    
		
		/*
        // Building Form using Form JSON
        $form_json = '[
                        {"type": "settings", "position": "label-top"},
                        {"type": "input", "name": "tag1", value: "' . $form_value_arr[0][0] . '", "label": "Tag 1", "position": "label-top", "inputWidth":"250", "offsetLeft": "20", "inputTop": "7", "offsetTop": "15"},
                        {"type": "newcolumn"},
                        {"type": "input", "name": "tag2", value: "' . $form_value_arr[0][1] . '", "label": "Tag 2", "position": "label-top", "inputWidth":"250", "offsetLeft": "20", "inputTop": "7", "offsetTop": "15"},
                        {"type": "newcolumn"},
                        {"type": "input", "name": "tag3", value: "' . $form_value_arr[0][2] . '", "label": "Tag 3", "position": "label-top", "inputWidth":"250", "offsetLeft": "20", "inputTop": "7", "offsetTop": "15"},
                        {"type": "newcolumn"},
                        {"type": "input", "name": "tag4", value: "' . $form_value_arr[0][3] . '", "label": "Tag 4", "position": "label-top", "inputWidth":"250", "offsetLeft": "20", "inputTop": "7", "offsetTop": "15"},
                    ]';
		*/
        // Creating new Form Object
        $form_name = 'tag_rename_form';
        $form_obj = new AdihaForm();
        echo $book_tag_layout->attach_form($form_name, 'a');
        echo $form_obj->init_by_attach($form_name, $namespace);
        echo $form_obj->load_form($general_form_structure);

        // required to close layout at the end to display layout
        echo $book_tag_layout->close_layout();         
    ?>
<script>
	$(function() {
        load_default_values();
         
    });
	
	function load_default_values() {
		var param = { 'action': 'spa_book_tag_name',
                      'flag': 's',
                      'xml': ''
                    };
        adiha_post_data('return_json', param, '', '', 'call_back_load_default_values', ''); 
	}
	
	function call_back_load_default_values(return_json) {

		var return_value = JSON.parse(return_json)[0];
		var tag1 = return_value.tag1;
		var tag2 = return_value.tag2;
		var tag3 = return_value.tag3;
		var tag4 = return_value.tag4;
		var reporting_group1 = return_value.reporting_group1;
		var reporting_group2 = return_value.reporting_group2;
		var reporting_group3 = return_value.reporting_group3;
		var reporting_group4 = return_value.reporting_group4;
		var reporting_group5 = return_value.reporting_group5;
		
		if (reporting_group1 == '' || reporting_group1 === null)
            reporting_group1 = 'Reporting Group1';    
		
		if (reporting_group2 == '' || reporting_group2 === null)
            reporting_group2 = 'Reporting Group2';    
		
		if (reporting_group3 == '' || reporting_group3 === null)
            reporting_group3 = 'Reporting Group3';   
		
		if (reporting_group4 == '' || reporting_group4 === null)
            reporting_group4 = 'Reporting Group4';    
		
		if (reporting_group5 == '' || reporting_group5 === null)
            reporting_group5 = 'Reporting Group5'; 
		
		var form_object = book_tag_name.tag_rename_form;
		form_object.setItemValue('tag1', tag1);
		form_object.setItemValue('tag2', tag2);
		form_object.setItemValue('tag3', tag3);
		form_object.setItemValue('tag4', tag4);
		form_object.setItemValue('reporting_group1', reporting_group1);
		form_object.setItemValue('reporting_group2', reporting_group2);
		form_object.setItemValue('reporting_group3', reporting_group3);
		form_object.setItemValue('reporting_group4', reporting_group4);
		form_object.setItemValue('reporting_group5', reporting_group5);
	}
	
    book_tag_name.save_or_reset = function(id) {
        var form_object = book_tag_name.tag_rename_form;
        switch(id) {
            case 'save':
                is_user_authorized('book_tag_name.proceed_to_save', '');
                break;

            case 'reset':
                // Set Default Values when 'Reset' is clicked
                form_object.setItemValue('tag1', 'Tag 1');
                form_object.setItemValue('tag2', 'Tag 2');
                form_object.setItemValue('tag3', 'Tag 3');
                form_object.setItemValue('tag4', 'Tag 4');
				form_object.setItemValue('reporting_group1', 'Reporting Group 1');
                form_object.setItemValue('reporting_group2', 'Reporting Group 2');
                form_object.setItemValue('reporting_group3', 'Reporting Group 3');
                form_object.setItemValue('reporting_group4', 'Reporting Group 4');
				form_object.setItemValue('reporting_group5', 'Reporting Group 5');
                break;

            default:
                // Set default values
                form_object.setItemValue('tag1', 'Tag 1');
                form_object.setItemValue('tag2', 'Tag 2');
                form_object.setItemValue('tag3', 'Tag 3');
                form_object.setItemValue('tag4', 'Tag 4');
				form_object.setItemValue('reporting_group1', 'Reporting Group 1');
                form_object.setItemValue('reporting_group2', 'Reporting Group 2');
                form_object.setItemValue('reporting_group3', 'Reporting Group 3');
                form_object.setItemValue('reporting_group4', 'Reporting Group 4');
				form_object.setItemValue('reporting_group5', 'Reporting Group 5');
                break;

        }
    }

    book_tag_name.proceed_to_save = function() {
        var form_xml = "<FormXML ";
        var form_object = book_tag_name.tag_rename_form;
        book_tag_name.book_tag_layout.progressOn();
        var tag1 = form_object.getItemValue('tag1');
        var tag2 = form_object.getItemValue('tag2');
        var tag3 = form_object.getItemValue('tag3');
        var tag4 = form_object.getItemValue('tag4');
		var reporting_group1 = form_object.getItemValue('reporting_group1');
		var reporting_group2 = form_object.getItemValue('reporting_group2');
		var reporting_group3 = form_object.getItemValue('reporting_group3');
		var reporting_group4 = form_object.getItemValue('reporting_group4');
		var reporting_group5 = form_object.getItemValue('reporting_group5');
		
        form_xml += ' tag1 = "' + tag1 +'"';
        form_xml += ' tag2 = "' + tag2 + '"';
        form_xml += ' tag3 = "' + tag3 + '"';
        form_xml += ' tag4 = "' + tag4 + '"';
		form_xml += ' reporting_group1 = "' + reporting_group1 + '"';
		form_xml += ' reporting_group2 = "' + reporting_group2 + '"';
		form_xml += ' reporting_group3 = "' + reporting_group3 + '"';
		form_xml += ' reporting_group4 = "' + reporting_group4 + '"';
		form_xml += ' reporting_group5 = "' + reporting_group5 + '"';
        form_xml += "></FormXML>";
        var xml = "<Root function_id=\"20010500\" >";
        xml += form_xml;
        xml += "</Root>";
        xml = xml.replace(/'/g, "\"");

        if (tag1 == '')
            tag1 = 'Tag 1';

        if (tag2 == '')
            tag2 = 'Tag 2';

        if (tag3 == '')
            tag3 = 'Tag 3';

        if (tag4 == '')
            tag4 = 'Tag 4';     

		if (reporting_group1 == '')
            reporting_group1 = 'Reporting Group 1';    
		
		if (reporting_group2 == '')
            reporting_group2 = 'Reporting Group 2';    
		
		if (reporting_group3 == '')
            reporting_group3 = 'Reporting Group 3';   
		
		if (reporting_group4 == '')
            reporting_group4 = 'Reporting Group 4';    
		
		if (reporting_group5 == '')
            reporting_group5 = 'Reporting Group 5';    
		
        if (tag1.toLowerCase() == tag2.toLowerCase() || tag1.toLowerCase() == tag3.toLowerCase() || tag1.toLowerCase() == tag4.toLowerCase() || tag2.toLowerCase() == tag3.toLowerCase() || tag2.toLowerCase() == tag4.toLowerCase() || tag3.toLowerCase() == tag4.toLowerCase()) {                    
            if (tag1.toLowerCase() == tag2.toLowerCase()) {
                show_messagebox('Tag names are duplicate on <b>Tag 1</b> and <b>Tag 2</b>.');
            } else if (tag1.toLowerCase() == tag3.toLowerCase()) {
                show_messagebox('Tag names are duplicate on <b>Tag 1</b> and <b>Tag 3</b>.');
            } else if (tag1.toLowerCase() == tag4.toLowerCase()) {
                show_messagebox('Tag names are duplicate on <b>Tag 1</b> and <b>Tag 4</b>.');
            } else if (tag2.toLowerCase() == tag3.toLowerCase()) {
                show_messagebox('Tag names are duplicate on <b>Tag 2</b> and <b>Tag 3</b>.');
            } else if (tag2.toLowerCase() == tag4.toLowerCase()) {
                show_messagebox('Tag names are duplicate on <b>Tag 2</b> and <b>Tag 4</b>.');
            } else if (tag3.toLowerCase() == tag4.toLowerCase()) {
                show_messagebox('Tag names are duplicate on <b>Tag 3</b> and <b>Tag 4</b>.');
            }
            book_tag_name.book_tag_layout.progressOff();
            return false;
        }
				 
		var reporting_group = [];
		reporting_group.push(reporting_group1);
		reporting_group.push(reporting_group2);
		reporting_group.push(reporting_group3);
		reporting_group.push(reporting_group4);
		reporting_group.push(reporting_group5);
 
		var results = [];
			
		reporting_group.forEach(function(item, index){
			for(var i = 0; i <= reporting_group.length; i++) {
				if ((i + 1) != index) {
					if (reporting_group[i + 1] === reporting_group[index]) {
						results.push('Reporting Group' + (index + 1) + ' and ' + 'Reporting Group' + (i + 2));
					}
				}
			}
		});
		
		if(results.length > 0) {
			var msg = results.join();
			msg = 'Reporting Group names are duplicate on ' + msg;
			show_messagebox(msg);
			book_tag_name.book_tag_layout.progressOff();
            return false;			
		}
		
        var data_insert = {
                        "action": "spa_book_tag_name", 
                        "flag": "i",
                        "xml": xml
                    };

        adiha_post_data('return_json', data_insert, '', '', function(result) {
            var result = JSON.parse(result); 
            if(result[0].errorcode == 'Success') {
                success_call(result[0].message);

                var load_value_sql = {
                    "action": "spa_book_tag_name", 
                    "flag": "s"
                };
                var load_value_result = adiha_post_data('return_array', load_value_sql, '', '', function(load_value_result) {
                    form_object.setItemValue('tag1', load_value_result[0][0]);
                    form_object.setItemValue('tag2', load_value_result[0][1]);
                    form_object.setItemValue('tag3', load_value_result[0][2]);
                    form_object.setItemValue('tag4', load_value_result[0][3]);
					form_object.setItemValue('reporting_group1', load_value_result[0][4]);
					form_object.setItemValue('reporting_group2', load_value_result[0][5]);
					form_object.setItemValue('reporting_group3', load_value_result[0][6]);
					form_object.setItemValue('reporting_group4', load_value_result[0][7]);
					form_object.setItemValue('reporting_group5', load_value_result[0][8]);					
                });
                book_tag_name.book_tag_layout.progressOff();
            } else {
                dhtmlx.alert({
                    title: "Alert",
                    type: "alert-error",
                    text: result[0].message
                });
                book_tag_name.book_tag_layout.progressOff();
                return;
            }
        });
    }
</script>
<body>
</body>
</html>