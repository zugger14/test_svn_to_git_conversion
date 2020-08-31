<html>
    <head>
        <?php
        include '../../../../adiha.php.scripts/components/include.file.v3.php';
        $args = $_SERVER['QUERY_STRING'];
        
        echo '<title>' . get_PS_form_title('View Delivery Transactions') . '</title>';                
        ?>
    </head>
    <frameset cols="100%,0%" frameborder="0" framespacing="0">
        <frame name="main" src="schedule.and.delivery.main.php?<?php echo $args; ?>">
        <frame name="f1" src="UntitledFrame-2">
    </frameset>
    <noframes></noframes>
</html>
