IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_deal_detail_template]') AND type in (N'P', N'PC'))
DROP PROC [dbo].[spa_source_deal_detail_template]  
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**
	Performs select, insert, update and delete on source_deal_detail_template table

	Parameters 	
	@flag : 
			- t - Returns data for HTML file
			- s - Returns data for editable grid
			- i - Inserts new deal template
			- u - Updates deal template
			- d - Deletes deal template
			- x - Deletes those template detail exists in @template_detail_id of template id = @template_id
			- c - Updates deal volume frequency and deal volume uom 
			- v - Added new legs in deal template
	@template_detail_id : Template Detail Id
	@leg : Leg
	@fixed_float_leg : Fixed Float Leg
	@buy_sell_flag : Buy Sell Flag
	@curve_type : Curve Type
	@curve_id : Curve Id
	@deal_volume_frequency : Deal Volume Frequency
	@deal_volume_uom_id : Deal Volume Uom Id
	@currency_id : Currency Id
	@block_description : Block Description
	@template_id : Template Id
	@commodity_id : Commodity Id
	@day_count : Day Count
	@physical_financial_flag : Physical Financial Flag
	@location_id : Location Id
	@strip_months_from : Strip Months From
	@lag_months : Lag Months
	@strip_months_to : Strip Months To
	@conversion_factor : Conversion Factor
	@meter_id : Meter Id
	@formula : Formula
	@pay_opposite : Pay Opposite
	@settlement_currency : Settlement Currency
	@standard_yearly_volume : Standard Yearly Volume
	@price_uom_id : Price Uom Id
	@category : Category
	@profile_code : Profile Code
	@pv_party : Pv Party
	@adder_currency_id : Adder Currency Id
	@booked : Booked
	@capacity : Capacity
	@day_count_id : Day Count Id
	@deal_detail_description : Deal Detail Description
	@fixed_cost : Fixed Cost
	@fixed_cost_currency_id : Fixed Cost Currency Id
	@formula_currency_id : Formula Currency Id
	@formula_curve_id : Formula Curve Id
	@formula_id : Formula Id
	@multiplier : Multiplier
	@option_strike_price : Option Strike Price
	@price_adder : Price Adder
	@price_adder_currency2 : Price Adder Currency2
	@price_adder2 : Price Adder2
	@price_multiplier : Price Multiplier
	@process_deal_status : Process Deal Status
	@settlement_date : Settlement Date
	@settlement_uom : Settlement Uom
	@settlement_volume : Settlement Volume
	@total_volume : Total Volume
	@volume_left : Volume Left
	@volume_multiplier2 : Volume Multiplier2
	@term_start : Term Start
	@term_end : Term End
	@contract_expiration_date : Contract Expiration Date
	@fixed_price : Fixed Price
	@fixed_price_currency_id : Fixed Price Currency Id
	@deal_volume : Deal Volume
	@xmlValue : XmlValue
	@call_from : Call From
	@detail_commodity_id : Detail Commodity Id

*/

create proc [dbo].[spa_source_deal_detail_template]  
	@flag char(1),  
	@template_detail_id VARCHAR(1000) = NULL,  
	@leg as int= NULL,  
	@fixed_float_leg as NCHAR(1)= NULL,  
	@buy_sell_flag as NCHAR(1)= NULL,  
	@curve_type as int=NULL,  
	@curve_id as int= NULL,  
	@deal_volume_frequency as NCHAR(1)= NULL,  
	@deal_volume_uom_id as int= NULL,  
	@currency_id as int=NULL,  
	@block_description as NVARCHAR(50)= NULL,  
	@template_id int= NULL,  
	@commodity_id int=NULL,  
	@day_count int=NULL,  
	@physical_financial_flag as NCHAR(1) = NULL,  
	@location_id int = NULL,  
	@strip_months_from INT=NULL,  
	@lag_months INT=NULL,  
	@strip_months_to INT=NULL,  
	@conversion_factor FLOAT=NULL,  
	@meter_id int=NULL,  
	@formula NVARCHAR(100)=NULL,  
	--@pay_opposite NVARCHAR(100)=NULL, 
	@pay_opposite NVARCHAR(100)='y',  
	@settlement_currency INT=NULL,  
	@standard_yearly_volume  float=NULL,  
	@price_uom_id  INT=NULL,  
	@category INT=NULL,  
	@profile_code INT=NULL,  
	@pv_party INT=NULL,
	@adder_currency_id INT=NULL,
	@booked NCHAR=NULL,
	@capacity NUMERIC(38,17)=NULL,
	@day_count_id INT=NULL,
	@deal_detail_description NVARCHAR(100)=NULL,
	@fixed_cost NUMERIC(38, 17)=NULL,
	@fixed_cost_currency_id INT=NULL,
	@formula_currency_id INT =NULL,
	@formula_curve_id INT =NULL,
	@formula_id INT=NULL,
	@multiplier NUMERIC(38,17)=NULL,
	@option_strike_price  NUMERIC(38,17)=NULL,
	@price_adder  NUMERIC(38,17)=NULL,
	@price_adder_currency2 INT =NULL,
	@price_adder2  NUMERIC(38,17)=NULL,
	@price_multiplier  NUMERIC(38,17)=NULL,
	@process_deal_status INT=NULL,
	@settlement_date DATETIME=NULL,
	@settlement_uom int=NULL,
	@settlement_volume FLOAT(53)=NULL,
	@total_volume  NUMERIC(38,17)=NULL,
	@volume_left FLOAT(53)=NULL,
	@volume_multiplier2 NUMERIC(38,17)=NULL,
	@term_start DATETIME=NULL,
	@term_end DATETIME=NULL,
	@contract_expiration_date DATETIME=NULL,
	@fixed_price  NUMERIC(38,17)=NULL,
	@fixed_price_currency_id INT=NULL,
	@deal_volume  NUMERIC(38,17)=NULL,  
	@xmlValue TEXT=NULL,
	@call_from INT = NULL,
	@detail_commodity_id INT = NULL
AS  
  
SET NOCOUNT ON  



DECLARE @IntVariable INT;
DECLARE @SQLString NVARCHAR(MAX);
DECLARE @ParmDefinition NVARCHAR(MAX);
DECLARE @return NCHAR(1);

SET @IntVariable = 197;   
DECLARE @fields NVARCHAR(1000)

