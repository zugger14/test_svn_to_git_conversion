<?php
    Class AdihaFormulaTextbox {
        public $textbox_name;
        public $width;
        public $height;
        public $name_space;
        public $value = '';
        public $enabled = true;
        public $default_value = '';
        
        /**
         * [init_formula_textbox Initialize the formula textbox]
         * @param  [string] $textbox_name   [Formula textbox name, string without space.]
         * @param  [int] $width             [Width of tree]
         * @param  [int] $height            [Heigth of tree]
         * @param  [string] $namespace      [Same name to be used in all components in a form]
         */
        function init_formula_textbox($textbox_name, $width, $height, $namespace) {
            $this->width = $width;
            $this->height = $height;
            $this->name_space = $namespace; 
            $this->textbox_name = $textbox_name . '.' .  $namespace;
        }
        
        /**
         * [set_enabled True-Enable formula textbox, False-Disable formula textbox, By defaule true]
         * @param  [string] $value   [True/False]
         */
        function set_enabled($value) {
            $this->enabled = $value;
        }
        
        /**
         * [set_default_value Set the default value in the textbox]
         * @param  [string] $defailt_value   [Default Value]
         */
        function set_default_value($defailt_value) {
            $this->default_value = $defailt_value;
        }
        
        /**
         * [load_formula_textbox Load the formula textbox]
         */
        function load_formula_textbox() {
            $html_string = "";
            $html_string .= "<TEXTAREA id='" . $this->textbox_name . "' class=adiha_multitext_control rows='" . $this->height . "' cols='" . $this->width . "' name='" . $this->textbox_name ."'" . "\n";
            if ($this->enabled == false) {
                $html_string .=" disabled" . "\n";
            }
            
            $html_string .= ">" . $this->value . "</TEXTAREA>". "\n";
            $html_string .= "   <script>". "\n";
            $html_string .= "       var myTextArea=document.getElementById('".$this->textbox_name."');" . "\n";
            $html_string .= "       var " . $this->name_space . " = CodeMirror.fromTextArea(myTextArea,{" . "\n";
            $html_string .= "       lineNumbers:true,lineWrapping:true,\n mode:'text/x-mssql',\n indentUnit:5});" . "\n";
            $html_string .=         $this->load_formula_textbox_functions();
            $html_string .= "   </script>" . "\n";
            return $html_string;
        }
        
        /**
         * [Javascript Functions]
         */
        function load_formula_textbox_functions() {
            /**
             * [Get the value of the formula textbox]
             */
            $html_string =      $this->name_space . ".get_formula_textbox_value = function(){ " . "\n";
            $html_string .= "       var x = " . $this->name_space . ".getDoc().getValue();" . "\n";
            $html_string .= "       x = ( x == undefined  || x=='') ? 'NULL' : x ;" . "\n";
            $html_string .= "       return encodeURIComponent(x);" . "\n";
            $html_string .= "   }" . "\n";
            
            /**
             * [Set the value in the formula textbox]
             * @param [string] val [Value to be set]
             */
            $html_string .=     $this->name_space . ".set_formula_textbox_value = function(val){" . "\n";
            $html_string .= "       " . $this->name_space . ".getDoc().setValue(decodeURIComponent(val));" . "\n";
            $html_string .= "   }" . "\n"; 
            return $html_string;
        }
    }       
?>