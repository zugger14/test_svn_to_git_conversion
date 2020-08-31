<?php
/**
* Report viewer screen
* @copyright Pioneer Solutions
*/
?>
<?php ob_start();?>
<!--(dont use for now, causes tablix row shrik)!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"-->
<html>   
    <?php
    ob_clean();
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    require_once 'report.global.vars.php';

    $php_script_loc = $app_php_script_loc;
    global $app_adiha_loc;
    $app_user_loc = $app_user_name;
    
    $form_name = "report_viewer";
    $call_from = isset($_GET['call_from']) ? $_GET['call_from'] : '';
    $process_id = isset($_GET['process_id']) ? $_GET['process_id'] : '';
    $close_progress = isset($_GET['close_progress']) ? $_GET['close_progress'] : 0 ;

    $result_formatted_filter_gbl = '';
    rfx_get_formatted_filter();
    $result_html = '';
    $total_pages = 1;
    $execution_id = '';
    $tmp_replace_root_url = '';

    if ($call_from == 'power_bi') {
        
        $report_filter = $_POST['report_filter'];
        $power_bi_report_id = $_POST['power_bi_report_id'];
        $undock_opt = $_POST['undock_opt'];
        $has_rights_report_manager_powerbi = $_POST['has_rights_report_manager_powerbi'];

        $report_filter_arr = explode("_-_", $report_filter);
        $report_filter = $report_filter_arr[0];
        $sec_filter_process_id = $report_filter_arr[1];

        $xml_formatted_filter = "EXEC spa_power_bi_report @flag='f', @power_bi_report_id=".$power_bi_report_id.", @report_filter='$report_filter'";
            
        $result_formatted_filter_power_bi = readXMLURL2($xml_formatted_filter);
        $formatted_filter = '';
        for ($i = 0; $i < sizeof($result_formatted_filter_power_bi); $i++) {
            $formatted_filter .= $result_formatted_filter_power_bi[$i]['filter_display_label'] . ' = ' . $result_formatted_filter_power_bi[$i]['filter_display_value'] . ($i == sizeof($result_formatted_filter_power_bi) - 1 ? '' : ' | ');
        }
        
       
        $xml_power_bi_info = "EXEC spa_power_bi_report @flag = 'r', @report_filter = '" . $report_filter . "', @power_bi_report_id='" . $power_bi_report_id . "', @undock_opt='" . $undock_opt . "'" . ", @sec_filter_process_id='" . $sec_filter_process_id . "'";

        $data_power_bi_info = readXMLURL2($xml_power_bi_info); //die(print_r($data_power_bi_info)); 
        $report_name = $data_power_bi_info[0]['report_name'];
        $source_report = $data_power_bi_info[0]['source_report'];
        $power_bi_url = $data_power_bi_info[0]['report_url'];
        $power_bi_table = $data_power_bi_info[0]['process_id'];
        $powerbi_username = $data_power_bi_info[0]['power_bi_username'];
        $powerbi_password = $data_power_bi_info[0]['power_bi_password'];
		$powerbi_client_id = $data_power_bi_info[0]['power_bi_client_id'];
		$powerbi_group_id = $data_power_bi_info[0]['power_bi_group_id'];
        

        //var_dump($power_bi_url .'?rs:Embed=true&filter=process_table eq \'' . $power_bi_table);
        ?>
             <style type="text/css">
                body {
                    background-color: white;
                    width: 99%;
                }  

                #report-body {
                    width: 99.5%;
                }

                #cn-ssrs-viewer-report {
                    border-top: 1px solid steelblue;
                }

                #report-name {
                    font-family: 'Tahoma';
                    font-size: 15px;    
                    font-weight: bold;
                }

                .tree-navigator .plus {
                    background-image: url('<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/TogglePlus.gif');
                    background-repeat:no-repeat; 
                    cursor: hand; 
                    font-weight: bold;
                }

                .tree-navigator .minus {
                    background-image: url('<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/ToggleMinus.gif');
                }

                .tree-navigator {  
                    margin-bottom: 2px;
                    padding-right: 2px;
                    text-indent: 12px;
                }

                .child {
                    display: none;
                    text-indent: 0px;
                    margin-left: 13px;
                }            
              
                body {
                    overflow: auto;
                }
                
                .report_filter_font {
                    font-family: 'Tahoma';
                    font-size: 12px;

                }

                #power_bi_report_div {
                    height: 93%;
                }

                #power_bi_report_div iframe {
                    border: 1px solid #aaa;
                    margin: 2px;                    
                }

                .change_mode_view_span {
                     background-image: url('<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/themes/dhtmlx_jomsomGreen/imgs/dhxtoolbar_web/view.gif');
                }

                .change_mode_edit_span {
                    background-image: url('<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/themes/dhtmlx_jomsomGreen/imgs/dhxtoolbar_web/edit.gif');
                }

                .print_span {
                    background-image: url('<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/themes/dhtmlx_jomsomGreen/imgs/dhxtoolbar_web/print.gif');
                }

                .reload_span {
                    background-image: url('<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/themes/dhtmlx_jomsomGreen/imgs/dhxtoolbar_web/refresh.gif');
                }


                #remove_save_btn {
                    height: 39px;
                    background-color: #EAEAEA;
                    width: 59px;
                    border-top: 1px solid #aaa;
                    position: absolute;
                    border-left: 1px solid #aaa;
                    text-align: center;
                    cursor: pointer;
                    margin: 2px;
                }

                #powerbi_saveas_btn {
                    font-size: 12px;
                    color: #444;
                    line-height: 41px;
                }
                /*
               #remove_save_btn_right {
                    height: 39px;
                    background-color: #EAEAEA;
                    width: 5.2%;
                    border-top: 1px solid #aaa;
                    position: absolute;
                    border-right: 1px solid #aaa;
                    right: 8;
                    text-align: center;
                    cursor: pointer;
                }
                #powerbi_save_btn {
                    font-size: 10px;
                    color: #444;
                    line-height: 41px;
                    border: 1px solid #555;
                    padding: 3px;
                }
                */

            </style>
            <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/lib/power_bi/es6-promise.js"></script>
            <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/lib/power_bi/powerbi.js"></script>
             <script type="text/javascript">

                $(function() {
                    dhxWins = new dhtmlXWindows();
                    $('img[src$="ToggleMinus.gif"]').attr('src','<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/ToggleMinus.gif');
                    $('img[src$="TogglePlus.gif"]').attr('src','<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/TogglePlus.gif');
                                                
                    $(".tree-navigator .plus").click(function() {
                        $(this).toggleClass( "tree-navigator minus"); 
                        var current_item = $('#report-body').find('.child');
                                                    
                        if (current_item.css('display') == 'none') {
                            current_item.fadeIn('fast');
                        } else {
                            current_item.fadeOut('fast');
                        }
                    });
                });
            </script>
        <?php
        //if  ($undock_opt != 'true') {
            echo '<div id="report-body">
                <div id="cn-ssrs-viewer-header">
                    <p id="report-name"></p>
                </div>
                <div class="tree-navigator report_filter_font" >
                    <div class="plus" style="display: inline-block"> <label class="">' . get_locale_value("Report Filter", true) . '</label></div>
                    <div class="child" >
                    ';
            echo $formatted_filter;
            echo '   </div> 
                </div>
                <div id="cn-ssrs-viewer-report">
                    <div style="margin-bottom: 8px"></div>
                    <div id="remove_save_btn" style="display:none" title="Save As" onclick="power_bi_saveas_clicked()"><span id="powerbi_saveas_btn">Save As</div>
                    <!--<div id="remove_save_btn_right" style="display:none" title="Save"><span id="powerbi_save_btn">Save</div></div>-->
                    <div id="power_bi_report_div"></div>
                    ';
             echo '    </div>
            </div>';
        //}
         /*************************************************************************************/
         
         function power_bi_api($url, $headers, $fields, $is_post) {
            // Open connection
            $ch = curl_init();

            // Set the URL, number of POST vars, POST data
            curl_setopt( $ch, CURLOPT_URL, $url);
            if ($is_post)
                curl_setopt( $ch, CURLOPT_POST, true);
            curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers);
            curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true);
            if ($is_post)
                curl_setopt( $ch, CURLOPT_POSTFIELDS, $fields);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
             if ($is_post)
                curl_setopt($ch, CURLOPT_POST, true);
             curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

            // Execute post
            $result = curl_exec($ch);
			
			if (curl_error($ch)) {
				ob_clean();
				$msg_desc =  curl_error($ch);
				echo $msg_desc;
				die();
			}
			
            // Close connection
            curl_close($ch);
            return json_decode($result);

         }
        //Get ACCESS TOKEN
            $client_id = $powerbi_client_id;
            $username = $powerbi_username;
            $password = $powerbi_password;
            $group_id = $powerbi_group_id;
            $api_power_bi_url = "https://api.powerbi.com/v1.0/myorg/groups/";
            $app_power_bi_url = "https://app.powerbi.com/reportEmbed";

            $url = "https://login.microsoftonline.com/common/oauth2/token";
            $headers = array(
                'Content-Type: application/x-www-form-urlencoded'
            );
            $fields_len = 'grant_type=password&client_id='.$client_id.'&resource=https://analysis.windows.net/powerbi/api&scope=openid&username='.$username.'&password='.$password;
            $results = power_bi_api($url, $headers, $fields_len, true);
            //b_clean(); var_dump($results); die();
            
            $token_type = $results->token_type;
            $access_token = $results->access_token;
			if ($access_token == '') {
				ob_clean();
				$msg_desc = 'Error! Unable to connect microsoftonline.';
				echo $msg_desc;
				die();
			}
            
        //Get list of reports            
            $url = $api_power_bi_url.$group_id."/reports";
            $headers = array(
                'Content-Type: application/json',
                'Authorization: ' .$token_type. ' ' . $access_token
            );
            $fields_len = '{}';
            $results = power_bi_api($url, $headers, $fields_len, false);
            $report_lists = $results->value;
            $report_exists = false;
            for($i=0;$i<count($report_lists); $i++) {

                if($report_lists[$i]->name == str_replace(' ', '_',$source_report)) {
                    $report_exists = true;
                    $report_id = $report_lists[$i]->id;
                    $dataset_id = $report_lists[$i]->datasetId;
                    continue;
                }
           }
           
    if ($report_exists) {
            $report_id = $report_id;
            $dataset_id = $dataset_id;
            $role = 'Role1';  

        //Get EMBEDDED TOKEN
            $url = $api_power_bi_url.$group_id."/reports/".$report_id."/GenerateToken";

            
            $headers = array(
                'Content-Type: application/json',
                'Authorization: ' .$token_type. ' ' . $access_token
            );

            if ($has_rights_report_manager_powerbi == 1) {
                $edit_view = 'edit';
            } else {
                $edit_view = 'view';
            }

            $fields_len = '{   
                            "accessLevel": "'.$edit_view.'",
                            "allowSaveAs": "true",
                            "identities": [     
                                {      
                                    "username": "'.$app_user_loc.'",
                                    "roles": ["'.$role.'"],
                                    "datasets": [ "'.$dataset_id.'" ]
                                }   
                                ] 
                            }';
            $results = power_bi_api($url, $headers, $fields_len, true);
            $embed_token = $results->token;
			if ($embed_token == '') {
				ob_clean();
				$msg_desc = 'Error! Embed token failed to generate.';
				echo $msg_desc;
				die();
			}

        
        //SET Dataset parameter
        /*
            $url = $api_power_bi_url.$group_id."/datasets/".$dataset_id."/parameters";
            $headers = array(
                'Content-Type: application/json',
                'Authorization: ' .$token_type. ' ' . $access_token
            );
            $fields_len = '{}';
            $results = power_bi_api($url, $headers, $fields_len, false);
            var_dump($results);
            //var_dump($access_token);
            die();
        */
            //sleep(5);
        
        //SET Dataset END
        /*    
        //Update Parameters
            $url = $api_power_bi_url.$group_id."/datasets/".$dataset_id."/UpdateParameters";

            
            $headers = array(
                'Content-Type: application/json',
                'Authorization: ' .$token_type. ' ' . $access_token
            );
            $fields_len = '{ 
                          "updateDetails": [ 
                            { 
                              "name": "Parameter1", 
                              "newValue": "adiha_process.dbo.batch_report_farrms_admin_TRMTracker_Master_Demo3_Dev_AR_Aging_Report2" 
                            }
                          ] 
                        } 
                        ';
            $results = power_bi_api($url, $headers, $fields_len, true);
            //sleep(5);
            //var_dump($results);
            //die();
            */
        
        

        $embed_url = $app_power_bi_url.'?reportId='.$report_id.'&groupId='.$group_id;

        ?>

         <script type="text/javascript">
            var embedToken = '<?php echo $embed_token;?>';
            var embedURL = '<?php echo $embed_url;?>';
            var embedID = '<?php echo $report_id;?>';
            


            // Get models. models contains enums that can be used.
            var models = window['powerbi-client'].models;
            //console.log(models);
            
            // We give All permissions to demonstrate switching between View and Edit mode and saving report.
            var permissions = models.Permissions.ReadWrite;
            //var permissions = models.Permissions.All;

            view_mode = 'view';

            var embedConfiguration = {
                type: 'report',
                tokenType: models.TokenType.Embed,
                accessToken: embedToken,
                embedUrl: embedURL,
                id: embedID,
                permissions: permissions,
                 viewMode: models.ViewMode.View,
                settings: {
                    filterPaneEnabled: false,
                    navContentPaneEnabled: true
                }
            };

            // Grab the reference to the div HTML element that will host the report
            var reportContainer = $('#power_bi_report_div')[0];

            // Embed report
            report = powerbi.embed(reportContainer, embedConfiguration);
            var  change_mode = '<div title="Click to Edit Mode" style="float:right;width:85px;cursor:pointer;margin-top:-8px;" id="change_mode"><span id="change_mode_span" class="change_mode_edit_span" style="float:left;width:18px;height:18px;"></span><span id="change_mode_text" style="font-size:12px;padding-left:3px;line-height:22px;" >Edit Mode</span></div>';
            
            var print_mode = '<div title="Click to Print" style="float:right;width:65px;cursor:pointer;margin-top:-8px;" id="print_mode"><span id="print_mode_span" class="print_span" style="float:left;width:18px;height:18px;"></span><span id="print_mode_text" style="font-size:12px;padding-left:3px;line-height:22px;" >Print</span></div>';
            
            var reload_mode = '<div title="Click to Reload" style="float:right;width:75px;cursor:pointer;margin-top:-8px;" id="reload_mode"><span id="reload_mode_span" class="reload_span" style="float:left;width:18px;height:18px;"></span><span id="reload_mode_text" style="font-size:12px;padding-left:3px;line-height:22px;" >Reload</span></div>';

            $('#cn-ssrs-viewer-header').append(change_mode + reload_mode + print_mode);

            $('#change_mode').click(function() {
                // Switch to view mode.
                if (view_mode == 'view') {
                    report.switchMode("edit");  
                    const newSettings = {
                          navContentPaneEnabled: true,
                          filterPaneEnabled: true
                        };
                    report.updateSettings(newSettings).catch(function (error) {
                        console.log(errors);
                    });
                    view_mode = 'edit';
                    $(this).find('#change_mode_text').text('View Mode');
                    $(this).find('#change_mode_span').addClass('change_mode_view_span');
                    $(this).find('#change_mode_span').removeClass('change_mode_edit_span');
                    $(this).attr('title','Click to View Mode');
                    $('#print_mode').hide();
                    setTimeout(function(){$('#remove_save_btn').hide()}, 200);
                    //setTimeout(function(){$('#remove_save_btn_right').show()}, 200);
                    //console.log($('#power_bi_report_div').find('iframe'))
                }
                else {
                    report.switchMode("view");    
                    const newSettings = {
                          navContentPaneEnabled: true,
                          filterPaneEnabled: false
                        };
                    report.updateSettings(newSettings).catch(function (error) {
                        console.log(errors);
                    });                    
                    view_mode = 'view';
                    $(this).find('#change_mode_text').text('Edit Mode');
                    $(this).find('#change_mode_span').removeClass('change_mode_view_span');
                    $(this).find('#change_mode_span').addClass('change_mode_edit_span');
                    $(this).attr('title','Click to Edit Mode');
                    $('#print_mode').show();
                    setTimeout(function(){$('#remove_save_btn').hide()}, 200);
                    //setTimeout(function(){$('#remove_save_btn_right').hide()}, 200);
                }
            })

            $('#print_mode').click(function() {
                 
                // Get a reference to the embedded report.
                print_report = powerbi.get(reportContainer);
                 
                // Trigger the print dialog for your browser.
                print_report.print()
                    .catch(function (errors) {
                        console.log(errors);
                    });
            });

            $('#reload_mode').click(function() {
                // Reload the displayed report
                report.reload()
                    .then(function (result) {
                        console.log("Reloaded");
                    })
                    .catch(function (errors) {
                        console.log(errors);
                    });
                 report.switchMode("view");                        
                view_mode = 'view';
                $('#change_mode').find('#change_mode_text').text('Edit Mode');
                $('#change_mode').find('#change_mode_span').removeClass('change_mode_view_span');
                $('#change_mode').find('#change_mode_span').addClass('change_mode_edit_span');
                $('#change_mode').attr('title','Click to Edit Mode');
                $('#print_mode').show();
                setTimeout(function(){$('#remove_save_btn').hide()}, 200);
            });
            
            // Report.off removes a given event handler if it exists.
            report.off("loaded");
             
            // Report.on will add an event handler which prints to Log window.
            report.on("loaded", function() {
                console.log("Loaded");
            });
             
            report.on("error", function(event) {
               console.log(event);
                 
                report.off("error");
            });
            
             

            function power_bi_saveas_clicked() {
                var rdf_form_json = [
                        {type:'settings', position: 'label-top', inputHeight: 28},
                        {type:'block', blockOffset: ui_settings['block_offset'], list: [
                            {type:"input", name:'saveas_report_name', required: true, label:'Report Name', width: ui_settings['field_size'], offsetLeft : ui_settings['offset_left'], userdata:{"validation_message":"Required Field."}},                            
                        ]}
                    ];

                var is_win = dhxWins.isWindow('w1_saveas');
                
                if (is_win == true) {
                    w1_saveas.close();
                } 
                
                w1_saveas = dhxWins.createWindow({
                    id:'w1_saveas'
                    ,width: 450
                    ,height: 180
                    ,modal: true
                    ,resize: true
                    ,text: 'Save As PowerBI Report'
                    ,center: false
                    
                });
                w1_saveas.button('minmax').hide();
                w1_saveas.button('park').hide(); 
                form_rd = w1_saveas.attachForm(rdf_form_json, true);

                window_rdf_menu = w1_saveas.attachToolbar({
                    icon_path: js_image_path + 'dhxtoolbar_web/',
                    items:[
                        {id:"save", title:"Save", text:"Save", type: "button", disabled: false, img: 'save.gif', img_disabled: 'save_dis.gif'}
                    ],
                    onClick:function(id){
                        switch(id) {
                            case 'save':
                                if(!validate_form(form_rd)) {
                                    return;
                                }
                                power_bi_saveas_process();
                                break;
                        }  
                    }
                });

             }

            function power_bi_saveas_process() {
                var saveas_report_name = form_rd.getItemValue('saveas_report_name');

                // Get a reference to the embedded report HTML element
                var embedContainer = $('#power_bi_report_div')[0];
                 
                // Get a reference to the embedded report.
                new_report = powerbi.get(embedContainer);
                var saveas_report_name = saveas_report_name.replace(/ /g, "_");

                var saveAsParameters = {
                    name: saveas_report_name
                };
                 
                // SaveAs report
                var r = new_report.saveAs(saveAsParameters);
                console.log(r);

            }


        </script>


         <?php
         /****************************************************************************************/
     } //End of $report_exists
     else {	
			ob_clean();
            echo 'Error! No Report Exists';
     }
        die();
    }

    if ($call_from == 'excel') {
        ob_start();
        $excel_sheet_id = $_GET['excel_sheet_id'];
        $export_type = $_GET['export_type'];
        $filter_string = ($_POST['sec_filters_info'] != '') ? "'" . $_POST['sec_filters_info'] . "'" : 'NULL';

        if($export_type == 'pdf2') {
            $export_format  = 'PDF';
        } else if ($export_type == 'excel2') {
            $export_format  = 'excel'; 
        } else {
            $export_format  = 'PNG';
        }

        //$export_format = ($export_type == 'pdf2') ? 'PDF' : 'excel';
        
        $flag = ($export_type == 'SYNC') || ($export_type == 'pdf2') || ($export_type == 'excel2') ? 'o' : 'n';
        //$filter_in_xml = isset($_POST['filter_in_xml']) ? urldecode($_POST['filter_in_xml']) : '';
        $filter_in_xml = build_excel_parameters($result_formatted_filter_gbl);
        
        $xml_url_report_item_info = "EXEC spa_view_report @flag = '" . $flag . "', @report_id = " . $excel_sheet_id . ", @view_report_filter_xml='" . $filter_in_xml . "', @export_format='" . $export_format . "', @filter_string=" . $filter_string;
        
        $data_report_info_param = readXMLURL2($xml_url_report_item_info); //die(print_r($data_report_info_param)); 
        $report_name_excel = $data_report_info_param[0]['report_name'] ?? '';
        $report_filter_excel_default = $data_report_info_param[0]['snapshot_applied_filter'] ?? '';
        $snapshot_filename =  $php_script_loc.'dev/shared_docs/temp_note/'.($data_report_info_param[0]['snapshot_filename'] ?? '');
        $snapshot_export_type = $data_report_info_param[0]['snapshot_filename'] ?? '';

        // $report_name = 'Mt Evans'; //$data_report_info_param[0]['report_name'];
        // $snapshot_filename = $php_script_loc.'dev/shared_docs/temp_note/abc.png';
        
        $snapshot_filename_doc =  $rootdir . '\\' . $farrms_root . '\\adiha.php.scripts\\dev\\shared_docs\\temp_note\\' . ($data_report_info_param[0]["snapshot_filename"] ?? '');
        //$snapshot_filename_doc =  $rootdir . '\\' . $farrms_root . '\\adiha.php.scripts\\dev\\shared_docs\\temp_note\\abc.png';
                
        // $formatted_filter = '';
        // $formatted_filter .= '<span style="float:left">' . str_replace(',','|',str_replace(':',' = ',$data_report_info_param[0]['snapshot_applied_filter'])) . ' </span><span style="float:right;"> Refresh on ' . $data_report_info_param[0]['snapshot_refreshed_on'] . '</span>';
        if ($call_from == 'excel' && $export_type == 'pdf2')  {
            ob_clean();
            echo '<script type="text/javascript">';
            echo 'parent.excel_download("' . $php_script_loc.'force_download.php?path=dev/shared_docs/temp_note/'. $snapshot_export_type.'");';
            echo '</script>';
         } 

        if ($call_from == 'excel' && $export_type == 'excel2') {
            ob_clean();
            echo '<script type="text/javascript">';
            echo 'parent.excel_download("' . $php_script_loc.'force_download.php?path=dev/shared_docs/temp_note/'. $snapshot_export_type.'");';
            echo '</script>';
        }
        
        
        if ($report_name_excel && file_exists($snapshot_filename_doc) && $export_type != 'pdf2' ) {                 
            $snapshot_filename_img =  '<img src="'.$snapshot_filename.'" />';            
        }   else {
            $snapshot_filename_img =  "<div>" . ($data_report_info_param[0]['description'] ?? '') . "</div>";
            //$snapshot_filename_img =  "<div>No file</div>";
        }
        
    }

    function rfx_get_formatted_filter() {
        /** REPORT MANAGER FORMAT FILTER LOGIC **/
        global $result_formatted_filter_gbl;

        if($result_formatted_filter_gbl == '') {
            $formatting_filter_arr = (isset($_POST['sec_filters_info']) && $_POST['sec_filters_info'] != 'undefined') ? $_POST['sec_filters_info'] : ($_GET["report_filter"] ?? '');
            $formatting_filter_arr = explode("_-_", $formatting_filter_arr);
            $formatting_filter = $formatting_filter_arr[0];

            if(($_GET['call_from'] ?? '') == 'dhx_preview') {
                $xml_formatted_filter = "EXEC spa_rfx_format_filter_dhx @flag='f', @paramset_id='" . $_GET['paramset_id'] . "', @parameter_string='$formatting_filter', '" . $_GET['process_id'] . "'";
            } else {
                $is_excel_report = (($_GET['call_from'] ?? '') == 'excel' ? 1 : 0);
                $xml_formatted_filter = "EXEC spa_rfx_format_filter @flag='f', @paramset_id='" . ($_GET['paramset_id'] ?? '') . "', @parameter_string='$formatting_filter', @is_excel_report= $is_excel_report";
            }

            $result_formatted_filter_gbl = readXMLURL2($xml_formatted_filter);
        }
    }

    function rfx_replace_custom_as_of_date($filter_string) {
        $transposed_filter_string = rfx_get_first_day_of_month($filter_string);
        $transposed_filter_string = rfx_get_last_day_of_month($transposed_filter_string);
        $transposed_filter_string = rfx_get_day_before_run_date($transposed_filter_string);
        $transposed_filter_string = rfx_get_custom_day_before_run_date($transposed_filter_string);
        return $transposed_filter_string;
    }

    function rfx_add_days($date, $days) {
        $date = strtotime($days . " days", strtotime($date));
        return date("Y-m-d", $date);
    }

    function rfx_get_first_day_of_month($filter_string) {
        $first_day_of_month = date('Y-m-01');
        return str_replace('DATE.F', $first_day_of_month, $filter_string);
    }

    function rfx_get_last_day_of_month($filter_string) {
        $last_day_of_month = date('Y-m-t');
        return str_replace('DATE.L', $last_day_of_month, $filter_string);
    }

    function rfx_get_day_before_run_date($filter_string) {
        $last_day_of_month = rfx_add_days(date('Y-m-d'), '-1');
        return str_replace('DATE.1', $last_day_of_month, $filter_string);
    }

    function rfx_get_custom_day_before_run_date($filter_string) {
        $ret_string = null;
        $filter_array = array();
        if ($filter_string != '')
            $filter_array = explode(',', $filter_string);

        foreach ($filter_array as $val) {
            $inner_date_array = explode('=', $val);

            if (stripos($inner_date_array[1] ?? '', '.')) {
                $init = explode('.', $inner_date_array[1]);

                if ($init[0] == 'DATE') {
                    $final = explode('.', $inner_date_array[1]);
                }
            }
            $final_value = $final[1] ?? 0;
            $replace_key = 'DATE.' . ((int) $final_value);
            $day = ((int) $final_value < 10) ? '0' . $final_value : $final_value;
            $custom_day_of_month = rfx_add_days(date('Y-m-d'), '-' . $day);
            $ret_string = str_replace($replace_key, $custom_day_of_month, $filter_string);
        }

        return $ret_string;
    }

    function get_report_url($args, $page = NULL, $with_ent = FALSE) {
        $glue = ($with_ent) ? '&amp;' : '&';
        $url_partial = array();

        foreach ($args as $ky => $arg) {
            if ($ky != 'page')
                array_push($url_partial, $ky . '=' . $arg);
        }

        $url_partial = implode($glue, $url_partial);

        if ($page != NULL)
            $url_partial .= $glue . 'page=' . $page;

        return get_page_url() . '?' . $url_partial;
    }

    function get_page_url() {
        $page_url = get_request_protocol();
        $page_url = $page_url . '://';
        
        $uri = $_SERVER["REQUEST_URI"];
        $index = strpos($uri, '?');

        if ($index !== false) {
            $uri = substr($uri, 0, $index);
        }

        //removed appending server port as it gave issue to load next page causing insecure connection
        //$page_url .= $_SERVER["SERVER_NAME"] . ":" . $_SERVER["SERVER_PORT"] . $uri;
        $page_url .= $_SERVER["SERVER_NAME"] . $uri;
        return $page_url;
    }
    
    if($call_from == 'dhx_preview') {
        $report_folder = '/' . $ssrs_config["REPORT_TARGET_FOLDER"] . '/Preview/';
    } else {
        $report_folder = '/' . $ssrs_config["REPORT_TARGET_FOLDER"] . '/';
    }
    
    $arguments = array();
    $arguments['__user_name__'] = isset($_GET['__user_name__']) ? $_GET['__user_name__'] : '';
    $arguments['session_id'] = $_GET['session_id'] ?? '';
    $arguments['windowTitle'] = isset($_GET['window_title']) ? $_GET['window_title'] : '';
    $arguments['report_name'] = ($call_from == 'excel' ? $report_name_excel : (isset($_GET['report_name']) ? $_GET['report_name'] : ''));
    $arguments['paramset_id'] = isset($_GET['paramset_id']) ? $_GET['paramset_id'] : '';
    $arguments['report_filter'] = isset($_GET['report_filter']) ? $_GET['report_filter'] : '';
    $arguments['items_combined'] = isset($_GET['items_combined']) ? $_GET['items_combined'] : '';
    $arguments['export_type'] = isset($_GET['export_type']) ? $_GET['export_type'] : '';
    $arguments['is_refresh'] = isset($_GET['is_refresh']) ? $_GET['is_refresh'] : 0;
    $current_page = (isset($_GET['page']) && intval($_GET['page']) > 0) ? intval($_GET['page']) : 1;
    $paramset_id = $arguments['paramset_id'];
    $items_combined = $arguments['items_combined'];

    $sec_filters_info = isset($_POST['sec_filters_info']) ? $_POST['sec_filters_info'] : '';

    if ($sec_filters_info == '') {
        $load_report_detail_url = "EXEC spa_view_report  @flag='c',@report_name='',@report_id='" . $arguments['paramset_id'] . "',@report_param_id='" . $arguments['paramset_id'] . "'";
        $result_report_detail_url = readXMLURL2($load_report_detail_url);
        $filter_process_id = $result_report_detail_url[0]['layout_pattern'];

        $sec_filters_info = $arguments['report_filter'] . "_-_" . $filter_process_id;
    }
    //var_dump($sec_filters_info); die();
    if (!isset($_SESSION['page_total']))
        $_SESSION['page_total'] = 1;

    $arguments['call_from'] = $call_from;
    $arguments['region'] = $ssrs_config['REPORT_REGION'];

    #use relative path only; absolute not supported
    $image_path = '../../../' . $relative_temp_path . '/';
    $refresh_time = isset($_GET['refresh_time']) ? $_GET['refresh_time'] : 0;

    if ($refresh_time != 0) {
        $set_refresh_time = $refresh_time * 60;
        header("Refresh:" . $set_refresh_time);
    }