DECLARE @field_template_id INT   
SELECT @field_template_id=field_template_id from dbo.source_deal_header_template WHERE template_id=@template_id   

  
--for html file  
if @flag='t' AND  @template_id is NOT NULL  
begin  
		SELECT sddt.template_detail_id [Template Detail ID],
		       sddt.leg [Leg],
		       CASE fixed_float_leg
		            WHEN 't' THEN 'Float'
		            WHEN 'f' THEN 'Fix'
		       END [Fixed/Float],
		       CASE 
		            WHEN sddt.buy_sell_flag = 'b' THEN 'Buy'
		            ELSE 'Sell'
		       END [Buy/Sell],
		       sdv_ct.code [Curve Type],
		       spcd.curve_name [Curve Name],
		       CASE sddt.deal_volume_frequency
		            WHEN 'h' THEN 'Hourly'
		            WHEN 'd' THEN 'Daily'
		            WHEN 'w' THEN 'Weekly'
		            WHEN 'm' THEN 'Monthly'
		            WHEN 'q' THEN 'Quarterly'
		            WHEN 's' THEN 'Semi-Annually'
		            WHEN 'a' THEN 'Annually'
		            WHEN 't' THEN 'Term'
		       END [Deal Volume Frequency],
		       su.uom_name [Deal Volume UOM],
		       sc_curr.currency_name [Currency],
		       block_description [Block Description],
		       sddt.template_id [Template ID],
		       sc_com_detail.commodity_name [Commodity],
		       sddt.create_user [Create User],
		       dbo.FNADateFormat(sddt.create_ts) [Create Time],
		       sddt.update_user [Update User],
		       dbo.FNADateFormat(sddt.update_ts) [Update Time],
		       sddt.day_count [Day Count],
		       CASE sddt.physical_financial_flag
		            WHEN 'P' THEN 'Physical'
		            WHEN 'f' THEN 'Financial'
		       END [Physical/Financial],
		       sml.Location_Name [Location],
		       mi.[description] [Meter],
		       sddt.strip_months_from [Strip Month From],
		       sddt.lag_months [Lag Months],
		       sddt.strip_months_to [Strip Month To],
		       dbo.FNARemoveTrailingZeroes(sddt.conversion_factor) [Conversion Factor],
		       CASE pay_opposite
		            WHEN 'Y' THEN 'Yes'
		            ELSE 'No'
		       END [Pay opposite],
		       fe.formula [Formula],
		       sc_set.currency_name [Settlement Currency],
		       dbo.FNARemoveTrailingZeroes(sddt.standard_yearly_volume) [Standard Yearly Volume],
		       su_detail.uom_name [Price UOM],
		       sdv_dc_detail.code [Category],
		       sdv_pc.code [Profile Code],
		       sdv_pv.code [PV Party],
		       sc_adder.currency_name [Adder Currency],
		       sddt.booked [Booked],
		       dbo.FNARemoveTrailingZeroes(sddt.capacity) [Capacity],		      
		       sddt.deal_detail_description [Deal Detail Description],
		       dbo.FNARemoveTrailingZeroes(sddt.fixed_cost) [Fixed Cost],
		       sddt.fixed_cost_currency_id [Fixed Cost Currency],
		       sc_formula.currency_name [Formula Currency],
		       sddt.formula_curve_id [Formula Curve],
		       NULLIF(sddt.formula_id, 0) [Formula],
		       dbo.FNARemoveTrailingZeroes(sddt.multiplier) [Multiplier],
		       dbo.FNARemoveTrailingZeroes(sddt.option_strike_price) [Option Strike Price],
		       dbo.FNARemoveTrailingZeroes(sddt.price_adder) [Price Adder],
		       sddt.price_adder_currency2 [Price Adder Currency2],
		       dbo.FNARemoveTrailingZeroes(sddt.price_adder2) [Price Adder2],
		       dbo.FNARemoveTrailingZeroes(sddt.price_multiplier) [Price Multiplier],
		       sddt.process_deal_status [Process Deal Status],
		       dbo.FNADateFormat(sddt.settlement_date) [Settlement Date],
		       sddt.settlement_uom [Settlement UOM],
		       dbo.FNARemoveTrailingZeroes(sddt.settlement_volume) [Settle Volume],
		       dbo.FNARemoveTrailingZeroes(sddt.total_volume) [Total Volume],
		       dbo.FNARemoveTrailingZeroes(sddt.volume_left) [Volume Left],
		       dbo.FNARemoveTrailingZeroes(sddt.volume_multiplier2) [Volume Multiplier2],
		       dbo.FNADateFormat(sddt.term_start) [Term Start],
		       dbo.FNADateFormat(sddt.term_end) [Term End],
		       dbo.FNADateFormat(sddt.contract_expiration_date) [Contract Expiration Date],
		       dbo.FNARemoveTrailingZeroes(sddt.fixed_price) [Fixed Price],
		       sddt.fixed_price_currency_id [Fixed Price Currency],
		       dbo.FNARemoveTrailingZeroes(sddt.deal_volume) [Deal Volume],
		       su_pos.uom_name [Position UOM],
		       sdv_it.code [Inco Term],
				sddt.batch_id [Batch ID],
				CASE WHEN sddt.detail_sample_control = 'y' THEN 'Yes' ELSE 'No' END [Subject to Sample Control],
				sdv_cy.code [Crop Year],
				sddt.lot [Lot],
				sdv_bs.code [Buyer/Seller Option],
				sddt.product_description [Product Desc],
				fp.profile_name [Profile Name],
				sdv_st.code [Strike Granularity],
				sddt.delivery_date [Delivery Date],
				 dbo.FNADateFormat(sddt.payment_date) payment_date,
				sddt.fx_conversion_rate [Fx Conversion Rate]
		FROM   source_deal_detail_template sddt
		       LEFT JOIN static_data_value sdv_ct
		            ON  sdv_ct.value_id = sddt.curve_type
		       LEFT JOIN source_uom su
		            ON  su.source_uom_id = sddt.deal_volume_uom_id
		       LEFT JOIN source_currency sc_curr
		            ON  sc_curr.source_currency_id = sddt.currency_id
		       LEFT JOIN source_commodity sc_com_detail
		            ON  sc_com_detail.source_commodity_id = sddt.commodity_id
		       LEFT JOIN source_minor_location sml
		            ON  sml.source_minor_location_id = sddt.location_id
		       LEFT JOIN source_minor_location_meter smlm
		            ON  smlm.source_minor_location_id = sddt.meter_id
		       LEFT JOIN meter_id mi
		            ON  mi.meter_id = smlm.meter_id
		       LEFT JOIN formula_editor fe
		            ON  fe.formula_id = sddt.formula
		       LEFT JOIN source_currency sc_set
		            ON  sc_set.source_currency_id = sddt.settlement_currency
		       LEFT JOIN source_uom su_detail
		            ON  su.source_uom_id = sddt.price_uom_id
		       LEFT JOIN static_data_value sdv_dc_detail
		            ON  sdv_dc_detail.value_id = sddt.category
		       LEFT JOIN static_data_value sdv_pv
		            ON  sdv_pv.value_id = sddt.pv_party
		       LEFT JOIN static_data_value sdv_pc
		            ON  sdv_pc.value_id = sddt.profile_code
		       LEFT JOIN source_price_curve_def spcd
		            ON  spcd.source_curve_def_id = sddt.curve_id
		       LEFT JOIN source_currency sc_adder
					ON sc_adder.source_currency_id = sddt.adder_currency_id
			   LEFT JOIN source_currency sc_formula
					ON sc_formula.source_currency_id = sddt.formula_currency_id
			   LEFT JOIN source_currency sc_price
					ON sc_price.source_currency_id = sddt.fixed_price_currency_id
			   LEFT JOIN source_uom su_pos ON su_pos.source_uom_id = sddt.position_uom
			   LEFT JOIN static_data_value sdv_it ON sdv_it.value_id = sddt.detail_inco_terms AND sdv_it.[type_id] = 40200
			   LEFT JOIN static_data_value sdv_cy ON sdv_cy.value_id = sddt.crop_year AND sdv_cy.[type_id] = 10092
			   LEFT JOIN static_data_value sdv_bs ON sdv_bs.value_id = sddt.buyer_seller_option AND sdv_bs.[type_id] = 40400
			   LEFT JOIN forecast_profile fp ON sddt.profile_id = fp.profile_id
			   LEFT JOIN static_data_value sdv_st ON sdv_st.value_id = sddt.strike_granularity AND sdv_st.[type_id] = 978
		WHERE  sddt.template_id = @template_id
		ORDER BY sddt.leg
  
 If @@error <> 0  
  Exec spa_ErrorHandler @@error, 'Source Deal Detail Template',   
    'spa_Source_Deal_Detial_Template', 'DB Error',   
    'Failed to Select the Source Deal Dtail Template.', ''  
 Else  
  Exec spa_ErrorHandler 0, 'Source Deal Detail Template',   
    'spa_Source_Deal_Detial_Template', 'Success',   
    'Source Deal Detial Template is successfully selected.', ''  
  
end  
--for editabel grid  
IF @flag = 's'  AND  @template_id is NOT NULL  

