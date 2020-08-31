BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'scd'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'scd' and name <> 'Shipper Code Details View')
	begin
		select top 1 @new_ds_alias = 'scd' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'scd' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR ('Datasource alias already exists on system.', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Shipper Code Details View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'Shipper Code Details View' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'Shipper Code Details View' AS [name], @new_ds_alias AS ALIAS, 'Shipper Code Details View' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'0' AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'Shipper Code Details View'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE 

@_location_id NVARCHAR(20), 

@_counterparty_id NVARCHAR(20), 

@_term_start NVARCHAR(20), 	

@_contract_id NVARCHAR(20),

@_deal_detail_id NVARCHAR(20), 

@_deal_header_id NVARCHAR(20),

@_term_end NVARCHAR(20),

@_external_id NVARCHAR(20)

IF ''@location_id'' <> ''NULL''

    SET @_location_id = ''@location_id''

IF ''@counterparty_id'' <> ''NULL''

    SET @_counterparty_id = ''@counterparty_id''

IF ''@term_start'' <> ''NULL''

    SET @_term_start = ''@term_start''

IF ''@deal_detail_id'' <> ''NULL''

    SET @_deal_detail_id = ''@deal_detail_id''

IF ''@contract_id'' <> ''NULL''

    SET @_contract_id = ''@contract_id''

IF ''@deal_header_id'' <> ''NULL''

    SET @_deal_header_id = ''@deal_header_id''

IF ''@term_end'' <> ''NULL''

    SET @_term_end = ''@term_end''

IF ''@external_id'' <> ''NULL''

    SET @_external_id = ''@external_id''

DECLARE @_latest_start_eff_dt DATETIME, @_default_value INT, @_term_day INT, @_row_count INT, @_eff_date DATETIME

, @_deal_ship_cd1 NVARCHAR(50), @_deal_ship_cd2 NVARCHAR(50), @_template_name NVARCHAR(20)

IF OBJECT_ID(''tempdb..#temp_final_shipper_codes'') IS NOT NULL

	DROP TABLE #temp_final_shipper_codes

			

CREATE TABLE #temp_final_shipper_codes (	

	deal_header_id INT, 

	deal_detail_id INT, 

	counterparty_id INT, 

	location_id INT, 

	contract_id INT,

	shipper_code1 INT,

	shipper_code2 INT,

	effective_date DATETIME

)

IF OBJECT_ID(''tempdb..#temp_collect_shipper_code1'') IS NOT NULL

	DROP TABLE #temp_collect_shipper_code1

			

CREATE TABLE #temp_collect_shipper_code1 (

	shipper_code_id INT,

	shipper_code1 NVARCHAR(500) COLLATE DATABASE_DEFAULT,

	shipper_code1_is_default NCHAR(1) COLLATE DATABASE_DEFAULT,

	effective_date DATETIME,

	is_generated BIT

)

IF OBJECT_ID(''tempdb..#temp_collect_shipper_code2'') IS NOT NULL

	DROP TABLE #temp_collect_shipper_code2

			

CREATE TABLE #temp_collect_shipper_code2 (

	shipper_code_id INT,

	shipper_code2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,

	shipper_code2_is_default NCHAR(1) COLLATE DATABASE_DEFAULT,

	effective_date DATETIME,

	is_generated BIT

)

IF OBJECT_ID(''tempdb..#temp_shipper_codes'') IS NOT NULL

	DROP TABLE #temp_shipper_codes

			

CREATE TABLE #temp_shipper_codes (

	shipper_code_id INT,

	shipper_code1 NVARCHAR(500) COLLATE DATABASE_DEFAULT,

	shipper_code2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,

	effective_date DATETIME

)

DECLARE shipper_code_cur CURSOR FOR

SELECT 

	sdd.source_deal_header_id source_deal_header_id	

	, sdd.source_deal_detail_id source_deal_detail_id

	, sdd.term_start term_start

	, sdd.location_id  location_id

	, sdh.counterparty_id counterparty_id

	, sdh.contract_id contract_id

FROM source_deal_detail sdd

INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id

WHERE 1=1 

AND ((@_deal_header_id IS NOT NULL AND sdd.source_deal_header_id = @_deal_header_id) OR (@_deal_header_id IS NULL AND 1=1 ))

AND ((@_deal_detail_id IS NOT NULL AND sdd.source_deal_detail_id = @_deal_detail_id) OR (@_deal_detail_id IS NULL AND 1=1 ))

AND ((@_location_id IS NOT NULL AND sdd.location_id = @_location_id) OR (@_location_id IS NULL AND 1=1 ))

AND ((@_counterparty_id IS NOT NULL AND sdh.counterparty_id = @_counterparty_id) OR (@_counterparty_id IS NULL AND 1=1 ))

AND ((@_contract_id IS NOT NULL AND sdh.contract_id = @_contract_id) OR (@_contract_id IS NULL AND 1=1 ))

AND ((@_term_start IS NOT NULL AND sdd.term_start >= @_term_start) OR (@_term_start IS NULL AND 1=1 ))

AND ((@_term_end IS NOT NULL AND sdd.term_end <= @_term_end) OR (@_term_end IS NULL AND 1=1 ))

OPEN shipper_code_cur

FETCH NEXT FROM shipper_code_cur

INTO @_deal_header_id, @_deal_detail_id, @_term_start, @_location_id, @_counterparty_id, @_contract_id

WHILE @@FETCH_STATUS = 0

BEGIN		
	DELETE FROM #temp_collect_shipper_code1

	DELETE FROM #temp_collect_shipper_code2

	DELETE FROM #temp_shipper_codes

	SELECT @_template_name = template_name  FROM source_deal_header sdh

	INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id

	WHERE sdh.source_deal_header_id = @_deal_header_id

	IF @_template_name = ''Transportation NG''

	BEGIN

		SELECT @_location_id = location_id 

		FROM transportation_contract_location 

		OUTER APPLY (SELECT buy_sell_flag FROM source_deal_detail sdd WHERE source_deal_detail_id = @_deal_detail_id) a

		WHERE contract_id = @_contract_id AND rec_del = IIF (a.buy_sell_flag = ''b'', 2, 1)

	END	

	--SELECT @_deal_ship_cd1 = scmd.shipper_code_mapping_detail_id, @_deal_ship_cd2=scmd2.shipper_code_mapping_detail_id	 

	--FROM source_deal_detail sdd 

	--INNER JOIN shipper_code_mapping_detail scmd ON scmd.shipper_code_mapping_detail_id = sdd.shipper_code1	

	--INNER JOIN shipper_code_mapping_detail scmd2 ON scmd2.shipper_code_mapping_detail_id = sdd.shipper_code2	

	--WHERE source_deal_detail_id = @_deal_detail_id
	--select @_deal_ship_cd1, @_deal_ship_cd2

	--return

	-- Case when values are saved in deal detail

	IF (NULLIF(@_deal_ship_cd1, '''') IS NOT NULL AND NULLIF(@_deal_ship_cd2, '''') IS NOT NULL)

	BEGIN

		INSERT INTO #temp_final_shipper_codes(deal_header_id, deal_detail_id, counterparty_id, location_id, contract_id, shipper_code1, shipper_code2, effective_date)

		SELECT @_deal_header_id, @_deal_detail_id, @_counterparty_id, @_location_id, @_contract_id, @_deal_ship_cd1, @_deal_ship_cd2, DATEFROMPARTS(YEAR(term_start), MONTH(term_start), n) FROM source_deal_detail  sdd

		CROSS APPLY (SELECT n FROM seq WHERE n <= DAY(EOMONTH(sdd.term_start))) a

		WHERE source_deal_detail_id = @_deal_detail_id

	END

	ELSE

	BEGIN	

		--------------- Start Shipper code 1-------------		

		INSERT INTO #temp_collect_shipper_code1(shipper_code_id, shipper_code1, shipper_code1_is_default, effective_date)

		SELECT scmd.shipper_code_mapping_detail_id, 

			scmd.shipper_code1, 

			scmd.shipper_code1_is_default, 

			scmd.effective_date

		FROM shipper_code_mapping sscm

		INNER JOIN shipper_code_mapping_detail scmd ON scmd.shipper_code_id = sscm.shipper_code_id				

		WHERE sscm.counterparty_id = @_counterparty_id AND scmd.is_active = ''y'' AND scmd.[location_id] = @_location_id 

		AND (

			(MONTH(scmd.effective_date) <= MONTH(@_term_start) AND YEAR(scmd.effective_date) <= YEAR(@_term_start) )

			OR (YEAR(scmd.effective_date) < YEAR(@_term_start) AND scmd.effective_date < @_term_start) 

		)

		SELECT TOP 1 @_latest_start_eff_dt = effective_date 

		FROM #temp_collect_shipper_code1 

		WHERE (MONTH(effective_date) < MONTH(@_term_start) AND YEAR(effective_date) <= YEAR(@_term_start) )

				OR (YEAR(effective_date) < YEAR(@_term_start) AND effective_date < @_term_start) 

		ORDER BY effective_date DESC	

		SELECT TOP 1 @_term_day = DAY(effective_date) FROM #temp_collect_shipper_code1 

		WHERE MONTH(effective_date) = MONTH(@_term_start) AND YEAR(effective_date) = YEAR(@_term_start)

		ORDER BY effective_date ASC

		--Case when effective date does not start with 1st day of the month, added 1st day by generating values from previous month

		IF (@_term_day != 1)

		BEGIN	

			IF EXISTS ( SELECT 1 FROM #temp_collect_shipper_code1 WHERE effective_date = @_latest_start_eff_dt AND shipper_code1_is_default = ''y'')

			BEGIN

				INSERT INTO #temp_collect_shipper_code1(shipper_code_id, shipper_code1, shipper_code1_is_default, effective_date, is_generated)

				SELECT shipper_code_id, shipper_code1, ''y'',DATEFROMPARTS(YEAR(@_term_start), MONTH(@_term_start), 1), 1 FROM #temp_collect_shipper_code1 

				WHERE effective_date = @_latest_start_eff_dt AND shipper_code1_is_default = ''y''

			END

			ELSE

			BEGIN

				INSERT INTO #temp_collect_shipper_code1(shipper_code_id, shipper_code1, shipper_code1_is_default, effective_date, is_generated)

				SELECT TOP 1 shipper_code_id, shipper_code1, ''y'',DATEFROMPARTS(YEAR(@_term_start), MONTH(@_term_start), 1), 1 FROM #temp_collect_shipper_code1 

				WHERE effective_date = @_latest_start_eff_dt AND shipper_code1_is_default != ''y'' ORDER BY shipper_code1 ASC

			END

		END

		IF EXISTS (SELECT 1 FROM #temp_collect_shipper_code1 WHERE MONTH(effective_date) = MONTH(@_term_start) AND YEAR(effective_date) = YEAR(@_term_start))

		BEGIN

			DELETE FROM #temp_collect_shipper_code1 WHERE shipper_code_id NOT IN (SELECT shipper_code_id FROM #temp_collect_shipper_code1 WHERE MONTH(effective_date) = MONTH(@_term_start) AND YEAR(effective_date) = YEAR(@_term_start))	

		END

		ELSE

		BEGIN

			DELETE FROM #temp_collect_shipper_code1 WHERE shipper_code_id NOT IN (SELECT shipper_code_id FROM #temp_collect_shipper_code1 WHERE MONTH(effective_date) = MONTH(@_latest_start_eff_dt) AND YEAR(effective_date) = YEAR(@_latest_start_eff_dt)) 

		END

		DELETE FROM #temp_collect_shipper_code1 

		WHERE ISNULL(is_generated, 0) <> 1 AND shipper_code_id IN (SELECT shipper_code_id FROM #temp_collect_shipper_code1 GROUP BY shipper_code_id HAVING COUNT(shipper_code_id) >1 )  

		SELECT @_row_count = COUNT(DISTINCT effective_date) FROM #temp_collect_shipper_code1 

		-- Case when only one day in a month is defined in shipper code details

		IF @_row_count = 1

		BEGIN

			IF EXISTS(SELECT 1 FROM #temp_collect_shipper_code1 WHERE shipper_code1_is_default = ''y'' ) 

			BEGIN

				-- Case when default value is set

				INSERT INTO #temp_shipper_codes(shipper_code_id, shipper_code1, effective_date)

				SELECT shipper_code_id, shipper_code1, DATEFROMPARTS(YEAR(@_term_start), MONTH(@_term_start), n)  FROM #temp_collect_shipper_code1 

				CROSS JOIN (SELECT n FROM seq WHERE n <= (SELECT TOP 1 DAY(EOMONTH(@_term_start)) FROM #temp_collect_shipper_code1)) a

				WHERE shipper_code1_is_default = ''y''

			END

			ELSE

			BEGIN

				-- Case when default is selected by asc order or shipper code name

				INSERT INTO #temp_shipper_codes(shipper_code_id, shipper_code1, effective_date)

				SELECT shipper_code_id, shipper_code1, DATEFROMPARTS(YEAR(@_term_start), MONTH(@_term_start), n)  FROM 

				(SELECT TOP 1 * FROM #temp_collect_shipper_code1  ORDER BY shipper_code1) a

				CROSS JOIN (SELECT n FROM seq WHERE n <= (SELECT TOP 1 DAY(EOMONTH(@_term_start)) FROM #temp_collect_shipper_code1)) b

			END	

		END

		ELSE

		BEGIN	

			-- Case when only multiple days in a month is defined in shipper code details

			DECLARE date_cursor_ship1 CURSOR FOR

			SELECT DISTINCT effective_date

			FROM #temp_collect_shipper_code1 ORDER BY effective_date ASC

			OPEN date_cursor_ship1

			FETCH NEXT FROM date_cursor_ship1

			INTO @_eff_date

			WHILE @@FETCH_STATUS = 0

			BEGIN	

				IF EXISTS(SELECT 1 FROM #temp_collect_shipper_code1 WHERE shipper_code1_is_default = ''y'' AND effective_date = @_eff_date ) 

				BEGIN

					-- Case when default value is set

					INSERT INTO #temp_shipper_codes(shipper_code_id, shipper_code1, effective_date)

					SELECT shipper_code_id, shipper_code1,DATEFROMPARTS(YEAR(@_term_start), MONTH(@_term_start), n) 

					FROM #temp_collect_shipper_code1 tsc

					OUTER APPLY (SELECT TOP 1 effective_date FROM #temp_collect_shipper_code1 WHERE effective_date > @_eff_date ORDER BY effective_date ASC) a

					CROSS APPLY (

						SELECT n FROM seq WHERE 

						(a.effective_date IS NOT NULL AND n < DAY(a.effective_date) AND n >= DAY(@_eff_date))

						OR (a.effective_date IS NULL AND n >= DAY(@_eff_date) AND n <= DAY(EOMONTH((@_term_start))))

					) b

					WHERE shipper_code1_is_default = ''y'' AND tsc.effective_date = @_eff_date

				END

				ELSE

				BEGIN

					-- Case when default is selected by asc order or shipper code name

					INSERT INTO #temp_shipper_codes(shipper_code_id, shipper_code1, effective_date)

					SELECT shipper_code_id, shipper_code1, DATEFROMPARTS(YEAR(@_term_start), MONTH(@_term_start), n) 

					FROM

					(SELECT TOP 1 * FROM #temp_collect_shipper_code1 WHERE effective_date = @_eff_date AND shipper_code1_is_default != ''y'' ORDER BY shipper_code1) tsc

					OUTER APPLY (SELECT TOP 1 effective_date FROM #temp_collect_shipper_code1 WHERE effective_date > @_eff_date ORDER BY effective_date ASC) a

					CROSS APPLY (

						SELECT n FROM seq WHERE 

						(a.effective_date IS NOT NULL AND n < DAY(a.effective_date) AND n >= DAY(@_eff_date))

						OR (a.effective_date IS NULL AND n >= DAY(@_eff_date) AND n <= DAY(EOMONTH((@_term_start))))

					) b			

				END	

				FETCH NEXT FROM date_cursor_ship1 INTO @_eff_date

			END

			CLOSE date_cursor_ship1

			DEALLOCATE date_cursor_ship1

	

		END

		--------------- END Shipper code 1-------------

		--------------- Start Shipper code 2-------------

		INSERT INTO #temp_collect_shipper_code2(shipper_code_id, shipper_code2, shipper_code2_is_default, effective_date)

		SELECT scmd.shipper_code_mapping_detail_id, 

			scmd.shipper_code, 

			scmd.is_default, 

			scmd.effective_date

		FROM shipper_code_mapping sscm

		INNER JOIN shipper_code_mapping_detail scmd ON scmd.shipper_code_id = sscm.shipper_code_id				

		WHERE sscm.counterparty_id = @_counterparty_id AND scmd.is_active = ''y'' AND scmd.[location_id] = @_location_id 

		AND (

			(MONTH(scmd.effective_date) <= MONTH(@_term_start) AND YEAR(scmd.effective_date) <= YEAR(@_term_start) )

			OR (YEAR(scmd.effective_date) < YEAR(@_term_start) AND scmd.effective_date < @_term_start) 

		)

		SELECT TOP 1 @_latest_start_eff_dt = effective_date 

		FROM #temp_collect_shipper_code2 

		WHERE (MONTH(effective_date) < MONTH(@_term_start) AND YEAR(effective_date) <= YEAR(@_term_start) )

				OR (YEAR(effective_date) < YEAR(@_term_start) AND effective_date < @_term_start) 

		ORDER BY effective_date DESC	

		SELECT TOP 1 @_term_day = DAY(effective_date) FROM #temp_collect_shipper_code2 

		WHERE MONTH(effective_date) = MONTH(@_term_start) AND YEAR(effective_date) = YEAR(@_term_start)

		ORDER BY effective_date ASC

		--Case when effective date does not start with 1st day of the month, added 1st day by generating values from previous month

		IF (@_term_day != 1)

		BEGIN

			IF EXISTS ( SELECT 1 FROM #temp_collect_shipper_code2 WHERE effective_date = @_latest_start_eff_dt AND shipper_code2_is_default = ''y'')

			BEGIN

				INSERT INTO #temp_collect_shipper_code2(shipper_code_id, shipper_code2, shipper_code2_is_default, effective_date, is_generated)

				SELECT shipper_code_id, shipper_code2, ''y'',DATEFROMPARTS(YEAR(@_term_start), MONTH(@_term_start), 1), 1 FROM #temp_collect_shipper_code2 

				WHERE effective_date = @_latest_start_eff_dt AND shipper_code2_is_default = ''y''

			END

			ELSE

			BEGIN

				INSERT INTO #temp_collect_shipper_code2(shipper_code_id, shipper_code2, shipper_code2_is_default, effective_date, is_generated)

				SELECT TOP 1 shipper_code_id, shipper_code2, ''y'',DATEFROMPARTS(YEAR(@_term_start), MONTH(@_term_start), 1),1 FROM #temp_collect_shipper_code2 

				WHERE effective_date = @_latest_start_eff_dt AND shipper_code2_is_default != ''y'' ORDER BY shipper_code2 ASC

			END

		END

	

		IF EXISTS (SELECT 1 FROM #temp_collect_shipper_code2 WHERE MONTH(effective_date) = MONTH(@_term_start) AND YEAR(effective_date) = YEAR(@_term_start))

		BEGIN

			DELETE FROM #temp_collect_shipper_code2 WHERE shipper_code_id NOT IN (SELECT shipper_code_id FROM #temp_collect_shipper_code2 WHERE MONTH(effective_date) = MONTH(@_term_start) AND YEAR(effective_date) = YEAR(@_term_start))

	

		END

		ELSE

		BEGIN

			DELETE FROM #temp_collect_shipper_code2 WHERE shipper_code_id NOT IN (SELECT shipper_code_id FROM #temp_collect_shipper_code2 WHERE MONTH(effective_date) = MONTH(@_latest_start_eff_dt) AND YEAR(effective_date) = YEAR(@_latest_start_eff_dt)) 

		END

		DELETE FROM #temp_collect_shipper_code2

		WHERE ISNULL(is_generated, 0) <> 1 AND shipper_code_id IN (SELECT shipper_code_id FROM #temp_collect_shipper_code2 GROUP BY shipper_code_id HAVING COUNT(shipper_code_id) >1 )  

		SELECT @_row_count = COUNT(DISTINCT effective_date) FROM #temp_collect_shipper_code2 

		-- Case when only one day in a month is defined in shipper code details

		IF @_row_count = 1

		BEGIN

			-- Case when default value is set

			IF EXISTS(SELECT 1 FROM #temp_collect_shipper_code2 WHERE shipper_code2_is_default = ''y'' ) 

			BEGIN

				INSERT INTO #temp_shipper_codes(shipper_code_id, shipper_code2, effective_date)

				SELECT shipper_code_id, shipper_code2, DATEFROMPARTS(YEAR(@_term_start), MONTH(@_term_start), n)  FROM #temp_collect_shipper_code2 

				CROSS JOIN (SELECT n FROM seq WHERE n <= (SELECT TOP 1 DAY(EOMONTH(@_term_start)) FROM #temp_collect_shipper_code2)) a

				WHERE shipper_code2_is_default = ''y''

			END

			ELSE

			BEGIN

				-- Case when default is selected by asc order or shipper code name

				INSERT INTO #temp_shipper_codes(shipper_code_id, shipper_code2, effective_date)

				SELECT shipper_code_id, shipper_code2, DATEFROMPARTS(YEAR(@_term_start), MONTH(@_term_start), n)  FROM 

				(SELECT TOP 1 * FROM #temp_collect_shipper_code2  ORDER BY shipper_code2) a

				CROSS JOIN (SELECT n FROM seq WHERE n <= (SELECT TOP 1 DAY(EOMONTH(@_term_start)) FROM #temp_collect_shipper_code2)) b

			END	

		END

		ELSE

		BEGIN	

			-- Case when only multiple days in a month is defined in shipper code details

			DECLARE date_cursor_ship2 CURSOR FOR

			SELECT DISTINCT effective_date

			FROM #temp_collect_shipper_code2 ORDER BY effective_date ASC

			OPEN date_cursor_ship2

			FETCH NEXT FROM date_cursor_ship2

			INTO @_eff_date

			WHILE @@FETCH_STATUS = 0

			BEGIN	

				IF EXISTS(SELECT 1 FROM #temp_collect_shipper_code2 WHERE shipper_code2_is_default = ''y'' AND effective_date = @_eff_date ) 

				BEGIN

					INSERT INTO #temp_shipper_codes(shipper_code_id, shipper_code2, effective_date)

					SELECT shipper_code_id, shipper_code2,DATEFROMPARTS(YEAR(@_term_start), MONTH(@_term_start), n) 

					FROM #temp_collect_shipper_code2 tsc

					OUTER APPLY (SELECT TOP 1 effective_date FROM #temp_collect_shipper_code2 WHERE effective_date > @_eff_date ORDER BY effective_date ASC) a

					CROSS APPLY (

						SELECT n FROM seq WHERE 

						(a.effective_date IS NOT NULL AND n < DAY(a.effective_date) AND n >= DAY(@_eff_date))

						OR (a.effective_date IS NULL AND n >= DAY(@_eff_date) AND n <= DAY(EOMONTH((@_term_start))))

					) b

					WHERE shipper_code2_is_default = ''y'' AND tsc.effective_date = @_eff_date

				END

				ELSE

				BEGIN

					-- Case when default is selected by asc order or shipper code name

					INSERT INTO #temp_shipper_codes(shipper_code_id, shipper_code2, effective_date)

					SELECT shipper_code_id, shipper_code2, DATEFROMPARTS(YEAR(@_term_start), MONTH(@_term_start), n) 

					FROM

					(SELECT TOP 1 * FROM #temp_collect_shipper_code2 WHERE effective_date = @_eff_date AND shipper_code2_is_default != ''y'' ORDER BY shipper_code2) tsc

					OUTER APPLY (SELECT TOP 1 effective_date FROM #temp_collect_shipper_code2 WHERE effective_date > @_eff_date ORDER BY effective_date ASC) a

					CROSS APPLY (

						SELECT n FROM seq WHERE 

						(a.effective_date IS NOT NULL AND n < DAY(a.effective_date) AND n >= DAY(@_eff_date))

						OR (a.effective_date IS NULL AND n >= DAY(@_eff_date) AND n <= DAY(EOMONTH((@_term_start))))

					) b			

				END	

				FETCH NEXT FROM date_cursor_ship2 INTO @_eff_date

			END

			CLOSE date_cursor_ship2

			DEALLOCATE date_cursor_ship2

	

		END

			--------------- END Shipper code 2-------------

		INSERT INTO #temp_final_shipper_codes(deal_header_id, deal_detail_id, counterparty_id, location_id, contract_id, shipper_code1, shipper_code2, effective_date)

		SELECT @_deal_header_id, @_deal_detail_id, @_counterparty_id, @_location_id, @_contract_id, sp1.shipper_code_id, sp2.shipper_code_id, sp1.effective_date 

		FROM

		(SELECT shipper_code_id, effective_date FROM #temp_shipper_codes WHERE shipper_code1 IS NOT NULL )sp1

		INNER JOIN  

		(SELECT shipper_code_id, effective_date FROM #temp_shipper_codes WHERE shipper_code2 IS NOT NULL )sp2

		ON sp2.effective_date = sp1.effective_date	

	END

FETCH NEXT FROM shipper_code_cur INTO @_deal_header_id, @_deal_detail_id, @_term_start, @_location_id, @_counterparty_id, @_contract_id

END

CLOSE shipper_code_cur

DEALLOCATE shipper_code_cur

DROP TABLE IF exists #final_data

SELECT sc.counterparty_name

	, sml.Location_Name

	, sdd.source_deal_header_id

	, a.effective_date 

	, tfsc.effective_date term

	, scmd.shipper_code1 shipper_code1

	, scmd2.shipper_code shipper_code2

	, a.external_id external_id_value

	, sdd.leg

	, cg.[contract_name]

	, @_counterparty_id counterparty_id	

	, @_contract_id contract_id

	, @_deal_detail_id deal_detail_id

	, @_location_id location_id

	, @_term_start term_start

	, @_deal_header_id deal_header_id

	, @_term_end term_end

	, @_external_id external_id

INTO #final_data

FROM #temp_final_shipper_codes tfsc

INNER JOIN shipper_code_mapping_detail scmd ON scmd.shipper_code_mapping_detail_id = tfsc.shipper_code1	

INNER JOIN shipper_code_mapping_detail scmd2 ON scmd2.shipper_code_mapping_detail_id = tfsc.shipper_code2	

INNER JOIN source_counterparty sc ON sc.source_counterparty_id = tfsc.counterparty_id

INNER JOIN source_minor_location sml ON sml.source_minor_location_id = tfsc.location_id

OUTER APPLY (SELECT effective_date, external_id FROM shipper_code_mapping_detail scmd3 

	INNER JOIN shipper_code_mapping scm ON scm.shipper_code_id = scmd3.shipper_code_id AND scm.counterparty_id = tfsc.counterparty_id 

	WHERE scmd3.shipper_code1 = scmd.shipper_code1 AND scmd3.shipper_code = scmd2.shipper_code AND scmd3.location_id = tfsc.location_id 

) a

INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = tfsc.deal_detail_id

INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id AND sdh.source_deal_header_id = tfsc.deal_header_id 

INNER JOIN contract_group cg ON cg.contract_id = tfsc.contract_id 

WHERE ((@_external_id IS NOT NULL AND a.external_id = @_external_id) OR (@_external_id IS NULL AND 1=1 ))

ORDER BY tfsc.effective_date ASC

select z.counterparty_name
	, z.Location_Name
	, z.source_deal_header_id
	, IIF(MONTH(z.effective_date) <> MONTH(z.term), a.effective_date, z.effective_date) effective_date
	, z.term
	, IIF(MONTH(z.effective_date) <> MONTH(z.term), a.shipper_code1, z.shipper_code1) shipper_code1
	, IIF(MONTH(z.effective_date) <> MONTH(z.term), a.shipper_code, z.shipper_code2) shipper_code2
	, z.external_id_value
	, z.leg
	, z.contract_name
	, z.counterparty_id
	, z.contract_id
	, z.deal_detail_id
	, z.location_id
	, z.term_start
	, z.deal_header_id
	, z.term_end
	, z.external_id 
	--[__batch_report__]
FROM #final_data z
INNER JOIN shipper_code_mapping scm
	ON scm.counterparty_id = z.counterparty_id
OUTER APPLY (
	SELECT TOP 1 MIN(shipper_code1) shipper_code1, MIN(shipper_code) shipper_code,effective_date
	FROM shipper_code_mapping_detail
	WHERE shipper_code_id = scm.shipper_code_id
		AND location_id = z.location_id
		AND effective_date <= @_term_start
	GROUP BY effective_date
	ORDER BY effective_date DESC
)a
ORDER BY IIF(MONTH(z.effective_date) <> MONTH(z.term), a.effective_date, z.effective_date) ASC', report_id = @report_id_data_source_dest,
	system_defined = '0'
	,category = '106500' 
	WHERE [name] = 'Shipper Code Details View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'contract_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract ID'
			   , reqd_param = NULL, widget_id = 7, datatype_id = 5, param_data_source = 'browse_contract_counterparty', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'contract_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_id' AS [name], 'Contract ID' AS ALIAS, NULL AS reqd_param, 7 AS widget_id, 5 AS datatype_id, 'browse_contract_counterparty' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'Counterparty' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'deal_detail_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Detail Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'deal_detail_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_detail_id' AS [name], 'Deal Detail Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'external_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'External Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'external_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'external_id' AS [name], 'External Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'Location_Name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'Location_Name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Location_Name' AS [name], 'Location Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'shipper_code1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Shipper Code1'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'shipper_code1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'shipper_code1' AS [name], 'Shipper Code1' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'shipper_code2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Shipper Code2'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'shipper_code2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'shipper_code2' AS [name], 'Shipper Code2' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID'
			   , reqd_param = NULL, widget_id = 7, datatype_id = 5, param_data_source = 'browse_counterparty', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id' AS [name], 'Counterparty ID' AS ALIAS, NULL AS reqd_param, 7 AS widget_id, 5 AS datatype_id, 'browse_counterparty' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'location_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location ID'
			   , reqd_param = NULL, widget_id = 7, datatype_id = 5, param_data_source = 'browse_location', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'location_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_id' AS [name], 'Location ID' AS ALIAS, NULL AS reqd_param, 7 AS widget_id, 5 AS datatype_id, 'browse_location' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Header Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_header_id' AS [name], 'Deal Header Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'effective_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Effective Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'effective_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'effective_date' AS [name], 'Effective Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'external_id_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'External Id Value'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'external_id_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'external_id_value' AS [name], 'External Id Value' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'leg'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Leg'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'leg'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'leg' AS [name], 'Leg' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'Term End' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'contract_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'contract_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_name' AS [name], 'Contract Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Shipper Code Details View'
	            AND dsc.name =  'term'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Shipper Code Details View'
			AND dsc.name =  'term'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term' AS [name], 'Term' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Shipper Code Details View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Shipper Code Details View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	