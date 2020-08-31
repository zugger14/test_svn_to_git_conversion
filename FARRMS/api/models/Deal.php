<?php
/**
*  @brief Deal Deal Class
*  @par Description
*  This class is used for all Deal CRUD Operations
*  @copyright Pioneer Solutions.
*/
class Deal {
    /**
     * Get Deals for Login User
     *
     * @return  Array  List of Deals with Detail
     */
    public static function find() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 's', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    /**
     * Get Deal Information
     *
     * @param   Integer  $deal_id  Deal ID
     *
     * @return  Array            Deal Detail Information
     */
    public static function findOne($deal_id) {
        global $app_user_name;
        $deal_id = (int)$deal_id;
        $query = "EXEC spa_mobile_deal 's',@source_deal_header_id = $deal_id, @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    /**
     * Add Deal
     *
     * @param   Integer  $deal_template_id  Deal Template ID
     * @param   String  $header_xml        Header XML
     * @param   String  $detail_xml        Detail XML
     *
     * @return  Array                     Success or Failure
     */
    public static function insert($deal_template_id, $header_xml, $detail_xml) {
        global $app_user_name;
        $deal_template_id = (int)$deal_template_id;
        $query = "EXEC spa_insert_blotter_deal @flag = 'i', @call_from = 'form', @template_id = $deal_template_id, @header_xml = '$header_xml', @detail_xml = '$detail_xml', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    /**
     * Update Deal
     *
     * @param   Integer  $deal_id     Deal ID
     * @param   String  $header_xml   Header XML
     * @param   String  $detail_xml   Detail XML
     *
     * @return  Array               Success or Failure
     */
    public static function update($deal_id, $header_xml, $detail_xml) {
        global $app_user_name;
        $deal_id = (int)$deal_id;
        $query = "EXEC spa_deal_update_new @flag = 's', @source_deal_header_id = '$deal_id', @header_xml = '$header_xml', @detail_xml = '$detail_xml', @pricing_process_id=NULL,@header_cost_xml=NULL";
        return DB::query($query);
    }
    
    /**
     * Delete Deal
     *
     * @param   Integer  $deal_id  Deal ID
     *
     * @return  Array            Success or Failure
     */
    public static function delete($deal_id) {
        global $app_user_name;
        $deal_id = (int)$deal_id;
        $query = "EXEC spa_mobile_deal 'd',@source_deal_header_id = $deal_id, @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    /**
     * get Term Start and Term End
     *
     * @param   Integer  $deal_template_id  Template ID
     * @param   Date  $deal_date         Deal Date
     *
     * @return  Array                     Term Dates
     */
	public static function getTermStartEnd($deal_template_id, $deal_date) {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 'a', @deal_template_id = $deal_template_id, @deal_date = '$deal_date', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
	
    /**
     * List All Frequencies
     *
     * @return  Array  List Frequencies
     */
    public static function findAllFrequency() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 'f', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    /**
     * List Deal Types
     *
     * @return  Array  Deal Types
     */
    public static function findAllDealType() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 'p', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    /**
     * List Commodities
     *
     * @return  Array  Commodities List
     */
    public static function findAllCommodity() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 'm', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    /**
     * List Currencies
     *
     * @return  Array  Currency List
     */
    public static function findAllCurrency() {
        global $app_user_name;
        $query = "EXEC spa_source_currency_maintain 'p', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    /**
     * search Deals
     *
     * @param   String  $search_txt  Search Key
     *
     * @return  Array               List of Deals
     */
    public static function search($search_txt) {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal @flag='z', @search_txt= '$search_txt', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    /**
     * Get ssrs config if deal id exists
     *
     * @param   Integer  $deal_id  Deal ID
     *
     * @return  Array            SSRS Config Information
     */
    public static function getSSRSLoginDeal($deal_id) {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal @flag='h', @source_deal_header_id = '$deal_id', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    /**
     * Get ssrs config if invoice id exists
     *
     * @param   Integer  $invoice_id  Invoice ID
     *
     * @return  Array               SSRS Config Information
     */
    public static function getSSRSLoginInvoice($invoice_id) {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal @flag='h', @invoice_id = '$invoice_id', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    /**
     * Get ssrs config if paramset id exists
     *
     * @param   Integer  $paramset_id  Paramset ID
     *
     * @return  Array                SSRS Config Information
     */
    public static function getSSRSLoginParamset($paramset_id) {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal @flag='h', @paramset_id = '$paramset_id', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    /**
     * Get ssrs config
     *
     * @return  Array                SSRS Config Information
     */
    public static function getSSRSLogin() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal @flag='h', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
}
