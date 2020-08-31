<?php
/**
* Show plot graph screen
* @copyright Pioneer Solutions
*/
?>
<?php ob_start(); ?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <?php
	$php_script_loc = $app_php_script_loc;
    $measure = isset($_GET['measure']) ? get_sanitized_value($_GET['measure']) : 17351;
    $call_from = isset($_GET['call_from']) ? get_sanitized_value($_GET['call_from']) : 'atrisk';
    $var_criteria_id = get_sanitized_value($_GET['var_criteria_id']);
    $as_of_date = get_sanitized_value($_GET['as_of_date']);

    if (isset($_GET['counterparty']))
        $counterparty = singleQuote(get_sanitized_value($_GET['counterparty']));
     else
        $counterparty = 'NULL';        
    
    if($call_from == 'atrisk')
        $sp_url = "EXEC spa_var_plotting_data @flag='s', @var_criteria_id=$var_criteria_id, @as_of_date='$as_of_date', @counterparty=$counterparty";
    else
        $sp_url = "EXEC spa_var_plotting_data_whatif @flag='s', @var_criteria_id=$var_criteria_id, @as_of_date='$as_of_date', @counterparty=$counterparty, @measure = $measure"; 
    
        
    $return_value1 = readXMLURL($sp_url);
    $maximum_pdf_var = null;
    $maximum_pdf = null;
    $mtm_array = array();

//echo "VaR=>".$sp_url; 
//echo "<pre>";
//print_r($return_value1); die();
    # Data array used
    /*
    data[]  => main bell curve ; lines plot.
    data1[] => mtm line, var line ; thinbarline plot.
    data2[] => out of var area ; area plot.
    data3[] => mtm to var area ; area plot.
    data4[] => var_avg to mtm_avg line ; linespoint plot.
    data5[] => single point var_avg + var pdf ; linespoint plot.
    data6[] => single point mtm_avg + var pdf ; linespoint plot.
    */
    $data2 = array();
    $data3 = array();

    foreach ($return_value1 as $key => $value) {
       $data[] = array('', $value[0], $value[1]); 
       $maximum_pdf = $maximum_pdf == null ? $value[1] : max($maximum_pdf, $value[1]);  
       array_push($mtm_array, $value[0]);     
    }
    if($call_from == 'atrisk')
        $sp_url = "EXEC spa_var_plotting_data @flag='m', @var_criteria_id=$var_criteria_id, @as_of_date='$as_of_date', @counterparty=$counterparty";
    else
        $sp_url = "EXEC spa_var_plotting_data_whatif @flag='m', @var_criteria_id=$var_criteria_id, @as_of_date='$as_of_date', @counterparty=$counterparty, @measure = $measure";
    
    //echo $sp_url; die();    
    $return_value = readXMLURL($sp_url);
    $xmin = $return_value[0][0];
    $xmax = $return_value[0][1];
    $ymin = $return_value[0][2];
    $ymax = $return_value[0][3];
    $mtm_avg = $return_value[0][4];
    $x_heading = $return_value[0][5];
    $var_heading = $return_value[0][6];
    $var_avg =  $return_value[0][7];
    $var = $return_value[0][8];
    $which_xpos = '160';

    //take nearest mtm_value for corresponding var_avg and pick up pdf for that mtm_value
    $mtm_nearest_to_var_avg = get_closest_value($var_avg, $mtm_array);
    $mtm_nearest_to_mtm_avg = get_closest_value($mtm_avg, $mtm_array);
