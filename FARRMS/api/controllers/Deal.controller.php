<?php
/**
*  @brief DealController Deal Controller Class extends REST class
*  @par Description
*  This class is used for all Deal CRUD Operations
*  @copyright Pioneer Solutions.
*/
class DealController extends REST {
    /**
     * Get Deals for Login User
     *
     * @return  JSON  List of Deals with Detail
     */
    public function index() {
        $results = Deal::find();
        $this->response($this->json($results));
    }

    /**
     * Get Deal Information
     *
     * @param   Integer  $dealId  Deal ID
     *
     * @return  JSON            Deal Detail Information
     */
    public function get($dealId) {
        $results = Deal::findOne($dealId);
        
        if(count($results) == 0 || $results == '[]') {
            $error = array("message" => "Deal not found.");
            $this->response($this->json($error), 404);
        }
            
        $this->response($this->json($results[0]));
    }
    
    /**
     * get Term Start and Term End
     *
     * @param   Array  $body  POST Data
     *
     * @return  JSON          Term Dates
     */
	public function getTermStartEnd($body) {
        $deal_template_id = $body->template_id;
        $deal_date = $body->deal_date;
        $results = Deal::getTermStartEnd($deal_template_id, $deal_date);
        $this->response($this->json($results[0]));
    }
	
    /**
     * List All Frequencies
     *
     * @return  JSON  List Frequencies
     */
    public function listFrequency() {
        $results = Deal::findAllFrequency();
        $this->response($this->json($results));
    }
    
    /**
     * List Deal Types
     *
     * @return  JSON  Deal Types
     */
    public function listDealType() {
        $results = Deal::findAllDealType();
        $this->response($this->json($results));
    }
    
    /**
     * List Commodities
     *
     * @return  JSON  Commodities List
     */
    public function listCommodity() {
        $results = Deal::findAllCommodity();
        $this->response($this->json($results));
    }
    
    /**
     * List Currencies
     *
     * @return  JSON  Currency List
     */
    public function listCurrency() {
        $results = Deal::findAllCurrency();
        $this->response($this->json($results));
    }
    
    /**
     * search Deals
     *
     * @param   String  $searchTxt  Search Key
     *
     * @return  JSON               List of Deals
     */
    public function search($searchTxt) {
        $results = Deal::search($searchTxt);
        $this->response($this->json($results));
    }
    
    /**
     * Add Deal
     *
     * @param   Array  $body  POST Data
     *
     * @return  JSON                     Success or Failure
     */
    public function insert($body) {
        $deal_template_id = $body->template_id;
        
        $result0 = DealTemplate::findOne($deal_template_id);
        
            $physical_financial_flag = $result0[0]['physical_financial_flag'];
            $source_deal_type_id = $result0[0]['source_deal_type_id'];
            $commodity_id = $result0[0]['commodity_id'];
            
            $leg = $result0[0]['leg'];
            $fixed_price = $result0[0]['fixed_price'];
            $fixed_price_currency_id = $result0[0]['fixed_price_currency_id'];
            
            
            $sub_book               = $body->sub_book;
            $buy_sell               = $body->header_buy_sell_flag;
            $trader_id              = $body->trader_id;
            $counterparty_id        = $body->counterparty_id;
            $contract_id            = $body->contract_id;
            $deal_volume_uom_id     = $body->deal_volume_uom_id;
            $deal_volume_frequency  = $body->deal_volume_frequency;
            $deal_volume            = $body->deal_volume;
            $deal_date              = $this->formatDate($body->deal_date);
            $entire_term_start      = $this->formatDate($body->entire_term_start);
            $entire_term_end        = $this->formatDate($body->entire_term_end);
            $source_deal_type_id    = isset($body->source_deal_type_id) ? $body->source_deal_type_id : $source_deal_type_id;
            
            $header_xml = '<GridXML>
                                <GridRow row_id="1" 
                                        sub_book="' . $sub_book . '"  
                                        source_deal_header_id="" 
                                        deal_id="" 
                                        deal_date="' . $deal_date . '" 
                                        counterparty_id="' . $counterparty_id . '" 
                                        trader_id="' . $trader_id . '" 
                                        header_buy_sell_flag=" ' . $buy_sell . '" 
                                        physical_financial_flag="' . $physical_financial_flag . '" 
                                        source_deal_type_id="' . $source_deal_type_id . '" 
                                        contract_id="' . $contract_id . '" ';
            $detail_xml = '<GridXML>
                                <GridRow row_id="1"  
                                        deal_group="New Group" 
                                        group_id="1" 
                                        detail_flag="0" 
                                        blotterleg="' . $leg . '" 
                                        source_deal_detail_id=""
                                        term_start="' . $entire_term_start . '" 
                                        term_end="' . $entire_term_end . '"
                                        deal_volume="' . $deal_volume . '" 
                                        deal_volume_uom_id="' . $deal_volume_uom_id . '"
                                        deal_volume_frequency="' . $deal_volume_frequency . '"
                                        fixed_price_currency_id="' . $fixed_price_currency_id . '" ';
               
            foreach ($body as $label => $val) {
                if ($label == 'commodity_id')
                    $header_xml .= 'commodity_id="' . $val . '" ';
                if ($label == 'location_id')
                    $detail_xml .= 'location_id="' . $val . '" ';
                if ($label == 'curve_id')
                    $detail_xml .= 'curve_id="' . $val . '" ';
                if ($label == 'formula_curve_id')
                    $detail_xml .= 'formula_curve_id="' . $val . '" ';
                if ($label == 'fixed_price')
                    $detail_xml .= 'fixed_price="' . $val . '" ';
                
            }       
            
            foreach ($result0[0] as $label0 => $val0) {
                if ($label0 == 'fixed_float_leg' && $val0 <> "" && $val0 <> "NULL")
                    $detail_xml .= 'fixed_float_leg="' . $val0 . '" ';
            }
            
            $header_xml .= '>
                            </GridRow>
                        </GridXML>';
                
            $detail_xml .= '></GridRow>
                        </GridXML>'; 
        
        $results = Deal::insert($deal_template_id, $header_xml, $detail_xml);
                
        if ($results[0]['ErrorCode'] == 'Success') {
            $results[0]['source_deal_header_id'] = $results[0]['Recommendation'];
            unset($results[0]['ErrorCode']);
            $this->response($this->json($results[0]), 201);
        } else {
            $results[0]['Message'] = preg_replace('![(]Deal Header(.*?)[)]!','',$results[0]['Message']);
            $results[0]['Message'] = preg_replace('![(]Deal Detail(.*?)[)]!','',$results[0]['Message']);
            $results[0]['Message'] = preg_replace('!in row(.*?)[.]!','.',$results[0]['Message']);
            $results[0]['Message'] = preg_replace('![(]Error(.*?)[)]!','',$results[0]['Message']);
            $results[0]['Message'] = preg_replace('!Indexed On!','Indexed Price',$results[0]['Message']);
			$results[0]['Message'] = preg_replace('![(]Arithmetic(.*?)[)]!','',$results[0]['Message']);
            $this->response($this->json($results[0]), 400);   
        }
    }
    
