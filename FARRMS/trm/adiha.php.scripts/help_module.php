 <?php
    $help_url = (isset($_POST['help_url'])) ? $_POST['help_url'] : '';
    
    if ($help_url != '')
        $help_url1 = 'adiha_pm_html/FARRMSHelpFile/index.html' . $help_url;
        //$help_url1 = 'adiha_pm_html/FARRMSHelpFile/index.html#8 Setup User';
    else {
        $help_url1 = 'adiha_pm_html/FARRMSHelpFile/index.html';
    }
 ?>
 
 <iframe src="<?php echo $help_url1;?>" width="100%" height="99%" style="border: none;"></iframe>