<?php
/**
* Maintain contract screen
* @copyright Pioneer Solutions
*/
?>
<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
    <html>
        <?php
        include '../../../adiha.php.scripts/components/include.file.v3.php';
        ?>
        <?php
        $call_from_combo = get_sanitized_value($_GET['call_from_combo'] ?? '');
        $contract_id = get_sanitized_value($_GET['contract_id'] ?? '');
        
        $contract_name = get_sanitized_value($_GET['contract_name'] ?? '');

        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        /* start of main layout */
        $form_namespace = 'standard';
        $layout = new AdihaLayout();
        //json for main layout.
        /* start */
        $json = '[
            {
                id:             "a",
                text:           "Standard Contract",
                header:         false,
                collapse:       false
            }
            
           
        ]';
        /* end */

        //attach main layout to gl code screen
        echo $layout->init_layout('new_layout', '', '1C', $json, $form_namespace);

        if($contract_id != '') {
            echo 'standard.new_layout.cells("a").attachURL("maintain.contract.template.php?call_from=standard&contract_id='.$contract_id.'&contract_name='.$contract_name.'", null, true);';
        } else {
            echo 'standard.new_layout.cells("a").attachURL("maintain.contract.template.php?call_from=standard&call_from_combo=' . $call_from_combo . '", null, true);';
        }      

        echo $layout->close_layout();
        /* end of main layout */
        ?>
        <style>
            /*div#layoutObj {
                position: relative;
                width: 640px;
                height: 350px;
                display: inline-block;
            }*/
        </style>
        
