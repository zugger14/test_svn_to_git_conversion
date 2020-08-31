 BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'D3917C1E_D6DB_4C89_ADAC_14A32A8B4120'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Treasury Price'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Treasury Price' ,
					'N' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'n' ,
					@admin_user ,
					23503,
					1,
					'D3917C1E_D6DB_4C89_ADAC_14A32A8B4120'
					 )

				SET @ixp_rules_id_new = SCOPE_IDENTITY()
				EXEC spa_print 	@ixp_rules_id_new

				UPDATE ixp
				SET import_export_id = @ixp_rules_id_new
				FROM ipx_privileges ixp
				WHERE ixp.import_export_id = @old_ixp_rule_id
		END
				
				

		ELSE 
		BEGIN
			SET @ixp_rules_id_new = @old_ixp_rule_id
			EXEC spa_print 	@ixp_rules_id_new
			
			UPDATE
			ixp_rules
			SET ixp_rules_name = 'Treasury Price'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = NULL
				, after_insert_trigger = NULL
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23503
				, is_system_import = 'n'
				, is_active = 1
			WHERE ixp_rules_id = @ixp_rules_id_new
				
		END

				
INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)  
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  0,
										  0,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_source_price_curve_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password, clr_function_id, ws_function_name)
					SELECT @ixp_rules_id_new,
						   NULL,
						   'adiha_process.dbo.treasury_import_A2A1099D_C6ED_43FC_A34C_6F9AC908B104',
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'pc',
						   '1',
						   '	
		if OBJECT_ID(''tempdb..#source_table_columns'') is not null  drop table #source_table_columns 
		if OBJECT_ID(''tempdb..#tmp_source_price_curve_treasury'') is not null  drop table #tmp_source_price_curve_treasury 

			CREATE TABLE #source_table_columns  
			( 
				column_name		VARCHAR(100) COLLATE DATABASE_DEFAULT , 
				no_months		INT
			)

		CREATE TABLE #tmp_source_price_curve_treasury([id] INT IDENTITY(1,1),asOfDate VARCHAR(200),[1mo] FLOAT, [3mo] FLOAT,[6mo] FLOAT,[1yr] FLOAT,[2yr] FLOAT,[3yr] FLOAT,[5yr] FLOAT,[7yr] FLOAT,[10yr] FLOAT,[20yr] FLOAT,[30yr] FLOAT,[30yrDisplay] FLOAT)

		DECLARE  @sql VARCHAR(MAX)
		DECLARE @as_of_date VARCHAR(10)
		SET @as_of_date = CONVERT(VARCHAR(10),getdate(),120)

		INSERT INTO #tmp_source_price_curve_treasury(asofdate,[1mo], [3mo],[6mo],[1yr],[2yr],[3yr],[5yr],[7yr],[10yr],[20yr],[30yr],[30yrDisplay])
		SELECT new_date, BC_1Month,BC_3Month,BC_6Month,BC_1Year,BC_2Year,BC_3Year,BC_5Year,BC_7Year,BC_10Year,BC_20Year,BC_30Year,BC_30YearDisplay 
		from 
			--adiha_process.dbo.treasury_import_A2A1099D_C6ED_43FC_A34C_6F9AC908B104 
			[temp_process_table]
		WHERE ISDATE(new_date)=1

	INSERT INTO #source_table_columns(column_name, no_months)
		SELECT ''1mo'',1
				UNION ALL SELECT ''3mo'',3
				UNION ALL SELECT ''6mo'',6
				UNION ALL SELECT ''1yr'',12
				UNION ALL SELECT ''2yr'',24
				UNION ALL SELECT ''3yr'',36
				UNION ALL SELECT ''5yr'',60
				UNION ALL SELECT ''7yr'',84
				UNION ALL SELECT ''10yr'',120
				UNION ALL SELECT ''20yr'',240
				UNION ALL SELECT ''30yr'',360
				
				SELECT @sql =
					''
					SELECT 
					  final_set.curve_id [curve id]
					, final_set.asofdate [as of date]
					, ''''Master'''' [source curve name]
					, final_set.maturity_date [maturity date]
					, final_set.is_dst [is dst]
					, final_set.Curve_value [curve value]
					, final_set.maturity_hour [hour]	 
					, NULL [minute]
					, NULL [bid value]
					, NULL [ask value]
				--[__custom_table__]
					 FROM 
					(					
						SELECT spcd.curve_id,2 [source_system_id],asofdate,77[Assessment_curve_type_value_id],4500[curve_source_value_id],a.maturity_date,NULL [maturity_hour],a.Curve_value,0 [is_dst]
						from 
					(
						select asofdate,maturity_date,Curve_value from 
						(
							SELECT RowNumber,dt.asofdate,DATEADD(MONTH,no_months, cast(stuff(asofdate,1,2,''''01'''') AS DATETIME)) maturity_date  , col.column_name  from #source_table_columns col 
							CROSS JOIN 
							(
								SELECT ROW_NUMBER() OVER(ORDER BY id) AS RowNumber,* FROM #tmp_source_price_curve_treasury WHERE asOfDate IS NOT NULL
							) dt
						) cur_date 
						INNER JOIN
						(
							SELECT RowNumber, column_name, Curve_value
							FROM 
							   (
									SELECT ROW_NUMBER() OVER(ORDER BY id) AS RowNumber,[1mo], [3mo],[6mo],[1yr],[2yr],[3yr],[5yr],[7yr],[10yr],[20yr],[30yr],[30yrDisplay] from #tmp_source_price_curve_treasury --where asOfDate is  null
								) p
							UNPIVOT
							   ( Curve_value FOR column_name IN 
								  ([1mo], [3mo],[6mo],[1yr],[2yr],[3yr],[5yr],[7yr],[10yr],[20yr],[30yr],[30yrDisplay])
								)AS unpvt
						) cur_value on cur_date.RowNumber=cur_value.RowNumber and cur_date.column_name=cur_value.column_name 
							WHERE Curve_value IS NOT NULL
						)  a cross join source_price_curve_def spcd where spcd.market_value_id=''''Treasury Yield''''
					) final_set
				WHERE 1=1
				AND asofdate = CONVERT(VARCHAR(10),CAST(''''''+@as_of_date+'''''' AS DATETIME),110)
				 ''
				
				--PRINT @sql	
				EXEC(@sql)	',
						   'n',
						   0,
						   'D:\Raju\Time series\Price curve data',
						   '1',
						   'n',
						   'Sheet1',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   '0',
						   '',
						   '',
						   0x01000000C8294FD285B9699A4C01156767DED290D64A5449BECDE2E6,
						   icf.ixp_clr_functions_id,
						   ''
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = 'Treasury' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 


INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pc.[curve id]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_curve_def_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pc.[as of date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'as_of_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pc.[source curve name]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curve_source_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pc.[maturity date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'maturity_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pc.[curve value]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curve_value' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pc.[bid value]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'bid_value' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pc.[ask value]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'ask_value' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pc.[is dst]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_dst' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pc.[hour]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hour' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'pc.[minute]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'minute' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_template'

COMMIT 

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
				DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
				DECLARE @msg_severity INT = ERROR_SEVERITY();
				DECLARE @msg_state INT = ERROR_STATE();
					
				RAISERROR(@msg, @msg_severity, @msg_state)
			
				--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH
			END
		