<?php

    /**
	 *  @brief ChartCommon
	 * 
	 *  @par Description
	 *  This class handles to construct all common chart property values on RDL
	 *  @copyright Pioneer Solutions
	 */
    class ChartCommon {
        
        public $chart_com_xml;
        public function __construct($ds_name, $caption, $top, $left, $width, $height, $zindex, $y_axis_caption, $x_axis_caption, $page_break, $is_3d = '', $is_tick_marks_enabled = true) {
		
            //$caption = ucwords(strtolower(str_replace('_', ' ', $caption)));
		
            $this->chart_com_xml = '
    	               <ChartAreas>
                            <ChartArea Name="Default">
                    		<ChartCategoryAxes>
                                    <ChartAxis Name="Primary">
                                        
                                        <StyleXAxisReplaceText>                                          
                                        
                                        <ChartAxisTitle>
                                            <Caption>' . $x_axis_caption . '</Caption> 
                                        </ChartAxisTitle>
                                        <Margin>False</Margin>
                                        <Interval>1</Interval>
                                        <ChartMajorGridLines>
                                        <Enabled>False</Enabled>
                                        <Style>
                                            <Border>
                                                <Color>Gainsboro</Color>
                                            </Border>
                                        </Style>
                                        </ChartMajorGridLines>
                                        <ChartMinorGridLines>
                                            <Style>
                                                <Border>
                                                    <Color>Gainsboro</Color>
                                                    <Style>Dotted</Style>
                                                </Border>
                                            </Style>
                                        </ChartMinorGridLines>
                                        <ChartMinorTickMarks>
                                        ' . $this->set_tick_marks($is_tick_marks_enabled) . 
                                        '</ChartMinorTickMarks>
                                        <CrossAt>NaN</CrossAt>
                                        <Minimum>NaN</Minimum>
                                        <Maximum>NaN</Maximum>
                                        <PreventLabelOffset>true</PreventLabelOffset>
                                        <IncludeZero>false</IncludeZero>
                                    </ChartAxis>
                                    <ChartAxis Name="Secondary">
                                        <Style>
                                                <FontSize>8pt</FontSize>
                                        </Style>
                                        <ChartAxisTitle>
                                            <Caption>Axis Title</Caption>
                                            <Style>
                                                <FontSize>8pt</FontSize>
                                            </Style>
                                        </ChartAxisTitle>
                                        <ChartMajorGridLines>
                                            <Enabled>False</Enabled>
                                            <Style>
                                                <Border>
                                                    <Color>Gainsboro</Color>
                                                </Border>
                                            </Style>
                                        </ChartMajorGridLines>
                                        <ChartMinorGridLines>
                                            <Style>
                                                <Border>
                                                    <Color>Gainsboro</Color>
                                                    <Style>Dotted</Style>
                                                </Border>
                                            </Style>
                                        </ChartMinorGridLines>
                                        <ChartMinorTickMarks>
                                            <Length>0.5</Length>
                                        </ChartMinorTickMarks>
                                        <CrossAt>NaN</CrossAt>
                                        <Location>Opposite</Location>
                                        <Minimum>NaN</Minimum>
                                        <Maximum>NaN</Maximum>
                                    </ChartAxis>
                    		</ChartCategoryAxes>
                    		<ChartValueAxes>
                                    <ChartAxis Name="Primary">
                                        
                                        <StyleYAxisReplaceText>
                                        
                                        <ChartAxisTitle>
                                            <Caption>' . $y_axis_caption . '</Caption>  
                                        </ChartAxisTitle>
                                        <ChartMajorGridLines>
                                            <Style>
                                                <Border>
                                                    <Color>Gainsboro</Color>
                                                </Border>
                                            </Style>
                                        </ChartMajorGridLines>
                                        <ChartMinorGridLines>
                                            <Style>
                                                <Border>
                                                    <Color>Gainsboro</Color>
                                                    <Style>Dotted</Style>
                                                </Border>
                                            </Style>
                                        </ChartMinorGridLines>
                                        <ChartMinorTickMarks>' 
                                        . (($is_tick_marks_enabled == false) ? '<Enabled>True</Enabled>' : '') . 
                                        '<Length>0.25</Length>
                                        </ChartMinorTickMarks>
                                        <CrossAt>NaN</CrossAt>
                                        <Minimum>NaN</Minimum>
                                        <Maximum>NaN</Maximum>
                                        <IncludeZero>false</IncludeZero>
                                        <MaxFontSize>8pt</MaxFontSize>
                                    </ChartAxis>
                                    <ChartAxis Name="Secondary">
                                        <Style>
                                            <FontSize>8pt</FontSize>
                                        </Style>
                                        <ChartAxisTitle>
                                            <Caption>Axis Title</Caption>
                                            <Style>
                                                <FontSize>8pt</FontSize>
                                            </Style>
                                        </ChartAxisTitle>
                                        <ChartMajorGridLines>
                                            <Style>
                                                <Border>
                                                    <Color>Gainsboro</Color>
                                                </Border>
                                            </Style>
                                        </ChartMajorGridLines>
                                        <ChartMinorGridLines>
                                            <Style>
                                                <Border>
                                                    <Color>Gainsboro</Color>
                                                    <Style>Dotted</Style>
                                                </Border>
                                            </Style>
                                        </ChartMinorGridLines>
                                        <ChartMinorTickMarks>
                                                <Length>0.5</Length>
                                        </ChartMinorTickMarks>
                                        <CrossAt>NaN</CrossAt>
                                        <Location>Opposite</Location>
                                        <Minimum>NaN</Minimum>
                                        <Maximum>NaN</Maximum>
                                    </ChartAxis>
                    		</ChartValueAxes>
                            ' . $is_3d . '                        
                    		<Style>
                                    <BackgroundGradientType>None</BackgroundGradientType>
                    		</Style>
                    	</ChartArea>
                    </ChartAreas>                    
                    <ChartLegends>
                    	<ChartLegend Name="Default">
                            
                            <StyleZAxisReplaceText>

                            <Position>TopCenter</Position>
                            <ChartLegendTitle>
                                <Caption />
                                <Style>
                                    <FontSize>8pt</FontSize>
                                    <FontWeight>Bold</FontWeight>
                                    <TextAlign>Center</TextAlign>
                                </Style>
                            </ChartLegendTitle>
                            <HeaderSeparatorColor>Black</HeaderSeparatorColor>
                            <ColumnSeparatorColor>Black</ColumnSeparatorColor>
                    	</ChartLegend>
                    </ChartLegends>
                    <ChartTitles>
                    	<ChartTitle Name="Default">
                            <Caption>=First(Fields!'.preg_replace("/[^\w]/","_",$caption).'.Value, "Dataset_header")</Caption>
							<Style>
                                <BackgroundGradientType>None</BackgroundGradientType>
                                <FontWeight>Bold</FontWeight>
                                <TextAlign>General</TextAlign>
                                <VerticalAlign>Top</VerticalAlign>
                            </Style>
                    	</ChartTitle>
                    </ChartTitles>
                    <Palette>BrightPastel</Palette>
                    <ChartBorderSkin>
                    	<Style>
                            <BackgroundColor>Gray</BackgroundColor>
                            <BackgroundGradientType>None</BackgroundGradientType>
                            <Color>White</Color>
                    	</Style>
                    </ChartBorderSkin>
                    <ChartNoDataMessage Name="NoDataMessage">
                    	<Caption>=First(Fields!No_Data_Available.Value, "Dataset_header")</Caption>
                    	<Style>
                            <BackgroundGradientType>None</BackgroundGradientType>
                            <TextAlign>General</TextAlign>
                            <VerticalAlign>Top</VerticalAlign>
                    	</Style>
                    </ChartNoDataMessage>
                    <DataSetName>' . $ds_name . '</DataSetName>    
                    <Top>' . $top . '</Top>
                    <Left>' . $left . '</Left>
                    <Height>' . $height . '</Height>
                    <Width>' . $width . '</Width>
                    <ZIndex>' . $zindex . '</ZIndex>
                    <Style>
                    	<Border>
                            <Color>LightGrey</Color>
                            <Style>None</Style>
                            <Width>0.25pt</Width>
                    	</Border>
                    	<BackgroundColor>White</BackgroundColor>
                    	<BackgroundGradientType>None</BackgroundGradientType>
                    </Style>
                ';
               
            if ($page_break > 0) {
                switch($page_break) {
                    case '1': $this->chart_com_xml .= '<PageBreak><BreakLocation>Start</BreakLocation></PageBreak>'; break;
                    case '2': $this->chart_com_xml .= '<PageBreak><BreakLocation>End</BreakLocation></PageBreak>'; break;
                    case '3': $this->chart_com_xml .= '<PageBreak><BreakLocation>StartAndEnd</BreakLocation></PageBreak>'; break;
                }
            }
        }
        
        /**
         * constructs tick mark enabled property
         *
         * @param   String  $is_tick_marks_enabled  Boolean value for tick marks enabled. 
         *
         * @return  string    returns xml string of tick mark enabled property
         */
        public function set_tick_marks($is_tick_marks_enabled) {
            if ($is_tick_marks_enabled == false) {
                return '<Length>0.5</Length>';
            } else {        
                return '<Enabled>True</Enabled>
                        <Style>
                            <Border>
                              <Width>1.25pt</Width>
                            </Border>
                        </Style>
                        <Length>0.25</Length>
                        <Interval>5</Interval>';
            }
        }
        
        /**
         * gets build chart common rdl xml.
         *
         * @return  string  returns common property rdl string xml
         */
        public function __toString(){
            return $this->chart_com_xml;
        }        
    } 
?>