BEGIN  
	SELECT sddt.template_detail_id,
		sddt.leg,
		sddt.fixed_float_leg,
		sddt.buy_sell_flag,
		sddt.curve_type,
		sddt.curve_id,
		sddt.deal_volume_frequency,
		sddt.deal_volume_uom_id,
		sddt.contractual_uom_id,
		sddt.actual_volume,
		sddt.contractual_volume,
		sddt.currency_id,
		sddt.block_description,
		sddt.template_id,
		sddt.commodity_id,
		sddt.create_user,
		dbo.FNADateFormat(sddt.create_ts) create_ts,
		sddt.update_user,
		dbo.FNADateFormat(sddt.update_ts) update_ts,
		sddt.day_count,
		sddt.physical_financial_flag,
		sddt.location_id,
		sddt.meter_id,
		sddt.strip_months_from,
		sddt.lag_months,
		sddt.strip_months_to,
		sddt.conversion_factor,
		sddt.pay_opposite,
		sddt.formula,
		sddt.settlement_currency,
		sddt.standard_yearly_volume,
		sddt.price_uom_id,
		sddt.category,
		sddt.profile_code,
		sddt.pv_party,
		adder_currency_id,
		sddt.booked,
		sddt.capacity,
		sddt.day_count_id,
		sddt.deal_detail_description,
		sddt.fixed_cost,
		sddt.fixed_cost_currency_id,
		sddt.formula_currency_id,
		sddt.formula_curve_id,
		NULLIF(sddt.formula_id, 0)formula_id,
		sddt.multiplier,
		sddt.option_strike_price,
		sddt.price_adder,
		sddt.price_adder_currency2,
		sddt.price_adder2,
		sddt.price_multiplier,
		sddt.process_deal_status,
		dbo.FNADateFormat(sddt.settlement_date) settlement_date,
		sddt.settlement_uom,
		sddt.settlement_volume,
		sddt.total_volume,
		sddt.volume_left,
		sddt.volume_multiplier2,
		dbo.FNADateFormat(sddt.term_start) term_start,
		dbo.FNADateFormat(sddt.term_end) term_end,
		dbo.FNADateFormat(sddt.contract_expiration_date) contract_expiration_date,
		sddt.fixed_price,
		sddt.fixed_price_currency_id,
		sddt.deal_volume,
		sddt.lock_deal_detail,
		sddt.detail_commodity_id,
		sddt.detail_pricing,
		sddt.pricing_end,
		sddt.pricing_start,
		sddt.cycle,
		sddt.schedule_volume,
		sddt.[status],
		sddt.origin, 
		sddt.form, 
		sddt.organic, 
		sddt.attribute1, 
		sddt.attribute2,
		sddt.attribute3, 
		sddt.attribute4, 
		sddt.attribute5,
		sddt.position_uom,
		sddt.detail_inco_terms, 
		sddt.detail_sample_control, 
		sddt.lot,
		sddt.batch_id, 
		sddt.crop_year,
		sddt.buyer_seller_option,
		sddt.product_description,
		sddt.profile_id,
		sddt.premium_settlement_date,
		sddt.no_of_strikes,
		sddt.strike_granularity,
		sddt.delivery_date,
		dbo.FNADateFormat(sddt.payment_date) payment_date,
		sddt.upstream_counterparty,
		sddt.upstream_contract,
		sddt.fx_conversion_rate,
                sddt.vintage,
		sddt.position_formula_id,
		sddt.delivery_date_to,
		sddt.actual_delivery_date,
		sddt.pnl_date,
		sddt.shipper_code1,
		sddt.shipper_code2
	INTO #tempDeal
	FROM   source_deal_detail_template sddt
	WHERE  sddt.template_id = @template_id	
  
	DECLARE @udf_field NVARCHAR(MAX)  
	DECLARE @update_field NVARCHAR(MAX)
	SET @udf_field=''  
	SET @update_field = ''
     
	SELECT @udf_field = @udf_field + ' UDF___' + CAST(udf_template_id AS NVARCHAR) +
	       ' NVARCHAR(100),'
	FROM   maintain_field_template_detail d
	       JOIN user_defined_fields_template udf_temp
	            ON  d.field_id = udf_temp.udf_template_id
	WHERE  udf_or_system = 'u'
	       AND udf_temp.udf_type = 'd'
	       AND d.field_template_id = @field_template_id   
	
	
	SELECT @update_field = @update_field + 'UPDATE #tempdeal SET UDF___' + CAST(udf_user_field_id AS NVARCHAR) 
	       + ' = ' + CASE 
	                      WHEN (uddft.data_type IN ('int', 'float')) THEN CAST(ISNULL(uddft.default_value, d.default_value) AS NVARCHAR)
	                      WHEN uddft.Field_type = 'a' THEN '''' + CAST(
	                               dbo.FNADateFormat(ISNULL(uddft.default_value, d.default_value)) AS NVARCHAR
	                           ) + ''''
	                      ELSE '''' + CAST(ISNULL(uddft.default_value, d.default_value) AS NVARCHAR) + ''''
	                 END
	       + ' WHERE leg = ' + CAST(uddft.leg AS NVARCHAR(10)) + '; '
	FROM   maintain_field_template_detail d
	       INNER JOIN user_defined_deal_fields_template_main uddft
	            ON  d.field_id = uddft.udf_user_field_id
	WHERE  udf_or_system = 'u'
	       AND uddft.udf_type = 'd'
	       AND d.field_template_id = @field_template_id
	       AND uddft.template_id = @template_id
	       AND ISNULL(uddft.default_value, '') <> '' 


  

   
	IF LEN(@udf_field) > 1
	BEGIN
		SET @udf_field = LEFT(@udf_field, LEN(@udf_field) -1)  

		EXEC ('ALTER TABLE #tempDeal add ' + @udf_field) 
	  
		IF NULLIF(@update_field, '') IS NOT NULL
		BEGIN
			EXEC spa_print @update_field   

			EXEC ( @update_field)
		END
	END
  
  SELECT column_name INTO #temp_field_detail FROM INFORMATION_SCHEMA.Columns where TABLE_NAME = 'source_deal_detail_template'   
   

  DECLARE @sql_pre          NVARCHAR(MAX),
          @farrms_field_id  NVARCHAR(100),
          @default_label    NVARCHAR(100)
  
  SET @sql_pre = ''  
  DECLARE dealCur           CURSOR FORWARD_ONLY READ_ONLY 
  FOR
      SELECT ISNULL(farrms_field_id, t.column_name) farrms_field_id,
             default_label  
      FROM   (
                 SELECT f.farrms_field_id,
                        ISNULL(d.field_caption, f.default_label) default_label,
                        d.seq_no
                 FROM   maintain_field_template_detail d
                        JOIN maintain_field_deal f
                             ON  d.field_id = f.field_id
                 WHERE  f.header_detail = 'd'
                        AND d.field_template_id = @field_template_id
                        AND ISNULL(d.udf_or_system, 's') = 's' 
                 UNION ALL   
                 SELECT 'UDF___' + CAST(udf_template_id AS NVARCHAR),
                        ISNULL(d.field_caption, f.Field_label) default_label,
                        d.seq_no
                 FROM   maintain_field_template_detail d
                        JOIN user_defined_fields_template f
                             ON  d.field_id = f.udf_template_id
                 WHERE  d.field_template_id = @field_template_id
                        AND f.udf_type = 'd'
                        AND d.udf_or_system = 'u'
             ) l
             LEFT OUTER JOIN #temp_field_detail t
                  ON  l.farrms_field_id = t.column_name
      WHERE  l.farrms_field_id NOT IN ('source_deal_header_id', 'source_deal_detail_id')
      ORDER BY
             l.seq_no
  
  OPEN dealCur  
  FETCH NEXT FROM dealCur INTO @farrms_field_id,@default_label                              
  WHILE @@FETCH_STATUS = 0
  BEGIN
      SET @sql_pre = @sql_pre + ' ' + @farrms_field_id + ' AS [' + @default_label + '],' 
      FETCH NEXT FROM dealCur INTO @farrms_field_id,@default_label
  END  
  CLOSE dealCur  
  DEALLOCATE dealCur  
  IF LEN(@sql_pre) > 1
  BEGIN
      SET @sql_pre = LEFT(@sql_pre, LEN(@sql_pre) -1)
  END   
  
  EXEC spa_print 'SELECT template_detail_id ID,', @sql_pre, ' FROM #tempDeal'
          
  EXEC (
           'SELECT template_detail_id ID,' + @sql_pre + ' FROM #tempDeal'
       ) 
END  
  
  
ELSE If @flag='i'  
BEGIN  
 IF @pay_opposite IS NULL  OR @pay_opposite <> 'n'
  SET @pay_opposite = 'Y'  
  
 SELECT @leg=MAX(leg)+1 FROM dbo.source_deal_detail_template WHERE template_id=@template_id  
 IF @leg IS NULL   
  SET @leg=1  
  
 -----------------------------------Start of Min and Max value validation-------------------------------------------------
  SELECT @leg AS leg,
        @fixed_float_leg AS fixed_float_leg,
        @buy_sell_flag AS buy_sell_flag,
        @curve_type AS curve_type,
        @curve_id AS curve_id,
        @deal_volume_frequency AS deal_volume_frequency,
        @deal_volume_uom_id AS deal_volume_uom_id,
        @currency_id AS currency_id,
        @block_description AS block_description,
        @template_id AS template_id,
        @commodity_id AS commodity_id,
        @physical_financial_flag AS physical_financial_flag,
        @location_id AS location_id,
        @meter_id AS meter_id,
        @strip_months_from AS strip_months_from,
        @lag_months AS lag_months,
        @strip_months_to AS strip_months_to,
        @conversion_factor AS conversion_factor,
        @formula AS formula,
        @pay_opposite AS pay_opposite,
        @settlement_currency AS settlement_currency,
        @standard_yearly_volume AS standard_yearly_volume,
        @price_uom_id AS price_uom_id,
        @category AS category,
        @profile_code AS profile_code,
        @pv_party AS pv_party,
        @adder_currency_id AS adder_currency_id,
        @booked AS booked,
        @capacity AS capacity,
        @day_count_id AS day_count_id,
        @deal_detail_description AS deal_detail_description,
        @fixed_cost AS fixed_cost,
        @fixed_cost_currency_id AS fixed_cost_currency_id,
        @formula_currency_id AS formula_currency_id,
        @formula_curve_id AS formula_curve_id,
        @formula_id AS formula_id,
        @multiplier AS multiplier,
        @option_strike_price AS option_strike_price,
        @price_adder AS price_adder,
        @price_adder_currency2 AS price_adder_currency2,
        @price_adder2 AS price_adder2,
        @price_multiplier AS price_multiplier,
        @process_deal_status AS process_deal_status,
        @settlement_date AS settlement_date,
        @settlement_uom AS settlement_uom,
        @settlement_volume AS settlement_volume,
        @total_volume AS total_volume,
        @volume_left AS volume_left,
        @volume_multiplier2 AS volume_multiplier2,
        @term_start AS term_start,
        @term_end AS term_end,
        @contract_expiration_date AS contract_expiration_date,
        @fixed_price AS fixed_price,
        @fixed_price_currency_id AS fixed_price_currency_id,
        @deal_volume AS deal_volume 
        INTO #temp_sddt
     
            
SELECT 
       @fields = COALESCE(@fields + ',', ' ' ) + cast(mfd.farrms_field_id AS NVARCHAR(30))
      
