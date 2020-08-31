<?php

	/**
    *  @brief Scatter
    *
    *  @par Description
    *  This Class includes Scatter Chart Generation implmenting iChart Interface.
    *  @copyright Pioneer Solutions
    */
	class Scatter implements iChart {
	   
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
		public function set_sorts($sorts)      		        	{ $this->sorts = $sorts;				   return $this; }
        public function set_y_axis_caption($y_axis_caption) 	{ $this->y_axis_caption = $y_axis_caption; return $this; }
        public function set_x_axis_caption($x_axis_caption) 	{ $this->x_axis_caption = $x_axis_caption; return $this; }
        public function set_page_break($page_break) 	        { $this->page_break = $page_break;         return $this; }        
		
		/**
		 * Build Member Hierarchy XML Block
		 *
		 * @param   String  $name        Group Name
		 * @param   String  $identifier  Identifier
		 *
		 * @return  XML               Chart Members XML Block
		 */
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
		
		/**
		 * Build Group Hierarchy XML Block
		 *
		 * @param   String  $name        Group Name
		 * @param   String  $identifier  Identifier
		 * @param   String  $sort_name  Soring order
		 *
		 * @return  XML               Group Chart Members XML Block
		 */
        private function build_group_hierarchy_xml($name, $identifier, $sort_name) {
			$name = str_replace('_Key', '', $name);
			$name = str_replace('_key', '', $name);			
			$sort_arr = explode('||', $sort_name);
			$sort_nm = $sort_arr[0];
			$sort_dir = (($sort_arr[1] ?? '') == 1) ? 'Ascending' : 'Descending';
			
			$return = '<ChartMembers>
            			<ChartMember>
            				<Group Name="' . $this->name . 'ChartMemberGroup_' . $identifier . '_' . $name . '">
            					<GroupExpressions>
            						<GroupExpression>=Fields!' . $name . '.Value</GroupExpression>
            					</GroupExpressions>
            				</Group>';
			if (count($sort_arr) > 0 && $sort_nm != '') {
				$return .= '<SortExpressions>
								<SortExpression>
								  <Value>=Fields!'.$sort_nm.'.Value</Value>
								  <Direction>'.$sort_dir.'</Direction>
								</SortExpression>
						  </SortExpressions>';
			}
					
			$return .= '				
            				<ChartMembers></ChartMembers>
            				<Label>=Fields!' . $name . '.Value</Label>
            			</ChartMember>
            		</ChartMembers>'; 
			return $return;
        }
        
        /**
		 * Build Chart Member XML Block
		 *
		 * @param   Array  $members  Members List
		 *
		 * @return  XML            List of ChartMembers to be enclosed inside ChartMembers Block
		 */
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
					$member_xml .= '<ChartMember><Label>=First(Fields!'.preg_replace("/[^\w]/","_",$member).'.Value, "Dataset_header")</Label></ChartMember>';
                    $iterate++;
                }                
                $member_xml = '<ChartMembers>' . $member_xml . '</ChartMembers>';                
            }
            return $member_xml;
		}
		
		/**
		 * Build Groups
		 *
		 * @param   Array  $groups  Group List
		 * @param   String  $sorts  Sorting Order
		 *
		 * @return  XML           XML Group Format
		 */
        private function build_groups($groups, $sorts) {
    		$group_xml = NULL;            
            if (count($groups) > 0) {   
				$total_series = sizeof($groups);
            	foreach ($groups as $sn => $node) {
            		if ($sn == 0) {
            			$group_xml .= $this->build_group_hierarchy_xml($node, $sn, ($sorts[$sn] ?? ''));
            		} else {
            			$xml_partial = $this->build_group_hierarchy_xml($node, $sn, ($sorts[$sn] ?? ''));
            			$group_xml = str_replace('<ChartMembers></ChartMembers>', $xml_partial, $group_xml); 
            		}
            		if ($total_series == ($sn + 1)) {
            			$group_xml = str_replace('<ChartMembers></ChartMembers>', '', $group_xml); 
            		}
            	}               
            }
        	return $group_xml;	
		}
		
		/**
		 * Build ChartSeries XML Block
		 *
		 * @param   Array  $series  Series Information
		 *
		 * @return  XML           ChartSeries XML Block
		 */
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
    									<Type>Scatter</Type>
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
		
		/**
		 * Build XML of Scatter Chart
		 *
		 * @return  XML  Scatter Chart
		 */
		private function build_scatter_chart() {
            $this->xml_str = '<Chart Name="' . $this->name . '">
                					<ChartCategoryHierarchy>' . $this->build_groups($this->groups, $this->sorts) . '</ChartCategoryHierarchy>
                					<ChartSeriesHierarchy>' . $this->build_members($this->series) . '</ChartSeriesHierarchy>
                					<ChartData>
                                        <ChartSeriesCollection>' . $this->build_series($this->members) . '</ChartSeriesCollection>
                                    </ChartData>';                    
            
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
                                        $this->page_break
                                    );
            
            $this->xml_str .= '</Chart>';              
            
            return $this->xml_str;                    
		} 
		
		/**
		 * Get Scatter Chart RDL
		 *
		 * @return  XML  Scatter Chart XML Block
		 */
        public function get_chart_rdl() {
			return $this->build_scatter_chart();
		}	  
	}

?>