<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
    	require_once('components/include.file.v3.php'); 
        require_once('components/include.ssrs.reporting.files.php');
        $html_string = (isset($_POST["html_string"]) && $_POST["html_string"] != '') ? $_POST["html_string"] : '';
        $report_title = (isset($_POST["report_title"]) && $_POST["report_title"] != '') ? $_POST["report_title"] : '';
    ?>    
    <title><?php echo $report_title;?></title>
    <link href="<?php echo $main_menu_path; ?>bootstrap-3.3.1/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<div id='printable'>
		<h3><?php echo $report_title;?></h3>
		<?php echo $html_string;?>
	</div>
</body>
<script type="text/javascript">	
	$(function(){
		window.print();
	})
</script>
<style type="text/css">	
	@media print {
	    body * {
	        visibility: hidden;
	    }
	    #printable, #printable * {
	        visibility: visible;
	    }
	    #printable {
	        left: 0;
	        top: 0;        
	        position:absolute !important;
	    }
	}

	html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 5px;
        background-color: #ebebeb;
    }
    #printable {
    	width: 100%
    }
</style>
</html>