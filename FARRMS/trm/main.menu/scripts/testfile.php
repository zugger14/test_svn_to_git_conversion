<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
      
</head>
<body>
     
   
<?php

  echo 'test page';
?>
 <script src="../js/farrms_scripts/jquery-1.11.1.js"></script>
  <script type="text/javascript">
   	$(function(){
	    refresh_alert();  
	    setInterval(refresh_alert, 1000);  
	    
	});
   

    function refresh_alert() {    
    $.ajax({
        type: "POST",
        dataType: "json",
        url: "test01.php",
        success: function(data) { 
        }
      });  
   }
 </script>
 </body> 

 </html>