<?php
/**
* Maintain nonstandard contract screen
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
        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        /* start of main layout */
        $link_contract_id = get_sanitized_value($_GET['contract_id'] ?? 'NULL');
        $link_contract_name = get_sanitized_value($_GET['contract_name'] ?? 'NULL');
        $call_from_combo = get_sanitized_value($_GET['call_from_combo'] ?? '');
        $form_namespace = 'nonstandard';
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

       echo 'nonstandard.new_layout.cells("a").attachURL("maintain.contract.template.php?call_from=nonstandard&call_from_combo=' . $call_from_combo . '&contract_id=' . $link_contract_id . '&link_contract_name=' . $link_contract_name . '", null, true);';

      

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
        
