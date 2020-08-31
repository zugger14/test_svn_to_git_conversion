<?php
/**
 *  @brief RDL generation operation
 *
 *  @par Description
 *  This class handles base of RDL generation operation
 *  @copyright Pioneer Solutions
 */
class RDL {

    public $rds_alias = array();
    public $report_name;
    public $arr_rdl;
    public $ssrs_config;
    public $chart_collection_xml = false;
    public $gauge_collection_xml = false;

    /**
     * Init RDL object
     * @param string $report_name
     * @param array $ssrs_config
     */
    public function __construct($report_name = null, $ssrs_config = null) {
        $this->report_name = $report_name;
        $this->ssrs_config = $ssrs_config;
    }

    /**
     * Initialise chart vars; if not already inited
     */
    public function init_chart() {
        if (!$this->chart_collection_xml) {
            $this->chart_collection_xml = ' ';
            if(!isset($this->arr_rdl['Report']['Body']['ReportItems']['Chart']))
                $this->arr_rdl['Report']['Body']['ReportItems']['Chart'] = array();
            $this->arr_rdl['Report']['Body']['ReportItems']['Chart'] = '<Chart>TestChart</Chart>';
        }
    }
    
    /**
     * Initialise chart vars; if not already inited
     */
    public function init_gauge() {
        if (!$this->gauge_collection_xml) {
            $this->gauge_collection_xml = ' ';
            $this->arr_rdl['Report']['Body']['ReportItems']['GaugePanel'] = '<GaugePanel>TestGauge</GaugePanel>';
        }
    }

    /**
     * Sets Base skeletion of array for RDL, Report Params, Dimensions, Datasource 
     * @param int $report_height Height of report
     * @param int $report_width Width of Report
     * @param string $report_hash Report HASH
     */
    public function set_base($report_height, $report_width, $report_hash) {
        $this->arr_rdl = array(
            'Report' => array(
                '@attributes' => array(
                    'xmlns:rd' => 'http://schemas.microsoft.com/SQLServer/reporting/reportdesigner',
                    'xmlns' => 'http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition'
                ),
                'DataSources' => array(
                    'DataSource' => array(
                        '@attributes' => array('Name' => $this->ssrs_config['DATA_SOURCE']),
                        'DataSourceReference' => $this->ssrs_config['DATA_SOURCE'],
                        'rd:DataSourceID' => ($this->ssrs_config['DATA_SOURCE_DSID'] ?? '')
                    ),
                ),
                'DataSets' => '',
                'Body' => array(
                    'ReportItems' => array(),
                    'Height' => $report_height . 'in',
                    'Style' => ''
                ),
                'ReportParameters' => array('ReportParameter' => $this->_set_report_params()),
                'Width' => $report_width . 'in',
                'Page' => array(
                    'LeftMargin' => '0in',
                    'RightMargin' => '0in',
                    'TopMargin' => '0in',
                    'BottomMargin' => '0in',
                    'Style' => ''
                ),
                'Language' => '=Parameters!report_region.Value',
                'ConsumeContainerWhitespace' => true,
                'rd:ReportID' => $report_hash,
                'rd:ReportUnitType' => 'Inch'
            )
        );
    }

