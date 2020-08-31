if object_id('spa_get_tax_percentage') is not null
	drop proc dbo.spa_get_tax_percentage

go

create proc dbo.spa_get_tax_percentage
	@charge_type_id int,--1 nmgrt; 2 compensesion; 3 spks; 4 city
	@source_deal_detail_id int,
	@prod_date datetime
as

/*

declare @charge_type_id int=2,
--1 nmgrt
--2 compensesion
--3 spks
--4 city
	@source_deal_detail_id int=81095,
	@prod_date datetime='2017-07-17'
--*/

IF OBJECT_ID('tempdb..#temp_curve_ids') IS NOT NULL
	DROP TABLE #temp_curve_ids
	
IF OBJECT_ID('tempdb..#gmv') IS NOT NULL
	DROP TABLE #gmv


DECLARE @curve_id INT
DECLARE @_loan_deal_id INT
DECLARE @sdv_from_deal VARCHAR(100)
DECLARE @cpty_id INT
--DECLARE @source_deal_detail_id INT

SELECT @sdv_from_deal =value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'From Deal'


if @charge_type_id in (1,3)
begin
	--#1 Added by PNM, Taxes were not being calced for Loan Paybacks based on Facility of original Buy Deal.
	SELECT  @_loan_deal_id = sdd1.source_deal_detail_id
	FROM   source_deal_header sdh 
		inner join source_deal_detail sdd on sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER join user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdd.source_deal_header_id  
		INNER JOIN user_defined_deal_fields_template uddft ON  uddft.template_id = sdh.template_id 
			AND uddft.field_label = 'Loan Deal ID' and uddft.udf_template_id = uddf.udf_template_id
		INNER JOIN source_deal_detail sdd1 ON sdd1.source_deal_header_id = uddf.udf_value
		WHERE
			sdd.source_deal_detail_id = @source_deal_detail_id

	--#2 Added by PNM, If deal is Loan Payback, get CPTY from Payback deal for Tax Mapping
	select @cpty_id = sdh.counterparty_id from source_deal_header sdh
	inner join source_deal_detail sdd on sdh.source_deal_header_id = sdd.source_deal_header_id
	where sdd.source_deal_detail_id = @source_deal_detail_id
end
else
begin
	set @_loan_deal_id=null
	set @cpty_id=null
end

set @_loan_deal_id=isnull(@_loan_deal_id,@source_deal_detail_id)

--#3 Conditionally, If deal is Loan Payback the below statement will return the Tax Curve ID using the Loan Deal ID from original Buy Deal, but the CPTY_ID from the Payback Deal

select 
	CAST(sdh.source_deal_header_id as VARCHAR(10)) source_deal_header_id,
	cast(clm4_value as int) to_location_id,
	case @charge_type_id
		when 1 then gmv.clm6_value -- nmgrt
		when 2 then gmv.clm7_value -- compensesion
		when 3 then gmv.clm8_value -- spks
		when 4 then gmv.clm9_value -- city
		else null
	end curve_id
into #gmv
FROM source_deal_detail sdd
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	and sdd.source_deal_detail_id = @_loan_deal_id
INNER JOIN generic_mapping_values gmv ON gmv.clm1_value=sdd.buy_sell_flag 
	AND gmv.clm2_value=CAST(isnull(@cpty_id,sdh.counterparty_id) AS VARCHAR)
	AND gmv.clm3_value=CAST(sdd.location_id AS VARCHAR) 
	--AND gmv.clm4_value=CAST(sdd_tran.location_id AS VARCHAR) 
INNER JOIN  generic_mapping_header gmh  ON  gmv.mapping_table_id = gmh.mapping_table_id
			and  gmh.mapping_name = 'TAX Rule Mapping'


SELECT top(1) @curve_id= gmv.curve_id
FROM  #gmv gmv
cross apply
(
select --top(1) 
	uddf.source_deal_header_id 
	from user_defined_deal_fields uddf
	INNER JOIN user_defined_deal_fields_template uddft ON uddf.udf_template_id = uddft.udf_template_id 
		AND uddft.field_name = @sdv_from_deal
		and uddf.udf_value = gmv.source_deal_header_id
) tr
INNER JOIN source_deal_detail sdd_tran ON sdd_tran.source_deal_header_id = tr.source_deal_header_id 
	AND sdd_tran.leg = 2 --- and ????????? sdd.term_start=@prod_date
	AND gmv.to_location_id=sdd_tran.location_id


SELECT top(1) @prod_date prod_date, 0 [hr], 0 [mins], ISNULL(MAX(curve_value),0)  [curve_value]
--[__final_output__]
FROM (
SELECT MAX(as_of_date) as_of_date FROM  source_price_curve WHERE source_curve_def_id=@curve_id 
	AND as_of_date <= @prod_date
) spc
INNER JOIN source_price_curve spc1 ON spc1.source_curve_def_id = @curve_id
	AND spc1.as_of_date=spc1.maturity_date and spc1.as_of_date = spc.as_of_date 