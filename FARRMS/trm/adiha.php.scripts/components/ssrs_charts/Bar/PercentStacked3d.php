<?php

	/*
	 * PercentStacked3d
	 * 
	 * @package   
	 * @author Pawan Adhikari
	 * @copyright Pioneer Solutions Global
	 * @version 2012
	 * @access public
	 */
	class PercentStacked3d implements iChart {	   
        private $xml_str;
        private $ds_name, $name, $caption;
        private $top, $left, $height, $width, $zindex, $page_break;
        private $members, $groups, $series, $y_axis_caption, $x_axis_caption;
		
        public function set_ds_name($dsName) 		            { $this->ds_name = $dsName;                return $this; }        
        public function set_name($name)          		        { $this->name = $name;                     return $this; }
        public function set_caption($caption)    		        { $this->caption = $caption;               return $this; }
        public function set_top($top)            		        { $this->top = $top;                       return $this; }
        public function set_left($left)          		        { $this->left = $left;                     return $this; }
        public function set_height($height)      		        { $this->height = $height;                 return $this; }
        public function set_width($width)        		        { $this->width = $width;                   return $this; }
        public function set_zindex($zindex)      		        { $this->zindex = $zindex;                 return $this; }
        public function set_members($members)    		        { $this->members = $members;               return $this; }
        public function set_series($series)      		        { $this->series = $series;                 return $this; }
        public function set_groups($groups)      		        { $this->groups = $groups;                 return $this; }
        public function set_y_axis_caption($y_axis_caption) 	{ $this->y_axis_caption = $y_axis_caption; return $this; }
        public function set_x_axis_caption($x_axis_caption) 	{ $this->x_axis_caption = $x_axis_caption; return $this; }
        public function set_page_break($page_break) 	        { $this->page_break = $page_break;         return $this; }  
        
        private function build_member_hierarchy_xml($name, $identifier) {
        	return '<ChartMembers>
            			<ChartMember>
            				<Group Name="' . $this->name . 'ChartMemberSeries_' . $identifier . '_' . $name . '">
            					<GroupExpressions>
            						<GroupExpression>=Fields!' . $name . '.Value</GroupExpression>
            					</GroupExpressions>
            				</Group>
            				<ChartMembers></ChartMembers>
            				<Label>=Fields!' . $name . '.Value</Label>
            			</ChartMember>
            		</ChartMembers>'; 
        }
        
        private function build_group_hierarchy_xml($name, $identifier) {
			$name = str_replace('_Key', '', $name);
			$name = str_replace('_key', '', $name);			
			return '<ChartMembers>
            			<ChartMember>
            				<Group Name="' . $this->name . 'ChartMemberGroup_' . $identifier . '_' . $name . '">
            					<GroupExpressions>
            						<GroupExpression>=Fields!' . $name . '.Value</GroupExpression>
            					</GroupExpressions>
            				</Group>
            				<ChartMembers></ChartMembers>
            				<Label>=Fields!' . $name . '.Value</Label>
            			</ChartMember>
            		</ChartMembers>'; 
        }
        
        private function build_members($members) {
		  	$member_xml = '<ChartMember/>';            
            if (count($members) > 0) {
                $member_xml = NULL;
                $total_series = sizeof($members);
            	foreach ($members as $sn => $node) {
            		if ($sn == 0) {
            			$member_xml .= $this->build_member_hierarchy_xml($node, $sn);
            		} else {
            			$xml_partial = $this->build_member_hierarchy_xml($node, $sn);
            			$member_xml = str_replace('<ChartMembers></ChartMembers>', $xml_partial, $member_xml); 
            		}
            		if ($total_series == ($sn + 1)) {
            			$member_xml = str_replace('<ChartMembers></ChartMembers>', '', $member_xml); 
            		}
            	}
            } else {
                $member_xml = NULL;
                $iterate = 1;
                foreach($this->members as $member) {		
					$member_xml .= '<ChartMember><Label>' . $member . '</Label></ChartMember>';
                    $iterate++;
                }
                $member_xml = '<ChartMembers>' . $member_xml . '</ChartMembers>';
            }
            return $member_xml;
		}
		
        private function build_groups($groups) {
    	   $group_xml = NULL;            
            if (count($groups) > 0) {        
				$total_series = sizeof($groups);
            	foreach ($groups as $sn => $node) {
            		if ($sn == 0) {
            			$group_xml .= $this->build_group_hierarchy_xml($node, $sn);
            		} else {
            			$xml_partial = $this->build_group_hierarchy_xml($node, $sn);
            			$group_xml = str_replace('<ChartMembers></ChartMembers>', $xml_partial, $group_xml); 
            		}
            		if ($total_series == ($sn + 1)) {
            			$group_xml = str_replace('<ChartMembers></ChartMembers>', '', $group_xml); 
            		}
            	}               
            }
        	return $group_xml;	
		}
		
        private function build_series($series) {
            $series_xml = NULL;
			$count = 0;
			foreach ($series as $val) {			
				if ($count < 1) {			
					$series_xml .= '<ChartSeries Name="' . $val . '">
    									<ChartDataPoints>
    										<ChartDataPoint>
    										<ChartDataPointValues>
    											<Y>=Sum(CDbl(Fields!' . $val . '.Value))</Y>
    										</ChartDataPointValues>
    										<ChartDataLabel>
    											<Style />
    										</ChartDataLabel>
    										<Style />
    											<ChartMarker>
    										<Style />
    										</ChartMarker>
    										<DataElementOutput>Output</DataElementOutput>
    										</ChartDataPoint>
    									</ChartDataPoints>
    									<Type>Bar</Type>
    									<Subtype>PercentStacked</Subtype>
    									<Style />
    										<ChartEmptyPoints>
    									<Style />
    									<ChartMarker>
    										<Style />
    									</ChartMarker>
    									<ChartDataLabel>
    										<Style />
    									</ChartDataLabel>
    									</ChartEmptyPoints>
    									<ValueAxisName>Primary</ValueAxisName>
    									<CategoryAxisName>Primary</CategoryAxisName>
    									<ChartSmartLabel>
    										<CalloutLineColor>Black</CalloutLineColor>
    										<MinMovingDistance>0pt</MinMovingDistance>
    									</ChartSmartLabel>
								    </ChartSeries>';				
            	}	
				$count++;					
            }
            return $series_xml;
		}
		
		private function build_percent_stacked3d_chart(){
            $this->xml_str = '<Chart Name="' . $this->name . '">
                					<ChartCategoryHierarchy>' . $this->build_groups($this->groups) . '</ChartCategoryHierarchy>
                					<ChartSeriesHierarchy>' . $this->build_members($this->series) . '</ChartSeriesHierarchy>
                					<ChartData>
                                        <ChartSeriesCollection>' . $this->build_series($this->members) . '</ChartSeriesCollection>
                                    </ChartData>';
            
            $def_3d = '<ChartThreeDProperties>
                                    <Enabled>true</Enabled>
                                </ChartThreeDProperties>';

            $this->xml_str .= new ChartCommon(
                                        $this->ds_name, 
                                        $this->caption, 
                                        $this->top, 
                                        $this->left, 
                                        $this->width, 
                                        $this->height, 
                                        $this->zindex,
                                        $this->y_axis_caption,
                                        $this->x_axis_caption,
                                        $this->page_break,
                                        $def_3d
									);
                                    
            $this->xml_str .= '</Chart>';
            
            return $this->xml_str;                     
		} 
        
        public function get_chart_rdl() {
			return $this->build_percent_stacked3d_chart();
		}	  
	}

?>