<?php
    /**
     *  @brief AdihaFormulaTextbox
     *  
     *  @par Description
     *  This class is used to generate a formula textbox
     *  
     *  @copyright Pioneer Solutions
     */
    Class AdihaFormulaTextbox {
        public $textbox_name;
        public $width;
        public $height;
        public $name_space;
        public $enabled = true;
        public $default_value = '';
        
        /**
         * Initialize the formula textbox.
         * @param  String  $textbox_name   Formula textbox name, string without space
         * @param  Integer $width          Width of tree
         * @param  Integer $height         Heigth of tree
         * @param  string  $namespace      Same name to be used in all components in a form
         */
        function init_formula_textbox($textbox_name, $width, $height, $namespace) {
            $this->width = $width;
            $this->height = $height;
            $this->name_space = $namespace; 
            $this->textbox_name = $textbox_name . '.' .  $namespace;
        }
        
        /**
         * True-Enable formula textbox, False-Disable formula textbox, By defaule true.
         * @param  Boolean $value   Is editor enabled
         */
        function set_enabled($value) {
            $this->enabled = $value;
        }
        
        /**
         * Set the default value in the textbox.
         * @param String $default_value   Default Value
         */
        function set_default_value($default_value) {
            $this->default_value = $default_value;
        }
        
        /**
         * Load the formula textbox.
         * @return String JS to create formula textbox
         */
        function load_formula_textbox() {
            $html_string = "";
            $html_string .= "   <div id='" . $this->textbox_name . "' name='" . $this->textbox_name . "' class='code-editor'></div>";
            $html_string .=     $this->default_value . "</div>" . "\n";
            $html_string .= "   <script>". "\n";
            $html_string .= "       var editor_div = document.getElementById('" . $this->textbox_name . "');" . "\n";
            $html_string .= "       var " . $this->name_space . " = ace.edit(editor_div); " . "\n";
            $html_string .=         $this->name_space . ".session.setMode('ace/mode/sqlserver'); " . "\n";
            $html_string .=         $this->name_space . ".setTheme('ace/theme/sqlserver'); " . "\n";
            $html_string .=         $this->name_space . ".setOptions({ " . "\n";
            $html_string .= "           enableBasicAutocompletion: true, " . "\n";
            $html_string .= "           enableSnippets: true, " . "\n";
            $html_string .= "           enableLiveAutocompletion: false " . "\n";
            $html_string .= "       });" . "\n";
            
            if (!$this->enabled) {
                $html_string .=     $this->name_space . ".setReadOnly(true)" . "\n";
            }

            $html_string .=         $this->load_formula_textbox_functions();
            return $html_string .= "   </script>" . "\n";
        }
        
        /**
         * Loads all formula texbox Functions
         * @return String JS to load formula textbox functions
         */
        function load_formula_textbox_functions() {
            /**
             * Get the value of the formula textbox.
             */
            $html_string =      $this->name_space . ".get_formula_textbox_value = function(){ " . "\n";
            $html_string .= "       var x = " . $this->name_space . ".getValue();" . "\n";
            $html_string .= "       x = ( x == undefined  || x=='') ? 'NULL' : x ;" . "\n";
            $html_string .= "       return encodeURIComponent(x);" . "\n";
            $html_string .= "   }" . "\n";
            
            /**
             * Set the value in the formula textbox.
             * @param String $val Value to be set
             */
            $html_string .=     $this->name_space . ".set_formula_textbox_value = function(val){" . "\n";
            $html_string .= "       " . $this->name_space . ".setValue(decodeURIComponent(val));" . "\n";
            return $html_string .= "   }" . "\n";
        }
    }       
?>