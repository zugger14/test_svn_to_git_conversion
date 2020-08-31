<?php
/**
 * Gauge Injector
 *
 * @author mshrestha
 */
class RDL_Gauge extends RDL_Item{
    
    public function __construct($ssrs_config = null, $languange_dict = null, $rdl_type = null, $process_id = null) {
        parent::__construct($ssrs_config, $languange_dict, $rdl_type, $process_id);
        $this->display_type = 'g';
    }
    
    public function get_gauge_type($type){       
        $gauge_type = array(
                                1 => 'Radial', 
                                2 => 'Radial180DegreesNorth',
                                3 => 'LinearThreeColorRangeHorizontal',
                                4 => 'LinearThreeColorRangeVertical'
                            );
        return $gauge_type[$type];
    }
}

?>
