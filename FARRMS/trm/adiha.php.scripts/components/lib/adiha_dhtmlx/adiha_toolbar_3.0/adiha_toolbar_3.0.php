<?php
	class AdihaToolbar {
		public $toolbar_name;

		/**
		 * [init_script Initialize Script]
		 * @param type $toolbar_name string Toolbar name
		 * @return type
		 */
		private function init_script($toolbar_name) {
			global $app_php_script_loc;
			$html_string = "<script type='text/javascript'>";
			$html_string .= "hideHourGlass();"  . "\n";
			$html_string .= "$(function(){"  . "\n";
            $html_string .= "	load_toolbar_" . $toolbar_name . "();"  . "\n";
        	$html_string .= "});"  . "\n";
			$html_string .= "function load_toolbar_" . $toolbar_name . "() {"  . "\n";
			return $html_string;
		}

		/**
		 * [close_toolbar Close script tag]
		 */
		function close_toolbar() {
			$html_string =	"}" . "\n";
			$html_string .= "</script>" . "\n";
			echo $html_string;
		}

		/**
		 * [init_toolbar Initialize toolbar]
		 * @param  [string] $toolbar_name   [toolbar Name, string without space.]
		 * @param  [type] $parent_object   [Parent element id for toolbar.]
		 * @param  [type] $pattern         [Pattern for toolbar. Example: 3L, 1C... for more infor: http://docs.dhtmlx.com/toolbar__patterns.html]
		 * @param  [json] $button_jsoned    [JSON data for toolbar] -	Format -
		 *  	[{
				    id:      "open"             // required, will be generated automatically if empty
				    type:    "button"           // required, item type
				    img:     "open.gif"         // optional, icon for the enabled item
				    imgdis:  "open_dis.gif"     // optional, icon for the disabled image
				    text:    "Open"             // optional, item text
				    title:   "Tooltip here"     // optional, tooltip for an item
				    enabled: false              // optional, disable an item
				    hidden:  true               // optional, hide an item
				    action:  "function_name"    // optional, function name to exec on click
				    userdata: {                 // optional, userdata
				        p1: "value1"            // userdata, name:value pairs
				        p2: "value2"
				    }
				    // deprecated from 4.0: do not use it
				    img_disabled: "open_dis.gif"    // => imgdis:  "open_dis.gif"
				    disabled:     true              // => enabled: false
				}]
				Details on - http://docs.dhtmlx.com/api__link__dhtmlxtoolbar_loadstruct.html
		 * @return [type]                  [description]
		 */
		function init_toolbar($toolbar_name, $parent_object, $button_jsoned = "") {
			global $image_path;
			$this->toolbar_name = $toolbar_name;

			$html_string = $this->init_script($toolbar_name);
			$html_string .= $toolbar_name . " = new dhtmlXToolbarObject('" . $parent_object ."')" . "\n";
			$html_string .= $this->toolbar_name. ".setIconsPath('". $image_path . "dhxtoolbar_web/');" . "\n";

			if ($button_jsoned != '') {
				$button_jsoned = '{data:' . $button_jsoned . '}';
				$html_string .= $this->toolbar_name. ".loadStruct(". $button_jsoned . ");" . "\n";
			}

			return $html_string;
		}

		/**
		 * [init_by_attach initialize the toolbar by attaching component]
		 * @param  [string] $toolbar_name [toolbar name]
		 */
		function init_by_attach($toolbar_name, $name_space) {
			global $image_path;
			$this->toolbar_name = $name_space . "." . $toolbar_name;
			$html_string .= $this->toolbar_name. ".setIconsPath('". $image_path . "dhxtoolbar_web/');" . "\n";
			return $html_string;
		}

		/**
		 * load_toolbar - Load toolbar
		 * @param [json] $button_jsoned [JSON data for toolbar]
		 */
		function load_toolbar($button_jsoned) {
			if ($button_jsoned != '') {
				$html_string .= $this->toolbar_name. ".loadStruct(". $button_jsoned . ");" . "\n";
				return $html_string;
			}
		}

		/**
		 * load_toolbar_xml - Load toolbar
		 * @param  [XML] $button_xml [XML data for toolbar]
		 */
		function load_toolbar_xml($button_xml) {
			if ($button_xml != '') {
				$html_string .= $this->toolbar_name. ".loadStruct('". $button_xml . "'');" . "\n";
				return $html_string;
			}
		}

		/**
		 * [set_skin - sets skin]
		 * @param [string] $skin_name [Name of a skin]
		 */
		function set_skin($skin_name) {
			$html_string = $this->toolbar_name . ".setSkin('". $skin_name . "');" . "\n";
			return $html_string;
		}

		/**
		 * [enable_item enables the specified item]
		 * @param [string] $item_id [id of an item to enable]
		 */
		function enable_item($item_id) {
			$html_string = $this->toolbar_name . ".enableItem('". $item_id . "');" . "\n";
			return $html_string;
		}

		/**
		 * [disable_item disables the specified item]
		 * @param [string] $item_id [id of an item to disable]
		 */
		function disable_item($item_id) {
			$html_string = $this->toolbar_name . ".disableItem('". $item_id . "');" . "\n";
			return $html_string;
		}

		/**
		 * [hide_item hides the specified item]
		 * @param [string] $item_id [id of an item to hide
		 */
		function hide_item($item_id) {
			$html_string = $this->toolbar_name . ".hideItem('". $item_id . "');" . "\n";
			return $html_string;
		}

		/**
		 * [attach_event - adds any user-defined handler to available events]
		 * @param [string] $event_id [variable name to store event]
		 * @param [string] $event_name [name of the event. Available event: http://docs.dhtmlx.com/api__refs__dhtmlxtoolbar_events.html]
		 * @param [string] $event_function [user defined function name, which will be called on particular event. This function can be defined in main page itself.]
		 */
		function attach_event($event_id = '', $event_name, $event_function) {
			if ($event_id == '') {
				$html_string = $this->toolbar_name . ".attachEvent('". $event_name . "', $event_function);" . "\n";
			} else  {
				$html_string = "var " . $event_id . "=" . $this->toolbar_name . ".attachEvent('". $event_name . "', $event_function);" . "\n";
			}
			return $html_string;
		}

		/**
		 * [detach_event - detach event]
		 * @param [string] event_id [event_id]
		 */
		function detach_event($event_id) {
			$html_string = $this->toolbar_name . ".detachEvent('". $event_id ."');" . "\n";
			return $html_string;
		}

		/**
		 * [unload - destructor, unloads toolbar]
		 */
		function unload() {
			$html_string = $this->toolbar_name . ".unload();" . "\n";
			$html_string .= $this->toolbar_name . "= null;";
			return $html_string;
		}

		function save_privilege($type_id, $value_id) {
		    $xml_file = "EXEC spa_static_data_privilege @flag = 'c', @type_id = ".$type_id.", @value_id=".$value_id;
		    $return_privilege = readXMLURL($xml_file);

		    $privilege_status = $return_privilege[0][0];

		    if($privilege_status == 'false') {
		        $html_string = $this->disable_item('save');
		    }
		    return $html_string;
		}

	}
?>