    /**
     * Returns base Report Parameters of report-region, paramset-id, global-options and more
     * @return array
     */
    private function _set_report_params() {
        return array(
            array(
                'DataType' => 'Integer',
                'DefaultValue' => array('Values' => array('Value' => 0)),
                'Prompt' => 'Paramset ID',
                '@attributes' => array('Name' => 'paramset_id')
            ),
            array(
                'DataType' => 'String',
                'DefaultValue' => array('Values' => array('Value' => 'NULL')),
                'Prompt' => 'Report Filter',
                '@attributes' => array('Name' => 'report_filter')
            ),
            array(
                'DataType' => 'String',
                'DefaultValue' => array('Values' => array('Value' => $this->ssrs_config['REPORT_REGION'])),
                'Prompt' => 'Region',
                '@attributes' => array('Name' => 'report_region')
            ),
            array(
                'DataType' => 'String',
                'DefaultValue' => array('Values' => array('Value' => 'farrms_admin')),
                'Prompt' => 'runtime_user',
                '@attributes' => array('Name' => 'runtime_user')
            ),
            
            array(
                'DataType' => 'String',
                'DefaultValue' => array('Values' => array('Value' => 'y')),
                'Prompt' => 'is_html',
                '@attributes' => array('Name' => 'is_html')
            ),
            
            array(
                'DataType' => 'String',
                'DefaultValue' => array('Values' => array('Value' => 0)),
                'Prompt' => 'is_refresh',
                '@attributes' => array('Name' => 'is_refresh')
            ),
            
            array(
                'DataType' => 'String',
                'Nullable' => 'true',
                'Prompt' => 'global_currency_format',
                '@attributes' => array('Name' => 'global_currency_format')
            ),
            array(
                'DataType' => 'String',
                'Nullable' => 'true',
                'Prompt' => 'global_date_format',
                '@attributes' => array('Name' => 'global_date_format')
            ),
            array(
                'DataType' => 'String',
                'Nullable' => 'true',
                'Prompt' => 'global_thousand_format',
                '@attributes' => array('Name' => 'global_thousand_format')
            ),
            array(
                'DataType' => 'String',
                'Nullable' => 'true',
                'Prompt' => 'global_rounding_format',
                '@attributes' => array('Name' => 'global_rounding_format')
            ),
			array(
                'DataType' => 'String',
                'Nullable' => 'true',
                'Prompt' => 'global_price_rounding_format',
                '@attributes' => array('Name' => 'global_price_rounding_format')
            ),
			 array(
                'DataType' => 'String',
                'Nullable' => 'true',
                'Prompt' => 'global_volume_rounding_format',
                '@attributes' => array('Name' => 'global_volume_rounding_format')
            ),
			 array(
                'DataType' => 'String',
                'Nullable' => 'true',
                'Prompt' => 'global_amount_rounding_format',
                '@attributes' => array('Name' => 'global_amount_rounding_format')
            ),
            array(
                'DataType' => 'String',
                'Nullable' => 'true',
                'Prompt' => 'global_science_rounding_format',
                '@attributes' => array('Name' => 'global_science_rounding_format')
            ),
            array(
                'DataType' => 'String',
                'Nullable' => 'true',
                'Prompt' => 'global_negative_mark_format',
                '@attributes' => array('Name' => 'global_negative_mark_format')
            ),
			array(
                'DataType' => 'String',
                'DefaultValue' => array('Values' => array('Value' => $this->ssrs_config['REPORT_REGION'])),
                'Prompt' => 'global_number_format_region',
                '@attributes' => array('Name' => 'global_number_format_region')
            )
        );
    }

    /**
     * Adds RDS alias
     * @param string $alias
     */
    public function push_rds_alias($alias) {
        $alias = str_replace(' ', '', $alias);
        array_push($this->rds_alias, preg_replace('/[^\w]/', '_', $alias));
    }

    /**
     * Set RDS Parameters ; works for all tablix's RDS; must be executed at end
     */
    public function set_rds_params() {
        $this->rds_alias = array_unique($this->rds_alias);
		
        foreach ($this->rds_alias as $alias) {
			if (!is_array($this->arr_rdl['Report']['ReportParameters']['ReportParameter'])) {
				$this->arr_rdl['Report']['ReportParameters']['ReportParameter'] = array();
			}
            array_push($this->arr_rdl['Report']['ReportParameters']['ReportParameter'], array(
                'DataType' => 'Integer',
                'DefaultValue' => array('Values' => array('Value' => 0)),
                'Prompt' => 'ItemID for ' . $alias,
                '@attributes' => array('Name' => 'ITEM_' . $alias)
            ));
        }
    }

    /**
     * Adds dataset
     *
     * @param   array  $dataset  Report datasets
     */
    public function push_dataset($dataset) {
        if (!is_array($this->arr_rdl['Report'])) {
            $this->arr_rdl['Report'] = array();
        }
        if (!is_array($this->arr_rdl['Report']['DataSets'])) {
            $this->arr_rdl['Report']['DataSets'] = array();
        }
        if (!isset($this->arr_rdl['Report']['DataSets']['DataSet'])) {
            $this->arr_rdl['Report']['DataSets']['DataSet'] = array();
        }
        array_push($this->arr_rdl['Report']['DataSets']['DataSet'], $dataset);
    }