FROM   maintain_field_template_detail mftd
       INNER JOIN maintain_field_deal mfd
            ON  mftd.field_id = mfd.field_id
            AND mftd.udf_or_system = 's'
            AND mfd.header_detail = 'd'
WHERE  mftd.field_template_id = @field_template_id
       AND (NULLIF(mftd.min_value, 0) IS NOT NULL OR NULLIF(mftd.max_value, 0) IS NOT NULL)

SET @SQLString =  '
			DECLARE @error_field NVARCHAR(100)
			DECLARE @min_value FLOAT
			DECLARE @max_value FLOAT
			DECLARE @msg NVARCHAR(1000)
			
			SELECT @error_field = mfd.default_label,
					@min_value = mftd.min_value,
					@max_value = mftd.max_value
			FROM   maintain_field_template_detail mftd
			       INNER JOIN maintain_field_deal mfd
			            ON  mftd.field_id = mfd.field_id
			            AND mftd.udf_or_system = ''s''
			            AND mfd.header_detail = ''d''
			       INNER JOIN (
			                SELECT ' +  @fields + '
			                FROM   #temp_sddt
			            )p
			            UNPIVOT(col_value FOR field IN (' +  @fields + ')) AS 
			            unpvt
			            ON  unpvt.field = mfd.farrms_field_id
			            AND (
			                    unpvt.col_value < mftd.min_value
			                    OR unpvt.col_value > mftd.max_value
			                )
			WHERE  mftd.field_template_id = ' + CAST(@field_template_id AS NVARCHAR(10)) + '
			       AND (mftd.min_value IS NOT NULL OR mftd.max_value IS NOT NULL)
			
			IF @error_field IS NOT NULL 
				SET @msg = ''The value for '' + cast(@error_field as NVARCHAR(100)) + '' should be between '' + cast(@min_value as NVARCHAR(100)) + '' and '' + cast(@max_value as NVARCHAR(100)) + ''.'' 
			
			SET @max_titleOUT = 0
			IF  @msg IS NOT NULL 
			BEGIN
				EXEC spa_ErrorHandler -1, ''Error'', 
								''spa_InsertDealXmlBlotter'', ''DB Error'', 
								@msg, @msg						
				
				SET @max_titleOUT = 1	
			END
			
			
   '
   SET @ParmDefinition = N'@level tinyint, @max_titleOUT NVARCHAR(30) OUTPUT';
EXEC spa_print '---------------------------------------------------------------------------------------'

EXECUTE sp_executesql @SQLString, @ParmDefinition, @level = @IntVariable, @max_titleOUT=@return OUTPUT;

--Return if column value is not between min and max value
IF @return = 1
    RETURN 

-----------------------------------End of Min and Max value validation-------------------------------------------------


    
 INSERT INTO source_deal_detail_template
   (
     leg,
     fixed_float_leg,
     buy_sell_flag,
     curve_type,
     curve_id,
     deal_volume_frequency,
     deal_volume_uom_id,
     currency_id,
     block_description,
     template_id,
     commodity_id,
     physical_financial_flag,
     location_id,
     meter_id,
     strip_months_from,
     lag_months,
     strip_months_to,
     conversion_factor,
     formula,
     pay_opposite,
     settlement_currency,
     standard_yearly_volume,
     price_uom_id,
     category,
     profile_code,
     pv_party,
     adder_currency_id,
     booked,
     capacity,
     day_count_id,
     deal_detail_description,
     fixed_cost,
     fixed_cost_currency_id,
     formula_currency_id,
     formula_curve_id,
     formula_id,
     multiplier,
     option_strike_price,
     price_adder,
     price_adder_currency2,
     price_adder2,
     price_multiplier,
     process_deal_status,
     settlement_date,
     settlement_uom,
     settlement_volume,
     total_volume,
     volume_left,
     volume_multiplier2,
     term_start,
     term_end,
     contract_expiration_date,
     fixed_price,
     fixed_price_currency_id,
     deal_volume
   )
 VALUES
   (
     @leg,
     @fixed_float_leg,
     @buy_sell_flag,
     @curve_type,
     @curve_id,
     @deal_volume_frequency,
     @deal_volume_uom_id,
     @currency_id,
     @block_description,
     @template_id,
     @commodity_id,
     @physical_financial_flag,
     @location_id,
     @meter_id,
     @strip_months_from,
     @lag_months,
     @strip_months_to,
     @conversion_factor,
     @formula,
     @pay_opposite,
     @settlement_currency,
     @standard_yearly_volume,
     @price_uom_id,
     @category,
     @profile_code,
     @pv_party,
     @adder_currency_id,
     @booked,
     @capacity,
     @day_count_id,
     @deal_detail_description,
     @fixed_cost,
     @fixed_cost_currency_id,
     @formula_currency_id,
     @formula_curve_id,
     @formula_id,
     @multiplier,
     @option_strike_price,
     @price_adder,
     @price_adder_currency2,
     @price_adder2,
     @price_multiplier,
     @process_deal_status,
     @settlement_date,
     @settlement_uom,
     @settlement_volume,
     @total_volume,
     @volume_left,
     @volume_multiplier2,
     @term_start,
     @term_end,
     @contract_expiration_date,
     @fixed_price,
     @fixed_price_currency_id,
     @deal_volume
   )  
 If @@error <> 0  
  Exec spa_ErrorHandler @@error, 'Source Deal Detail Template',   
    'spa_Source_Deal_Header_Template', 'DB Error',   
    'Failed to Insert the new Source Deal Detial Template.', ''  
 Else  
  Exec spa_ErrorHandler 0, 'Source Deal Detial Template',   
    'spa_Source_Deal_Detial_Template', 'Success',   
    'New Source Deal Detial Template is successfully Inserted.', ''  
  
   
end  
  
ELSE If @flag='u'  
begin  



DECLARE @idoc int    

EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue    


SELECT  
 template_detail_id,    
 leg,    
 fixed_float_leg,    
 buy_sell_flag,    
 curve_type,   
 curve_id,  
 deal_volume_frequency,  
 deal_volume_uom_id,   
 currency_id,   
 block_description,  
 template_id,   
 commodity_id,  
 day_count,   
 physical_financial_flag,    
 location_id,   
 meter_id,  
 strip_months_from,  
 lag_months,  
 strip_months_to,  
 conversion_factor,  
 pay_opposite,  
 formula,  
 settlement_currency,  
 standard_yearly_volume,  
 price_uom_id,  
 category,  
 profile_code,  
 pv_party,
 fixed_price,
 fixed_price_currency_id,
 dbo.FNACovertToSTDDate(term_start) term_start,
 dbo.FNACovertToSTDDate(term_end) term_end, 
 dbo.FNACovertToSTDDate(contract_expiration_date) contract_expiration_date,
 booked , 
 capacity,
 day_count_id ,
 deal_detail_description,  
 fixed_cost, 
 fixed_cost_currency_id , 
 formula_currency_id,
 formula_curve_id ,
 formula_id , 
 multiplier,
 option_strike_price,
 price_adder,
 price_adder_currency2,
 price_adder2,
 price_multiplier,
 process_deal_status ,
 dbo.FNACovertToSTDDate(settlement_date) settlement_date, 
 settlement_uom,
 settlement_volume, 
 total_volume,  
 volume_left,
 volume_multiplier2,
 deal_volume,
 adder_currency_id,
 [status],
 lock_deal_detail,
 detail_commodity_id,
 origin, 
 form, 
 organic, 
 attribute1, 
 attribute2,
 attribute3, 
 attribute4, 
 attribute5,
 position_uom,
 detail_inco_terms, 
 detail_sample_control, 
 lot,
 batch_id, 
 crop_year,
 buyer_seller_option,
 product_description,
 profile_id,
 premium_settlement_date,
 no_of_strikes,
 strike_granularity,
 delivery_date,
 payment_date,
 upstream_counterparty,
 upstream_contract,
 fx_conversion_rate,
 vintage,
 position_formula_id
 delivery_date_to,
 actual_delivery_date,
 pnl_date,
 shipper_code1,
 shipper_code2
INTO     
 #ztbl_xmlvalue    
