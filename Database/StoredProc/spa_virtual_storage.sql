
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_virtual_storage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_virtual_storage]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.

-- Params:
-- @param1 @flag : to identify opertation
-- @param2 @general_assest_id : general asset id
-- @param3 @storage_location : storage location type
-- @param4 @storage_type : Storage type
-- @param5 @beg_storage_volume : Begining Storage Volume
-- @param6 @volumn_uom : UOM type
-- @param7 @beg_storage_cost : Begining Storage Cost 
-- @param8 @cost_currency : currency type
-- @param9 @agreement : agreement type
-- @param10 $@fee : fee type 
-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_virtual_storage]
@flag CHAR(1),
@general_assest_id INT = NULL,
@storage_location INT = NULL,
@storage_type INT = NULL,
@beg_storage_volume FLOAT = NULL,
@volumn_uom INT = NULL,
@beg_storage_cost FLOAT = NULL , 
@cost_currency INT = NULL,
@agreement INT = NULL,
@fees INT = NULL,
@internal_deal_type_value_id INT = NULL,
@schedule_injection_id INT = NULL,
@schedule_withdrawl_id INT = NULL,
@nomination_injection_id INT = NULL,
@nomination_withdrawl_id INT = NULL,
@actual_injection_id INT = NULL,
@actual_withdrawl_id INT = NULL,
@effective_date DATETIME = NULL,
@source_counterparty_id INT = NULL,
@inj_with char(1) = NULL,
@storage_position FLOAT = NULL, 
@process_id VARCHAR(200) = NULL
AS
set nocount on
/*
declare
@flag CHAR(1) = 'o',
@general_assest_id INT = NULL,
@storage_location INT = 2687,
@storage_type INT = NULL,
@beg_storage_volume FLOAT = NULL,
@volumn_uom INT = NULL,
@beg_storage_cost FLOAT = NULL , 
@cost_currency INT = NULL,
@agreement INT = NULL,
@fees INT = NULL,
@internal_deal_type_value_id INT = NULL,
@schedule_injection_id INT = NULL,
@schedule_withdrawl_id INT = NULL,
@nomination_injection_id INT = NULL,
@nomination_withdrawl_id INT = NULL,
@actual_injection_id INT = NULL,
@actual_withdrawl_id INT = NULL,
@effective_date DATETIME = '2017-11-03',
@source_counterparty_id INT = NULL,
@inj_with char(1) = 'i',
@storage_position FLOAT = '48546680'

--*/
IF @flag = 's'
BEGIN
	SELECT 
	general_assest_id AS Id,
	sml.Location_Name AS [Location Name],
	cg.contract_name AS [Contract Name],
	cpty.counterparty_name [Counterparty],
	sc.currency_name AS [Currency Type],
	su.uom_name AS [UOM Type],
	sdv.code AS [Fees],
	gaivs.beg_storage_volume AS [Begining Storage Volume],
	gaivs.beg_storage_cost AS [Begining Storage Cost],
	sdv1.code AS [Storage Type],
	sml.source_minor_location_id AS [Location Id]
	
	FROM [general_assest_info_virtual_storage] gaivs INNER JOIN contract_group cg ON cg.contract_id = gaivs.agreement
	INNER JOIN source_currency sc ON sc.source_currency_id = gaivs.cost_currency
	INNER JOIN source_minor_location sml ON sml.source_minor_location_id = gaivs.storage_location
	INNER JOIN source_uom su ON su.source_uom_id = gaivs.volumn_uom
	INNER JOIN static_data_value sdv ON sdv.value_id = gaivs.fees
	INNER JOIN static_data_value sdv1 ON sdv1.value_id = gaivs.storage_type
	left join source_counterparty cpty on cpty.source_counterparty_id = gaivs.source_counterparty_id
END

