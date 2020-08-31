<html>
<head>
    <?php
    include '../../../../adiha.php.scripts/components/include.file.v3.php';
    $src_file = "subsidiary.property.program.affiliation.iu.main.php";
    $args = $_SERVER['QUERY_STRING'];
    $url = $src_file . "?" . $args;
    $windowTitle = trim($_GET['windowTitle']);
    
    echo '<title>' . get_PS_form_title($windowTitle) . '</title>';    
    ?>
</head>
<frameset cols="100%,0%" frameborder="0" framespacing="0">
    <frame name="main" src="<?php echo $url; ?>" noresize>
    <frame name="f1" src="blank.htm">
</frameset><noframes></noframes>
</html>