FROM       
 OPENXML (@idoc, '/Root/PSRecordset',2)    
 WITH (    
 template_detail_id   NVARCHAR(1000) '@template_detail_id',    
 leg   int '@leg',    
 fixed_float_leg   NCHAR(1) '@fixed_float_leg',    
 buy_sell_flag   NCHAR(1) '@buy_sell_flag',    
 curve_type  int '@curve_type',   
 curve_id int '@curve_id',  
 deal_volume_frequency NCHAR(1) '@deal_volume_frequency',  
 deal_volume_uom_id  int '@deal_volume_uom_id',   
 currency_id  int '@currency_id',   
 block_description NVARCHAR(150) '@block_description',  
 template_id  int '@template_id',   
 commodity_id int '@commodity_id',  
 day_count  int '@day_count',   
 physical_financial_flag   NCHAR(1) '@physical_financial_flag',    
 location_id  int '@location_id',   
 meter_id int '@meter_id',  
 strip_months_from int '@strip_months_from',  
 lag_months int '@lag_months',  
 strip_months_to int '@strip_months_to',  
 conversion_factor float '@conversion_factor',  
 pay_opposite NVARCHAR(50) '@pay_opposite',  
 formula NVARCHAR(100) '@formula',  
 settlement_currency int '@settlement_currency',  
 standard_yearly_volume float '@standard_yearly_volume',  
 price_uom_id int '@price_uom_id',  
 category int '@category',  
 profile_code int '@profile_code',  
 pv_party  int '@pv_party' ,
 fixed_price NVARCHAR(100) '@fixed_price',
 fixed_price_currency_id INT '@fixed_price_currency_id',  
 term_start NVARCHAR(100) '@term_start',
 term_end NVARCHAR(100) '@term_end', 
 contract_expiration_date NVARCHAR(100) '@contract_expiration_date',
 booked NCHAR '@booked', 
 capacity NVARCHAR(100) '@capacity',
 day_count_id INT '@day_count_id',
 deal_detail_description NVARCHAR(100) '@deal_detail_description',  
 fixed_cost NVARCHAR(100) '@fixed_cost', 
 fixed_cost_currency_id INT '@fixed_cost_currency_id', 
 formula_currency_id INT '@formula_currency_id',
 formula_curve_id INT '@formula_curve_id',
 formula_id INT '@formula_id', 
 multiplier NVARCHAR(100) '@multiplier',
 option_strike_price NVARCHAR(100) '@option_strike_price',
 price_adder NVARCHAR(100) '@price_adder',
 price_adder_currency2 INT '@price_adder_currency2',
 price_adder2 NVARCHAR(100) '@price_adder2',
 price_multiplier NVARCHAR(100) '@price_multiplier',
 process_deal_status INT '@process_deal_status',
 settlement_date NVARCHAR(100) '@settlement_date', 
 settlement_uom INT '@settlement_uom',
 settlement_volume FLOAT(53) '@settlement_volume', 
 total_volume NVARCHAR(100) '@total_volume',  
 volume_left FLOAT '@volume_left',
 volume_multiplier2 NVARCHAR(100) '@volume_multiplier2',
 deal_volume  NVARCHAR(100) '@deal_volume',  
 adder_currency_id INT '@adder_currency_id',
 [status] NVARCHAR(100) '@status',
lock_deal_detail NCHAR(1) '@lock_deal_detail',
detail_commodity_id INT '@detail_commodity_id',
origin INT '@origin', 
[form] INT '@form', 
organic NCHAR(1) '@organic', 
attribute1 INT '@attribute1', 
attribute2 INT '@attribute2',
attribute3 INT '@attribute3', 
attribute4 INT '@attribute4', 
attribute5 INT '@attribute5',
position_uom INT '@position_uom',
detail_inco_terms INT '@detail_inco_terms', 
detail_sample_control NCHAR(1) '@detail_sample_control', 
lot NVARCHAR(1000) '@lot',
batch_id NVARCHAR(1000) '@batch_id', 
crop_year INT '@crop_year',
buyer_seller_option INT '@buyer_seller_option',
product_description NVARCHAR(500) '@product_description',
profile_id INT '@profile_id',
premium_settlement_date NVARCHAR(100) '@premium_settlement_date',
no_of_strikes INT '@no_of_strikes',
strike_granularity INT '@strike_granularity',
delivery_date DATETIME '@delivery_date',
payment_date NVARCHAR(100) '@payment_date',
upstream_counterparty INT '@upstream_counterparty',
upstream_contract INT '@upstream_contract',
fx_conversion_rate FLOAT '@fx_conversion_rate',
vintage INT '@vintage',
position_formula_id INT '@position_formula_id',
delivery_date_to DATETIME '@delivery_date_to',
actual_delivery_date DATETIME '@actual_delivery_date',
pnl_date DATETIME '@pnl_date',
shipper_code1 INT '@shipper_code1',
shipper_code2 INT '@shipper_code2'
) 
-----------------------------------Start of Min and Max value validation-------------------------------------------------

SELECT 
       @fields = COALESCE(@fields + ',', ' ' ) + cast(mfd.farrms_field_id AS NVARCHAR(30))
      
FROM   maintain_field_template_detail mftd
       INNER JOIN maintain_field_deal mfd
            ON  mftd.field_id = mfd.field_id
            AND mftd.udf_or_system = 's'
            AND mfd.header_detail = 'd'
WHERE  mftd.field_template_id = @field_template_id
       AND (NULLIF(mftd.min_value, 0) IS NOT NULL OR NULLIF(mftd.max_value, 0) IS NOT NULL)

SET @SQLString =  '
			DECLARE @error_field NVARCHAR(100)
			DECLARE @min_value FLOAT
			DECLARE @max_value FLOAT
			DECLARE @msg NVARCHAR(1000)
			
			SELECT @error_field = mfd.default_label,
					@min_value = mftd.min_value,
					@max_value = mftd.max_value
			FROM   maintain_field_template_detail mftd
			       INNER JOIN maintain_field_deal mfd
			            ON  mftd.field_id = mfd.field_id
			            AND mftd.udf_or_system = ''s''
			            AND mfd.header_detail = ''d''
			       INNER JOIN (
			                SELECT ' +  @fields + '
			                FROM   #ztbl_xmlvalue
			            )p
			            UNPIVOT(col_value FOR field IN (' +  @fields + ')) AS 
			            unpvt
			            ON  unpvt.field = mfd.farrms_field_id
			            AND (
			                    unpvt.col_value < mftd.min_value
			                    OR unpvt.col_value > mftd.max_value
			                )
			WHERE  mftd.field_template_id = ' + CAST(@field_template_id AS NVARCHAR(10)) + '
			       AND (mftd.min_value IS NOT NULL OR mftd.max_value IS NOT NULL)
			
			IF @error_field IS NOT NULL 
				SET @msg = ''The value for '' + cast(@error_field as NVARCHAR(100)) + '' should be between '' + cast(@min_value as NVARCHAR(100)) + '' and '' + cast(@max_value as NVARCHAR(100)) + ''.'' 
			
			SET @max_titleOUT = 0
			IF  @msg IS NOT NULL 
			BEGIN
				EXEC spa_ErrorHandler -1, ''Error'', 
								''spa_InsertDealXmlBlotter'', ''DB Error'', 
								@msg, @msg						
				
				SET @max_titleOUT = 1	
			END
			
   '
   SET @ParmDefinition = N'@level tinyint, @max_titleOUT NVARCHAR(30) OUTPUT';
EXEC spa_print '---------------------------------------------------------------------------------------'

EXECUTE sp_executesql @SQLString, @ParmDefinition, @level = @IntVariable, @max_titleOUT=@return OUTPUT;

--Return if column value is not between min and max value
IF @return = 1
    RETURN 

-----------------------------------End of Min and Max value validation-------------------------------------------------


--UPDATE #ztbl_xmlvalue SET curve_id=CASE WHEN curve_id=0 THEN NULL ELSE curve_id end
UPDATE #ztbl_xmlvalue SET deal_volume_uom_id=CASE WHEN deal_volume_uom_id=0 THEN NULL ELSE deal_volume_uom_id end
UPDATE #ztbl_xmlvalue SET location_id=CASE WHEN location_id=0 THEN NULL  ELSE location_id end
UPDATE #ztbl_xmlvalue SET deal_volume_frequency=CASE WHEN  deal_volume_frequency='' THEN NULL ELSE deal_volume_frequency end
UPDATE #ztbl_xmlvalue SET fixed_price_currency_id = CASE WHEN fixed_price_currency_id = 0 THEN NULL ELSE fixed_price_currency_id END 
UPDATE #ztbl_xmlvalue SET day_count_id = CASE WHEN day_count_id = 0 THEN NULL ELSE day_count_id END 
UPDATE #ztbl_xmlvalue SET formula_curve_id = CASE WHEN formula_curve_id = 0 THEN NULL ELSE formula_curve_id END 
UPDATE #ztbl_xmlvalue SET [status] = CASE WHEN [status] = 0 THEN NULL ELSE [status] END 


UPDATE #ztbl_xmlvalue SET total_volume=NULL WHERE total_volume = ''
UPDATE #ztbl_xmlvalue SET capacity=NULL WHERE capacity = ''
UPDATE #ztbl_xmlvalue SET fixed_price=NULL WHERE fixed_price = ''
UPDATE #ztbl_xmlvalue SET fixed_cost=NULL WHERE fixed_cost = ''
UPDATE #ztbl_xmlvalue SET price_adder=NULL WHERE price_adder = ''
UPDATE #ztbl_xmlvalue SET price_adder2=NULL WHERE price_adder2 = ''
UPDATE #ztbl_xmlvalue SET price_multiplier=NULL WHERE price_multiplier = ''
UPDATE #ztbl_xmlvalue SET option_strike_price=NULL WHERE option_strike_price = ''

