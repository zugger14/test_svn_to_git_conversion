<?php
/**
* Certification systems screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php 

$rights_static_data_iu = 10101010; // main Save
list (
    $has_rights_static_data_iu
    ) = build_security_rights(
    $rights_static_data_iu
);

$layout = new AdihaLayout();
$form_obj = new AdihaForm();

if (isset($_POST['value_id'])) {
    $value_id = get_sanitized_value($_POST['value_id']);
    $xml = '<Root><PSRecordset gis_id="' . $value_id . '"></PSRecordset></Root>';
} else if (isset($_GET['value_id'])) { 
    $value_id = get_sanitized_value($_GET['value_id']);
    $xml = '<Root><PSRecordset gis_id="' . $value_id . '"></PSRecordset></Root>';
} else {
    $value_id = "null";
    $xml = '<Root><PSRecordset gis_id=""></PSRecordset></Root>';
}

//Loads data for form from backend.
$xml_file = "EXEC spa_create_application_ui_json 'j','10101025','certification_systems','" . $xml."'";
$return_value1 = readXMLURL($xml_file);

$i = 0;
$tab_json = '';
foreach ($return_value1 as $temp) {
    if ($i > 0)
        $tab_json = $tab_json . ',';
    $tab_json = $tab_json . $temp[1];
    $i++;
}
$tab_json = '[' . $tab_json . ']';

$name_space = 'certification_systems';

$layout_json = '[
                    {
                        id:             "a",
                        text:           "Certification Systems",
                        // width:          720,
                        // height:         160,
                        header:         false,
                        collapse:       false,
                        fix_size:       [true,true]
                    },

                ]';

$layout_name = 'certification_systems_layout';
echo $layout->init_layout($layout_name, '', '1C', $layout_json, $name_space);

$toolbar_name = 'certification_systems_toolbar';
echo $layout->attach_toolbar_cell($toolbar_name, 'a');
$toolbar_obj = new AdihaToolbar();
$toolbar_obj->init_by_attach($toolbar_name, $name_space);
$theme_selected = 'dhtmlx_'.$default_theme;
echo "var icon_loc = '../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/".$theme_selected."/imgs/dhxtoolbar_web/';";
echo 'certification_systems.certification_systems_toolbar.setIconsPath(icon_loc);';
echo $toolbar_obj->load_toolbar('[{id: "save", type: "button",text:"Save", img: "save.gif", imgdis: "save_dis.gif", title:"Save", action: "save_certification_systems",  }]');
if($value_id != 'null') {   //Save button Privilege
    $type_id = ( isset($_POST['type_id']) && $_POST['type_id'] != '' ) ? get_sanitized_value($_POST['type_id']) : 10011; 
    echo $toolbar_obj->save_privilege($type_id, $value_id);
}

//Start of Tabs
$tab_name = 'certification_systems_tabs';
echo $layout->attach_tab_cell($tab_name, 'a', $tab_json);
echo $name_space . "." . $tab_name . '.setTabsMode("bottom");';
//Attaching tabbar.
$tab_obj = new AdihaTab();
echo $tab_obj->init_by_attach($tab_name, $name_space);
$yy = 0;
foreach ($return_value1 as $temp1) {
    $form_json = $temp1[2];
    $tab_id = 'detail_tab_' . $temp1[0];
    $form_name = 'form_' . $temp1[0];
    if ($form_json) {
        echo $tab_obj->attach_form($form_name, $tab_id, $form_json, $name_space);
        if ($yy == 0) {
            $first_form = $name_space . "." . $form_name;
        }
        else if ($yy == 1) {
            $second_form = $name_space . "." . $form_name;
        }
        else if ($yy == 2) {
            $third_form = $name_space . "." . $form_name;
        }
        $last_form = $name_space . "." . $form_name;
    }
    $yy++;
}
    
echo $layout->close_layout();

?>

<script type="text/javascript">

    var value_id = '<?php echo $value_id; ?>';

    $(document).ready(function () {
        if (value_id != null) {
            import_data(value_id);
        }
    });

    /*
     * Gets value of each form component from database.
     */
    function import_data(value_id) {
        var params = {
                        'action': 'spa_certification_systems',
                        'flag': 's',
                        'value_id': value_id
                    }
        
        var result = adiha_post_data('return_json', params, '', '', 'load_data');
    }

    /*
     * Load value of each form component.
     */
    function load_data(result) {
        result = JSON.parse(result);        
        var all_tab = certification_systems.certification_systems_tabs.getAllTabs();
        
        for(var i=0; i<all_tab.length; i++) {
            if(i == 0) {
                var general_tab_obj = certification_systems.certification_systems_tabs.tabs(all_tab[0]).getAttachedObject();
                if (general_tab_obj instanceof dhtmlXForm) {
                    general_tab_obj.forEachItem(function(name){
                        switch(name) {
                            case 'value_id':
                            general_tab_obj.setItemValue('value_id', result[0].value_id);
                            break;

                            case 'type_id':
                            general_tab_obj.setItemValue('type_id', result[0].type_id);
                            break;

                            case 'code':
                            general_tab_obj.setItemValue('code', result[0].code);
                            break;

                            case 'description':
                            general_tab_obj.setItemValue('description', result[0].description);
                            break;
                        }
                    });                    
                }
            } else if (i == 1) {
                var properties_tab_obj = certification_systems.certification_systems_tabs.tabs(all_tab[1]).getAttachedObject();
                if (properties_tab_obj instanceof dhtmlXForm) {
                    properties_tab_obj.forEachItem(function(name) {
                        switch(name) {
                            case 'gis_id':
                            properties_tab_obj.setItemValue('gis_id', result[0].code);
                            break;

                            case 'curve_id':
                            properties_tab_obj.setItemValue('curve_id', result[0].curve_id);
                            break;

                            case 'cert_rule':
                            properties_tab_obj.setItemValue('cert_rule', result[0].cert_rule);
                            properties_tab_obj.setNote('cert_rule', {
                                text: "<span style='color: black;font-style: inherit;font-size: 12px;text-align: justify'><br><strong>Rules for writing certificate</strong> - Each tag must contain <strong>#n</strong> , where <em>n</em> indicates number of fixed characters. &lt;yy#2&gt; &lt;yyyy#4&gt; = Year , &lt;mm#2&gt; = Month,&lt;q#1&gt; = Quarterly , &lt;facid#5&gt; = Facility ID , &lt;i#4&gt; to &lt;i#10&gt; # of digits in the block in the sequence  and special character ( -  /  : [  ]  {  } ) must be enclosed within &quot;&lt; &gt;&quot;, e.g. <em>&lt;:#1&gt;</em><span>",
                                width: 400
                            });
                            break;
                        }
                    })
                }
            } else {
                var address_tab_obj = certification_systems.certification_systems_tabs.tabs(all_tab[2]).getAttachedObject();
                if (address_tab_obj instanceof dhtmlXForm) {
                    address_tab_obj.forEachItem(function(name) {
                        switch(name) {
                            case 'reporting_type':
                            address_tab_obj.setItemValue('reporting_type', result[0].reporting_type);
                            break;

                            case 'address':
                            address_tab_obj.setItemValue('address', result[0].address);
                            break;

                            case 'phone_no':
                            address_tab_obj.setItemValue('phone_no', result[0].phone_no);
                            break;

                            case 'fax_email':
                            address_tab_obj.setItemValue('fax_email', result[0].fax_email);
                            break;

                            case 'website':
                            address_tab_obj.setItemValue('website', result[0].website);
                            break;

                            case 'interconnecting_utility':
                            address_tab_obj.setItemValue('interconnecting_utility', result[0].interconnecting_utility);
                            break;

                            case 'voltage_level':
                            address_tab_obj.setItemValue('voltage_level', result[0].voltage_level);
                            break;

                            case 'contact_name':
                            address_tab_obj.setItemValue('contact_name', result[0].contact_name);
                            break;

                            case 'contact_address':
                            address_tab_obj.setItemValue('contact_address', result[0].contact_address);
                            break;

                            case 'contact_phone':
                            address_tab_obj.setItemValue('contact_phone', result[0].contact_phone);
                            break;

                            case 'contact_email':
                            address_tab_obj.setItemValue('contact_email', result[0].contact_email);
                            break;

                            case 'control_area_operator':
                            address_tab_obj.setItemValue('control_area_operator', result[0].control_area_operator);
                            break;
                        }
                    })
                }
            }
        }
    }

    function save_certification_systems() {
        if(value_id != '') {
            flag = 'u'
        } else {
            flag = 'i'
        }

        var status = true;
        var general_xml = '<Root>';
        var cert_xml = '<Root>';
        var all_tab = certification_systems.certification_systems_tabs.getAllTabs();

        for(var i=0; i<all_tab.length; i++) {

            if(i == 0) {
                var general_tab_obj = certification_systems.certification_systems_tabs.tabs(all_tab[0]).getAttachedObject();
                if (general_tab_obj instanceof dhtmlXForm) {
                    status = validate_form(general_tab_obj);
                    if (!status) {
                        return;
                    } else {
                        var value_code = general_tab_obj.getItemValue('code');
                        var value_desc = general_tab_obj.getItemValue('description');
                        if (value_desc == '') {
                            value_desc = value_code;
                        }
                        general_xml += '<PSRecordset type_id="10011" value_id="' + value_id + '" code="' + value_code + '" description="' + value_desc + '"></PSRecordset></Root>'
                    }
                }
            }  else if (i == 1) {
                var properties_tab_obj = certification_systems.certification_systems_tabs.tabs(all_tab[1]).getAttachedObject();
                if (properties_tab_obj instanceof dhtmlXForm) {
                    status = validate_form(properties_tab_obj);
                    if (!status) {
                        return;
                    } else {
                        var value_gis_id    = value_id;
                        var value_curve_id  = properties_tab_obj.getItemValue('curve_id') || '';
                        var value_cert_rule = properties_tab_obj.getItemValue('cert_rule') || '';
                        cert_xml += '<PSRecordset gis_id="' + value_gis_id + '" curve_id="' + value_curve_id + '" cert_rule="' + value_cert_rule + '" '
                    }
                }
            } else if (i == 2){
                var address_tab_obj = certification_systems.certification_systems_tabs.tabs(all_tab[2]).getAttachedObject();
                if (address_tab_obj instanceof dhtmlXForm) {
                    status = validate_form(address_tab_obj);
                    if (!status) {
                        return;
                    } else {
                        var form_data3 = address_tab_obj.getFormData();
                        var value_reporting_type            = form_data3.reporting_type || '';
                        var value_address                   = form_data3.address || '';
                        var value_phone_no                  = form_data3.phone_no || '';
                        var value_fax_email                 = form_data3.fax_email || '';
                        var value_website                   = form_data3.website || '';
                        var value_interconnecting_utility   = form_data3.interconnecting_utility || '';
                        var value_voltage_level             = form_data3.voltage_level || '';
                        var value_contact_name              = form_data3.contact_name || '';
                        var value_contact_address           = form_data3.contact_address || '';
                        var value_contact_phone             = form_data3.contact_phone || '';
                        var value_contact_email             = form_data3.contact_email || '';
                        var value_control_area_operator     = form_data3.control_area_operator || '';

                        cert_xml += 'reporting_type="' + value_reporting_type + '" address="' + value_address + '" phone_no="' + value_phone_no + '" fax_email="' + value_fax_email + '" website="' + value_website + '" interconnecting_utility="' + value_interconnecting_utility + '" voltage_level="' + value_voltage_level + '" contact_name="' + value_contact_name + '" contact_address="' + value_contact_address + '" contact_phone="' + value_contact_phone + '" contact_email="' + value_contact_email + '" control_area_operator="' + value_control_area_operator + '" ></PSRecordset></Root>'
                    }
                }
            }

        }
        
        data = {
                "action": "spa_certification_systems",
                "flag": flag,
                "xmlValue1": general_xml,
                "xmlValue2": cert_xml
            };

        //added the callback parameter to refresh the grid of parent grid
        adiha_post_data("alert", data, "", "", "save_callback");
    }

    function save_callback(result) {
        if (result[0].status == 'Success') {
            var new_id = result[0].recommendation;
            var code = '';
            var all_tab = certification_systems.certification_systems_tabs.getAllTabs();
        
            for(var i=0; i<all_tab.length; i++) {
                if(i == 0) {
                    var general_tab_obj = certification_systems.certification_systems_tabs.tabs(all_tab[0]).getAttachedObject();
                    if (general_tab_obj instanceof dhtmlXForm) {
                        general_tab_obj.setItemValue('value_id', new_id)
                        code = general_tab_obj.getItemValue('code');
                    }
                }
            }
            
            parent.setup_static_data.special_menu_case(result, code,'certification_systems');
        }
    }

</script>

</body>
</html>