<?php

/**
 * Radial Gauge
 * 
 * @package   
 * @author Pawan Adhikari
 * @copyright Pioneer Solutions Global
 * @version 2012
 * @access public
 */
 class Radial180DegreesNorth {

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
        $pointer_xml .= '<RadialPointer Name="RadialPointer_' . $escaped_name . $name . '">
                            <PointerCap>
                              <Style>
                                <BackgroundColor>White</BackgroundColor>
                                <BackgroundGradientType>DiagonalLeft</BackgroundGradientType>
                                <BackgroundGradientEndColor>DimGray</BackgroundGradientEndColor>
                                <BackgroundHatchType>None</BackgroundHatchType>
                              </Style>
                              <CapImage>
                                <OffsetX>0pt</OffsetX>
                                <OffsetY>0pt</OffsetY>
                                <Source>External</Source>
                                <Value />
                              </CapImage>
                              <OnTop>true</OnTop>
                              <CapStyle>RoundedWithWideIndentation</CapStyle>
                              <Width>20</Width>
                            </PointerCap>
                            <NeedleStyle>Tapered</NeedleStyle>
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
                            <PointerImage>
                              <OffsetX>0pt</OffsetX>
                              <OffsetY>0pt</OffsetY>
                              <Source>External</Source>
                              <Value />
                            </PointerImage>
                            <MarkerLength>25</MarkerLength>
                            <MarkerStyle>Wedge</MarkerStyle>
                            <Placement>Inside</Placement>
                            <Width>10</Width>
                          </RadialPointer>';
        return $pointer_xml . '</GaugePointers>';
    }

    private function build_ranges($ranges) {
        $range_xml = '<ScaleRanges>';
        $secondary = false;
               
        foreach ($ranges as $i=>$range) {
            $range_xml .= $this->buildrange_xml($i, $range['scale_start'], $range['scale_end'],$range['scale_range_color']);
            $secondary = TRUE;
        }
        return $range_xml . '</ScaleRanges>';
    }

    private function buildrange_xml($escaped_name, $min = 0, $max = 100, $color = 'SteelBlue') {
        
        if ($color == '') {
			$color = 'SteelBlue';
		}
        
        $distance_scale = (($secondary ?? FALSE)) ? '<DistanceFromScale>25</DistanceFromScale>' : '';
        return '<ScaleRange Name="RadialRange' . $escaped_name . '">
                    <Style>
                      <Border>
                        <Color>Silver</Color>
                        <Style>Solid</Style>
                      </Border>
                      <BackgroundColor>#ffffff</BackgroundColor>
                      <BackgroundGradientType>DiagonalLeft</BackgroundGradientType>
                      <BackgroundGradientEndColor>' . $color . '</BackgroundGradientEndColor>
                      <BackgroundHatchType>None</BackgroundHatchType>
                      <ShadowOffset>0pt</ShadowOffset>
                    </Style>
                    <BackgroundGradientType>TopBottom</BackgroundGradientType>
                    <DistanceFromScale>25</DistanceFromScale>
                    <StartValue>
                      <Value>' . $min . '</Value>
                      <Multiplier>1</Multiplier>
                    </StartValue>
                    <EndValue>
                      <Value>' . $max . '</Value>
                      <Multiplier>1</Multiplier>
                    </EndValue>
                    <StartWidth>10</StartWidth>
                    <EndWidth>10</EndWidth>
                    <Placement>Inside</Placement>
                  </ScaleRange>';
    }

    private function build_scale() {
        $scale_xml = '<GaugeScales>';
        $secondary = FALSE;
        foreach ($this->scales as $identifier => $scale) {
            if ($scale['scale_interval'] != '' && $scale['scale_maximum'] != '' && $scale['scale_minimum'] != '') {
			$scale_xml .= '<RadialScale Name="RadialScale' . $identifier . '">';
            
            $scale_xml .= '<Radius>54</Radius>
        					<StartAngle>90</StartAngle>
        					<SweepAngle>180</SweepAngle>';
            
            $scale_xml .= ($secondary) ? '<Radius>25</Radius>' : '';
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
                            <Length>18</Length>
                            <Width>2</Width>
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
                            <Length>8</Length>
                            <Width>1</Width>
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
                        </RadialScale>';
            $secondary = TRUE;
        }
		}
        return $scale_xml . '</GaugeScales>';
    }

    private function get_radial_gauge() {
		if(!isset($xml_str))
			$xml_str = '';
        $xml_str .= '<GaugePanel Name="GaugePanel' . $this->name . '">
                        <RadialGauges>
                            <RadialGauge Name="RadialGauge' . $this->name . '">
                            <PivotY>75</PivotY>
                            ';
        $xml_str .= $this->build_scale();
        $xml_str .= '<BackFrame>
                        <Style>
                          <Border>
                            <Style>None</Style>
                          </Border>
                          <BackgroundColor>WhiteSmoke</BackgroundColor>
                          <BackgroundGradientType>DiagonalLeft</BackgroundGradientType>
                          <BackgroundGradientEndColor>Gainsboro</BackgroundGradientEndColor>
                          <BackgroundHatchType>None</BackgroundHatchType>
                          <ShadowOffset>0pt</ShadowOffset>
                        </Style>
                        <FrameStyle>Edged</FrameStyle>
                        <FrameShape>CustomSemiCircularN1</FrameShape>
                        <FrameBackground>
                          <Style>
                            <BackgroundColor>WhiteSmoke</BackgroundColor>
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
                      <ClipContent>true</ClipContent>
                      <TopImage>
                        <Source>External</Source>
                        <Value />
                      </TopImage>
                      <AspectRatio>1</AspectRatio>
                      <Height>90</Height>
                      <Width>100</Width>
                    </RadialGauge>
                  </RadialGauges>
                  
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
		return $this->get_radial_gauge();
	}
    

}