<html>
    <body>
        <?php
        include "../components/include.file.v3.php";
              
        $getKeys = array_keys($_REQUEST);
        $urlString = "spa_html.php";
        $getKeyLength = count($_REQUEST);
        $keys_values = array();
        $mtm_report = '';

        for ($i = 0; $i < $getKeyLength; $i++) {
            if ($i == 0) {
                $urlString .= "?";
            } else {
                $urlString .= "&";
            }
        
            $keyName = $getKeys[$i];
            $value = $_REQUEST[$keyName];
            $value = stripslashes($value);
            $value = urlencode($value);
            if ($keyName != 'exec' && $keyName != 'applied_filters')
                $urlString .= "$keyName=$value";
            $keys_values[$keyName] = $value;
        }
        
        if ($getKeyLength == 0) {
            $urlString .= "?writeFile=true";
        } else {
            $urlString .= "&writeFile=true";
        }
      
        $exec = $keys_values['exec'] ?? '';
        
        $applied_filters = $keys_values['applied_filters'] ?? '';
         
        if (strpos($exec, 'spa_create_mtm_period_report_trm') !== false) {
            $mtm_report = 1;
        } 

        $sp_name = $keys_values['sp_name'] ?? '';

        if ($sp_name == 'spa_create_hourly_position_report' || $sp_name == 'spa_create_mtm_period_report_trm' || $mtm_report == 1) {
            //for postion MTM and settlement reports 
        ?>
            <script type="text/javascript">
                call_spa_html();
                
                function call_spa_html() {
                    var exec_call = decodeURIComponent('<?php echo strtolower($keys_values['exec']); ?>');
                    var rnd = '<?php echo $keys_values['rnd']; ?>';
                   
                    var url = js_php_path + 'dev/spa_html.php';
                    var param_session = js_session_id;
                   
                    if (exec_call == null) {
                        return;
                    }
                    
                    exec_call = exec_call.replace('+spa_create_mtm_period_report_trm+', ' spa_create_mtm_period_report_trm ');
                    
                    if ('<?php echo $keys_values['sp_name']; ?>' == 'spa_create_hourly_position_report') {
                        var param = {   
                                'spa' : exec_call, 
                                'rnd' : rnd,
                                'enable_paging' : false, 
                                'session_id' : param_session,
                                'writeFile' : true
                        };
                    } else {
                        var param = {   
                                'exec' : exec_call, 
                                'enable_paging' : false, 
                                'session_id' : param_session,
                                'writeFile' : true
                        };    
                    }
                                                    
                    open_window_with_post(url, 'new_window', param, '_parent');
                }
            
            </script>
        <?php
        } else { //old logic for other sps
            ?>
            <script>
                var param = {   
                                    'exec' : decodeURIComponent('<?php echo str_ireplace('+', ' ', $exec);?>'),
                                    'applied_filters' : decodeURIComponent('<?php echo str_ireplace('+', ' ',$applied_filters);?>'),
                            };
                open_window_with_post('<?php echo $urlString;?>', 'new_window', param, '_parent');
            
            </script>
            <?php
            //echo( "<HTML><HEAD><META HTTP-EQUIV='refresh' content='1; url=\"$urlString\"'></HEAD></HTML>" );    
        }
        ?>
    </body>
</html>
