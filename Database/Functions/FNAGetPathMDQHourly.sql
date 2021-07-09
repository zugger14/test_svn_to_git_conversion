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
	[is_dst] TINYINT NULL,
	[mdq] NUMERIC(10,4) NULL,
	[used_mdq] NUMERIC(10,4) NULL,
	[rmdq] NUMERIC(10,4) NULL,
	[is_complex] VARCHAR(10) NULL,
	[only_path_mdq] CHAR(1) NULL,
	[stg_affected_path_id] INT NULL,
	[stg_net_flow] NUMERIC(10,4) NULL,
	[stg_net_type] VARCHAR(50) NULL
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
	[is_dst] TINYINT NULL,
	[mdq] NUMERIC(10,4) NULL,
	[used_mdq] NUMERIC(10,4) NULL,
	[rmdq] NUMERIC(10,4) NULL,
	[is_complex] VARCHAR(10) NULL,
	[only_path_mdq] CHAR(1) NULL,
	[stg_affected_path_id] INT NULL,
	[stg_net_flow] NUMERIC(10,4) NULL,
	[stg_net_type] VARCHAR(50) NULL
)

SELECT @path_id = '321', @term_start = '2010-10-30', @term_end = '2010-10-30', @data_level = ''

	
EXEC dbo.spa_drop_all_temp_table

--*/