UPDATE #ztbl_xmlvalue SET volume_multiplier2 = NULL WHERE volume_multiplier2 = ''
--UPDATE #ztbl_xmlvalue SET multiplier = NULL WHERE multiplier = ''
UPDATE #ztbl_xmlvalue SET multiplier = NULL WHERE multiplier = '' 
UPDATE #ztbl_xmlvalue SET deal_volume = NULL WHERE deal_volume = ''
UPDATE #ztbl_xmlvalue SET formula_id = NULL WHERE formula_id = ''

UPDATE #ztbl_xmlvalue SET standard_yearly_volume = NULL WHERE standard_yearly_volume = ''
UPDATE #ztbl_xmlvalue SET price_uom_id = NULL WHERE price_uom_id = ''
UPDATE #ztbl_xmlvalue SET category = NULL WHERE category = ''
UPDATE #ztbl_xmlvalue SET meter_id = NULL WHERE meter_id = ''

UPDATE #ztbl_xmlvalue SET settlement_uom = NULL WHERE settlement_uom = ''
UPDATE #ztbl_xmlvalue SET settlement_volume = NULL WHERE settlement_volume = ''
UPDATE #ztbl_xmlvalue SET process_deal_status = NULL WHERE process_deal_status = ''
UPDATE #ztbl_xmlvalue SET adder_currency_id = NULL WHERE adder_currency_id = ''
UPDATE #ztbl_xmlvalue SET fixed_cost_currency_id = NULL WHERE fixed_cost_currency_id = ''
UPDATE #ztbl_xmlvalue SET formula_currency_id = NULL WHERE formula_currency_id = ''
UPDATE #ztbl_xmlvalue SET price_adder_currency2 = NULL WHERE price_adder_currency2 = ''
UPDATE #ztbl_xmlvalue SET settlement_currency = NULL WHERE settlement_currency = ''
UPDATE #ztbl_xmlvalue SET profile_code = NULL WHERE profile_code = ''
UPDATE #ztbl_xmlvalue SET pv_party = NULL WHERE pv_party = ''
UPDATE #ztbl_xmlvalue SET location_id = NULL WHERE location_id = ''
UPDATE #ztbl_xmlvalue SET curve_id = (CASE WHEN fixed_float_leg = 't' THEN curve_id WHEN fixed_float_leg = 'f' THEN  NULL END)
UPDATE #ztbl_xmlvalue SET pay_opposite = 'Y' WHERE pay_opposite <> 'n' OR pay_opposite IS NULL

UPDATE #ztbl_xmlvalue SET [origin] = CASE WHEN [origin] = 0 THEN NULL ELSE [origin] END 
UPDATE #ztbl_xmlvalue SET [form] = CASE WHEN [form] = 0 THEN NULL ELSE [form] END 
UPDATE #ztbl_xmlvalue SET [attribute1] = CASE WHEN [attribute1] = 0 THEN NULL ELSE [attribute1] END 
UPDATE #ztbl_xmlvalue SET [attribute2] = CASE WHEN [attribute2] = 0 THEN NULL ELSE [attribute2] END 
UPDATE #ztbl_xmlvalue SET [attribute3] = CASE WHEN [attribute3] = 0 THEN NULL ELSE [attribute3] END 
UPDATE #ztbl_xmlvalue SET [attribute4] = CASE WHEN [attribute4] = 0 THEN NULL ELSE [attribute4] END 
UPDATE #ztbl_xmlvalue SET [attribute5] = CASE WHEN [attribute5] = 0 THEN NULL ELSE [attribute5] END 
UPDATE #ztbl_xmlvalue SET detail_commodity_id = CASE WHEN [detail_commodity_id] = 0 THEN NULL ELSE detail_commodity_id END 


UPDATE #ztbl_xmlvalue SET position_uom = CASE WHEN ISNULL(NULLIF(position_uom, ''), 0) = 0 THEN NULL ELSE position_uom END 
UPDATE #ztbl_xmlvalue SET detail_inco_terms = CASE WHEN ISNULL(NULLIF(detail_inco_terms, ''), 0) = 0 THEN NULL ELSE detail_inco_terms END  
UPDATE #ztbl_xmlvalue SET detail_sample_control = 'y' WHERE detail_sample_control <> 'n' OR detail_sample_control IS NULL 
UPDATE #ztbl_xmlvalue SET lot = NULL WHERE lot = ''
UPDATE #ztbl_xmlvalue SET batch_id = NULL WHERE batch_id = ''
UPDATE #ztbl_xmlvalue SET crop_year = CASE WHEN ISNULL(NULLIF(crop_year, ''), 0) = 0 THEN NULL ELSE crop_year END 
UPDATE #ztbl_xmlvalue SET buyer_seller_option = CASE WHEN ISNULL(NULLIF(buyer_seller_option, ''), 0) = 0 THEN NULL ELSE buyer_seller_option END 
UPDATE #ztbl_xmlvalue SET product_description = NULL WHERE product_description = ''
UPDATE #ztbl_xmlvalue SET profile_id = CASE WHEN ISNULL(NULLIF(profile_id, ''), 0) = 0 THEN NULL ELSE profile_id END
UPDATE #ztbl_xmlvalue SET no_of_strikes = CASE WHEN ISNULL(NULLIF(no_of_strikes, ''), 0) = 0 THEN NULL ELSE no_of_strikes END
UPDATE #ztbl_xmlvalue SET strike_granularity = CASE WHEN ISNULL(NULLIF(strike_granularity, ''), 0) = 0 THEN NULL ELSE strike_granularity END
UPDATE #ztbl_xmlvalue SET payment_date = NULL WHERE payment_date = ''
UPDATE #ztbl_xmlvalue SET upstream_counterparty = CASE WHEN upstream_counterparty=0 THEN NULL ELSE upstream_counterparty END
UPDATE #ztbl_xmlvalue SET upstream_contract = CASE WHEN upstream_contract=0 THEN NULL ELSE upstream_contract END

 update source_deal_detail_template  
 set  
	leg = t.leg,   
	fixed_float_leg = t.fixed_float_leg,   
	buy_sell_flag = t.buy_sell_flag,   
	curve_type=t.curve_type,  
	curve_id = t.curve_id,   
	deal_volume_frequency = t.deal_volume_frequency,   
	deal_volume_uom_id = t.deal_volume_uom_id,   
	currency_id=t.currency_id,  
	block_description = t.block_description,   
	commodity_id=t.commodity_id,  
	day_count=t.day_count,  
	physical_financial_flag = t.physical_financial_flag,  
	location_id = t.location_id,  
	meter_id=t.meter_id,  
	strip_months_from=t.strip_months_from,  
	lag_months=t.lag_months,  
	strip_months_to=t.strip_months_to,  
	conversion_factor=t.conversion_factor,  
	formula = t.formula,  
	pay_opposite = t.pay_opposite,    
	settlement_currency=t.settlement_currency,  
	standard_yearly_volume=t.standard_yearly_volume,  
	price_uom_id=t.price_uom_id,  
	category=t.category,  
	profile_code = t.profile_code,  
	pv_party = t.pv_party,
	fixed_price= CAST(t.fixed_price AS NUMERIC(38,17)),
	fixed_price_currency_id=t.fixed_price_currency_id,
	term_start = t.term_start,
	term_end = t.term_end,
	contract_expiration_date = t.contract_expiration_date,
	booked = t.booked, 
	capacity = CAST(t.capacity AS NUMERIC(38,17)),
	day_count_id = t.day_count_id,
	deal_detail_description = t.deal_detail_description,  
	fixed_cost = CAST(t.fixed_cost AS NUMERIC(38,17)), 
	fixed_cost_currency_id = t.fixed_cost_currency_id, 
	formula_currency_id = t.formula_currency_id,
	formula_curve_id = t.formula_curve_id,
	formula_id = t.formula_id, 
	multiplier= CAST(t.multiplier AS NUMERIC(38,17)),
	option_strike_price = CAST(t.option_strike_price AS NUMERIC(38,17)),
	price_adder = CAST(t.price_adder AS NUMERIC(38,17)),
	price_adder_currency2 = t.price_adder_currency2,
	price_adder2 =  CAST(t.price_adder2 AS NUMERIC(38,17)),
	price_multiplier=  CAST(t.price_multiplier AS NUMERIC(38,17)),
	process_deal_status = t.process_deal_status,
	settlement_date = t.settlement_date, 
	settlement_uom = t.settlement_uom,
	settlement_volume = t.settlement_volume, 
	total_volume = CAST(t.total_volume AS NUMERIC(38,17)),  
	volume_left = t.volume_left,
	volume_multiplier2 = CAST(t.volume_multiplier2 AS NUMERIC(38,17)),
	deal_volume = CAST(t.deal_volume AS NUMERIC(38,17)),
	adder_currency_id = t.adder_currency_id,
	[status] = t.[status],
	lock_deal_detail = t.lock_deal_detail,
	detail_commodity_id = t.detail_commodity_id,
	origin = t.origin,
	form = t.form,
	organic = t.organic,
	attribute1 = t.attribute1,
	attribute2 = t.attribute2,
	attribute3 = t.attribute3,
	attribute4 = t.attribute4,
	attribute5 = t.attribute5,
	position_uom = t.position_uom,
	detail_inco_terms = t.detail_inco_terms,
	detail_sample_control = t.detail_sample_control,
	lot = t.lot,
	batch_id = t.batch_id,
	crop_year = t.crop_year,
	buyer_seller_option = t.buyer_seller_option,
	product_description = t.product_description,
	profile_id = t.profile_id,
	premium_settlement_date = t.premium_settlement_date,
	no_of_strikes = t.no_of_strikes,
	strike_granularity = t.strike_granularity,
	delivery_date = t.delivery_date,
	upstream_counterparty = t.upstream_counterparty,
	upstream_contract = t.upstream_contract
 FROM source_deal_detail_template sddt JOIN #ztbl_xmlvalue   t  
 ON sddt.template_detail_id=t.template_detail_id   
 where sddt.template_id = @template_id  
   