IF @flag = 'i'
BEGIN
	BEGIN TRY
	BEGIN TRAN 
		INSERT INTO [general_assest_info_virtual_storage]
		  (
		    storage_location,
		    storage_type,
		    beg_storage_volume,
		    volumn_uom,
		    beg_storage_cost,
		    cost_currency,
		    agreement,
		    fees,
		    schedule_injection_id,
		    schedule_withdrawl_id,
		    nomination_injection_id,
		    nomination_withdrawl_id,
		    actual_injection_id,
		    actual_withdrawl_id,
		    effective_date,
			source_counterparty_id
		  )
		VALUES 
		(
			@storage_location,
			@storage_type,
			@beg_storage_volume,
			@volumn_uom,
			@beg_storage_cost , 
			@cost_currency,
			@agreement,
			@fees,
			@schedule_injection_id,
			@schedule_withdrawl_id,
			@nomination_injection_id,
			@nomination_withdrawl_id,
			@actual_injection_id,
			@actual_withdrawl_id,
			dbo.FNADateFormat(@effective_date),
			@source_counterparty_id
		)
		
		COMMIT 
		DECLARE @last_id INT 
		SELECT @last_id = SCOPE_IDENTITY()
		EXEC spa_ErrorHandler 0
			, 'general_assest_info_virtual_storage table'--tablename
			, 'spa_virtual_storage'--sp
			, 'Success'--error type
			, 'Data insert successful Data.'
			, @last_id --personal msg
	END TRY
	BEGIN CATCH
	
		DECLARE @error VARCHAR(5000)
		SET @error = ERROR_MESSAGE()
		EXEC spa_ErrorHandler -1
			, 'general_assest_info_virtual_storage table'--tablename
			, 'spa_virtual_storage'--sp
			, 'DB Error'--error type
			, 'Failed Updating Data.'
			, @error --personal msg
			
		ROLLBACK 
		
	END CATCH
END

IF @flag = 'a'
BEGIN
	SELECT gaivs.general_assest_id,
	       gaivs.storage_location,
	       gaivs.storage_type,
	       gaivs.beg_storage_volume,
	       gaivs.volumn_uom,
	       gaivs.beg_storage_cost,
	       gaivs.cost_currency,
	       gaivs.agreement,
	       gaivs.fees,
	       sml.Location_Name,
	       gaivs.schedule_injection_id,
	       gaivs.schedule_withdrawl_id,
	       gaivs.nomination_injection_id,
	       gaivs.nomination_withdrawl_id,
	       gaivs.actual_injection_id,
	       gaivs.actual_withdrawl_id,
	       sdh1.deal_id,
	       sdh2.deal_id,
	       sdh3.deal_id,
	       sdh4.deal_id,
	       sdh5.deal_id,
	       sdh6.deal_id,
	       dbo.FNADateFormat(gaivs.effective_date),
		   gaivs.source_counterparty_id
	FROM   general_assest_info_virtual_storage gaivs
	       LEFT JOIN source_minor_location sml ON  sml.source_minor_location_id = gaivs.storage_location
	       LEFT JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = gaivs.schedule_injection_id
	       LEFT JOIN source_deal_header sdh2 ON sdh2.source_deal_header_id = gaivs.schedule_withdrawl_id
	       LEFT JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = gaivs.nomination_injection_id
	       LEFT JOIN source_deal_header sdh4 ON sdh4.source_deal_header_id = gaivs.nomination_withdrawl_id
	       LEFT JOIN source_deal_header sdh5 ON sdh5.source_deal_header_id = gaivs.actual_injection_id
	       LEFT JOIN source_deal_header sdh6 ON sdh6.source_deal_header_id = gaivs.actual_withdrawl_id
	WHERE  gaivs.general_assest_id = @general_assest_id
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
	BEGIN TRAN 
		UPDATE general_assest_info_virtual_storage
		SET    storage_location = @storage_location,
		       storage_type = @storage_type,
		       beg_storage_volume = @beg_storage_volume,
		       volumn_uom = @volumn_uom,
		       beg_storage_cost = @beg_storage_cost,
		       cost_currency = @cost_currency,
		       agreement = @agreement,
		       fees = @fees,
		       schedule_injection_id = @schedule_injection_id,
		       schedule_withdrawl_id = @schedule_withdrawl_id,
		       nomination_injection_id = @nomination_injection_id,
		       nomination_withdrawl_id = @nomination_withdrawl_id,
		       actual_injection_id = @actual_injection_id,
		       actual_withdrawl_id = @actual_withdrawl_id,
		       effective_date = dbo.FNADateFormat(@effective_date),
			   source_counterparty_id = @source_counterparty_id
		WHERE  general_assest_id = @general_assest_id
		
		COMMIT 
	
		EXEC spa_ErrorHandler 0
			, 'general_assest_info_virtual_storage table'--tablename
			, 'spa_virtual_storage'--sp
			, 'DB Error'--error type
			, 'Data Updated Successfully.'
			, 'Data Updated successfully.' --personal msg
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'general_assest_info_virtual_storage table'--tablename
			, 'spa_virtual_storage'--sp
			, 'DB Error'--error type
			, 'Failed Updating Data.'
			, 'Cannot Update Data.' --personal msg
			
		ROLLBACK 
	
	END CATCH
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
	BEGIN TRAN 
		DELETE FROM general_assest_info_virtual_storage WHERE general_assest_id = @general_assest_id
		
		COMMIT 
		
		EXEC spa_ErrorHandler 0
			, 'general_assest_info_virtual_storage table'--tablename
			, 'spa_virtual_storage'--sp
			, 'DB Error'--error type
			, 'Data Deleted Successfully.'
			, 'Data Deleted successfully.' --personal msg
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'general_assest_info_virtual_storage table'--tablename
			, 'spa_virtual_storage'--sp
			, 'DB Error'--error type
			, 'The selected data cannot be deleted.'
			, 'Cannot Delete Data.' --personal msg 
			
		ROLLBACK 
		
	END CATCH
