<?php

    /**
     * GaugeFactory
     * 
     * @package   
     * @author Pawan Adhikari
	 * @copyright Pioneer Solutions Global
	 * @version 2012
	 * @access public
     */
    class GaugeFactory {        
     
        // Parameter Factory-Method
        public static function get_gauge($type) {
            if (require_once $type . '.php') {
                $classname = $type;
                return new $classname;
            } else {
                throw new Exception('Error Occured :: Library not found');
            }
        }
        
    }

?>