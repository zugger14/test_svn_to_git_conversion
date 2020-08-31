IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_return_certificate_volume_detail]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_return_certificate_volume_detail]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Return sequences for the deals according to the certificate serial number and update existing matched deals sequence numbers in case if certificate imported after match 

	Parameters :
	@flag : 's' - Select sequence numbers to match, 'u' - update sequence numbers of matched deals
	@source_deal_detail_id : Deal detail id for which sequence to be returned or updated
	@process_id : Process ID to access deals from process table where deal information are saved
**/

CREATE PROCEDURE [dbo].[spa_return_certificate_volume_detail]
	@flag CHAR(1) = NULL,
	@source_deal_detail_id INT = NULL,
	@process_id VARCHAR(100) = NULL
AS 

/********Debug Code*********
DECLARE @flag CHAR(1) = 's',
	@source_deal_detail_id INT = NULL,
	@process_id VARCHAR(100) = 'D61E5BD8_07C9_4D4E_AD2D_8C5C87381D79'
--*************************/
SET NOCOUNT ON

	IF OBJECT_ID ('tempdb..#tmp_deals_info') IS NOT NULL
		DROP TABLE #tmp_deals_info

	DECLARE @TmpEligibleDeals VARCHAR(150), @user_name VARCHAR(100)
	SET @user_name = dbo.FNADBUser()

	SET @TmpEligibleDeals = dbo.FNAProcessTableName('TmpEligibleDeals', @user_name, @process_id)

	CREATE TABLE #tmp_deals_info(
		source_deal_detail_id INT
	)	
	IF OBJECT_ID(@TmpEligibleDeals) IS NOT NULL
	BEGIN
		EXEC('INSERT INTO #tmp_deals_info
		SELECT DISTINCT source_deal_detail_id FROM ' + @TmpEligibleDeals)
	END

	IF @source_deal_detail_id IS NOT NULL
	INSERT INTO #tmp_deals_info
	SELECT @source_deal_detail_id

	IF @flag = 'u' 
	BEGIN
		--Adjusting volume in the matched deals after same deal detail's volume breakdown into multiple legs or details
		
		IF OBJECT_ID(N'tempdb..#deal_info', N'U') IS NOT NULL
			DROP TABLE #deal_info

		CREATE TABLE #deal_info(id INT IDENTITY(1,1), 
			link_id INT,
			source_deal_header_id INT, 
			source_deal_detail_id INT,
			source_deal_header_id_from INT,
			source_deal_detail_id_from INT,
			assigned_vol FLOAT,
			volume_left FLOAT,
			assigned_sum FLOAT,
			volume_to_adjust FLOAT)

		INSERT INTO #deal_info
		SELECT mhdi.link_id,
			mhdi.source_deal_header_id, 
			mhdi.source_deal_detail_id, 
			mhdi.source_deal_header_id_from, 
			mhdi.source_deal_detail_id_from,
			mhdi.assigned_vol,
			sdd.volume_left,
			NULL,
			NULL
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN #tmp_deals_info tdi ON tdi.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN matching_header_detail_info mhdi ON mhdi.source_deal_detail_id_from = sdd.source_deal_detail_id
		OUTER APPLY(SELECT SUM(assigned_vol) vol
					FROM matching_header_detail_info mhdii
					WHERE mhdii.source_deal_detail_id_from = sdd.source_deal_detail_id) t
		LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			AND gc.state_value_id = mhdi.state_value_id
			AND gc.tier_type = mhdi.tier_value_id
		WHERE sdh.is_environmental = 'y' --AND sdh.generator_id IS NOT NULL
		AND sdh.header_buy_sell_flag = 'b'
		--AND sdd.source_deal_header_id IN (249990, 249991)
		AND t.vol > sdd.deal_volume
		AND sdd.volume_left > 0
		AND COALESCE(mhdi.sequence_from, mhdi.sequence_to) IS NULL
		ORDER BY mhdi.link_id

		IF EXISTS(SELECT TOP 1 1 FROM #deal_info)
		BEGIN

			;WITH quantityCheck AS (
			SELECT 
				link_id,
				source_deal_detail_id,
				SUM(CAST(assigned_vol AS INT)) OVER (PARTITION BY link_id, source_deal_detail_id_from ORDER BY link_id, source_deal_detail_id_from) AS volumeCheck
			FROM #deal_info di)
			UPDATE #deal_info SET 
				assigned_sum = volumeCheck,
				volume_to_adjust =  volume_left-volumeCheck
			FROM quantityCheck

			DELETE FROM #deal_info WHERE volume_to_adjust >= 0

			;WITH volumeAssign AS (
			SELECT 
				di.*
				, sdd.source_deal_detail_id detail_id
				, sdd.volume_left vleft
				, SUM(CAST(sdd.volume_left AS INT)) OVER (PARTITION BY di.link_id ORDER BY link_id, sdd.source_deal_header_id, sdd.term_start, sdd.leg  ASC) AS volumeCheck
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #deal_info di ON di.source_deal_header_id_from = sdd.source_deal_header_id)
			INSERT INTO #deal_info
			SELECT 
				link_id
				, source_deal_header_id
				, source_deal_detail_id
				, source_deal_header_id_from
				, detail_id
				, assigned_vol
				, vleft AS volume_left
				, volumeCheck AS assigned_sum
				, CASE WHEN assigned_vol > volumeCheck THEN vleft ELSE (assigned_vol-volumeCheck)+vleft END volume_to_adjust
			FROM volumeAssign va
			OUTER APPLY(SELECT TOP 1 volumeCheck vol
						FROM volumeAssign va1
						WHERE va1.source_deal_header_id_from = va.source_deal_header_id_from
						AND assigned_vol <= volumeCheck
						ORDER BY va1.detail_id) t
			OUTER APPLY(SELECT TOP 1 volumeCheck vol
						FROM volumeAssign va2
						WHERE va2.source_deal_header_id_from = va.source_deal_header_id_from
						AND volumeCheck <= assigned_vol
						ORDER BY va2.detail_id) t1
			WHERE volumeCheck <= ISNULL(t.vol,  t1.vol)

			BEGIN TRY 

				BEGIN TRAN

					UPDATE mhdi SET mhdi.assigned_vol = di.volume_left
					FROM matching_header_detail_info mhdi
					INNER JOIN #deal_info di ON di.link_id = mhdi.link_id
						AND di.source_deal_detail_id_from = mhdi.source_deal_detail_id_from
					WHERE di.volume_to_adjust > 0

					INSERT INTO matching_header_detail_info
					SELECT
						mhdi.link_id
						, mhdi.source_deal_header_id
						, mhdi.source_deal_detail_id
						, di.source_deal_header_id_from
						, di.source_deal_detail_id_from
						, di.volume_to_adjust
						, mhdi.state_value_id
						, mhdi.tier_value_id
						, GETDATE() AS create_ts
						, dbo.FNADBUser() AS create_user
						, NULL AS update_ts
						, NULL AS update_user
						, mhdi.vintage_yr
						, mhdi.expiration_dt
						, mhdi.sequence_from
						, mhdi.sequence_to
						, mhdi.delivery_date
						, mhdi.transfer_status
					FROM matching_header_detail_info mhdi
					INNER JOIN #deal_info di ON di.link_id = mhdi.link_id
						AND di.source_deal_detail_id = mhdi.source_deal_detail_id
						AND mhdi.source_deal_detail_id_from <> di.source_deal_detail_id_from
					WHERE di.volume_to_adjust > 0

					DELETE aa
					FROM assignment_audit aa
					INNER JOIN #deal_info di ON aa.source_deal_header_id = di.source_deal_detail_id
						AND aa.source_deal_header_id_from = di.source_deal_detail_id_from
					WHERE di.volume_to_adjust < 0

					UPDATE sdd SET volume_left = di.volume_left
					FROM source_deal_detail sdd
					INNER JOIN #deal_info di ON di.source_deal_detail_id_from = sdd.source_deal_detail_id
					WHERE di.volume_to_adjust < 0

					INSERT INTO assignment_audit(
						assignment_type, 
						assigned_volume, 
						source_deal_header_id, 
						source_deal_header_id_from, 
						compliance_year, 
						state_value_id,
						assigned_date, 
						assigned_by, 
						tier, 
						org_assigned_volume,
						create_user,
						create_ts)
					SELECT DISTINCT
						5173 assignment_type, 
						mhdi.assigned_vol, 
						mhdi.source_deal_detail_id sale_detail_id,
						mhdi.source_deal_detail_id_from rec_detail_id, 
						YEAR(GETDATE()) AS compliance_yr,
						mhdi.state_value_id,
						dbo.FNAGetSQLStandardDate(GETDATE()), 
						dbo.FNADBUser(),
						mhdi.tier_value_id, 
						mhdi.[assigned_vol] org_assigned_volume,
						dbo.FNADBUser(),
						GETDATE()
					FROM matching_header_detail_info mhdi
					INNER JOIN #deal_info di ON di.link_id = mhdi.link_id
						AND di.source_deal_detail_id = mhdi.source_deal_detail_id
						AND di.source_deal_detail_id_from = mhdi.source_deal_detail_id_from
					WHERE di.volume_to_adjust > 0

				COMMIT TRAN

				END TRY
				BEGIN CATCH	
					IF @@TRANCOUNT > 0
					ROLLBACK
					DECLARE @err_desc VARCHAR(150) = 'Fail to complete volume adjustment logic (Errr Description:' + ERROR_MESSAGE() + ').'

					EXEC spa_message_board 
						@flag = 'u',
						@user_login_id = @user_name,
						@source = 'Deal_Match',
						@description = @err_desc,
						@type = 'Error',
						@process_id = @process_id

				END CATCH 

			DECLARE @link_ids VARCHAR(4000)
			SELECT @link_ids = COALESCE(@link_ids + ',', '') + CAST(di.link_id AS VARCHAR)
			FROM #deal_info di
			GROUP BY link_id ORDER BY link_id ASC

			INSERT INTO source_system_data_import_status_detail (process_id, [source], [type], [description])
			SELECT @process_id, 'Deal Match', 'Success', 'Volume adjustment process has been completed. Affected Link ID(s): ' + @link_ids
		END
		--Updating sequence of matched deals after importing the certificates
		IF OBJECT_ID ('tempdb..#tmp_certificate_update_info') IS NOT NULL
			DROP TABLE #tmp_certificate_update_info

		SELECT id = IDENTITY(INT, 1, 1),
			mhdi.id match_info_id,
			mhdi.link_id AS match_id,
			gc.source_certificate_number,
			mhdi.source_deal_detail_id_from, 
			mhdi.assigned_vol,
			gc.certificate_number_from_int AS sequence_from,
			gc.certificate_number_to_int AS sequence_to
		INTO #tmp_certificate_update_info
		FROM #tmp_deals_info tdi --where source_deal_detail_id_from = 2274869
		INNER JOIN matching_header_detail_info mhdi ON mhdi.source_deal_detail_id_from = tdi.source_deal_detail_id
		INNER JOIN gis_certificate gc ON gc.source_deal_header_id = tdi.source_deal_detail_id
			AND mhdi.state_value_id = gc.state_value_id
			AND mhdi.tier_value_id = gc.tier_type
		WHERE COALESCE(mhdi.sequence_from, mhdi.sequence_to) IS NULL
		ORDER BY mhdi.link_id

		UPDATE mhdi SET 		
			mhdi.sequence_from = seqFrom.vol,
			mhdi.sequence_to = (seqFrom.vol+tcui.assigned_vol)-1
		FROM #tmp_certificate_update_info tcui
		INNER JOIN matching_header_detail_info mhdi ON mhdi.id = tcui.match_info_id
		OUTER APPLY(SELECT ISNULL(SUM(assigned_vol), 0)+tcui.sequence_from AS vol 
					FROM #tmp_certificate_update_info tcui1
					WHERE tcui1.id < tcui.id
					AND tcui1.source_deal_detail_id_from = tcui.source_deal_detail_id_from) seqFrom
		OUTER APPLY(SELECT SUM(assigned_vol) AS vol 
					FROM #tmp_certificate_update_info tcui2
					WHERE tcui2.id <= tcui.id
					AND tcui2.source_deal_detail_id_from = tcui.source_deal_detail_id_from) seqTo
	END
	ELSE IF @flag = 's'
	BEGIN
		IF OBJECT_ID ('tempdb..#source_deal_detail') IS NOT NULL
			DROP TABLE #source_deal_detail

		SELECT DISTINCT sdd.source_deal_detail_id, 
			CAST(sdd.volume_left AS INT) volume_left,
			ISNULL(cer.sequence_from, 1) sequence_from,
			ISNULL(cer.sequence_to, sdd.volume_left) sequence_to
		INTO #source_deal_detail
		FROM #tmp_deals_info ted
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ted.source_deal_detail_id
		OUTER APPLY(SELECT min(certificate_number_from_int) sequence_from,
						max(certificate_number_to_int) sequence_to
					FROM gis_certificate gc 
					WHERE gc.source_deal_header_id = sdd.source_deal_detail_id) cer
		WHERE cer.sequence_from IS NOT NULL

		--Selected all available sequences
		IF OBJECT_ID ('tempdb..#tmp_available_sequences_range') IS NOT NULL
			DROP TABLE #tmp_available_sequences_range

		SELECT 
			sdd.source_deal_detail_id,
			MIN(COALESCE(mhdia.sequence_from, mhdi.sequence_to, sdd.sequence_from)) sequence_from,
			MAX(sdd.sequence_to) sequence_to,
			MAX(ISNULL(mhdia.sequence_to, 0)) del_max,
			MAX(ISNULL(mhdi.sequence_to, 0)) ins_max
		INTO #tmp_available_sequences_range
		FROM #source_deal_detail sdd
		LEFT JOIN matching_header_detail_info_audit mhdia ON mhdia.source_deal_detail_id_from = sdd.source_deal_detail_id
			AND mhdia.sequence_from IS NOT NULL
			AND mhdia.user_action = 'Delete'
		OUTER APPLY (SELECT MAX(sequence_to) sequence_to
					FROM matching_header_detail_info mhdi 
					WHERE mhdi.source_deal_detail_id_from = sdd.source_deal_detail_id
					AND mhdi.sequence_from IS NOT NULL) mhdi
		GROUP BY sdd.source_deal_detail_id

		IF OBJECT_ID ('tempdb..#tmp_total_available_sequences') IS NOT NULL
			DROP TABLE #tmp_total_available_sequences

		SELECT tas.source_deal_detail_id, s.n AS seq
		INTO #tmp_total_available_sequences
		FROM #tmp_available_sequences_range tas
		INNER JOIN seq_big s ON s.n BETWEEN tas.sequence_from AND tas.sequence_to
		
		DELETE ttas
		FROM #tmp_total_available_sequences ttas
		INNER JOIN matching_header_detail_info mhdi ON mhdi.source_deal_detail_id_from = ttas.source_deal_detail_id
			AND ttas.seq BETWEEN mhdi.sequence_from and mhdi.sequence_to
		WHERE mhdi.sequence_from IS NOT NULL

		UPDATE sdd SET sdd.sequence_from = CASE WHEN 
			tasr.max_to > sdd.sequence_from THEN tasr.max_to+1 ELSE sdd.sequence_from END
		FROM #source_deal_detail sdd
		INNER JOIN (SELECT source_deal_detail_id,
						CASE WHEN del_max > ins_max THEN del_max ELSE ins_max END max_to
					FROM #tmp_available_sequences_range) tasr ON tasr.source_deal_detail_id = sdd.source_deal_detail_id

		INSERT INTO #source_deal_detail
		SELECT DISTINCT mhdia.source_deal_detail_id_from,
			sdd.volume_left,
			mhdia.sequence_from,
			mhdia.sequence_to
		FROM #source_deal_detail sdd
		INNER JOIN matching_header_detail_info_audit mhdia ON mhdia.source_deal_detail_id_from = sdd.source_deal_detail_id
			AND mhdia.sequence_from IS NOT NULL
			AND mhdia.user_action = 'Delete'
		WHERE NOT EXISTS(SELECT 1
						FROM #source_deal_detail sdd1
						WHERE sdd1.source_deal_detail_id = mhdia.source_deal_detail_id_from
						AND sdd1.sequence_from = mhdia.sequence_from 
						AND sdd1.sequence_to = mhdia.sequence_to)
		
		IF OBJECT_ID ('tempdb..#tmp_cert_info') IS NOT NULL
			DROP TABLE #tmp_cert_info

		IF OBJECT_ID ('tempdb..#source_deal_detail_final') IS NOT NULL
			DROP TABLE #source_deal_detail_final

		SELECT 
			id = identity(int, 1,1),
			*,
			(sequence_to - sequence_from)+1 AS tot
		INTO #source_deal_detail_final
		FROM #source_deal_detail
		WHERE (sequence_to - sequence_from)+1 > 0
		ORDER BY source_deal_detail_id, sequence_from, sequence_to ASC

		SELECT sdd.source_deal_detail_id,
			CASE WHEN MAX(t.sequence_from) IS NOT NULL THEN 
				MAX(t.sequence_from) ELSE MIN(ttas.seq) END sequence_from,
			MAX(ttas.seq) sequence_to
		INTO #tmp_cert_info
		FROM #tmp_total_available_sequences ttas
		INNER JOIN #source_deal_detail_final sdd ON sdd.source_deal_detail_id = ttas.source_deal_detail_id
			AND ttas.seq BETWEEN sdd.sequence_from AND sdd.sequence_to
		OUTER APPLY(SELECT 
						CASE WHEN sddf.sequence_to = sdd.sequence_from THEN 
							sdd.sequence_from+1
						WHEN sddf.sequence_from = sdd.sequence_from THEN 
							sddf.sequence_to+1 
						ELSE NULL END sequence_from
					FROM #source_deal_detail_final sddf
					WHERE sddf.source_deal_detail_id = sdd.source_deal_detail_id
					AND ttas.seq BETWEEN sddf.sequence_from AND sddf.sequence_to
					AND sddf.sequence_to <> sdd.sequence_to
					AND sddf.id < sdd.id) t
		GROUP BY sdd.source_deal_detail_id, sdd.sequence_to
		HAVING MAX(ttas.seq) > ISNULL(MAX(t.sequence_from), 1)

		SELECT source_deal_detail_id,
			(sequence_to-sequence_from)+1 volume,
			sequence_from sequence_from,
			sequence_to  sequence_to
		FROM #tmp_cert_info
		ORDER BY source_deal_detail_id, sequence_from
	END