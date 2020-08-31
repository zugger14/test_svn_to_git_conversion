<html>
    <head>
        <?php
        include '../../../../adiha.php.scripts/components/include.file.v3.php';
        echo '<title>' . get_PS_form_title('Schedule and Delivery Post Detail') . '</title>';
        
        $args = $_SERVER['QUERY_STRING'];
        ?>
    </head>
    <frameset cols="100%,0%" frameborder="0" framespacing="0">
        <frame name="main" src="postion.report.iu.php?<?php echo $args; ?>">
        <frame name="f1" src="UntitledFrame-2">
    </frameset>
    <noframes></noframes>
</html>