END

IF @flag = 'w'
BEGIN
    SELECT *
    FROM   source_deal_header sdh
           INNER JOIN source_deal_detail sdd
                ON  sdd.source_deal_header_id = sdh.source_deal_header_id
    WHERE  sdh.internal_deal_type_value_id = @internal_deal_type_value_id
END
IF @flag = 'o' --get storage info call from optimization grid
BEGIN
	--EXTRACT LATEST DATEWISE MIN MAX INJECTION AND WITHDRAWAL VALUES START
	--extract latest effective date for path mdq
	if OBJECT_ID('tempdb..#tmp_st_eff_date') is not null 
	drop table #tmp_st_eff_date
	
	select st.storage_location, vsc.constraint_type, max(vsc.effective_date) effective_date
	into #tmp_st_eff_date
	from virtual_storage_constraint vsc
	inner join general_assest_info_virtual_storage st on st.general_assest_id = vsc.general_assest_id
	where st.storage_location = @storage_location and vsc.effective_date <= @effective_date
	group by st.storage_location, vsc.constraint_type

	if OBJECT_ID('tempdb..#tmp_st_capacity') is not null 
	drop table #tmp_st_capacity

	select *
	into #tmp_st_capacity
	from #tmp_st_eff_date t
	cross apply (
		select vsc.general_assest_id, vsc.value 
		from virtual_storage_constraint vsc 
		inner join general_assest_info_virtual_storage st on st.general_assest_id = vsc.general_assest_id
		where st.storage_location = t.storage_location and vsc.effective_date = t.effective_date and vsc.constraint_type = t.constraint_type
	) ca_lf
	--return
	--EXTRACT LATEST DATEWISE MIN MAX INJECTION AND WITHDRAWAL VALUES START

	SELECT st.general_assest_id [storage_asset_id]
		, sml.Location_Name [storage_location]
		, sml.source_minor_location_id [storage_location_id]
		, cg.contract_name [storage_contract]
		, cg.contract_id [storage_contract_id]
		, sml.Location_Name + '-' + cg.contract_name [storage_location_contract]
		, st.beg_storage_cost [storage_cost]
		, st.beg_storage_volume [storage_volume]
		, st.storage_type
		, st.fees [storage_fee]
		, isnull(min_inj.value, -1) [min_inj]
		, isnull(max_inj.value, -1) [max_inj]
		, isnull(min_wid.value, -1) [min_wid]
		, isnull(max_wid.value, -1) [max_wid]
		, ratchet.type [ratchet_type]
		, ratchet.term_from [ratchet_term_from]
		, ratchet.term_to [ratchet_term_to]
		, isnull(ratchet.fixed_value, 0) [ratchet_fixed_value]
	FROM general_assest_info_virtual_storage st
	INNER JOIN source_minor_location sml ON sml.source_minor_location_id = st.storage_location
	INNER JOIN contract_group cg ON cg.contract_id = st.agreement
	left join #tmp_st_capacity min_inj on min_inj.general_assest_id = st.general_assest_id 
		and min_inj.constraint_type = 18605 --minimum injection capacity value id
	left join #tmp_st_capacity max_inj on max_inj.general_assest_id = st.general_assest_id 
		and max_inj.constraint_type = 18601 --max injection capacity value id
	left join #tmp_st_capacity min_wid on min_wid.general_assest_id = st.general_assest_id 
		and min_wid.constraint_type = 18606 --minimum wid capacity value id
	left join #tmp_st_capacity max_wid on max_wid.general_assest_id = st.general_assest_id 
		and max_wid.constraint_type = 18602 --max wid capacity value id
	outer apply (
		--select top 1 sr.storage_ratchet_id, sr.term_from, sr.term_to, sr.type, sr.fixed_value
		--from storage_ratchet sr 
		--where sr.general_assest_id = st.general_assest_id
		--	and sr.term_from <= @effective_date and sr.term_to >= @effective_date

		select top 1  sr.storage_ratchet_id, sr.term_from, sr.term_to, sr.type, sr.fixed_value
			, (sr.gas_in_storage_perc_to/100.0) * (st.storage_capacity * case when st.volumn_uom = 1209 then 1000000 else 1 end) 
				[gas_in_storage_perc_to]
			, case 
				when @storage_position <= ((sr.gas_in_storage_perc_to/100.0) * (st.storage_capacity * case when st.volumn_uom = 1209 then 1000000 else 1 end)) then 1 
				else 0
			 end [pick_ratchet]
			, (st.storage_capacity * case when st.volumn_uom = 1209 then 1000000 else 1 end) [storage_capacity]
	
		from storage_ratchet sr  
		inner join general_assest_info_virtual_storage st on sr.general_assest_id = st.general_assest_id
		where sr.general_assest_id = st.general_assest_id 
			and sr.type = isnull(nullif(@inj_with, ''), 'i')
			and sr.term_from <= @effective_date and sr.term_to >= @effective_date
			and case 
					when @storage_position <= ((sr.gas_in_storage_perc_to/100.0) * (st.storage_capacity * case when st.volumn_uom = 1209 then 1000000 else 1 end)) then 1 
					else 0
				 end = 1
		order by gas_in_storage_perc_to asc
	) ratchet
	WHERE st.storage_location = @storage_location


	--select sr.storage_ratchet_id, sr.term_from, sr.term_to, sr.type, sr.fixed_value
	--, (sr.gas_in_storage_perc_to/100.0) * (st.storage_capacity * case when st.volumn_uom = 1209 then 1000000 else 1 end)
	--	[gas_in_storage_perc_to]
	--, case 
	--	when 22000000 <= ((sr.gas_in_storage_perc_to/100.0) * (st.storage_capacity * case when st.volumn_uom = 1209 then 1000000 else 1 end)) then 1 
	--	else 0
	-- end [pick_ratchet]
	--, st.storage_capacity 
	
	--from storage_ratchet sr  
	--inner join general_assest_info_virtual_storage st on sr.general_assest_id = st.general_assest_id
	--where sr.general_assest_id = 105 and sr.type = 'i' -- isnull(nullif(@inj_with, ''), 'i')
	--	and sr.term_from <= '2017-11-03' and sr.term_to >= '2017-11-03'
	--	and case 
	--			when 12000000 <= ((sr.gas_in_storage_perc_to/100.0) * (st.storage_capacity * case when st.volumn_uom = 1209 then 1000000 else 1 end)) then 1 
	--			else 0
	--		 end = 1
	--order by gas_in_storage_perc_to asc


END
IF @flag = 'c'
BEGIN

	SELECT general_assest_id value, location_name + '-' + cg.contract_name label
	FROM general_assest_info_virtual_storage g
	INNER JOIN source_minor_location sml
		ON g.storage_location = sml.source_minor_location_id
	INNER JOIN contract_group cg
		ON cg.contract_id = g.agreement
	WHERE storage_location = @storage_location 

END