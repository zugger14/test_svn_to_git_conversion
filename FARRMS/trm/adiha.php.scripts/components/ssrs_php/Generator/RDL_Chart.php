<?php
/**
 * Chart Injector
 *
 * @author mshrestha
 */
class RDL_Chart extends RDL_Item{
    
    public function __construct($ssrs_config = null, $languange_dict = null, $rdl_type = null, $process_id = null) {
        parent::__construct($ssrs_config, $languange_dict, $rdl_type, $process_id);
        $this->display_type = 'c';
    }
    
    public function get_chart_type($type){
        return $type;
    }
}

?>
