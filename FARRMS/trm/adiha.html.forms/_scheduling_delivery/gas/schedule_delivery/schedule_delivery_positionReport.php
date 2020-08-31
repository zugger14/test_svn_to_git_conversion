<html>
    <head> 
        <?php
        include '../../../../adiha.php.scripts/components/include.file.v3.php';
        $window_title = isset($_GET['windowTitle']) ? trim($_GET['windowTitle']) : 'Run Gas Position Report';
        echo '<title>' . get_PS_form_title($window_title) . '</title>';
        
        $args = $_SERVER['QUERY_STRING'];
        $src_file = 'schedule_delivery_positionReport_main.php?' . $args;
        ?>
    </head>
    <frameset cols="100%,0%" framespacing="0" frameborder="0">
        <frame name="main" src="<?php echo $src_file; ?>">
        <frame name="f1" src="..\..\blank.htm">
    </frameset>
    <noframes></noframes>
</html>