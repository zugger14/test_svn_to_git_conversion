<?php
    Class AdihaChart {
        private $layout_name;
        private $name_space;
        private $layout_cell;
        private $chart_name;
        
        private $series_legend = '';
        private $view_type;
        private $marker_type;
        
        /*
         * Constructr to set the chart name and name space
         */
        public function __construct($chart_name, $name_space) {
            $this->name_space = $name_space;
            $this->chart_name = $name_space . '.' . $chart_name;
        }
        
        /*
         * Set the name of layout and layout cell to attach the chart
         */
        public function attach_to_layout($layout_name,$layout_cell) {
            $this->layout_name = $layout_name;
            $this->layout_cell = $layout_cell;
        }
        
        /*
         * Initialize the chart
         */
        public function init_chart($view, $xaxis_col, $xaxis_label, $yaxis_col, $yaxis_label, $yaxis_series_label = '') {
            if($yaxis_series_label == '') 
                $yaxis_series_label = $yaxis_label;
            
            $this->view_type = $view;
            if($view == 'line' || $view == 'spline') {
                $this->marker_type = 'item';
            } else {
                $this->marker_type = 'square';
            }
            
            $line_color = self::get_line_color(1);
            $this->series_legend = $this->series_legend . '{text:"' . $yaxis_series_label . '", color:"' . $line_color . '", markerType:"' . $this->marker_type . '"}';
            
            $html_string .= $this->chart_name . ' = ' . $this->name_space. '.' . $this->layout_name . ".cells('" . $this->layout_cell . "').attachChart({". "\n";
            $html_string .= '   view: "' . $view . '",'. "\n";
            $html_string .= '   value: "#' . $yaxis_col . '#",'. "\n";
            $html_string .= '   color: "' . $line_color . '",'. "\n";
            $html_string .= '   item:{'. "\n";
            $html_string .= '       borderColor: "' . $line_color . '",'. "\n";
            $html_string .= '       color: "' . $line_color . '",'. "\n";
            $html_string .= '       type:"' . self::get_marker_shape(1) . '"'. "\n";
            $html_string .= '   },'. "\n";
            $html_string .= '   padding:{left:75, bottom:90, top:25, right:25},'. "\n";
            $html_string .= '   yAxis:{title:"' . $yaxis_label . '"},'. "\n";
            $html_string .= '   xAxis:{   '. "\n";
            $html_string .= '       template:function(obj){ return "<span>" + obj.' . $xaxis_col . ' + "</span>" },'. "\n";
            $html_string .= '        title:"' . $xaxis_label . '"'. "\n";
            $html_string .= '   },'. "\n";
            $html_string .= '   tooltip:{'. "\n";
            $html_string .= '       template:function(obj){ return "<span>" + obj.' . $yaxis_col . ' + "</span>" }'. "\n";
            $html_string .= '   }'. "\n";
            $html_string .= '});';
            return $html_string;
        }
        
        /*
         * Add new series in the chart
         */
        public function add_series($value, $label, $template_id) {
            $line_color = self::get_line_color($template_id);
            
            if($this->series_legend <> '') 
                $this->series_legend = $this->series_legend . ',';
            $this->series_legend = $this->series_legend . '{text:"' . $label . '", color:"' . $line_color . '", markerType:"' . $this->marker_type . '"}';
            
            $html_string .= $this->chart_name . '.addSeries({' . "\n";
            $html_string .= '   value: "#' . $value . '#",'. "\n";
            $html_string .= '   line:{color:"' . $line_color . '"},'. "\n";
            $html_string .= '   color:"' . $line_color . '",'. "\n";
            $html_string .= '   item:{'. "\n";
            $html_string .= '       borderColor: "' . $line_color . '",'. "\n";
            $html_string .= '       color: "' . $line_color . '",'. "\n";
            $html_string .= '       type:"' . self::get_marker_shape($template_id) . '"'. "\n";
            $html_string .= '   },'. "\n";
            $html_string .= '   tooltip:{'. "\n";
            $html_string .= '       template:function(obj){ return "<span>" + obj.' . $value . ' + "</span>" }'. "\n";
            $html_string .= '   }'. "\n";
            $html_string .= '});'. "\n";
            
            return $html_string;
        }
        
        /*
         * Load the legend of the chart
         */
        public function load_legends($halign = 'right',$valign = 'top') {
            $html_string .= $this->chart_name . '.define("legend",{' . "\n";
            $html_string .= '   align:"' . $halign . '",'. "\n";
            $html_string .= '   valign:"' . $valign . '",'. "\n";
            $html_string .= '   toggle:"true",'. "\n";
            $html_string .= '   values:['. $this->series_legend .'],'. "\n";
            $html_string .= '});'. "\n";
            return $html_string;
        }
        
        
        /*
         * Returns the color of the line
         */
        public function get_line_color($template_id) {
            $line_color = '';
            
            switch($template_id) {
                case 1: //Blue
                    $line_color = '#4185f2';
                    break;
                case 2: //Green
                    $line_color = '#1ff270';
                    break;
                case 3: //Red
                    $line_color = '#f2341f';
                    break;
                case 4: //Yellow
                    $line_color = '#f2eb1f';
                    break;
                case 5: //Purple
                    $line_color = '#b35cf2';
                    break;
                default: //Black
                    $line_color = '#000000';
                    break;
            }
            
            return $line_color;
        }
        
        /*
         * Returns the shape of the line marker
         */
        private function get_marker_shape($template_id) {
            $marker_shape = '';
            
            switch($template_id) {
                case 1: //Blue
                    $marker_shape = 's';
                    break;
                case 2: //Green
                    $marker_shape = 'c';
                    break;
                case 3: //Red
                    $marker_shape = 't';
                    break;
                case 4: //Yellow
                    $marker_shape = 's';
                    break;
                case 5: //Purple
                    $marker_shape = 'c';
                    break;
                default: //Black
                    $marker_shape = 't';
                    break;
            }
            
            return $marker_shape;
        }
    
    }

?>