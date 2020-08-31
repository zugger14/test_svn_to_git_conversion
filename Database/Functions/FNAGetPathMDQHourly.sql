SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	Tabled valued Function to get path mdq information.

	Parameters
	@path_id	: path id
	@term_start	: term start date
	@term_end	: term end date
	@data_level	: final data level groping. 
				  valid values: 
					path_term_hour	=> gives final data on path,contract,term,hour level with sum of mdq,used_mdq,rmdq
					path_hour		=> gives final data on path,contract,hour level with sum of mdq,used_mdq,rmdq
					path_term		=> gives final data on path,contract,term level with sum of mdq,used_mdq,rmdq

	USAGE: SELECT * FROM [dbo].[FNAGetPathMDQHourly] ('158', '2001-10-01', '2001-10-01', 'path_term_hour')
*/

CREATE OR ALTER FUNCTION [dbo].[FNAGetPathMDQHourly]
(
	@path_id VARCHAR(20) NULL,
	@term_start DATETIME NULL,
	@term_end DATETIME NULL,
	@data_level VARCHAR(200) NULL 
)
RETURNS @return_table TABLE (
	[path_id] INT NULL,
	[contract_id] INT NULL,
	[term_start] DATETIME NULL,
	[hour] INT NULL,
	[mdq] NUMERIC(10,4) NULL,
	[used_mdq] NUMERIC(10,4) NULL,
	[rmdq] NUMERIC(10,4) NULL,
	[is_complex] VARCHAR(10) NULL,
	[only_path_mdq] CHAR(1) NULL
)
AS
/*
DECLARE @path_id VARCHAR(20)
DECLARE	@term_start DATETIME
DECLARE	@term_end DATETIME
DECLARE @data_level VARCHAR(200)

DECLARE @return_table TABLE (
	[path_id] INT NULL,
	[contract_id] INT NULL,
	[term_start] DATETIME NULL,
	[hour] INT NULL,
	[mdq] NUMERIC(10,4) NULL,
	[used_mdq] NUMERIC(10,4) NULL,
	[rmdq] NUMERIC(10,4) NULL,
	[is_complex] VARCHAR(10) NULL,
	[only_path_mdq] CHAR(1) NULL
)

SELECT @path_id = '130', @term_start = '2027-08-01', @term_end = '2027-08-01', @data_level = ''

--*/
BEGIN
	SET @data_level = ISNULL(NULLIF(@data_level, ''), 'path_term_hour')
	
	--get locations, contract and mdq (defined on path itself) from path
	BEGIN
		DECLARE @location_ids TABLE (location_id INT NULL)
		DECLARE @contract_ids TABLE (contract_id INT NULL)
		
		INSERT INTO @location_ids
		SELECT dp.from_location
		FROM delivery_path dp
		WHERE dp.path_id = @path_id
		UNION
		SELECT dp.to_location
		FROM delivery_path dp
		WHERE dp.path_id = @path_id

		--collect child proxy locations
		INSERT INTO @location_ids
		SELECT sml.source_minor_location_id
		FROM source_minor_location sml 
		INNER JOIN @location_ids loc 
			ON loc.location_id = sml.proxy_location_id
		UNION --collect parent proxy locations
		SELECT sml.proxy_location_id
		FROM source_minor_location sml 
		INNER JOIN @location_ids loc 
			ON loc.location_id = sml.source_minor_location_id
		WHERE sml.proxy_location_id IS NOT NULL
		
		INSERT INTO @contract_ids
		SELECT ccrs.contract_id
		FROM counterparty_contract_rate_schedule ccrs
		WHERE ccrs.path_id = @path_id

	END

	--store location capacity hourly volume
	BEGIN
		DECLARE @loc_wise_capacity_hourly_mdq TABLE	(
			[proxy_location_id] INT NULL,
			[location_id] INT NULL,
			[contract_id] INT NULL,
			[term_start] DATETIME NULL,
			[hour] INT NULL,
			[hourly_mdq] NUMERIC(10,4) NULL,
			[hourly_mdq1] NUMERIC(10,4) NULL
		)

		INSERT INTO @loc_wise_capacity_hourly_mdq (
			[proxy_location_id],
			[location_id],
			[contract_id],
			[term_start],
			[hour],
			[hourly_mdq],
			[hourly_mdq1]
		)
		SELECT MAX(sml.proxy_location_id) [proxy_location_id]
			, sdd.location_id
			, sdh.contract_id
			, sddh.term_date [term_start]
			, CAST(LEFT(sddh.hr,2) AS INT) [hour]
			, SUM(
				CASE WHEN sdv_pg.code NOT IN ('Complex-EEX', 'Complex-LTO', 'Complex-ROD') OR sdv_pg.code IS NULL
						THEN IIF(sdh.header_buy_sell_flag = 's', -1, 1) * sddh.volume
					 ELSE 0
				END
			  ) [hourly_mdq]
			, SUM(IIF(sdh.header_buy_sell_flag = 's', -1, 1) * sddh.volume) [hourly_mdq1]

			--,sdh.source_deal_header_id
		FROM source_deal_detail_hour sddh
		INNER JOIN source_deal_detail sdd 
			ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
		INNER JOIN source_deal_header sdh 
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN source_deal_type sdt 
			ON sdt.source_deal_type_id = sdh.source_deal_type_id
		INNER JOIN source_minor_location sml 
			ON sml.source_minor_location_id = sdd.location_id
		INNER JOIN @location_ids loc 
			ON loc.location_id = sdd.location_id
		INNER JOIN @contract_ids cn 
			ON cn.contract_id = sdh.contract_id
		LEFT JOIN static_data_value sdv_pg 
			ON sdv_pg.value_id = sdh.internal_portfolio_id
		WHERE sdt.source_deal_type_name = 'Capacity'
			AND sddh.term_date BETWEEN @term_start AND ISNULL(@term_end, @term_start)
			--AND (sdv_pg.code NOT IN ('Complex-EEX', 'Complex-LTO', 'Complex-ROD') OR sdv_pg.code IS NULL) --exclude these product group capacity deals.
		GROUP by sdd.location_id, sdh.contract_id, sddh.term_date, CAST(LEFT(sddh.hr,2) AS INT)--,sdh.source_deal_header_id

	END
	--select * from @loc_wise_capacity_hourly_mdq
	--return

	--store schedule deal hourly volume. picked deal with provided path.
	BEGIN
		DECLARE @sch_deal_info TABLE	(
			[path_id] INT NULL,
			source_deal_header_id INT NULL,
			[contract_id] INT NULL,
			[term_start] DATETIME NULL,
			[hour] INT NULL,
			[hourly_mdq] NUMERIC(10,4) NULL,
			[is_complex] VARCHAR(10) NULL
		)

		INSERT INTO @sch_deal_info (
			[path_id],
			source_deal_header_id,
			[contract_id],
			[term_start],
			[hour],
			[hourly_mdq],
			[is_complex]
		)
		SELECT uddf.udf_value [path_id]
			, sdh.source_deal_header_id
			, sdh.contract_id
			, sddh.term_date [term_start]
			, CAST(LEFT(sddh.hr,2) AS INT) [hour]
			, IIF(sdd.buy_sell_flag = 's', -1, 1) * sddh.volume [hourly_mdq]
			, CASE WHEN sdv_pg.code IN ('Complex-EEX', 'Complex-LTO', 'Complex-ROD') AND sddh.volume > 0 THEN 'y' ELSE 'n' END [is_complex]
		FROM source_deal_detail_hour sddh
		INNER JOIN source_deal_detail sdd 
			ON sdd.source_deal_detail_id = sddh.source_deal_detail_id 
			AND sdd.term_start = sddh.term_date
		INNER JOIN source_deal_header sdh 
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN source_deal_header_template sdht 
			ON sdht.template_id = sdh.template_id
		INNER JOIN user_defined_deal_fields_template uddft (NOLOCK) 
			ON  uddft.field_label = 'Delivery Path'	-- delivery_path
			AND uddft.template_id = sdh.template_id
		INNER JOIN user_defined_deal_fields uddf (NOLOCK) 
			ON uddf.source_deal_header_id = sdh.source_deal_header_id
			AND uddft.udf_template_id = uddf.udf_template_id
			AND uddf.udf_value = @path_id
		INNER JOIN @contract_ids cn ON cn.contract_id = sdh.contract_id
		LEFT JOIN static_data_value sdv_pg 
			ON sdv_pg.value_id = sdh.internal_portfolio_id
		where sdht.template_name = 'Transportation NG'
			AND sddh.term_date BETWEEN @term_start AND ISNULL(@term_end, @term_start)
			AND sdd.leg = 2
			AND sddh.volume IS NOT NULL

	END
	--select * from @sch_deal_info
	--return

	--store path mdq hourly information
	BEGIN
		DECLARE @path_mdq_info TABLE	(
			[path_id] INT NULL,
			[contract_id] INT NULL,
			[term_start] DATETIME NULL,
			[hour] INT NULL,
			[mdq] NUMERIC(10,4) NULL,
			[mdq1] NUMERIC(10,4) NULL,
			[used_mdq] NUMERIC(10,4) NULL,
			[rmdq] NUMERIC(10,4) NULL,
			[self_mdq] NUMERIC(10,4) NULL,
			[is_complex] VARCHAR(10) NULL,
			[only_path_mdq] CHAR(1) NULL
		)
	
		INSERT INTO @path_mdq_info (
			[path_id],
			[contract_id],
			[term_start],
			[hour],
			[mdq],
			[mdq1],
			[used_mdq],
			[self_mdq],
			[is_complex],
			[only_path_mdq]
		)
		SELECT dp.path_id
			, ccrs.contract_id
			, tm.term_start
			, hr_values.[hour]
			, ISNULL([dbo].[FNAGetGasSupplyDemandVol](
					  IIF(smj_from.location_name = 'storage', ABS(lwchm_to.hourly_mdq) + 1, lwchm_from.hourly_mdq) --incase of withdrawal, assume supply position greater than demand position
					, IIF(lwchm_to.hourly_mdq < 0, 0, -1 * lwchm_to.hourly_mdq) --capacity case; if -ve position assume 0 else pass value as negative, since function will see -ve demand volume as valid one.
					, IIF(smj_to.location_name = 'storage', 'storage_injection', '')
				)
			  , 0)
			  + COALESCE(self_mdq.mdq, dp.mdq, 0)
			  [mdq]
			, ISNULL([dbo].[FNAGetGasSupplyDemandVol](
					  IIF(smj_from.location_name = 'storage', ABS(lwchm_to.hourly_mdq1) + 1, lwchm_from.hourly_mdq1)
					, IIF(lwchm_to.hourly_mdq1 < 0, 0, -1 * lwchm_to.hourly_mdq1)
					, IIF(smj_to.location_name = 'storage', 'storage_injection', '')
				)
			  , 0)
			  + COALESCE(self_mdq.mdq, dp.mdq, 0)
			  [mdq1]
			, ISNULL(sch_info.[hourly_mdq], 0) [used_mdq]
			, COALESCE(self_mdq.mdq, dp.mdq) [self_mdq]
			, ISNULL(sch_info.[is_complex], 'n') [is_complex] 
			, IIF(COALESCE(lwchm_from.hourly_mdq, lwchm_to.hourly_mdq) IS NOT NULL, 'n', 'y') [only_path_mdq]

			--,[dbo].[FNAGetGasSupplyDemandVol](lwchm_from.hourly_mdq, lwchm_to.hourly_mdq, IIF(smj_to.location_name = 'storage', 'storage_injection', ''))
		FROM delivery_path dp
		LEFT JOIN counterparty_contract_rate_schedule ccrs 
			ON ccrs.path_id = dp.path_id
		CROSS JOIN (
			SELECT @term_start + (n - 1) [term_start]
			FROM seq s
			WHERE n <= (DATEDIFF(DAY, @term_start, @term_end) + 1)
		) tm
		CROSS JOIN (
			SELECT (n) [hour]
			FROM seq sq
			WHERE sq.n < 25
		) hr_values
		LEFT JOIN @loc_wise_capacity_hourly_mdq lwchm_from 
			ON (lwchm_from.location_id = dp.from_location OR lwchm_from.proxy_location_id = dp.from_location) 
			AND lwchm_from.contract_id = ccrs.contract_id 
			AND lwchm_from.term_start = tm.term_start
			AND lwchm_from.[hour] = hr_values.[hour]
		LEFT JOIN @loc_wise_capacity_hourly_mdq lwchm_to 
			ON (lwchm_to.location_id = dp.to_location OR lwchm_to.proxy_location_id = dp.to_location) 
			AND lwchm_to.contract_id = ccrs.contract_id 
			AND lwchm_to.term_start = tm.term_start
			AND lwchm_to.[hour] = hr_values.[hour]
		LEFT JOIN source_minor_location sml_from 
			ON sml_from.source_minor_location_id = dp.from_location
		LEFT JOIN source_major_location smj_from 
			ON smj_from.source_major_location_id = sml_from.source_major_location_id
		LEFT JOIN source_minor_location sml_to 
			ON sml_to.source_minor_location_id = dp.to_location
		LEFT JOIN source_major_location smj_to 
			ON smj_to.source_major_location_id = sml_to.source_major_location_id
		OUTER APPLY (
			SELECT SUM(sch.hourly_mdq) [hourly_mdq], MAX(sch.is_complex) [is_complex]
			FROM @sch_deal_info sch
			WHERE sch.path_id = dp.path_id
				AND sch.contract_id = ccrs.contract_id
				AND sch.term_start = tm.term_start
				AND sch.[hour] = hr_values.[hour]
		) sch_info
		OUTER APPLY (
			SELECT TOP 1 dpm.mdq [mdq]
			FROM delivery_path_mdq dpm
			WHERE dpm.path_id = dp.path_id
				AND dpm.effective_date <= tm.term_start
			ORDER BY dpm.effective_date DESC
		) self_mdq
		WHERE dp.path_id = @path_id
		
		--while deriving rmdq, use non-excluded mdq1
		UPDATE @path_mdq_info SET [rmdq] = [mdq1] - [used_mdq]
	END

	--select * from @path_mdq_info
	--return
	
	--select final data on basis of parameter data_level
	BEGIN
		IF @data_level = 'path_term_hour'
		BEGIN
			INSERT INTO @return_table
			SELECT [path_id]
				, [contract_id]
				, [term_start]
				, [hour]
				, [mdq]
				, [used_mdq]
				, [rmdq]
				, [is_complex]
				, [only_path_mdq]
			FROM @path_mdq_info
			--ORDER BY term_start
			--	,[hour]
		END
		ELSE IF @data_level = 'path_hour'
		BEGIN
			INSERT INTO @return_table
			SELECT [path_id]
				, [contract_id]
				, NULL [term_start]
				, [hour]
				, SUM([mdq]) [mdq]
				, SUM([used_mdq]) [used_mdq]
				, SUM([rmdq]) [rmdq]
				, MAX([is_complex]) [is_complex]
				, MAX([only_path_mdq]) [only_path_mdq]
			FROM @path_mdq_info
			GROUP BY [path_id]
				,[contract_id]
				,[hour]
			--ORDER BY [hour]
		END
		ELSE IF @data_level = 'path_term'
		BEGIN
			INSERT INTO @return_table
			SELECT [path_id]
				, [contract_id]
				, [term_start]
				, NULL [hour]
				, SUM([mdq]) [mdq]
				, SUM([used_mdq]) [used_mdq]
				, SUM([rmdq]) [rmdq]
				, MAX([is_complex]) [is_complex]
				, MAX([only_path_mdq]) [only_path_mdq]
			FROM @path_mdq_info
			GROUP BY [path_id]
				,[contract_id]
				,[term_start]
			--ORDER BY [term_start]
		END
	END
	
	--select * from @return_table order by 3,4
	RETURN

END;
