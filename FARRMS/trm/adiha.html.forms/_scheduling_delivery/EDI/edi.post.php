<?php
ob_start();
if(isset($_POST['post_from'])) {
    if($_POST['post_from'] == 'edi_create_file') {
        $file_name = isset($_POST['file_name']) ? urldecode($_POST['file_name']) : '';
        $file_path = isset($_POST['file_path']) ? urldecode($_POST['file_path']) : '';
        $file_content = isset($_POST['file_content']) ? urldecode($_POST['file_content']) : 'no content';
        
        if(!file_exists($file_path)) {
            print_r('path_not_exist');
        } else if(!is_writable($file_path)) {
            print_r('path_not_writable');
        } else {
            //print_r('path exists and is writable.');
            $full_file_path = $file_path . '\\' . str_replace(' ', '_', $file_name);
            
            try {
                $result_put_content = file_put_contents($full_file_path, $file_content);
                if($result_put_content === false) {
                    print_r('error_file_put_content');
                } else {
                    print_r('success_file_put_content');
                }
                
            } catch (Exception $e) {
                print_r($e->getMessage());
            }
        } 
        
    } else if($_POST['post_from'] == 'edi_delete_file') {
        $file_names = isset($_POST['file_names']) ? urldecode($_POST['file_names']) : '';
        //$file_names = '92027077_07939069_9981756528960242.txt';
        $file_path = realpath(urldecode($_POST['file_path']));
        $file_arr = explode(',', $file_names);
        //print_r($file_path);
        
        //$result = unlink($file_path . '\\' . $file_names);
        
        $delete_ok = false;
        foreach($file_arr as $value) {
            $result = unlink($file_path . '\\' . $value);
            //$delete_ok = ($result === false ? false : ($delete_ok || ));
        }
        
        if($result === false) {
            print_r('delete_fail');
        } else {
            print_r('delete_success');
        }
        
        
    } else if($_POST['post_from'] == 'edi_submit_file') {
        
        //print_r($_POST);exit();
        ///*
        $targer_url = urldecode($_POST['target_url']);
        $download_location = urldecode($_POST['download_location']);
        $file_path = isset($_POST['file_path']) ? urldecode($_POST['file_path']) : '';
        
        $post_params = array(
    						'from' => $_POST['from_duns'],
    						'to' => $_POST['to_duns'],
    						'input-format' => $_POST['input_format'],
                            'input-data' => '@'.realpath($file_path),
    						'refnum' => $_POST['refnum']
        				);
        //print_r($download_location);
        ///*
        try {
            $request = curl_init();
            
            curl_setopt($request, CURLOPT_URL, $targer_url);
            curl_setopt($request, CURLOPT_POST, true);
            curl_setopt($request, CURLOPT_POSTFIELDS,$post_params);
            curl_setopt($request, CURLOPT_RETURNTRANSFER, true);
            //curl_setopt($request, CURLOPT_HEADER, true);
            $filename_generated = 'confirmation_' . (string) time() . '.txt';
            $filepath_dest = $download_location . '\\' . $filename_generated;
            
            $fp = fopen($filepath_dest, "w");
            curl_setopt($request, CURLOPT_FILE, $fp);
            curl_setopt($request, CURLOPT_TIMEOUT, 28800);
            
            ob_clean();
            $buffer = curl_exec($request);
            
            
            if (empty($buffer)){
                print_r('empty_buffer');
            } else {
                $file_content = file_get_contents($filepath_dest);
                $needle = 'request-status=ok*';
                $request_ok = strstr($file_content,$needle,strpos($file_content, $needle));
                print_r($request_ok === false ? 'Transmission Failure,' . $filename_generated : 'Transmission Success,' . $filename_generated);
            }
            
            curl_close($request);
        } catch(Exception $e) {
            print_r('catch err');
        }
        
        
    }

}


?>