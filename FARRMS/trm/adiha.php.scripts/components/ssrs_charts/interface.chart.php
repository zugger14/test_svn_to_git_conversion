<?php 
    interface iChartData {        
        public function set_members($members);
        public function set_series($series);
	public function set_groups($group);
        public function set_y_axis_caption($y_axis_caption);
        public function set_x_axis_caption($x_axis_caption);
	}

    interface iChartDimension {        
        public function set_top($top);			
        public function set_left($left);        
        public function set_height($height);
        public function set_width($width);
        public function set_zindex($zindex);
        public function set_page_break($page_break);
	}    
    
    interface iChart extends iChartData, iChartDimension {
        public function set_ds_name($ds_name);
        public function set_caption($caption);
        public function set_name($name);
	public function get_chart_rdl();
	}

?>