DECLARE @udf            AS NVARCHAR(MAX)
DECLARE @udf_list       AS NVARCHAR(MAX)
DECLARE @udf_list_cast  AS NVARCHAR(MAX)

DECLARE @sql_string     AS NVARCHAR(MAX)
SELECT @udf = COALESCE(@udf + ', ', '') + 'udf___' + CAST(udf_user_field_id AS NVARCHAR(10)) 
       + ' NVARCHAR(150) '
       --' ' + CASE 
       --             WHEN data_type = 'datetime' THEN 'NVARCHAR(20)'
       --             WHEN data_type LIKE 'numeric%' THEN 'NVARCHAR(50)'
       --             ELSE data_type
       --        END + ' ' 
               
               + '''@udf___' + CAST(udf_user_field_id AS NVARCHAR(10)) 
       + '''',
       @udf_list = COALESCE(@udf_list + ', ', '') + 'udf___' + CAST(udf_user_field_id AS NVARCHAR(10)),
       @udf_list_cast = COALESCE(@udf_list_cast + ', ', '')       
       + 
       CASE WHEN field_type = 'a' THEN
       'CAST(dbo.FNACovertToSTDDate(udf___' + 
       CAST(udf_user_field_id AS NVARCHAR(10)) 
       + ') AS NVARCHAR(MAX)) udf___' 
       WHEN data_type LIKE 'numeric%' THEN
       'CAST(udf___' + 
       CAST(udf_user_field_id AS NVARCHAR(10)) 
       + ' AS NVARCHAR(MAX)) udf___'
       ELSE
       'CAST(udf___' + 
       CAST(udf_user_field_id AS NVARCHAR(10)) 
       + ' AS NVARCHAR(MAX)) udf___' 
       END
       + CAST(udf_user_field_id AS NVARCHAR(10))
FROM   user_defined_deal_fields_template_main
WHERE  template_id = @template_id
       AND udf_type = 'd'
       AND leg = 1