//print_r($arguments);
    if ($arguments['report_name'] != '' && ($arguments['paramset_id'] ?? '') != '' && $call_from != 'excel') {
        if($call_from == 'dhx_preview') {
            $xml_url_report_paramset_name = "EXEC spa_rfx_report_paramset_dhx @flag='y', @process_id='$process_id', @report_paramset_id='" . $arguments['paramset_id'] . "', @xml='$sec_filters_info'";
        } else {
            $xml_url_report_paramset_name = "EXEC spa_rfx_report_paramset @flag='y', @report_paramset_id=" . $arguments['paramset_id'] . ", @xml='$sec_filters_info'";
        }

        $data_report_param = readXMLURL2($xml_url_report_paramset_name);

        $paramset_name = $data_report_param[0]['name'];
        $major_version_no = $data_report_param[0]['major_version_no'];
        $arguments['report_filter'] = $data_report_param[0]['report_filter_final'];

        

        function get_render_type($type, $major_version_no) {
            switch ($type) {
                case "CSV":
                    return new RenderAsCSV();
                case "EXCEL":
                    ob_clean();
                    return (intval($major_version_no) > 10 )?new RenderAsOpenEXCEL():new RenderAsEXCEL();
                case "IMAGE":
                    return new RenderAsIMAGE();
                case "MHTML":
                    return new RenderAsMHTML();
                case "PDF":
                    return new RenderAsPDF();
                case "WORD":
                    return new RenderAsWORD();
                case "XML":
                    return new RenderAsXML();
                case "HTML4.0":
                    return new RenderAsHTML();
                default:
                    return null;
            }
        }

        function get_extension($type, $major_version_no) {
            switch ($type) {
                case "CSV":
                    return array('.csv', 'application/csv');
                case "EXCEL":
                    ob_clean();
                    return (intval($major_version_no) > 10 )?array('.xlsx', 'application/vnd.ms-excel'):array('.xls', 'application/vnd.ms-excel');
                case "IMAGE":
                    return array('.tiff', 'image/tiff');
                case "PDF":
                    return array('.pdf', 'application/pdf');
                case "WORD":
                    return array('.doc', 'application/msword');
                case "XML":
                    return array('.xml', 'application/vnd.ms-excel');
                case "MHTML":
                    return array('.mht', 'message/rfc82');
                default:
                    return array('', 'application/force-download');
            }
        }
		
		/*
		* Returns export type
		* @param type Export Type
		* @param major_version_no server version 
		*/
		function get_export_type($type, $major_version_no) {
            switch ($type) {
                case "EXCEL":
                    return (intval($major_version_no) > 10 ) ? 'EXCELOPENXML' : $type;             
                default:
                    return $type;
            }
        }

        $report = $report_folder . $arguments['report_name'];
        $result_html = '';
        $exception_msg = '';
        $tmp_replace_root_url = get_report_url($arguments, $current_page, TRUE);

    if($call_from != 'excel') {


        $paramset_id = "paramset_id:".$arguments['paramset_id'];
        $items_combined = $arguments['items_combined'];
        $report_filter = "report_filter:''".$arguments['report_filter']."''";
		
	
		if ($items_combined == '') {
            $parameters = $paramset_id.','.$report_filter;
        } else {
            $parameters = $items_combined.','.$paramset_id.','.$report_filter;
        }


        //$parameters = $items_combined.','.$paramset_id.','.$report_filter;
        $report_name = $arguments['report_name'];
        
        $parameters .= ",report_region:".$rfx_report_default_param['report_region'];
        $parameters .= ",runtime_user:".$rfx_report_default_param['runtime_user'];
        $parameters .= ",global_currency_format:".$rfx_report_default_param['global_currency_format'];
        $parameters .= ",global_date_format:".$rfx_report_default_param['global_date_format'];
        $parameters .= ",global_thousand_format:".$rfx_report_default_param['global_thousand_format'];
        $parameters .= ",global_rounding_format:".$rfx_report_default_param['global_rounding_format'];
        $parameters .= ",global_price_rounding_format:".$rfx_report_default_param['global_price_rounding_format'];
		$parameters .= ",global_volume_rounding_format:".$rfx_report_default_param['global_volume_rounding_format'];
		$parameters .= ",global_amount_rounding_format:".$rfx_report_default_param['global_amount_rounding_format'];
        $parameters .= ",global_science_rounding_format:".$rfx_report_default_param['global_science_rounding_format'];
        $parameters .= ",global_negative_mark_format:".$rfx_report_default_param['global_negative_mark_format'];
		$parameters .= ",global_number_format_region:".$rfx_report_default_param['global_number_format_region'];		

        //".$tmp_replace_root_url."

        $ssrs_sql = "EXEC spa_ssrs_html @report_name = '".$report_name."', @parameters='".$parameters."', @device_info='<DeviceInfo><Toolbar>False</Toolbar><Section>".$current_page."</Section><StreamRoot>".$app_php_script_loc."dev/shared_docs/temp_Note/</StreamRoot><ReplacementRoot></ReplacementRoot></DeviceInfo>'";
         if (isset($_REQUEST['rs:SortId']) && $_REQUEST['rs:SortId'] <> 'Sort') {
            $ssrs_sql .= ", @sorting='<Sort><Item>".$_REQUEST['rs:SortId']."</Item><Direction>".$_REQUEST['rs:SortDirection']."</Direction><Clear>".$_REQUEST['rs:ClearSort']."</Clear></Sort>'";
        }
        if (isset($_REQUEST['rs:ShowHideToggle'])) {
            $ssrs_sql .= ", @toggle_item='" . $_REQUEST['rs:ShowHideToggle'] . "'";
        }

        if (isset($_REQUEST['rs:execution_id'])) {
            $ssrs_sql .= ", @execution_id='" . $_REQUEST['rs:execution_id'] . "'";
        }
        $ssrs_sql .= ", @export_type='" . get_export_type($arguments['export_type'],$major_version_no) . "'";

        $ssrs_data = readXMLURL2($ssrs_sql);

        //var_dump($ssrs_data); die();

        $ssrs_status = $ssrs_data[0]['status'];

        if ($ssrs_status == 'Success') {
            $result_html = $ssrs_data[0]['html'];
            $total_pages = $ssrs_data[0]['totalpages'];
            $execution_id = $ssrs_data[0]['executionid'];
        } else {
            $errcode = $ssrs_data[0]['html'];
            $result_html = "";
            $total_pages = 1;
            $execution_id = '';
        }

        //$result_html = str_replace('onclick="Sort(','onclick="custom_sort(',$result_html);
        //$result_html = preg_replace('!href="(.*?)ShowHideToggle(.*?)">!i','class="show_hide_toggle">',$result_html);

        $_SESSION['page_total'] = $total_pages;

        //force Download
        if ($arguments['export_type'] != "HTML4.0") {
            ob_clean();
            $ext_info = get_extension($arguments['export_type'],$major_version_no);
            header("Content-Type:\"" .$ext_info[1]."\"");
            header("Content-Transfer-Encoding: Binary"); 
            header("Content-disposition: attachment; filename=\"" . $execution_id . $ext_info[0]. "\""); 

            readfile($result_html);
            exit;
        }

    }

        $exception_msg = array(
            'rrRenderingError' => get_locale_value('Report page couldnot be found. click', false) . '<a href="' . get_report_url($arguments, 1) . '">' . get_locale_value('here', false) . '</a>' . get_locale_value('to go to First page of report.', false),
            'rsItemNotFound' => get_locale_value('Report has not been deployed yet to the application.', false),
            'rsInvalidParameter' => get_locale_value('Invalid Parameter(s) specified.', false),
            'rsMissingParameter' => get_locale_value('Required Parameter(s) is missing.', false),
            'rsAccessDenied' => get_locale_value('Access Denied.', false),
            'rsExecutionNotFound' => get_locale_value('Report has expired. Please re-run the report from Report Manager.', false),
            'rsProcessingAborted' => get_locale_value('Report processing is aborted. Check SQL used.', false),
        );
        ?>
        

    <?php } ?>
        <script type="text/javascript">

            close_progress = <?php echo $close_progress; ?>;
            var execution_id  = '<?php echo $execution_id; ?>';
            if (close_progress == 1) {
                parent.close_progress();
            }

            $(function() {
                $('img[src$="ToggleMinus.gif"]').attr('src','<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/ToggleMinus.gif');
                $('img[src$="TogglePlus.gif"]').attr('src','<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/TogglePlus.gif');
                $('img[src$="unsorted.gif"]').attr('src','<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/unsorted.gif');
                $('img[src$="sortAsc.gif"]').attr('src','<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/sortAsc.gif');
                $('img[src$="sortDesc.gif"]').attr('src','<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/sortDesc.gif');
                
                $('.show_hide_toggle').click(function(){
                    var report_item = $(this).parent('div').attr('id');
                    var toggle_status = 'show';
                    if ($(this).find('img').attr('alt') == '-') {
                        var toggle_status = 'hide';
                    }

                    var report_item2 = '';
                    $('.show_hide_toggle').each(function(){
                        if ($(this).find('img').attr('alt') == '+') {
                            var r_item = $(this).parent('div').attr('id');
                            if (r_item != report_item) {
                                report_item2 += ',' + r_item;
                                //console.log(report_item2);

                            } else { //added for issue causing always a collapse state on report while toggling.
                                report_item2 = r_item;
                            }
                        }
                    });

                    var report_items = (toggle_status == 'hide') ? report_item  + report_item2 :  report_item2;

                    //console.log('report_items');console.log(report_items);
                    var url = '<?php echo html_entity_decode($tmp_replace_root_url);?>';
                    if (toggle_status == 'hide' || report_item2 != '') {
                        url += '&rs:ShowHideToggle=' + report_items;
                    }
                    view_report_redirect_with_post(url);
                })

                $('.cn-ssrs-viewer-paginator a[href!="javascript:void(0)"]').click(function() {
                    $('#hourglass').show();
                });
                                            
                $('.cn-ssrs-viewer-paginator a.a_disable').each(function() {
                    var link_object = $('img',$(this));
                    link_object.attr('src', link_object.attr('src').replace('.gif','_disable.gif'));
                    $(this).removeAttr('onclick');
                });
                                            
                hideHourGlass();
                                            
                $('#page-list').change(function() {
                    //window.location = $(this).val();
                    view_report_redirect_with_post($(this).val());
                });
                                            
                $('#page-list option[rel=<?php echo $current_page; ?>]').prop('selected', true);
                                            
                $(".tree-navigator .plus").click(function() {
                    $(this).toggleClass( "tree-navigator minus"); 
                    var current_item = $('#report-body').find('.child');
                                                
                    if (current_item.css('display') == 'none') {
                        current_item.fadeIn('fast');
                    } else {
                        current_item.fadeOut('fast');
                    }
                });
            }); 

            function custom_sort(sorting_item, sorting_direction) {
                var url = '<?php echo html_entity_decode($tmp_replace_root_url);?>';
                url += '&rs:Command=Sort&rs:SortId=' + sorting_item + '&rs:SortDirection=' + sorting_direction + '&rs:ClearSort=TRUE'
                view_report_redirect_with_post(url);
            }

            function view_report_redirect_with_post(url) {
                //$.post( $(this).val(), { sec_filters_info : "<?php echo $sec_filters_info;?>" } );
                view_report_form = document.createElement('form');
                view_report_form.setAttribute('method', 'POST');
                view_report_form.setAttribute('action', url+'&close_progress=1&rs:execution_id='+execution_id);
                view_report_input = document.createElement('input');
                view_report_input.setAttribute('name', 'sec_filters_info');
                view_report_input.setAttribute('type', 'hidden');
                view_report_input.setAttribute('value', '<?php echo $sec_filters_info;?>');
                view_report_form.appendChild(view_report_input);
                document.body.appendChild(view_report_form);
                view_report_form.submit(); 

            }
                                        
        </script>
        <style type="text/css">
            body {
                background: white;
            }  

            #report-body {
                emargin:10px 40px 0 40px;
            }

            #cn-ssrs-viewer-report {
                border-top: 1px solid steelblue;
            }

            .cn-ssrs-viewer-paginator {
                text-align: right;
                padding:4px;
                height:25px;
            }

            #report-name {
                font-family: 'Tahoma';
                font-size: 15px;    
                font-weight: bold;
            }

            .tree-navigator .plus {
                background-image: url('<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/TogglePlus.gif');
                background-repeat:no-repeat; 
                cursor: hand; 
                font-weight: bold;
            }

            .tree-navigator .minus {
                background-image: url('<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/ToggleMinus.gif');
            }

            .tree-navigator {  
                margin-bottom: 2px;
                padding-right: 2px;
                text-indent: 12px;
            }

            .child {
                display: none;
                text-indent: 0px;
                margin-left: 13px;
            }            
          
            body {
                overflow: auto;
            }
            
            .report_filter_font {
                font-family: 'Tahoma';
                font-size: 12px;
            }
            .pagination_fix {
                position: fixed;
                top: 0;
                width:100%;
                background: #f9f9f9;
            }
        </style>

        <div id="report-body">
            <?php if ($call_from != 'DASHBOARD') { ?>
            <div class="pagination_fix">
                <div id="cn-ssrs-viewer-header">
                    <p id="report-name"><?php echo (($paramset_name ?? '') == 'Default') ? str_replace('_', ' ', $arguments['report_name']) . ' ' . $paramset_name : ($paramset_name ?? ''); ?></p>
                </div>
                <div class="tree-navigator report_filter_font" >
                    <div class="plus" style="display: inline-block"> <label class=""><?php echo get_locale_value('Report Filter', true); ?></label></div>
                    <div class="child" >
                        <?php
                        if($call_from == 'excel') {
                            echo $report_filter_excel_default;
                        } else {
                            $formatted_filter = '';
                            for ($i = 0; $i < sizeof($result_formatted_filter_gbl); $i++) {
                                if ($result_formatted_filter_gbl[$i]['filter_display_value'] != '') // Remove field that has not filter value
                                    $formatted_filter .= $result_formatted_filter_gbl[$i]['filter_display_label'] . ' = ' . $result_formatted_filter_gbl[$i]['filter_display_value'] . ' | ';
                            }
                            $formatted_filter =  substr($formatted_filter, 0, -3); // Remove the last 3 string. No need to append | in last field

                            echo rfx_replace_custom_as_of_date((strlen($arguments['report_filter']) > 0) ? $formatted_filter . (($formatted_filter)?'.':'') : '<small>(' . get_locale_value('no parameter specified', false) . ')</small>');
                        }
                        
                        ?> 
                    </div> 
                </div>
                <div class="cn-ssrs-viewer-paginator" style="display: <?php echo ($call_from == 'excel' ? 'none' : 'block'); ?>;">
                    <?php
                    $href_first = "";
                    $href_prev = "";
                    $href_next = "";
                    $href_last = "";
                    $cls_first = "class = 'a_disable'";
                    $cls_prev = "class = 'a_disable'";
                    $cls_next = "class = 'a_disable'";
                    $cls_last = "class = 'a_disable'";

                    if ($current_page != 1) {
                        $href_first = get_report_url($arguments, 1);
                        $cls_first = '';
                    }

                    if ($current_page >= 2) {
                        $href_prev = get_report_url($arguments, ($current_page - 1));
                        $cls_prev = '';
                    }

                    if ($current_page < $total_pages && $current_page != $total_pages) {
                        $href_next = get_report_url($arguments, ($current_page + 1));
                        $cls_next = '';
                    }

                    if ($current_page != $_SESSION['page_total']) {
                        $href_last = get_report_url($arguments, $_SESSION['page_total']);
                        $cls_last = '';
                    }
                    ?>
                    <table class="report_filter_font" align="right">
                        <tr>
                            <td><a <?php echo $cls_first;?> href="javascript:void(0)" onclick="view_report_redirect_with_post('<?php echo $href_first; ?>')"><img style="cursor: pointer;" title="<?php echo get_locale_value('First Page'); ?>"  border="0" name="im_first_deal_page" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/paging/move_first.gif"></a></td>
                            <td><a <?php echo $cls_prev;?> href="javascript:void(0)" onclick="view_report_redirect_with_post('<?php echo $href_prev; ?>')"><img style="cursor: pointer;" title="<?php echo get_locale_value('Previous Page'); ?>"  border="0" name=im_prev_deal_page src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/paging/move_prev.gif"></a></td>
                            <td id="label_paging">&nbsp;
                                <?php echo $current_page, ' ' . get_locale_value('of') . ' ', $_SESSION['page_total'], ' ' . get_locale_value('Pages') . '' ?></td>
                            <td>
                                <select class="adiha_control report_filter_font" id="page-list" >
                                    <?php for ($x = 1; $x <= $_SESSION['page_total']; $x++) { ?>
                                        <option rel ="<?php echo $x; ?>" value="<?php echo get_report_url($arguments, $x, TRUE) ?>" > <?php echo $x ?></option>
                                    <?php } ?>
                                </select>
                            </td>
                            <td><a <?php echo $cls_next;?> href="javascript:void(0)" onclick="view_report_redirect_with_post('<?php echo $href_next; ?>')"><img style="cursor: pointer;" title="<?php echo get_locale_value('Next Page'); ?>"  border="0" name="im_next_deal_page" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/paging/move_next.gif"></a></td>
                            <td><a <?php echo $cls_last;?> href="javascript:void(0)" onclick="view_report_redirect_with_post('<?php echo $href_last; ?>')"><img style="cursor: pointer; bordercolor: black;" title="<?php echo get_locale_value('Last Page'); ?>" border=0 name=im_last_deal_page src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/paging/move_last.gif"></a></td>
                        </tr>
                    </table>
                </div>
            </div>
            <?php } ?>
            <div id="cn-ssrs-viewer-report">
                <div style="margin-bottom: 90px"></div>
                <?php 
                if($call_from == 'excel') {
                    echo $snapshot_filename_img; 
                } else {
                    echo (strlen($errcode ?? '') > 0) ? $exception_msg[$errcode] : '';
                    echo html_entity_decode($result_html, ENT_QUOTES | ENT_XML1 , 'UTF-8'); 
                }
                
                //echo str_replace('&gt;', '>', str_replace('&lt;', '<', $result_html));
                ?>
            </div>
        </div>
        <p>&nbsp;</p>