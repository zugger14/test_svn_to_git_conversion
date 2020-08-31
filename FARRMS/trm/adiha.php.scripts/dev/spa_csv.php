<html>
    <body>
        <?php
        include "../components/include.file.v3.php";
        
        $getKeys = array_keys($_REQUEST);
        $call_from = isset($_REQUEST['call_from']) ? $_REQUEST['call_from'] : '';
        
        if ($call_from == 'search') {
            $urlString = "spa_html_customized.php";
        } else {
            $urlString = "spa_html.php";
        }
        
        $getKeyLength = count($_REQUEST);
        $keys_values = array();
        
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
            $urlString .= "$keyName=$value";
            $keys_values[$keyName] = $value;
        }
            
        if ($getKeyLength == 0) {
            $urlString .= "?writeCSV=true";
        } else {
            $urlString .= "&writeCSV=true";
        }

        $sp_name = $keys_values['sp_name'] ?? '';
        if ($sp_name == 'spa_create_hourly_position_report' || $sp_name == 'spa_create_mtm_period_report_trm') {
            //for postion MTM and settlement reports 
        ?>
            <script type="text/javascript">
                call_spa_html();
                
                function call_spa_html() {
                    var exec_call = decodeURIComponent('<?php echo $keys_values['spa']; ?>');
                    var rnd = '<?php echo $keys_values['rnd']; ?>';
                   
                    var url = js_php_path + 'dev/spa_html.php';
                    var param_session = js_session_id;
                   
                    if (exec_call == null) {
                        return;
                    }
                    
                    var param = {   
                                'spa' : exec_call, 
                                'rnd' : rnd,
                                'enable_paging' : false, 
                                'session_id' : param_session ,
                                'writeCSV' : true
                            };
                                
                    open_window_with_post(url, 'new_window', param, '_parent');
                }
            
            </script>
        <?php
        } else { //old logic for other sps
            echo( "<HTML><HEAD><META HTTP-EQUIV='refresh' content='1; url=\"$urlString\"'></HEAD></HTML>" );    
        }
        ?>
    </body>
</html>