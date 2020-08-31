<?php

	/**
	 *  @brief Pie3d shape chart type
	 *
	 *  @par Description
	 *  This class handles shape chartype : Doughnut
	 *  @copyright Pioneer Solutions
	 */
	class Pie3d implements iChart {
	   
        private $xml_str;
        private $ds_name, $name, $caption;
        private $top, $left, $height, $width, $zindex, $page_break;
        private $members, $groups, $series, $y_axis_caption, $x_axis_caption;
		
        /**
		 * sets data source name
		 *
		 * @param   string  $dsName  data source name
		 *
		 * @return  object           returns class object
		 */
        public function set_ds_name($dsName) 		            { $this->ds_name = $dsName;                return $this; }        
		
		/**
		 * sets chart name
		 *
		 * @param   string  $name  chart item name
		 *
		 * @return  object         returns class object
		 */
		public function set_name($name)          		        { $this->name = $name;                     return $this; }
		
		/**
		 * sets chart caption 
		 *
		 * @param   string	$caption  chart caption
		 *
		 * @return  object            returns class object
		 */
		public function set_caption($caption)    		        { $this->caption = $caption;               return $this; }
		
		/**
		 * sets chart top position
		 *
		 * @param   string  $top  top position value
		 *
		 * @return  object        returns class object
		 */
		public function set_top($top)            		        { $this->top = $top;                       return $this; }
		
		/**
		 * sets chart left position
		 *
		 * @param   string  $left  left position value
		 *
		 * @return  object         returns class object
		 */
		public function set_left($left)          		        { $this->left = $left;                     return $this; }
		
		/**
		 * sets chart height
		 *
		 * @param   string  $height  height
		 *
		 * @return  object         	 returns class object
		 */
		public function set_height($height)      		        { $this->height = $height;                 return $this; }
		
		/**
		 * sets chart width
		 *
		 * @param   string  $width  width
		 *
		 * @return  object         	 returns class object
		 */
		public function set_width($width)        		        { $this->width = $width;                   return $this; }
		
		/**
		 * sets zindex
		 *
		 * @param   string  $zindex  zindex value
		 *
		 * @return  object         	 returns class object
		 */
		public function set_zindex($zindex)      		        { $this->zindex = $zindex;                 return $this; }
		
		/**
		 * sets chart members
		 *
		 * @param   array  $members  members
		 *
		 * @return  object         	 returns class object
		 */
		public function set_members($members)    		        { $this->members = $members;               return $this; }
		
		/**
		 * sets chart series
		 *
		 * @param   string  $series  series xml string
		 *
		 * @return  object         	 returns class object
		 */
		public function set_series($series)      		        { $this->series = $series;                 return $this; }
		
		/**
		 * sets chart groups
		 *
		 * @param   string  $groups  groups xml string
		 *
		 * @return  object           returns class object
		 */
		public function set_groups($groups)      		        { $this->groups = $groups;                 return $this; }
		
		/**
		 * sets sorts
		 *
		 * @param   array  $sorts  array of sorts
		 *
		 * @return  object           returns class object
		 */
		public function set_sorts($sorts)      		        	{ $this->sorts = $sorts;                   return $this; }
		
		/**
		 * sets y axis caption
		 *
		 * @param   string  $y_axis_caption  y axis caption
		 *
		 * @return  object                   returns class object
		 */
		public function set_y_axis_caption($y_axis_caption) 	{ $this->y_axis_caption = $y_axis_caption; return $this; }
		
		/**
		 * sets x axis caption
		 *
		 * @param   string  $x_axis_caption  x axis caption
		 *
		 * @return  object                   returns class object
		 */
		public function set_x_axis_caption($x_axis_caption) 	{ $this->x_axis_caption = $x_axis_caption; return $this; }
		
		/**
		 * sets page break
		 *
		 * @param   string  $page_break  page break value
		 *
		 * @return  object                   returns class object
		 */
		public function set_page_break($page_break) 	        { $this->page_break = $page_break;         return $this; }         
        
        /**
		 * builds chart members hierarchy xml
		 *
		 * @param   string  $name        group name
		 * @param   string  $identifier  unique identifier
		 *
		 * @return  string               xml string for ChartMembers
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
		 * builds group hierarchy xml
		 *
		 * @param   string  $name        group name
		 * @param   string  $identifier  unique identifier
		 *
		 * @return  string               xml string for ChartMembers
		 */
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
        
        /**
		 * builds chart members
		 *
		 * @param   array  $members  array of members
		 *
		 * @return  string            xml string for ChartMembers
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
		 * builds chart groups
		 *
		 * @param   array  $groups  array of groups
		 *
		 * @return  string           xml string for ChartMembers
		 */
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
        
        /**
		 * builds chart series
		 *
		 * @param   array  $series  array of series
		 *
		 * @return  string           xml string for ChartSeries
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
                                                <Y>=iif(Sum(CDbl(Fields!' . $val . '.Value))>0,Sum(CDbl(Fields!' . $val . '.Value)),"")</Y>
                                            </ChartDataPointValues>
                                            <ChartDataLabel>
                                                <Style />
                                                <Label>#PERCENT</Label>
                                                <Visible>true</Visible>
                                            </ChartDataLabel>
                                            <Style />
                                                <ChartMarker>
                                            <Style />
                                            </ChartMarker>
                                            <DataElementOutput>Output</DataElementOutput>
                                            </ChartDataPoint>
                                        </ChartDataPoints>
                                        <Type>Shape</Type>
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
                            
                                        <CustomProperties>
            								<CustomProperty>
            									<Name>PieLineColor</Name>
            									<Value>Black</Value>
            								</CustomProperty>
            								<CustomProperty>
            									<Name>PieLabelStyle</Name>
            									<Value>Outside</Value>
            								</CustomProperty>
            								<CustomProperty>
            									<Name>MinimumRelativePieSize</Name>
            									<Value>70</Value>
            								</CustomProperty>
            							</CustomProperties>
                                        
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
		 * builds Pie3d chart
		 *
		 * @return  string  xml string for Pie3d chart
		 */
		private function build_pie3d_chart() {
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
        
        /**
		 * gets chart rdl string
		 *
		 * @return  string  returns Pie3d chart rdl string
		 */
        public function get_chart_rdl() {
			return $this->build_pie3d_chart();
		}	  
	}

?>