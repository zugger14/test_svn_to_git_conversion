<?php

/**
 * ChartComposite
 * 
 * @package   
 * @author Pawan Adhikari
 * @copyright Pioneer Solutions Global
 * @version 2012
 * @access public
 */
class ChartComposite {
    public static function get_members($members) {
        $xml = '<ChartMembers></ChartMembers>';
        if (!(is_array($members) && count($members) > 0)) {
            return $xml;
        } 
        
        $xml = '<ChartMembers>';
        foreach($members as $i => $member) {
            $xml .= '<ChartMember><Label>' . $member . '</Label></ChartMember>';            
        }
        $xml .= '</ChartMembers>';
        return $xml;
    }
    
    public static function get_series($members) {
        $xml = '';
        if (!(is_array($members) && count($members) > 0)) {
            return $xml;
        } 
        
        foreach($members as $i => $member) {
            $xml .= '<ChartSeries Name="' . $member . '">
                        <ChartDataPoints>
                            <ChartDataPoint>
                                <ChartDataPointValues>
                                    <Y>=Sum(CDbl(Fields!' . $member . '.Value))</Y>
                                </ChartDataPointValues>
                                <ChartDataLabel><Style /></ChartDataLabel>
                                <Style />
                                <ChartMarker><Style /></ChartMarker>
                                <DataElementOutput>Output</DataElementOutput>
                            </ChartDataPoint>
                        </ChartDataPoints>
                        <Type>Line</Type>
                        <Subtype>Smooth</Subtype>
                        <Style />
                        <ChartEmptyPoints>
                                <Style />
                                <ChartMarker><Style /></ChartMarker>
                                <ChartDataLabel><Style /></ChartDataLabel>
                        </ChartEmptyPoints>
                        <ValueAxisName>Primary</ValueAxisName>
                        <CategoryAxisName>Primary</CategoryAxisName>
                        <ChartSmartLabel>
                                <CalloutLineColor>Black</CalloutLineColor>
                                <MinMovingDistance>0pt</MinMovingDistance>
                        </ChartSmartLabel>
                    </ChartSeries>';
        }   
        return $xml;
    }
}

?>