BEGIN
	SET @data_level = ISNULL(NULLIF(@data_level, ''), 'path_term_hour')
	
	--get locations, contract and mdq (defined on path itself) from path
	BEGIN
		DECLARE @location_ids TABLE (location_id INT NULL)
		DECLARE @contract_ids TABLE (contract_id INT NULL)
		DECLARE @storage_type CHAR(1)
		DECLARE @reverse_path_id VARCHAR(10)
		DECLARE @storage_loc_id INT
		DECLARE @inj_path_id VARCHAR(10)
		DECLARE @with_path_id VARCHAR(10)

		
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

		--storage case: get storage type on basis of from and to location of path
		SELECT @storage_type =	CASE WHEN smj_from.location_name = 'storage' AND sml_from.is_pool = 'y' THEN 'w' 
									WHEN smj_to.location_name = 'storage' AND sml_to.is_pool = 'y' THEN 'i' 
									ELSE NULL 
								END
			, @storage_loc_id = CASE WHEN smj_from.location_name = 'storage' THEN dp.from_location WHEN smj_to.location_name = 'storage' THEN dp.to_location ELSE NULL END
		FROM delivery_path dp
		INNER JOIN source_minor_location sml_from
			ON sml_from.source_minor_location_id = dp.from_location
		INNER JOIN source_major_location smj_from
			ON smj_from.source_major_location_id = sml_from.source_major_location_id
		INNER JOIN source_minor_location sml_to
			ON sml_to.source_minor_location_id = dp.to_location
		INNER JOIN source_major_location smj_to
			ON smj_to.source_major_location_id = sml_to.source_major_location_id
		WHERE dp.path_id = @path_id

		--select @storage_type


		--SET @storage_type = null

		--storage case: get reverse path id used on storage case
		IF @storage_type IS NOT NULL
		BEGIN
			SELECT @reverse_path_id = dp_reverse.path_id
			FROM delivery_path dp
			LEFT JOIN delivery_path dp_reverse
				ON dp_reverse.from_location = dp.to_location
				AND dp_reverse.to_location = dp.from_location
			WHERE dp.path_id = @path_id

			SET @inj_path_id = IIF(@storage_type = 'i', @path_id, @reverse_path_id)
			SET @with_path_id = IIF(@storage_type = 'w', @path_id, @reverse_path_id)

		END
	END
	

	--store location capacity hourly volume
	BEGIN
		DECLARE @loc_wise_capacity_hourly_mdq TABLE	(
			[proxy_location_id] INT NULL,
			[location_id] INT NULL,
			[contract_id] INT NULL,
			[term_start] DATETIME NULL,
			[hour] INT NULL,
			[is_dst] TINYINT NULL,
			[hourly_mdq] NUMERIC(10,4) NULL,
			[hourly_mdq1] NUMERIC(10,4) NULL
		)

		INSERT INTO @loc_wise_capacity_hourly_mdq (
			[proxy_location_id],
			[location_id],
			[contract_id],
			[term_start],
			[hour],
			[is_dst],
			[hourly_mdq],
			[hourly_mdq1]
		)
		SELECT MAX(sml.proxy_location_id) [proxy_location_id]
			, sdd.location_id
			, sdh.contract_id
			, sddh.term_date [term_start]
			, CAST(LEFT(sddh.hr,2) AS INT) [hour]
			, sddh.is_dst
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
			AND sdh.deal_status <> 5607 --avoid voided deals
		GROUP by sdd.location_id, sdh.contract_id, sddh.term_date, CAST(LEFT(sddh.hr,2) AS INT), sddh.is_dst--,sdh.source_deal_header_id

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
			[location_id] INT NULL,
			[leg] TINYINT NULL,
			[hour] TINYINT NULL,
			[is_dst] TINYINT NULL,
			[hourly_mdq] NUMERIC(10,4) NULL,
			[is_complex] VARCHAR(10) NULL,
			[storage_type] CHAR(1) NULL,
			[buy_sell_flag] CHAR(1)
		)

		INSERT INTO @sch_deal_info (
			[path_id],
			source_deal_header_id,
			[contract_id],
			[term_start],
			[location_id],
			[leg],
			[hour],
			[is_dst],
			[hourly_mdq],
			[is_complex],
			[storage_type],
			[buy_sell_flag]
		)
		SELECT uddf.udf_value [path_id]
			, sdh.source_deal_header_id
			, sdh.contract_id
			, sddh.term_date [term_start]
			, sdd.location_id
			, sdd.leg
			, CAST(LEFT(sddh.hr,2) AS INT) [hour]
			, sddh.is_dst
			, IIF(sdd.buy_sell_flag = 's', -1, 1) * sddh.volume [hourly_mdq]
			, CASE WHEN sdv_pg.code IN ('Complex-EEX', 'Complex-LTO', 'Complex-ROD') AND sddh.volume > 0 THEN 'y' ELSE 'n' END [is_complex]
			, @storage_type
			, sdd.buy_sell_flag
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
			AND uddf.udf_value IN (@path_id, @reverse_path_id)
		LEFT JOIN @contract_ids cn ON cn.contract_id = sdh.contract_id
		LEFT JOIN static_data_value sdv_pg 
			ON sdv_pg.value_id = sdh.internal_portfolio_id
		WHERE sdht.template_name = 'Transportation NG'
			AND sddh.term_date BETWEEN @term_start AND ISNULL(@term_end, @term_start)
			--AND (sdd.leg = 2 OR @storage_type IS NOT NULL)
			and sdd.leg = 2
			AND sddh.volume IS NOT NULL
			AND (cn.contract_id IS NOT NULL OR @storage_type IS NOT NULL)
			AND sdh.deal_status <> 5607 --avoid voided deals

	END

	--select * from @sch_deal_info
	--return
			
	--storage case: get affected storage path and storage new flow
	BEGIN
		DECLARE @stg_net_flow TABLE	(
			[stg_affected_path_id] INT NULL,
			[term_start] DATETIME NULL,
			[hour] INT NULL,
			[is_dst] TINYINT NULL,
			[stg_net_flow] NUMERIC(10,4) NULL,
			[stg_net_type] VARCHAR(50) NULL
		)

		INSERT INTO @stg_net_flow (
			[stg_affected_path_id],
			[term_start],
			[hour],
			[is_dst],
			[stg_net_flow],
			[stg_net_type]
		)
		SELECT NULL [stg_affected_path_id], t.[term_start], t.[hour], t.is_dst, SUM(IIF(t.path_id = @inj_path_id, 1, -1) * t.hourly_mdq) [stg_net_flow], CAST(NULL AS VARCHAR(50)) [stg_net_type]
		FROM @sch_deal_info t
		WHERE @storage_type IS NOT NULL --only on storage case
		GROUP BY t.[term_start], t.[hour], t.[is_dst]
	
		UPDATE @stg_net_flow SET [stg_affected_path_id] = IIF([stg_net_flow] >= 0, @inj_path_id, @with_path_id)
			, [stg_net_type] = CASE WHEN [stg_net_flow] > 0 THEN 'net_inj' WHEN [stg_net_flow] < 0 THEN 'net_with' ELSE NULL END

		--select * from @stg_net_flow
	END
	--return
	--store path mdq hourly information
	BEGIN
		DECLARE @path_mdq_info TABLE	(
			[path_id] INT NULL,
			[contract_id] INT NULL,
			[term_start] DATETIME NULL,
			[hour] INT NULL,
			[is_dst] TINYINT NULL,
			[mdq] NUMERIC(10,4) NULL,
			[mdq1] NUMERIC(10,4) NULL,
			[used_mdq] NUMERIC(10,4) NULL,
			[rmdq] NUMERIC(10,4) NULL,
			[self_mdq] NUMERIC(10,4) NULL,
			[is_complex] VARCHAR(10) NULL,
			[only_path_mdq] CHAR(1) NULL,
			[stg_affected_path_id] INT NULL,
			[stg_net_flow] NUMERIC(10,4) NULL,
			[stg_net_type] VARCHAR(50) NULL
		)
			
		INSERT INTO @path_mdq_info (
			[path_id],
			[contract_id],
			[term_start],
			[hour],
			[is_dst],
			[mdq],
			[mdq1],
			[rmdq],
			[used_mdq],
			[self_mdq],
			[is_complex],
			[only_path_mdq],
			[stg_affected_path_id],
			[stg_net_flow],
			[stg_net_type]
		)
		SELECT dp.path_id
			, ccrs.contract_id
			, tm.term_start
			, hr_values.[hour]
			, hr_values.is_dst [is_dst]
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
			, 0 [rmdq]
			, ISNULL(sch_info.[hourly_mdq], 0) [used_mdq]
			, COALESCE(self_mdq.mdq, dp.mdq) [self_mdq]
			, ISNULL(sch_info.[is_complex], 'n') [is_complex] 
			, IIF(COALESCE(lwchm_from.hourly_mdq, lwchm_to.hourly_mdq) IS NOT NULL, 'n', 'y') [only_path_mdq]
			, stn.stg_affected_path_id
			, stn.stg_net_flow
			, stn.stg_net_type		
			
		FROM delivery_path dp
		LEFT JOIN counterparty_contract_rate_schedule ccrs 
			ON ccrs.path_id = dp.path_id
		CROSS JOIN (
			SELECT @term_start + (n - 1) [term_start]
			FROM seq s
			WHERE n <= (DATEDIFF(DAY, @term_start, @term_end) + 1)
		) tm
		CROSS APPLY (
			SELECT CAST(LEFT(hr_col.clm_name, 2) AS INT) + 1 [hour], hr_col.is_dst
			FROM dbo.FNAGetDisplacedPivotGranularityColumn(tm.term_start, tm.term_start, 982, 102201, 6) hr_col
		) hr_values
		LEFT JOIN @loc_wise_capacity_hourly_mdq lwchm_from 
			ON (lwchm_from.location_id = dp.from_location OR lwchm_from.proxy_location_id = dp.from_location) 
			AND lwchm_from.contract_id = ccrs.contract_id 
			AND lwchm_from.term_start = tm.term_start
			AND lwchm_from.[hour] = hr_values.[hour]
			AND lwchm_from.is_dst = hr_values.is_dst
		LEFT JOIN @loc_wise_capacity_hourly_mdq lwchm_to 
			ON (lwchm_to.location_id = dp.to_location OR lwchm_to.proxy_location_id = dp.to_location) 
			AND lwchm_to.contract_id = ccrs.contract_id 
			AND lwchm_to.term_start = tm.term_start
			AND lwchm_to.[hour] = hr_values.[hour]
			AND lwchm_to.is_dst = hr_values.is_dst
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
				AND sch.is_dst = hr_values.is_dst
		) sch_info
		OUTER APPLY (
			SELECT TOP 1 dpm.mdq [mdq]
			FROM delivery_path_mdq dpm
			WHERE dpm.path_id = dp.path_id
				AND dpm.effective_date <= tm.term_start
			ORDER BY dpm.effective_date DESC
		) self_mdq
		LEFT JOIN @stg_net_flow stn
			ON stn.[hour] = hr_values.[hour]
			AND stn.[term_start] = tm.term_start
			AND stn.[is_dst] = hr_values.[is_dst]
		WHERE dp.path_id = @path_id

		IF @storage_type IS NULL
		BEGIN
			--while deriving rmdq, use non-excluded mdq1
			UPDATE @path_mdq_info SET [rmdq] = [mdq1] - [used_mdq]
		END
		ELSE
		BEGIN
			UPDATE @path_mdq_info 
			SET [rmdq] = [mdq1] - IIF(path_id = stg_affected_path_id AND stg_net_flow <> 0, ABS(stg_net_flow), 0)
			--WHERE (stg_net_flow = 0 OR path_id <> stg_affected_path_id OR stg_affected_path_id IS NULL)
		END
				
	END
	
	--select * from @path_mdq_info order by 3,4
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
				, [is_dst]
				, [mdq]
				, [used_mdq]
				, [rmdq]
				, [is_complex]
				, [only_path_mdq]
				, [stg_affected_path_id]
				, [stg_net_flow]
				, [stg_net_type]
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
				, [is_dst]
				, SUM([mdq]) [mdq]
				, SUM([used_mdq]) [used_mdq]
				, SUM([rmdq]) [rmdq]
				, MAX([is_complex]) [is_complex]
				, MAX([only_path_mdq]) [only_path_mdq]
				, MAX([stg_affected_path_id]) [stg_affected_path_id]
				, MAX([stg_net_flow]) [stg_net_flow]
				, MAX([stg_net_type]) [stg_net_type]
			FROM @path_mdq_info
			GROUP BY [path_id]
				,[contract_id]
				,[hour]
				,[is_dst]
			--ORDER BY [hour]
		END
		ELSE IF @data_level = 'path_term'
		BEGIN
			INSERT INTO @return_table
			SELECT [path_id]
				, [contract_id]
				, [term_start]
				, NULL [hour]
				, NULL [is_dst]
				, SUM([mdq]) [mdq]
				, SUM([used_mdq]) [used_mdq]
				, SUM([rmdq]) [rmdq]
				, MAX([is_complex]) [is_complex]
				, MAX([only_path_mdq]) [only_path_mdq]
				, MAX([stg_affected_path_id]) [stg_affected_path_id]
				, MAX([stg_net_flow]) [stg_net_flow]
				, MAX([stg_net_type]) [stg_net_type]
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
----------------------------------

