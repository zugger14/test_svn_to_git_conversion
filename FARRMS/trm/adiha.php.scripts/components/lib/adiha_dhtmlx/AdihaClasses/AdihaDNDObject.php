<?php
    
    class AdihaDNDObject {
        public $draggable_name;
        
        /**
		 * [init_DNDObject Initialize Style and HTML]
		 */
        function init_DNDObject($name, $height = '100px', $width = '200px') {
            $this->draggable_name = $name;
            $html_string = '<style>';
            $html_string .= '#' . $this->draggable_name . ' { background: white; padding: 5px;}';
            $html_string .= '.obj_div { float: left; margin: 5px; background: #EBEFFC;}';
            $html_string .= '#' . $this->draggable_name . ' .obj_div { float: left; margin: 5px; background: #FFFFFF;}';
            $html_string .= '.image_div {float:left; margin-right: 5px;}';
            $html_string .= '.button_div { float: left; width:20px;}';
            $html_string .= '.button_div img {margin-bottom: 5px;}';
            $html_string .= '.object_label { text-align:center; }';
            $html_string .= '#' . $this->draggable_name . ' .button_div { display:none; }';
            $html_string .= '#' . $this->draggable_name . ' .object_label { display:none; }';
            $html_string .= '</style>';
            $html_string .= '<div id="' . $name . '" style="height:' . $height . '; width:' . $width . ';">';
            return $html_string;
        }
        
        /**
		 * [close_DNDObject Close div tag]
		 */
        function close_DNDObject() {
            $html_string = '</div>';
            $html_string .=  '<script>';
            
            /**
             * [remove_object - Remove the dropped object]
		     */
            $html_string .= '   function remove_object(ob) { ';
            $html_string .= '       $(ob).parent().parent().remove(); ';
            $html_string .= '   }';
            
            /**
	         * [get_sequence - Returns the id of the object and sequence number in array]
		     * @param  [string] drop_area   [Id of the drop area]
		     */            
            $html_string .= '   function get_sequence(drop_area) {';
            $html_string .= '       var droparea_array = new Array();';
            $html_string .= '       $("#" + drop_area + " .obj_div").each(function(){';
            $html_string .= '           var temp_array = new Array();';
            $html_string .= '           temp_array[0] = $(this).attr("id");';
            $html_string .= '           temp_array[1] = $(this).css("top").replace("px","");';
            $html_string .= '           temp_array[2] = $(this).css("left").replace("px","");';
            $html_string .= '           droparea_array.push(temp_array);';
            $html_string .= '       });';
            $html_string .= '       droparea_array.sort(sort_array);';
            $html_string .= '       var sequence_array = new Array();';
            $html_string .= '       for(var i = 0; i < droparea_array.length; i++) {';
            $html_string .= '           var temp_array1 = new Array();';
            $html_string .= '           temp_array1[0] = droparea_array[i][0];';
            $html_string .= '           temp_array1[1] = i+1;';
            $html_string .= '           sequence_array.push(temp_array1);';
            $html_string .= '       }';
            $html_string .= '       return sequence_array';
            $html_string .= '   }';
            
            $html_string .= '   function sort_array(a,b) {';
            $html_string .= '       return parseInt(a[2]) - parseInt(b[2]);';
            $html_string .= '   }';
            
            /**
	         * [set_object - Set the object in drop area. Used in update mode]
		     * @param  [string] drop_area   [Id of the drop area]
             * @param  [string] object_id   [Id of the object]
		     */ 
            $html_string .= '   function set_object(drop_area, object_id) {';
            $html_string .= '       var obj_html = $("#' . $this->draggable_name . ' .obj_div").html();';
            $html_string .= '       obj_html = "<div class = obj_div id = " + object_id + ">" + obj_html + "</div>";';
            $html_string .= '       $("#" + drop_area).append(obj_html);';
            $html_string .= '       $("#" + drop_area).find(".obj_div").draggable({';
            $html_string .= '           containment: "parent"';
            $html_string .= '       });';
            $html_string .= '   }';
            
            $html_string .= '   function enable_draggable(drop_area) {';
            $html_string .= '       $("#" + drop_area).droppable({ disabled: false });';
            $html_string .= '   }';
            
            $html_string .= '   function disable_draggable(drop_area) {';
            $html_string .= '       $("#" + drop_area).droppable({ disabled: true });';
            $html_string .= '   }';
            
            /**
	         * [set_object_label - Set the object label]
		     * @param  [string] object_id     [Id of the object]
             * @param  [string] object_label  [Text to be shown in the object]
		     */ 
            $html_string .= '   function set_object_label(object_id, object_label) {';
            $html_string .= '       $("#" + object_id).find(".object_label").html(object_label);';
            $html_string .= '   }';
            
            /**
	         * [clear_droparea - Clear the drop area]
		     * @param  [string] drop_area   [Id of the drop area]
             */ 
            $html_string .= '   function clear_droparea(drop_area) {';
            $html_string .= '       $("#" + drop_area).html("");';
            $html_string .= '   }';
            $html_string .= '</script>'; 
            return $html_string;
        }
        
        /**
		 * [set_droparea - Set the drop area]
		 * @param  [string] $drop_area   [Id of the drop area, string without space.]
		 */
        function set_droparea($drop_area) {
            $html_string =  '<script>';
            $html_string .= '   $(function() { ';
            $html_string .= '       $("#' . $this->draggable_name . ' .obj_div").draggable({';
            $html_string .= '           revert: "invalid",';
            $html_string .= '           cursor: "move",';
            $html_string .= '           helper: "clone"';
            $html_string .= '       });';
            $html_string .= '       $("#' . $drop_area . '").droppable({ ';
            $html_string .= '           accept: "#' . $this->draggable_name . ' div",';
            $html_string .= '           drop: function( event, ui ) {';
            $html_string .= '               $(this).append($(ui.helper).clone());';
            $html_string .= '               $("#' . $drop_area . ' .obj_div").draggable({';
            $html_string .= '                   containment: "parent"';    
            $html_string .= '               });';
            $html_string .= '               var random = parseInt(Math.random() * 1000000);';
            $html_string .= '               var new_id = "' . $drop_area . '" + "_" + random;';
            $html_string .= '               $("#' . $drop_area . ' .obj_div:last").attr("id", new_id);';
            $html_string .= '           }';
            $html_string .= '       });';
            $html_string .= '   });';
            $html_string .= '</script>'; 
            return $html_string;
        }
        
        /**
		 * [set_drag_image Set the draggable image]
		 * @param  [string] $image_name   [Name of the image, string without space.]
		 */
        function set_drag_image($image_name) {
            global $app_php_script_loc;
            $path = $app_php_script_loc . "components/lib/adiha_dhtmlx/adiha_DNDobject_3.0/img/";
            $html_string =  '<div class="obj_div">';
            $html_string .= '<div class="image_div"><img class="' . $image_name . '" src="' . $path . $image_name . '.png"></img></div>';
            $html_string .= '<div class="button_div"><img src="' . $path . 'remove.jpg" onclick="remove_object(this)"></img></div>';
            $html_string .= '<div class="clear"></div>';
            $html_string .= '<div class="object_label"></div>';
            $html_string .= '</div>';
            return $html_string;
        }
        
        /**
		 * [set_button Set the button to the image]
		 * @param  [string] $image_name   [Name of the image where button is to be added, string without space.]
         * @param  [string] $button_name   [Name of the button, string without space.]
		 */
        function set_button($image_name, $button_name, $onclick_function) {
            global $app_php_script_loc;
            $path = $app_php_script_loc . "components/lib/adiha_dhtmlx/adiha_DNDobject_3.0/img/";
            
            $button = '<img class = "' . $button_name . '" src="' . $path . $button_name . '.jpg" onclick=' . $onclick_function . '($(this).parents(".obj_div").attr("id"))></img>';
            
            $html_string = '<script>';
            $html_string .= '$(".' . $image_name . '").parent().parent().find(".button_div").append(\'' . $button . '\');';
            $html_string .= '</script>';
            return $html_string;
        }
    }

?>