    /**
     * Update Deal
     *
     * @param   Array  $body     POST Data
     *
     * @return  JSON               Success or Failure
     */
    public function update($dealId, $body) {
        $dealId = (int)$dealId;
        $result0 = Deal::findOne($dealId);
            
            $ref_id = $result0[0]['deal_id'];
            $template_id = $result0[0]['template_id'];
            $source_deal_type_id = $result0[0]['source_deal_type_id'];
            $commodity_id = $result0[0]['commodity_id'];  
            $physical_financial_flag = $result0[0]['physical_financial_flag'];   
            $source_deal_detail_id = $result0[0]['source_deal_detail_id'];
            $group_id = $result0[0]['group_id'];
            $deal_group = $result0[0]['deal_group'];
            
            $sub_book               = $body->sub_book;
            $buy_sell               = $body->header_buy_sell_flag;
            $trader_id              = $body->trader_id;
            $counterparty_id        = $body->counterparty_id;
            $contract_id            = $body->contract_id;
            $deal_volume_uom_id     = $body->deal_volume_uom_id;
            $deal_volume_frequency  = $body->deal_volume_frequency;
            $deal_volume            = $body->deal_volume;
            $deal_date              = $this->formatDate($body->deal_date);
            $entire_term_start      = $this->formatDate($body->entire_term_start);
            $entire_term_end        = $this->formatDate($body->entire_term_end);
            
            $leg = 1;
            
            $header_xml = '<Root>
                                <FormXML 
                                        sub_book="' . $sub_book . '"  
                                        source_deal_header_id="' . $deal_id . '" 
                                        deal_id="' . $ref_id . '" 
                                        deal_date="' . $deal_date . '" 
                                        counterparty_id="' . $counterparty_id . '" 
                                        trader_id="' . $trader_id . '" 
                                        template_id="' . $template_id . '"
                                        header_buy_sell_flag="' . $buy_sell . '" 
                                        physical_financial_flag="' . trim($physical_financial_flag) . '" 
                                        source_deal_type_id="' . $source_deal_type_id . '"
                                        contract_id="' . $contract_id . '" ';
                                        
            $detail_xml = '<GridXML>
                                <GridRow 
                                        deal_group="' . $deal_group . '" 
                                        group_id="' . $group_id . '" 
                                        blotterleg="' . $leg . '" 
                                        source_deal_detail_id="' . $source_deal_detail_id . '"
                                        term_start="' . $entire_term_start . '" 
                                        term_end="' . $entire_term_start . '"
                                        deal_volume="' . $deal_volume . '" 
                                        deal_volume_uom_id="' . $deal_volume_uom_id . '"
                                        deal_volume_frequency="' . $deal_volume_frequency . '" ';
            
            foreach ($body as $label => $val) {
                if ($label == 'commodity_id')
                    $header_xml .= 'commodity_id="' . $val . '" ';
                if ($label == 'location_id')
                    $detail_xml .= 'location_id="' . $val . '" ';
                if ($label == 'curve_id')
                    $detail_xml .= 'curve_id="' . $val . '" ';
                if ($label == 'fixed_price')
                    $detail_xml .= 'fixed_price="' . $val . '" ';
                if ($label == 'fixed_price_currency_id')
                    $detail_xml .= 'fixed_price_currency_id="' . $val . '" ';
                if ($label == 'formula_curve_id')
                    $detail_xml .= 'formula_curve_id="' . $val . '" ';
                if ($label == 'total_volume')
                    $detail_xml .= 'total_volume="' . $val . '" ';
            }
            
            $header_xml .= '>
                                </FormXML>
                            </Root>';
            
            $detail_xml .= '></GridRow>
                                </GridXML>';
                                
        $results = Deal::update($dealId, $header_xml, $detail_xml);
        
        $this->response($this->json($results[0]));
    }
}
