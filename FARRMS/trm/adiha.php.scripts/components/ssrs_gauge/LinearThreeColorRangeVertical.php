<?php

/**
 * Linear Gauge
 * 
 * @package   
 * @author Pawan Adhikari
 * @copyright Pioneer Solutions Global
 * @version 2012
 * @access public
 */
 class LinearThreeColorRangeVertical {

    private $xml_str;
    private $ds_name, $name, $caption;
    private $top, $left, $height, $width, $zindex, $gauge_label_column;
    public $scales, $style;

    public function set_ds_name($ds_name)                { $this->ds_name = $ds_name;                       return $this; }
    public function set_name($name)                      { $this->name = $name;                             return $this; }
    public function set_top($top)                        { $this->top = $top;                               return $this; }
    public function set_left($left)                      { $this->left = $left;                             return $this; }
    public function set_height($height)                  { $this->height = $height;                         return $this; }
    public function set_width($width)                    { $this->width = $width;                           return $this; }
    public function set_zindex($zindex)                  { $this->zindex = $zindex;                         return $this; }
    public function set_gauge_label($gauge_label_column) { $this->gauge_label_column = $gauge_label_column; return $this; }
    public function set_scales($scales)                  { $this->scales = $scales;                         return $this; }
    public function set_style($style)                    { $this->style = $style;                           return $this; }

    /**
     * 
     * @param type $name DB Column name of dataset selected for the pointer
     * @param type $escaped_name CLS compliant name to make variable out of it
     * @return type
     */
    private function build_pointer($name, $escaped_name) {
        $pointer_xml = '<GaugePointers>';
        //$distance_scale = ($secondary)?'<DistanceFromScale>25</DistanceFromScale>':'';
        $pointer_xml .= '<LinearPointer Name="LinearPointer' . $escaped_name . $name . '">
                            <Thermometer>
                              <Style />
                            </Thermometer>
                            <Style>
                              <Border>
                                <Style>None</Style>
                              </Border>
                              <BackgroundColor>White</BackgroundColor>
                              <BackgroundGradientType>DiagonalLeft</BackgroundGradientType>
                              <BackgroundGradientEndColor>Orange</BackgroundGradientEndColor>
                              <BackgroundHatchType>None</BackgroundHatchType>
                              <ShadowOffset>1pt</ShadowOffset>
                            </Style>
                            <GaugeInputValue>
                              <Value>=First(CDbl(Fields!' . $name . '.Value))</Value>
                              <Multiplier>1</Multiplier>
                            </GaugeInputValue>
                            <DistanceFromScale>18</DistanceFromScale>
                            <PointerImage>
                              <OffsetX>0pt</OffsetX>
                              <OffsetY>0pt</OffsetY>
                              <Source>External</Source>
                              <Value />
                            </PointerImage>
                            <MarkerLength>12</MarkerLength>
                            <MarkerStyle>Wedge</MarkerStyle>
                            <Placement>Outside</Placement>
                            <Width>12</Width>
                          </LinearPointer>';
        return $pointer_xml . '</GaugePointers>';
    }

    private function build_ranges($ranges) {
        $range_xml = '<ScaleRanges>';
        $secondary = false;
        
        foreach ($ranges as $range) {
            $range_xml .= $this->buildrange_xml($range['name'], $range['scale_start'], $range['scale_end'], $range['scale_range_color']);
            $secondary = TRUE;
        }
        return $range_xml . '</ScaleRanges>';
    }

    private function buildrange_xml($escaped_name, $min = 0, $max = 100, $color = 'SteelBlue') {
        
        if ($color == '') {
			$color = 'SteelBlue';
		}
        
        return '<ScaleRange Name="LinearRange' . $escaped_name . '">
                    <Style>
                      <Border>
                        <Color>Silver</Color>
                        <Style>None</Style>
                      </Border>
                      <BackgroundColor>' . $color . '</BackgroundColor>
                      <BackgroundGradientType>DiagonalLeft</BackgroundGradientType>
                      <BackgroundGradientEndColor>#ffffff</BackgroundGradientEndColor>
                      <BackgroundHatchType>None</BackgroundHatchType>
                      <ShadowOffset>0pt</ShadowOffset>
                    </Style>
                    <BackgroundGradientType>None</BackgroundGradientType>
                    <DistanceFromScale>6</DistanceFromScale>
                    <StartValue>
                      <Value>' . $min . '</Value>
                      <Multiplier>1</Multiplier>
                    </StartValue>
                    <EndValue>
                      <Value>' . $max . '</Value>
                      <Multiplier>1</Multiplier>
                    </EndValue>
                    <StartWidth>15</StartWidth>
                    <EndWidth>15</EndWidth>
                    <Placement>Outside</Placement>
                  </ScaleRange>';
    }

    private function build_scale() {
        $scale_xml = '<GaugeScales>';
        $secondary = FALSE;
        foreach ($this->scales as $identifier => $scale) {
        	if ($scale['scale_interval'] != '' && $scale['scale_maximum'] != '' && $scale['scale_minimum'] != '') {
                $scale_xml .= '<LinearScale Name="LinearScale' . $identifier . '">
                                <StartMargin>10</StartMargin>
                                    <Position>40</Position>';
                $scale_xml .= $this->build_pointer(preg_replace('/[^\w]/', '_', $scale['column_name']), $identifier ); #TODO var pointing
                $scale_xml .= $this->build_ranges($scale['ranges']);
                $scale_xml .= '<Style>
                                <Border>
                                  <Style>None</Style>
                                </Border>
                                <BackgroundColor>CornflowerBlue</BackgroundColor>
                                <BackgroundGradientType>None</BackgroundGradientType>
                                <BackgroundGradientEndColor>White</BackgroundGradientEndColor>
                                <BackgroundHatchType>None</BackgroundHatchType>
                                <ShadowOffset>0pt</ShadowOffset>
                              </Style>
                              <Interval>' . $scale['scale_interval'] . '</Interval>
                              <IntervalOffset>NaN</IntervalOffset>
                              <MaximumValue>
                                <Value>' . $scale['scale_maximum'] . '</Value>
                                <Multiplier>1</Multiplier>
                              </MaximumValue>
                              <MinimumValue>
                                <Value>' . $scale['scale_minimum'] . '</Value>
                                <Multiplier>1</Multiplier>
                              </MinimumValue>
                              <GaugeMajorTickMarks>
                                <Interval>NaN</Interval>
                                <IntervalOffset>NaN</IntervalOffset>
                                <Style>
                                  <Border>
                                    <Color>DimGray</Color>
                                    <Style>None</Style>
                                  </Border>
                                  <BackgroundColor>DimGray</BackgroundColor>
                                </Style>
                                <Placement>Cross</Placement>
                                <TickMarkImage>
                                  <Source>External</Source>
                                  <Value />
                                </TickMarkImage>
                                <Length>10</Length>
                                <Width>3</Width>
                              </GaugeMajorTickMarks>
                              <GaugeMinorTickMarks>
                                <Interval>NaN</Interval>
                                <IntervalOffset>NaN</IntervalOffset>
                                <Style>
                                  <Border>
                                    <Color>DimGray</Color>
                                    <Style>None</Style>
                                  </Border>
                                  <BackgroundColor>DimGray</BackgroundColor>
                                </Style>
                                <Placement>Cross</Placement>
                                <TickMarkImage>
                                  <Source>External</Source>
                                  <Value />
                                </TickMarkImage>
                                <Length>6</Length>
                                <Width>2</Width>
                              </GaugeMinorTickMarks>
                              <MaximumPin>
                                <PinLabel>
                                  <Style>
                                    <FontSize>12pt</FontSize>
                                  </Style>
                                  <DistanceFromScale>0</DistanceFromScale>
                                </PinLabel>
                                <Style>
                                  <Border>
                                    <Color>DimGray</Color>
                                    <Style>Solid</Style>
                                  </Border>
                                  <BackgroundColor>WhiteSmoke</BackgroundColor>
                                </Style>
                                <Placement>Cross</Placement>
                                <TickMarkImage>
                                  <Source>External</Source>
                                  <Value />
                                </TickMarkImage>
                                <Length>6</Length>
                                <Width>6</Width>
                                <Shape>Circle</Shape>
                              </MaximumPin>
                              <MinimumPin>
                                <PinLabel>
                                  <Style>
                                    <FontSize>12pt</FontSize>
                                  </Style>
                                  <DistanceFromScale>0</DistanceFromScale>
                                </PinLabel>
                                <Style>
                                  <Border>
                                    <Color>DimGray</Color>
                                    <Style>Solid</Style>
                                  </Border>
                                  <BackgroundColor>WhiteSmoke</BackgroundColor>
                                </Style>
                                <Placement>Cross</Placement>
                                <TickMarkImage>
                              <Source>External</Source>
                              <Value />
                            </TickMarkImage>
                            <Length>6</Length>
                            <Width>6</Width>
                            <Shape>Circle</Shape>
                            </MinimumPin>
                          <ScaleLabels>'
                    
                            . $this->style . '
                            
                                <Interval>NaN</Interval>
                                <IntervalOffset>NaN</IntervalOffset>
                                <DistanceFromScale>0</DistanceFromScale>
                                <RotateLabels>true</RotateLabels>
                                <ShowEndLabels>true</ShowEndLabels>
                                <UseFontPercent>true</UseFontPercent>
                              </ScaleLabels>
                              <Width>0</Width>
                            </LinearScale>';
            $secondary = TRUE;
            }
	   }
       return $scale_xml . '</GaugeScales>';
    }

    public function get_linear_gauge() {
        $xml_str .= '<GaugePanel Name="GaugePanel' . $this->name . '">
                        <LinearGauges>
                            <LinearGauge Name="LinearGauge' . $this->name . '">';
        //$xml_str .= '<Orientation>Vertical</Orientation>';                                
        $xml_str .= $this->build_scale();
        $xml_str .= '<BackFrame>
                        <Style>
                          <Border>
                            <Style>None</Style>
                          </Border>
                          <BackgroundColor>WhiteSmoke</BackgroundColor>
                          <BackgroundGradientType>HorizontalCenter</BackgroundGradientType>
                          <BackgroundGradientEndColor>DarkGray</BackgroundGradientEndColor>
                          <BackgroundHatchType>None</BackgroundHatchType>
                          <ShadowOffset>0pt</ShadowOffset>
                        </Style>
                        <FrameStyle>Edged</FrameStyle>
                        <FrameShape>RoundedRectangular</FrameShape>
                        <FrameBackground>
                          <Style>
                            <BackgroundColor>Gainsboro</BackgroundColor>
                            <BackgroundGradientType>DiagonalLeft</BackgroundGradientType>
                            <BackgroundGradientEndColor>WhiteSmoke</BackgroundGradientEndColor>
                            <BackgroundHatchType>None</BackgroundHatchType>
                          </Style>
                        </FrameBackground>
                        <FrameImage>
                          <Source>External</Source>
                          <Value />
                        </FrameImage>
                      </BackFrame>
                      <ClipContent>true</ClipContent>
                      <TopImage>
                        <Source>External</Source>
                        <Value />
                      </TopImage>
                      <AspectRatio>NaN</AspectRatio>
                      <Height>90</Height>
                      <Width>100</Width>
                    </LinearGauge>
                  </LinearGauges>
                  
                  <GaugeLabels>
                    <GaugeLabel Name="GaugeLabel2">
                        <Text>=First(Fields!' . $this->gauge_label_column . '.Value, "' . $this->ds_name . '")</Text>
                        <UseFontPercent>true</UseFontPercent>
                        <Style>
                          <Border>
                            <Style>None</Style>
                          </Border>
                          <BackgroundColor>#ffffff</BackgroundColor>
                          <BackgroundGradientType>None</BackgroundGradientType>
                          <BackgroundGradientEndColor>#ffffff</BackgroundGradientEndColor>
                          <FontSize>8pt</FontSize>
                          <TextAlign>Center</TextAlign>
                          <Color>#404040</Color>
                          <ShadowOffset>0pt</ShadowOffset>
                        </Style>
                        <Top>90</Top>
                        <Left>2</Left>
                        <Height>10</Height>
                        <Width>90</Width>
                    </GaugeLabel>
                 </GaugeLabels>
                 
                  <BackFrame>
                    <Style>
                      <Border>
                        <Style>None</Style>
                      </Border>
                      <BackgroundColor>Gainsboro</BackgroundColor>
                      <BackgroundGradientType>DiagonalLeft</BackgroundGradientType>
                      <BackgroundGradientEndColor>Gray</BackgroundGradientEndColor>
                      <BackgroundHatchType>None</BackgroundHatchType>
                      <ShadowOffset>0pt</ShadowOffset>
                    </Style>
                    <FrameBackground>
                      <Style>
                        <BackgroundColor>Silver</BackgroundColor>
                        <BackgroundGradientType>DiagonalLeft</BackgroundGradientType>
                        <BackgroundGradientEndColor>Gray</BackgroundGradientEndColor>
                        <BackgroundHatchType>None</BackgroundHatchType>
                      </Style>
                    </FrameBackground>
                    <FrameImage>
                      <Source>External</Source>
                      <Value />
                    </FrameImage>
                  </BackFrame>
                  <TopImage>
                    <Source>External</Source>
                    <Value />
                  </TopImage>
                  <DataSetName>' . $this->ds_name . '</DataSetName>
                  <Top>' . $this->top . '</Top>
                  <Left>' . $this->left . '</Left>
                  <Height>' . $this->height . '</Height>
                  <Width>' . $this->width . '</Width>
                  <ZIndex>1</ZIndex>
                  <Style>
                    <Border>
                      <Style>None</Style>
                    </Border>
                    <BackgroundColor>White</BackgroundColor>
                  </Style>
                </GaugePanel>';
        return $xml_str;
    }

    public function get_gauge_rdl() {
		return $this->get_linear_gauge();
	}	

}