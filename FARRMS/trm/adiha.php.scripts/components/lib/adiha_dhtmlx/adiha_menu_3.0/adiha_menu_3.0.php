<?php

/**
 *  @brief AdihaMenu
 *  
 *  @par Description
 *  This class is used to generate menu according to the JSON loaded.
 *  @par Usage:
 *  <pre> 
 *  {@code 
 *  $menu_json =   '[
 *                      {id:"file", text:"File", items:[
 *                          {id: "new", text: "New", img: "new.gif", imgdis: "new_dis.gif"},
 *                          {id: "close", text: "Close", img: "close.gif", imgdis: "close_dis.gif"}
 *                      ]},
 *                      {id: "edit", text: "Edit", items:[
 *                          {id: "undo", text: "Undo", img: "undo.gif", imgdis: "undo_dis.gif"},
 *                          {id: "redo", text: "Redo", img: "redo.gif", imgdis: "redo_dis.gif"},
 *                          {id: "paste", text: "Paste", img: "paste.gif", imgdis: "paste_dis.gif"}
 *                      ]}
 *                  ]'; 
 *  $menu_obj = new AdihaMenu();
 *  echo $menu_obj->init_by_attach($menu_name, $namespace);
 *  echo $menu_obj->load_menu($menu_json);
 *  echo $menu_obj->attach_event('', 'onClick', 'menu_onclick');
 *  }
 *  </pre>
 *  @author    Biju Maharjan <bmaharjan@pioneersolutionsglobal.com>
 *  @version   3.0
 *  @date      2015-03-11
 *  @copyright Pioneer Solutions.
 */

Class AdihaMenu {
    public $menu_name;
    public $name_space;
    
    /**
     * [init_menu Initialize Menu when it is not attached to other object]
     * @param  [string] $menu_name    [Menu Name, string without space.]
     * @param  [string] $namespace    [Same name to be used in all components in a form]
     */
    public function init_menu($menu_name, $name_space) {
        $this->name_space = $name_space;
        $this->menu_name = $this->name_space . "." . $menu_name;
        
        $html_string = $this->menu_name . ' = new dhtmlXMenuObject({'. "\n";
        $html_string .= '   icons_path: js_image_path + "dhxmenu_web/"'. "\n";
        $html_string .= '});';
        return $html_string;
    }
    
    /**
     * [init_by_attach Initialize Menu when it is attached to other object]
     * @param  [string] $menu_name    [Menu Name, string without space.]
     * @param  [string] $namespace    [Same name to be used in all components in a form]
     */   
    public function init_by_attach($menu_name, $name_space) {
        $this->name_space = $name_space;
        $this->menu_name = $this->name_space . "." . $menu_name;
    }
    
    /**
     * [load_menu Load the JSON structure of menu and create menu]
     * @param  [string] $menu_json    [JSON to build menu]
     */   
    public function load_menu($menu_json) {
        $html_string = $this->menu_name . ".loadStruct(" . $menu_json .");" . "\n";
        return $html_string;
    }

    /**
     * [render_as_context_menu Render the menu as context menu]
     */   
    public function render_as_context_menu() {
        $html_string = $this->menu_name . ".renderAsContextMenu();" . "\n";
        return $html_string;
    }
    
    /**
     * [attach_event - adds any user-defined handler to available events]
     * @param [string] $event_id [variable name to store event]
     * @param [string] $event_name [name of the event. Available event: http://http://docs.dhtmlx.com/api__refs__dhtmlxmenu_events.html]
     * @param [string] $event_function [user defined function name, which will be called on particular event. This function can be defined in main page itself.]
     */
    public function attach_event($event_id = '', $event_name, $event_function) {
        if ($event_id == '') {
                $html_string = $this->menu_name . ".attachEvent('". $event_name . "', $event_function);" . "\n";
        } else  {
                $html_string = "var " . $event_id . "=" . $this->menu_name . ".attachEvent('". $event_name . "', $event_function);" . "\n";
        }
        return $html_string;
    }
}

?>