    /**
     * Adds report items textbox
     *
     * @param   array  $textboxes  Report item textboxs
     */
    public function push_textbox($textboxes) {
		if (!is_array($this->arr_rdl['Report']['Body']['ReportItems'])) {
            $this->arr_rdl['Report']['Body']['ReportItems'] = array();
        }
        if (!isset($this->arr_rdl['Report']['Body']['ReportItems']['Textbox'])) {
            $this->arr_rdl['Report']['Body']['ReportItems']['Textbox'] = array();
		}
        $this->arr_rdl['Report']['Body']['ReportItems']['Textbox'] = $textboxes;
    }

    /**
     * Adds report items line
     *
     * @param   array  $lines  Report item lines
     */
    public function push_line($lines) {
		if (!is_array($this->arr_rdl['Report']['Body']['ReportItems'])) {
            $this->arr_rdl['Report']['Body']['ReportItems'] = array();
		}
		if (!is_array($this->arr_rdl['Report']['Body']['ReportItems']['Line'])) {
            $this->arr_rdl['Report']['Body']['ReportItems']['Line'] = array();
		}
        $this->arr_rdl['Report']['Body']['ReportItems']['Line'] = $lines;
    }

    /**
     * Adds report item image
     *
     * @param   array  $images  Report item images
     */
    public function push_image($images) {
		if (!is_array($this->arr_rdl['Report']['Body']['ReportItems'])) {
            $this->arr_rdl['Report']['Body']['ReportItems'] = array();
		}
        if (!is_array($this->arr_rdl['Report']['Body']['ReportItems']['Image'])) {
            $this->arr_rdl['Report']['Body']['ReportItems']['Image'] = array();
		}
		$this->arr_rdl['Report']['Body']['ReportItems']['Image'] = $images;
    }

    /**
     * Adds report item tablix
     *
     * @param   array  $tablixes  Report item tablixes
     */
    public function push_tablix(array $tablixes) {
        if(is_array($tablixes) && sizeof($tablixes) > 0){
            if (!is_array($this->arr_rdl['Report']['Body']['ReportItems'])) {
                $this->arr_rdl['Report']['Body']['ReportItems'] = array();
            }
            if (!isset($this->arr_rdl['Report']['Body']['ReportItems']['Tablix'])) {
                $this->arr_rdl['Report']['Body']['ReportItems']['Tablix'] = array();
            }
            $this->arr_rdl['Report']['Body']['ReportItems']['Tablix'] = $tablixes;
		}
    }

    /**
     * Adds report item charts
     *
     * @param   string  $chart_xml  Chart XML
     */
    public function push_chart($chart_xml) {
        $this->chart_collection_xml .= $chart_xml;
    }
    
    /**
     * Adds gauge
     *
     * @param   string  $gauge_xml  Gauge XML
     */
    public function push_gauge($gauge_xml) {
        $this->gauge_collection_xml .= $gauge_xml;
    }

    /**
     * Save RDL file
     *
     * @return  string  Return XML
     */
    public function save_rdl() {
        $outfile = $this->ssrs_config['RDL_DIR_LOCAL'] . '\\' . $this->report_name . ".rdl";
        //Finally convert array to XML
        $xml = Array2XML::createXML('Report', $this->arr_rdl);
        $content = $xml->saveXML();
        if ($this->chart_collection_xml) {
            $content = str_replace('<Chart>TestChart</Chart>', $this->chart_collection_xml, $content);
            $content = str_replace('<Chart>&lt;Chart&gt;TestChart&lt;/Chart&gt;</Chart>', $this->chart_collection_xml, $content);
        }
        if ($this->gauge_collection_xml) {
            $content = str_replace('<GaugePanel>TestGauge</GaugePanel>', $this->gauge_collection_xml, $content);
            $content = str_replace('<GaugePanel>&lt;GaugePanel&gt;TestGauge&lt;/GaugePanel&gt;</GaugePanel>', $this->gauge_collection_xml, $content);
        }
        $file_handler = fopen($outfile, 'w+');
        $write_status = fwrite($file_handler, $content);
        fclose($file_handler);
        return $write_status;
    }

    /**
     * Deploy RDL
     *
     * @param   string  $report_page  Report page name
     *
     * @return  string                Return sql
     */
    public function get_job_sql($report_page) {
        return "EXEC [spa_rfx_deploy_rdl_as_job] 'RDL Deployer', NULL, 'TSQL', " . $report_page . ", '" .$this->report_name . "'" ;
    }
    
}