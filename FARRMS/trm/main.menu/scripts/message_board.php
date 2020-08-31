<html>
<?php
    ob_start();
	require "../../adiha.php.scripts/components/include.file.v3.php";

	global $app_php_script_loc, $app_user_name;
    $messages = '';
    $alerts = '';

    $xml_user = "EXEC spa_message_board 'v', '" . $app_user_name . "'";    
    
	$key_prefix = 'MB';  //Message board identifier
    $key_suffix = 'v';
    
    $recordsets = readXMLURLCached($xml_user, false, $key_prefix, $key_suffix, true);    
       
    $message_array = array();
    $message_array = filter_array($recordsets, 'Message');
    
    $alert_array = array();
    $alert_array = filter_array($recordsets, 'Alert');

	$messages = create_message_html($message_array, 'message');
	$alerts = create_message_html($alert_array, 'alert');
    
	function filter_array($recordsets, $type) {
	    $final_array = array();

	    foreach ($recordsets as $c_key => $item) {
	        if ($item['message_type'] == $type) {
	            array_push($final_array, $item);
	        }
	    }

	    return $final_array;
	}
	
    function create_message_html($array, $_type) {
    	$type = $_type;
        $is_alert = ($type == 'alert') ? 1 : 0;
        
    	$type .= (sizeof($array) > 1) ? 's' : ''; 

    	$html_string  = '<div class="pointer">';
        $html_string .= '	<div class="pointer-inner">';
        $html_string .= '		<div class="arrow"></div>';
        $html_string .= '    </div>';
        $html_string .= '</div>';
        $html_string .= '<div class="item-header">You have ' . sizeof($array). ' ' . $type . '.</div>';

        $html_string .= '<div class="nano-message-box">';
        $html_string .= '<div class="message-board-content">';
        $html_string .= '<ul id="message-board" class="message-board">';

		if (is_array($array) && sizeof($array) > 0) {
            $loop = (sizeof($array) < 10) ? sizeof($array) : 10;
            
        	for($i = 0; $i < $loop; $i++) { //show top 10 messages
        		$html_string .= '<li style="border-bottom:2px solid white;" id="' . $array[$i]['message_id'] . '" class="item-gap item ' . $array[$i]['is_read'] . '" onmouseenter="mark_message_as_read(' . $array[$i]['message_id'] . ', ' . $is_alert  .')" onmouseleave="reset_timer()" onClick="mark_message_as_read(' . $array[$i]['message_id'] . ', ' . $is_alert  .')">';
        		$html_string .= '	<div id="link-box">';
		    	$html_string .= '		<span class="content">';
		    	$html_string .= '			<span class="content-headline">';

		    	if ($_type != 'alert') {
		    		$html_string .= 				$array[$i]['source'];
	    		}

                $html_string .= '			<span class="pull-right hovicon effect-1 sub-a fa fa-trash" title="Clear" onclick="delete_message(' . $array[$i]['message_id'] . ', ' . $is_alert  .')"><i id="' . $array[$i]['message_id'] . '"></i></span>';
		    	$html_string .= '			</span>';
		    	$html_string .= '			<span class="content-text">';
		    	$html_string .= 				$array[$i]['description'];
		    	$html_string .= '			</span>';
                
                if ($array[$i]['url'] != '') {
                    $message_id = $array[$i]['message_id'];
                    $url = $array[$i]['url'] . '&message_id=' . $message_id;
                    $url_desc =  $array[$i]['url_desc'];
                    $html_string .= '			<span class="content-text"><a href="javascript: compliance_status_pop_up_drill(' . $message_id . ')">' . $array[$i]['description'] . '</a></span>';
                    //$html_string .= '			<span class="content-text"><a target=\'#\' href="../../adiha.php.scripts/' . $url . '">' . $url_desc . '</a></span>';
                }                
                
                if ($array[$i]['url_desc'] != '') {
                    $message_id = $array[$i]['message_id'];
                    $url = $array[$i]['url'] . '&message_id=' . $message_id;
                    $url_desc =  $array[$i]['url_desc'];
                    $html_string .= '			<span class="content-text" style="width:100%; float: right;"><span class="pull-right" style="margin-right:10px;">[' . $url_desc . ']</span></span>';
                 }  
                
		    	$html_string .= '		</span>';
		    	$html_string .= '		<span class="pull-right time"><i class="fa fa-clock-o"></i>' .  $array[$i]['create_ts'] . '</span>';

		    	if ($_type == 'alert') {
		    		$html_string .= '		<br/><span style="clear:both;" class="pull-right time-diff">' .  $array[$i]['created_on'] . '</span>';
	    		}

		    	$html_string .= '	</div>';
		    	$html_string .= '</li>';
			}
		}

		$html_string .= '</ul>';
		$html_string .= '</div>';
		$html_string .= '</div>';
    	$html_string .= '<div class="item-footer">';
        $html_string .= '	<a id="footer-link" href="#" onclick="return view_all_messages(&quot;' . $_type . '&quot;);">View all messages</a>';
        $html_string .= '</div>';

    	return $html_string;
    }

    ob_end_clean();
?>
<body>
	<div class='messages'>
		<?php echo $messages;?>
	</div>
	<div class='alerts'>
		<?php echo $alerts;?>
	</div>
</body>
</html>