<html>
    <?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    echo '<title>' . get_PS_form_title('Insert Menu Item') . '</title>';
    $src_file = 'maintain.menu.item.iu.main.php';
    $args = $_SERVER['QUERY_STRING'];
    $url = $src_file . '?' . $args;
    ?>
    <frameset cols="100%,0%" frameborder="0" framespacing="0">
        <frame name="main" src="<?php echo $url; ?>" noresize="noresize">
        <frame name="f1" src="../../../blank.htm">
    </frameset>
    <noframes></noframes>
</html>
