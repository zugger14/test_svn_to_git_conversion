<html>
    <?php
    include '../../../../../adiha.php.scripts/components/include.file.v3.php';      
    $window_title = trim($_GET['windowTitle']);
    echo '<title>' . get_PS_form_title($window_title) . '</title>';
    $args = $_SERVER['QUERY_STRING'];            
    ?>
    <frameset rows="*" cols="100%,0%" frameborder=0 framespacing=0>
        <frame name="main" src="delivery.status.main.php?<?php echo $args; ?>" />
        <frame name="f1" src="UntitledFrame-2" />
    </frameset>
    <noframes></noframes>
</html>