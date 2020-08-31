<?php

    /**
     * ChartFactory
     * 
     * @package   
     * @author Pawan Adhikari
	 * @copyright Pioneer Solutions Global
	 * @version 2012
	 * @access public
     */
    
    require_once('interface.chart.php');
    require_once('chart.common.php');
     
    class ChartFactory {        
        #Parameter Factory-Method
        public static function get_chart($type) {
            require_once($type . '.php');
            $class_name = explode('/', $type);
            return new $class_name[1];
        }
    }

?>