EXEC spa_print '-------------'
EXEC spa_print @template_id
EXEC spa_print @udf_list
EXEC spa_print @udf_list_cast
IF @udf_list IS NOT NULL 
BEGIN	
	DECLARE @udf1 NVARCHAR (2000)
	DECLARE @udf_list1 NVARCHAR(2000)
	DECLARE @udf_list_cast1 NVARCHAR(2000)
	SET @udf1 = ''
	SET @udf_list1 = ''
	SET @udf_list_cast1 = ''
	SET @udf1 = @udf + ', leg int ''@leg'''
	SET @udf_list1 = @udf_list + ', leg' 
	SET @udf_list_cast1 = @udf_list_cast + ', CAST(leg AS NVARCHAR(MAX)) leg'
	--SELECT @udf
	--SELECT @udf_list
	--SELECT @udf_list_cast
	SET  @sql_string =
	' 
	DECLARE @idoc_UDF INT

	EXEC sp_xml_preparedocument @idoc_UDF OUTPUT,''' + CAST(@xmlValue AS NVARCHAR(MAX)) + ''' 


	SELECT ' + @udf_list1 + ' INTO #temp_udf_field FROM  OPENXML (@idoc_UDF , ''/Root/PSRecordsetUDF'',2)    
	 WITH (' + @udf1 + ')
	 
	 --select * from #temp_udf_field
	
	 select UDF_field, UDF_value, leg into #temp_udf_field_unpivot from  
	 (select ' + @udf_list_cast + ', cast(leg as NVARCHAR(MAX)) leg from #temp_udf_field) as p
	 UNPIVOT
	 (UDF_value FOR UDF_field IN (' + @udf_list + ')) as up
	
	 --select * from #temp_udf_field_unpivot
	
	 update #temp_udf_field_unpivot set UDF_Field = replace(UDF_Field, ''udf___'', '''')
	
	 UPDATE uddft  
	 SET default_value = tuf.UDF_value
	 --select *
	 FROM user_defined_deal_fields_template_main uddft INNER JOIN #temp_udf_field_unpivot tuf ON uddft.udf_user_field_id = tuf.UDF_field and uddft.leg = tuf.leg
	 where uddft.udf_type = ''d'' and uddft.template_id = ' + CAST(@template_id AS NVARCHAR(10))   
	 
	 
	 
	EXEC spa_print @sql_string
	EXEC(@sql_string) 
END
ELSE
EXEC spa_print 'NO UDF FIELDS AVAILABLE'
  
  
 If @@error <> 0  
  Exec spa_ErrorHandler @@error, 'Source Deal Detial Template',   
    'spa_Source_Deal_Detial_Template', 'DB Error',   
    'Failed to Update the  Source Deal Detial Template.', ''  
 Else  
  Exec spa_ErrorHandler 0, 'Source Deal Detial Template',   
    'spa_Source_Deal_Detial_Template', 'Success',   
    'Source Deal Template is successfully Updated.', ''  
   
end  
  
else If @flag='d'  
  
BEGIN  
	DELETE uddft FROM user_defined_deal_fields_template_main uddft
	INNER JOIN source_deal_detail_template sddt ON sddt.template_id = uddft.template_id
		AND sddt.leg = uddft.leg
	INNER JOIN dbo.SplitCommaSeperatedValues(@template_detail_id) scsv ON scsv.Item = sddt.template_detail_id
	
	DELETE sddt FROM source_deal_detail_template	sddt
	INNER JOIN dbo.SplitCommaSeperatedValues(@template_detail_id) scsv ON scsv.Item = sddt.template_detail_id
  
	IF @@error <> 0  
		Exec spa_ErrorHandler @@error, 'Source Deal Detail Template',   
		'spa_Source_Deal_Detial_Template', 'DB Error',   
		'Failed to Delete the selected Source Deal Detail Template.', ''  
	ELSE  
	BEGIN  
		
		--SELECT @leg leg, @template_id template_id
		CREATE TABLE #temp_leg
		(
			leg                 INT IDENTITY(1, 1),
			template_detail_id  INT
		)
		
		
		INSERT INTO #temp_leg (template_detail_id)
		SELECT template_detail_id
		FROM   source_deal_detail_template
		WHERE  template_id = @template_id
		ORDER BY
		       template_detail_id ASC   		
		
		-- rebuild leg for source_deal_detail_template
		UPDATE uddft SET leg = tl.leg
		FROM user_defined_deal_fields_template_main uddft
		INNER JOIN source_deal_detail_template sddt ON sddt.template_id = uddft.template_id
		AND sddt.leg = uddft.leg
		INNER JOIN #temp_leg tl ON sddt.template_detail_id = tl.template_detail_id	
		where  uddft.template_id = @template_id  
		
		-- rebuild leg for source_deal_detail_template
		UPDATE sddt SET leg = tl.leg
		FROM source_deal_detail_template sddt	
		INNER JOIN #temp_leg tl ON sddt.template_detail_id = tl.template_detail_id	
		 where  template_id = @template_id   
			
			
			Exec spa_ErrorHandler 0, 'Source Deal Detail Template',   
			'spa_Source_Deal_Detial_Template', 'Success',   
			'Selected Source Deal Detail Template is successfully Deleted.', ''  
	END  
  
END  
--'x' for deleting those template detail exists in @template_detail_id of template id =@template_id
else If @flag='x'  
  
BEGIN  
	 IF  (@template_detail_id IS NOT NULL AND @template_id IS NOT NULL )
	  BEGIN
	  		DELETE uddft 
			--SELECT uddft.udf_template_id, sddt.template_detail_id, uddft.template_id, uddft.udf_type, uddft.leg
			FROM user_defined_deal_fields_template_main uddft
			LEFT JOIN source_deal_detail_template sddt
			ON sddt.template_id = uddft.template_id AND sddt.leg = uddft.leg
			LEFT JOIN dbo.SplitCommaSeperatedValues(@template_detail_id) scsv	
			ON scsv.item = sddt.template_detail_id
			WHERE sddt.template_id = @template_id
			AND scsv.item IS NOT NULL

			--DECLARE @SQL_qry NVARCHAR(MAX)
			--PRINT @template_id
			--PRINT @template_detail_id
			--set @SQL_qry = 'DELETE sddt 
			----SELECT * 
			--FROM source_deal_detail_template	sddt
			--left JOIN dbo.SplitCommaSeperatedValues(@template_detail_id) scsv	
			--ON scsv.item = sddt.template_detail_id
			--WHERE sddt.template_id = @template_id
			--AND scsv.item IS NOT NULL'
			--PRINT @SQL_qry
			
			DELETE sddt 
			--SELECT * 
			FROM source_deal_detail_template	sddt
			left JOIN dbo.SplitCommaSeperatedValues(@template_detail_id) scsv	
			ON scsv.item = sddt.template_detail_id
			WHERE sddt.template_id = @template_id
			AND scsv.item IS NOT NULL
			
			IF @@error <> 0  
				Exec spa_ErrorHandler @@error, 'Source Deal Detail Template',   
				'spa_Source_Deal_Detial_Template', 'DB Error',   
				'Failed to Delete the selected Source Deal Detail Template.', ''  
			ELSE  
			BEGIN  
				--UPDATE source_deal_detail_template SET leg=leg-1 where leg > @leg AND template_id = @template_id   
				CREATE TABLE #temp_leg1
				(
					leg                 INT IDENTITY(1, 1),
					template_detail_id  INT
				)
				
				
				INSERT INTO #temp_leg1 (template_detail_id)
				SELECT template_detail_id
				FROM   source_deal_detail_template
				WHERE  template_id = @template_id
				ORDER BY
					   template_detail_id ASC   		
				
				-- rebuild leg for source_deal_detail_template
				UPDATE uddft SET leg = tl.leg
				FROM user_defined_deal_fields_template_main uddft
				INNER JOIN source_deal_detail_template sddt ON sddt.template_id = uddft.template_id
				AND sddt.leg = uddft.leg
				INNER JOIN #temp_leg1 tl ON sddt.template_detail_id = tl.template_detail_id	
				where  uddft.template_id = @template_id  
				
				-- rebuild leg for source_deal_detail_template
				UPDATE sddt SET leg = tl.leg
				FROM source_deal_detail_template sddt	
				INNER JOIN #temp_leg1 tl ON sddt.template_detail_id = tl.template_detail_id	
				 where  template_id = @template_id  
				 
					Exec spa_ErrorHandler 0, 'Source Deal Detail Template',   
					'spa_Source_Deal_Detial_Template', 'Success',   
					'Selected Source Deal Detail Template is successfully Deleted.', ''  
			END 
	  END
	 ELSE 
	 	BEGIN
	 		EXEC spa_print @template_detail_id 
	 		EXEC spa_print @template_id
	 	END
	 	
  
END 
  
else if @flag='c'  
  
Begin  
 update source_deal_detail_template set   
  deal_volume_frequency = @deal_volume_frequency,   
  deal_volume_uom_id = @deal_volume_uom_id  
  where template_id = @template_id and template_detail_id <> @template_detail_id  
  
 If @@error <> 0  
  Exec spa_ErrorHandler @@error, 'Source Deal Detail Template',   
    'spa_Source_Deal_Detial_Template', 'DB Error',   
    'Failed to copy the selected Source Deal Detail Template.', ''  
 Else  
  Exec spa_ErrorHandler 0, 'Source Deal Detail Template',   
    'spa_Source_Deal_Detial_Template', 'Success',   
    'Selected Source Deal Detail Template is successfully Copied.', ''  
   
End   

ELSE IF @flag = 'v'
BEGIN

 DECLARE @field_template_id1 AS INT
 DECLARE @header_buy_sell AS NCHAR(1)
 SELECT @field_template_id1 = field_template_id, @header_buy_sell = header_buy_sell_flag
 FROM   dbo.source_deal_header_template
 WHERE  template_id = @template_id   
 

 
 SELECT @leg = MAX(leg) + 1
 FROM   dbo.source_deal_detail_template
 WHERE  template_id = @template_id  
 
 IF @leg IS NULL
     SET @leg = 1 
	
	DECLARE @sql            AS NVARCHAR(MAX)
	DECLARE @col            AS NVARCHAR(MAX)
	DECLARE @default_value  AS NVARCHAR(MAX)	
	SELECT @col = COALESCE(@col + ', ', '') + farrms_field_id,
	       @default_value = COALESCE(@default_value + ', ', '') +	  
	       CASE 
	            WHEN mdf.farrms_field_id = 'buy_sell_flag' THEN '''' + @header_buy_sell + '''' -- detail buy/sell
	            WHEN mdf.farrms_field_id = 'Leg' THEN CAST(@leg AS NVARCHAR(10)) --leg
	            WHEN mdf.farrms_field_id = 'pay_opposite' THEN '''' + ISNULL(mftd.default_value, 'y') + ''''--pay_opposite
	            --WHEN (mdf.field_id IN (82,83) ) THEN  CASE WHEN mftd.default_value IS NULL THEN 'NULL' else '''' + dbo.FNAGetDefaultValue(GETDATE(),mftd.default_value) + '''' END
	            WHEN (mdf.farrms_field_id IN ('term_start','term_end') ) THEN ''''''

	            ELSE CASE 
	                      WHEN LOWER(mdf.data_type) IN ('int', 'float', 'numeric') 
	                           OR NULLIF(mftd.default_value, '') IS NULL THEN ISNULL(CAST(NULLIF(mftd.default_value, '') AS NVARCHAR(100)), 'NULL')
	                      ELSE '''' + CAST(mftd.default_value AS NVARCHAR(MAX)) + 
	                           ''''
	                 END
	       END

	FROM   maintain_field_template_detail mftd
	       INNER JOIN maintain_field_deal mdf
	            ON  mftd.field_id = mdf.field_id
	            AND mdf.header_detail = 'd'
	            AND mftd.udf_or_system = 's'
	       INNER JOIN source_deal_header_template sdht
				ON sdht.field_template_id = mftd.field_template_id
	WHERE  sdht.template_id = @template_id
	       AND mdf.farrms_field_id NOT IN ('source_deal_header_id', 'source_deal_detail_id')  
	       

	SET @sql = 'INSERT INTO source_deal_detail_template(template_id, ' + @col + ') VALUES(' + CAST(@template_id AS NVARCHAR(10))+ ',' + @default_value + ')'
	
	
	
	EXEC spa_print @sql
	EXEC(@sql)
	
		
	
	SELECT udf.udf_template_id,
	       udf.field_name,
	       udf.Field_label,
	       udf.Field_type,
	       udf.data_type,
	       udf.is_required,
	       ISNULL(NULLIF(udf.sql_string, ''), uds.sql_string) sql_string,
	       udf.create_user,
	       udf.create_ts,
	       udf.update_user,
	       udf.update_ts,
	       udf.udf_type,
	       udf.field_size,
	       udf.field_id,
	       mftd.[default_value],
	       udf.book_id,
	       udf.udf_group,
	       udf.udf_tabgroup,
	       udf.formula_id,
	       udf.internal_field_type 
	INTO #temp_UDF
	FROM maintain_field_template_detail mftd
	JOIN user_defined_fields_template udf
		ON  udf.udf_template_id = mftd.field_id
	LEFT JOIN udf_data_source uds 
		ON uds.udf_data_source_id = udf.data_source_type_id
	WHERE  mftd.field_template_id = @field_template_id1
	       AND mftd.udf_or_system = 'u'
	       AND udf.udf_type = 'd'

	
	INSERT INTO user_defined_deal_fields_template_main
	  (
	    field_name,
	    Field_label,
	    Field_type,
	    data_type,
	    is_required,
	    sql_string,
	    udf_type,
	    field_size,
	    field_id,
	    default_value,
	    udf_group,
	    udf_tabgroup,
	    formula_id,
	    template_id,
	    udf_user_field_id, 
	    leg
	  )
	SELECT field_name,
	       Field_label,
	       Field_type,
	       data_type,
	       is_required,
	       sql_string,
	       udf_type,
	       field_size,
	       field_id,
	       CASE WHEN Field_type = 'a' THEN dbo.FNAGetSQLStandardDate(default_value) ELSE default_value END default_value,
	       udf_group,
	       udf_tabgroup,
	       formula_id,
	       @template_id,
	       udf_template_id,
	       @leg	       
	FROM   #temp_UDF
	
	
	
	IF @@error <> 0
	     EXEC spa_ErrorHandler @@error,
	          'Source Deal Detail Template',
	          'spa_Source_Deal_Header_Template',
	          'DB Error',
	          'Failed to Insert the new Source Deal Detial Template.',
	          ''
	 ELSE
	     EXEC spa_ErrorHandler 0,
	          'Source Deal Detial Template',
	          'spa_Source_Deal_Detial_Template',
	          'Success',
	          'New Source Deal Detial Template is successfully Inserted.', ''  

	
END


  
/************************************* Object: 'spa_source_deal_detail_template' END *************************************/  
    