//echo "VaR=>".$var_avg."MTM=>".$mtm_nearest_to_var_avg; die();
//echo "VaR=>".$value[0][0];
//echo "<pre>";
//print_r($return_value1);die();
    foreach ($return_value1 as $key => $value) {
        if ($var_avg < $mtm_avg) { //case for var
        
            if ($value[0] <= $mtm_nearest_to_var_avg) {
                $data2[] = array('',$value[0],$value[1]);
                
                if ($value[0] == $mtm_nearest_to_var_avg) {
                    $maximum_pdf_var = $value[1];
                    $data3[] = array('',$value[0],$value[1]); 
                }
            } else if ($value[0] >= $mtm_nearest_to_var_avg && $value[0] <= $mtm_nearest_to_mtm_avg){
                $data3[] = array('',$value[0],$value[1]);   
            }    
        } else if ($var_avg > $mtm_avg) { //case for pfe
            if ($value[0] >= $mtm_nearest_to_mtm_avg && $value[0] <= $mtm_nearest_to_var_avg) {
                $data3[] = array('',$value[0],$value[1]);
                if ($value[0] == $mtm_nearest_to_var_avg) {
                    $maximum_pdf_var = $value[1];
                    $data3[] = array('',$value[0],$value[1]);
                    $data2[] = array('',$value[0],$value[1]);
                }
            } else if ($value[0] > $mtm_nearest_to_var_avg){
                $data2[] = array('',$value[0],$value[1]);
            }
        }
    }
    //echoTextarea($data2);echoTextarea($data3);die();

    # On/Off different plots. 
    $var_line_plot_on = 0; //display var line: 1 => on; 0 => off
    $mtm_to_var_area_plot_on = 0; //plot mtm_to_var: 1 => on; 0 => off
    $out_of_var_area_plot_on = 1; //plot out_of_var_area: 1 => on; 0 => off
    $mtm_avg_line_plot_on = 1; //plot mtm_avg vertical line: 1 => on; 0 => off
    $mtm_to_var_avg_diff_plot_on = ($var_heading == 'PFE') ? 0 : 1; //plot mtm_avg to var_avg difference line: 1 => on; 0 => off

    # data1[] plot var_avg line and mtm_avg line
    if ($var_line_plot_on == 1) {
        $data1[] = array('', $var_avg, 0);
        $data1[] = array('', $var_avg, $maximum_pdf_var);
    }

    if ($mtm_avg_line_plot_on == 1) {
        $data1[] = array('', $mtm_avg, $maximum_pdf);    
    }

    # data4[], data5[], data6[] for var_avg to mtm_avg line, single point plot for var_avg and mtm_avg
    $data4[] = $data5[] = array('', $var_avg, $maximum_pdf_var / 2);
    $data4[] = $data6[] = array('', $mtm_avg, $maximum_pdf_var / 2);

    if ($mtm_avg != 0 && $var_avg != 0) {
        ob_clean(); //End of data Fetching and storing into a $data variable
        //require_once 'phplot.php';
        
        # Draw Text params
        
        //format numbers with comma
        $var_avg_display = number_format($var_avg, 4, '.', ',');
        $var_display = number_format($var, 4, '.', ',');
        $mtm_avg_display = number_format($mtm_avg, 4, '.', ',');
        define('DRAWTEXT', $var_heading . ' (' . (($var_heading == '1-Day PFE' || $var_heading == 'PFE') ? $var_avg_display : $var_display) . ')');
        define('XPOS', $which_xpos);
        
        $plot = new PHPlot(900, 700);
        
        # General , global info for plot
        
        // Disable auto-output:
        $plot->SetImageBorderType('none');
        $plot->SetPrintImage(0); //a must for multiple plots.
        
        // Make sure Y axis starts at 0:
        $plot->SetPlotAreaWorld($xmin, $ymin, $xmax, $ymax);
        $plot->SetPlotBorderType('left');
        
        // Graph titles:
        $plot->SetTitle('Distribution Chart');
        $plot->SetXTitle($x_heading . ' (' . $mtm_avg_display . ')');
        $plot->SetYTitle('Probability Density');
        
        // Setting plot data type
        $plot->SetDataType('data-data');
        
        // set line width for data curve
        $line_width_for_data_curve = 3;
        $plot->SetLineWidth($line_width_for_data_curve);
        
        // set line point size for point plot
        $line_point_size = 10;
        
        // Set number to display after decimal
        if ($var_heading == 'GMaR'){
            $plot->SetPrecisionX('4');    
        } else {
            $plot->SetPrecisionX('0');
        }
        
        $plot->SetPrecisionY('4');
        
        // Set Color
        $plot->SetBackgroundColor($which_color = 'white');
        $plot->SetTitleColor($which_color = 'blue');
        $plot->SetXTitleColor($which_color = 'black');
        $plot->SetYTitleColor($which_color = 'black');
        $plot->SetTextColor($which_color = 'black');
        $plot->SetDataColors($which_color = 'black');
        $plot->SetLightGridColor('black');
        
        // set fonts for title and generic element.
        /*$plot->SetFontTTF('title', '', 16); //Code commented because specified font was not present
        $plot->SetFontTTF('generic', 'verdana', 8);*/
        
        # Plot starts
        /* Plot Order:
            1. out of var area ; data2.
            2. mtm to var area ; data3.
            3. mtm_avg, var_avg vertical line ; data1
            4. var_avg to mtm_avg ; data4
            5. single point var_avg + var pdf ; data5
            6. single point mtm_avg + var pdf ; data6
            7. main bell curve plot ; data
        */
        
        # Do the first plot:
        if ($out_of_var_area_plot_on == 1) {
            $plot->SetPlotType('area');
            $plot->SetDataValues($data2);
            $plot->SetDataColors('red');
            $plot->DrawGraph(); //plot out of var area
        }
        
        # Do the second plot:
        if ($mtm_to_var_area_plot_on == 1) {
            $plot->SetPlotType('area');
            $plot->SetDataValues($data3);
            $plot->SetDataColors('gray');
            $plot->DrawGraph(); //plot mtm to var area
        } 
           
        # Do the third plot:
        if ($mtm_avg_line_plot_on == 1 || $var_line_plot_on == 1) {
            $plot->SetPlotType('thinbarline');
            $plot->SetDataValues($data1);
            $plot->SetDataColors(array('black'));
            $plot->DrawGraph(); //plot thinbarline vertical
        }
        
        # Do the fourth plot:
        if ($mtm_to_var_avg_diff_plot_on == 1) {
            $plot->SetPlotType('linepoints');
            $plot->SetPointShape('none');
            $plot->SetDataValues($data4);
            $plot->SetDataColors(array('black'));
            $plot->DrawGraph(); //plot linepoints horizontal for var_avg to mtm_avg
            
            # bowtie decision for sixth and seventh bowtie plot
            $bowtie_type_sixth = ($var_avg < $mtm_avg) ? 'bowtie_left' : 'bowtie_right';
            $bowtie_type_seventh = ($var_avg > $mtm_avg) ? 'bowtie_left' : 'bowtie_right';
            
            # Do the fifth plot:
            $plot->SetPlotType('linepoints');
            $plot->SetPointShape($bowtie_type_sixth);
            $plot->SetPointSize($line_point_size);
            $plot->SetDataValues($data5);
            $plot->SetDataColors(array('black'));
            $plot->DrawGraph(); //plot linepoints for var_avg , single point plot    
            
            # Do the sixth plot:
            $plot->SetPlotType('linepoints');
            $plot->SetPointShape($bowtie_type_seventh);
            $plot->SetPointSize($line_point_size);
            $plot->SetDataValues($data6);
            $plot->SetDataColors(array('black'));
            $plot->DrawGraph(); //plot linepoints for mtm_avg , single point plot
        }
               
        #Do the seventh main bell curve plot
        
        //area, bars, bubbles, candlesticks, candlesticks2, linepoints, lines, ohlc, pie, points, squared, stackedarea, stackedbars, thinbarline
        $plot->SetPlotType('lines');
        $plot->SetDataValues($data);
        $plot->SetCallback( 'draw_all', 
                            'write_text', 
                            array(  'object_plot' => $plot, 
                                    'world_x' => ($mtm_avg + $var_avg) / 2, 
                                    'world_y' => $maximum_pdf_var / 2)
                                    );
        $plot->DrawGraph(); //plot main bell curve
        
        # Output the image now:
        $plot->PrintImage();
    }
    ob_flush();

    # Draw text '1 Day Var/ PFE'
    function write_text($img, $array_set) {
        $text_color = imagecolorresolve($img, 213, 0, 0);
        $world_x = $array_set['world_x'];
        $world_y = $array_set['world_y'];
        $object_plot = $array_set['object_plot'];
        
        # get device x and y from world x and y
        list($device_x, $device_y) = $object_plot->GetDeviceXY($world_x, $world_y);
        //echo "mtm_avg = " . $world_x . " :: var_pdf = " . $world_y . " <br/> x = $device_x :: y = $device_y";die();
        $object_plot->DrawText('', 0, $device_x, $device_y - 5, $text_color, DRAWTEXT, 'center', 'bottom');
    }
        
    # Get closest value of array for given value
    function get_closest_value($search, $arr) {
       $closest = null;
       foreach($arr as $item) {
          if($closest == null || abs($search - $closest) > abs($item - $search)) {
             $closest = $item;
          }
       }
       return $closest;
    }
    ?>
</html>
<script type="text/javascript">
</script>