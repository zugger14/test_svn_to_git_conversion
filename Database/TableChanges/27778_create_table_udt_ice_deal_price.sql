
	SET ANSI_NULLS ON
	GO 

	SET QUOTED_IDENTIFIER ON
	GO

	-- Check if destination UDT view is already in use
	IF EXISTS ( SELECT 1 FROM [data_source] ds
				INNER JOIN report_dataset rd
					ON ds.data_source_id = rd.source_id
				WHERE ds.[name] = 'udt_ice_deal_price' )
	BEGIN
		IF EXISTS ( SELECT 1 FROM [data_source] ds
					INNER JOIN data_source_column dsc
						ON ds.data_source_id = dsc.source_id
					LEFT JOIN report_param rp
						ON dsc.data_source_column_id = rp.column_id
					LEFT JOIN report_tablix_column rtc
						ON dsc.data_source_column_id = rtc.column_id
					LEFT JOIN report_chart_column rcc
						ON dsc.data_source_column_id = rcc.column_id
					LEFT JOIN report_gauge_column rgc
						ON dsc.data_source_column_id = rgc.column_id
					WHERE ds.[name] = 'udt_ice_deal_price'
					AND COALESCE(rp.report_param_id, rtc.report_tablix_column_id, rcc.report_chart_column_id, rgc.report_gauge_column_id) IS NULL
		)
		BEGIN
			EXEC spa_ErrorHandler 0,
				'Setup User Defined Tables',
				'spa_user_defined_tables',
				'Error',
				'Source and destination user defined table are incompatible. Columns are used in report manager views.',
				''
			RETURN
		END
	END
	
	BEGIN TRY
		BEGIN TRAN 
		DECLARE @udt_id_new INT
		DECLARE @sql NVARCHAR(MAX)

		IF NOT EXISTS(SELECT 1 FROM user_defined_tables WHERE udt_hash = '8C1E0BC9_A10F_475B_BF47_8E2513FE3CEC')
		BEGIN
			INSERT INTO user_defined_tables(udt_name, udt_descriptions, udt_hash)
			SELECT 'ice_deal_price', 'Ice Deal Price', '8C1E0BC9_A10F_475B_BF47_8E2513FE3CEC'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables
			SET udt_name = 'ice_deal_price'
			  , udt_descriptions = 'Ice Deal Price'
			WHERE udt_hash = '8C1E0BC9_A10F_475B_BF47_8E2513FE3CEC'
		END

		SELECT @udt_id_new = udt_id FROM user_defined_tables WHERE udt_name = 'ice_deal_price'
		 
		IF OBJECT_ID('tempdb..#collect_all_column') IS NOT NULL
			DROP TABLE #collect_all_column
		CREATE TABLE #collect_all_column(
			id INT IDENTITY(1, 1),
			column_name NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)

		INSERT INTO #collect_all_column
		
		SELECT 'TradeId1' UNION ALL 
		SELECT 'id' UNION ALL 
		SELECT 'LegCFICode' UNION ALL 
		SELECT 'LegContractMultiplier' UNION ALL 
		SELECT 'LegCurrency' UNION ALL 
		SELECT 'LegEndDate' UNION ALL 
		SELECT 'LegExDestination' UNION ALL 
		SELECT 'LegLastPx' UNION ALL 
		SELECT 'LegMaturityDate' UNION ALL 
		SELECT 'LegMaturityMonthYear' UNION ALL 
		SELECT 'LegMemoField' UNION ALL 
		SELECT 'LegNumOfCycles' UNION ALL 
		SELECT 'LegNumOfLots' UNION ALL 
		SELECT 'LegPrice' UNION ALL 
		SELECT 'LegQty' UNION ALL 
		SELECT 'LegRefID' UNION ALL 
		SELECT 'LegSecurityAltID' UNION ALL 
		SELECT 'LegSecurityAltIDSource' UNION ALL 
		SELECT 'LegSecurityExchange' UNION ALL 
		SELECT 'LegSecurityID' UNION ALL 
		SELECT 'LegSecuritySubType' UNION ALL 
		SELECT 'LegSecurityType' UNION ALL 
		SELECT 'LegSecurityIDSource' UNION ALL 
		SELECT 'LegSide' UNION ALL 
		SELECT 'LegStartDate' UNION ALL 
		SELECT 'LegStrikePrice' UNION ALL 
		SELECT 'LegSymbol' UNION ALL 
		SELECT 'LegUnitOfMeasure' UNION ALL 
		SELECT 'TradeDate'
	
		DELETE udtm FROM user_defined_tables_metadata udtm 
		LEFT JOIN user_defined_tables udt
			ON udt.udt_id = udtm.udt_id
		LEFT JOIN #collect_all_column a
			ON udtm.column_name = a.column_name 
		WHERE udt.udt_id = @udt_id_new AND a.id IS NULL 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'EAF01005_3717_4DAE_AFEA_0021B20AFCB6' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'TradeId1', 'Trade Id', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 1, 1, NULL, 0, NULL, 'EAF01005_3717_4DAE_AFEA_0021B20AFCB6'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'TradeId1'
				,column_descriptions  = 'Trade Id'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 1
				,sequence_no  = 1
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'EAF01005_3717_4DAE_AFEA_0021B20AFCB6'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '23C2E905_BED2_4622_A3AA_E7F4830E606A' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'id', 'Id', '104302', 100, 1, 1, '0  ', 1,1,NULL, 0, 0, NULL, NULL, 0, NULL, '23C2E905_BED2_4622_A3AA_E7F4830E606A'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'id'
				,column_descriptions  = 'Id'
				,column_type  = '104302'
				,column_length  = 100
				,column_prec  = 1
				,column_scale  = 1
				,column_nullable  = '0  '
				,is_primary  = 1
				,is_identity  = 1
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = NULL
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '23C2E905_BED2_4622_A3AA_E7F4830E606A'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '98A7DE26_1E86_4A8E_85AE_A0A121AD54F0' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegCFICode', 'Leg CFI Code', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 2, NULL, 0, NULL, '98A7DE26_1E86_4A8E_85AE_A0A121AD54F0'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegCFICode'
				,column_descriptions  = 'Leg CFI Code'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 2
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '98A7DE26_1E86_4A8E_85AE_A0A121AD54F0'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'BD545A38_BA75_43CC_A0F0_AFC7BCB61A5B' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegContractMultiplier', 'Leg Contract Multiplier', '104302', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 3, NULL, 0, NULL, 'BD545A38_BA75_43CC_A0F0_AFC7BCB61A5B'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegContractMultiplier'
				,column_descriptions  = 'Leg Contract Multiplier'
				,column_type  = '104302'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 3
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'BD545A38_BA75_43CC_A0F0_AFC7BCB61A5B'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '73DBE2C2_7F0C_4977_A5BE_B42CDE435B46' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegCurrency', 'Leg Currency', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 4, NULL, 0, NULL, '73DBE2C2_7F0C_4977_A5BE_B42CDE435B46'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegCurrency'
				,column_descriptions  = 'Leg Currency'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 4
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '73DBE2C2_7F0C_4977_A5BE_B42CDE435B46'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '04EEBE23_95A9_40ED_95CC_D8F284C738E5' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegEndDate', 'Leg End Date', '104304', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 5, NULL, 0, NULL, '04EEBE23_95A9_40ED_95CC_D8F284C738E5'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegEndDate'
				,column_descriptions  = 'Leg End Date'
				,column_type  = '104304'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 5
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '04EEBE23_95A9_40ED_95CC_D8F284C738E5'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'AD871F40_3C04_4B1E_B7A6_12D530C904BB' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegExDestination', 'Leg Ex Destination', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 6, NULL, 0, NULL, 'AD871F40_3C04_4B1E_B7A6_12D530C904BB'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegExDestination'
				,column_descriptions  = 'Leg Ex Destination'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 6
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'AD871F40_3C04_4B1E_B7A6_12D530C904BB'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '91C090E2_F1DE_4FCA_8638_FBCB5260836E' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegLastPx', 'Leg Last Px', '104303', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 7, NULL, 0, NULL, '91C090E2_F1DE_4FCA_8638_FBCB5260836E'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegLastPx'
				,column_descriptions  = 'Leg Last Px'
				,column_type  = '104303'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 7
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '91C090E2_F1DE_4FCA_8638_FBCB5260836E'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '31F93C73_900A_4040_992F_C8C0A55876B8' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegMaturityDate', 'Leg Maturity Date', '104304', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 8, NULL, 0, NULL, '31F93C73_900A_4040_992F_C8C0A55876B8'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegMaturityDate'
				,column_descriptions  = 'Leg Maturity Date'
				,column_type  = '104304'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 8
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '31F93C73_900A_4040_992F_C8C0A55876B8'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '27D395E9_1C56_4D24_BAA7_71E8061AEF86' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegMaturityMonthYear', 'Leg Maturity Month Year', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 9, NULL, 0, NULL, '27D395E9_1C56_4D24_BAA7_71E8061AEF86'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegMaturityMonthYear'
				,column_descriptions  = 'Leg Maturity Month Year'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 9
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '27D395E9_1C56_4D24_BAA7_71E8061AEF86'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '6C0A2361_15DA_4F78_B9E5_38612F25C2FD' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegMemoField', 'Leg Memo Field', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 10, NULL, 0, NULL, '6C0A2361_15DA_4F78_B9E5_38612F25C2FD'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegMemoField'
				,column_descriptions  = 'Leg Memo Field'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 10
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '6C0A2361_15DA_4F78_B9E5_38612F25C2FD'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '1D01CE8C_A101_407D_BD55_64A916D511DB' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegNumOfCycles', 'Leg Number Of Cycles', '104302', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 11, NULL, 0, NULL, '1D01CE8C_A101_407D_BD55_64A916D511DB'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegNumOfCycles'
				,column_descriptions  = 'Leg Number Of Cycles'
				,column_type  = '104302'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 11
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '1D01CE8C_A101_407D_BD55_64A916D511DB'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '41426E5A_FA34_4580_B36A_FB7473E18443' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegNumOfLots', 'Leg Number Of Lots', '104302', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 12, NULL, 0, NULL, '41426E5A_FA34_4580_B36A_FB7473E18443'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegNumOfLots'
				,column_descriptions  = 'Leg Number Of Lots'
				,column_type  = '104302'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 12
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '41426E5A_FA34_4580_B36A_FB7473E18443'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'AE4223ED_E0EE_4A08_B145_7CF893BA9E40' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegPrice', 'Leg Price', '104303', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 13, NULL, 0, NULL, 'AE4223ED_E0EE_4A08_B145_7CF893BA9E40'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegPrice'
				,column_descriptions  = 'Leg Price'
				,column_type  = '104303'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 13
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'AE4223ED_E0EE_4A08_B145_7CF893BA9E40'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '718DA8D2_B797_489C_822D_874FFA729A55' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegQty', 'Leg Qty', '104302', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 14, NULL, 0, NULL, '718DA8D2_B797_489C_822D_874FFA729A55'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegQty'
				,column_descriptions  = 'Leg Qty'
				,column_type  = '104302'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 14
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '718DA8D2_B797_489C_822D_874FFA729A55'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '67B9D3D9_E29A_44C4_8BCA_3D305D58E7A8' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegRefID', 'Leg Reference ID', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 15, NULL, 0, NULL, '67B9D3D9_E29A_44C4_8BCA_3D305D58E7A8'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegRefID'
				,column_descriptions  = 'Leg Reference ID'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 15
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '67B9D3D9_E29A_44C4_8BCA_3D305D58E7A8'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '69E2641F_EA47_4AAE_A299_FEC2F5CC243C' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegSecurityAltID', 'Leg Security Alt ID', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 16, NULL, 0, NULL, '69E2641F_EA47_4AAE_A299_FEC2F5CC243C'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegSecurityAltID'
				,column_descriptions  = 'Leg Security Alt ID'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 16
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '69E2641F_EA47_4AAE_A299_FEC2F5CC243C'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '4CD79E70_133A_41AA_80ED_05990568463F' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegSecurityAltIDSource', 'Leg Security Alt ID Source', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 17, NULL, 0, NULL, '4CD79E70_133A_41AA_80ED_05990568463F'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegSecurityAltIDSource'
				,column_descriptions  = 'Leg Security Alt ID Source'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 17
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '4CD79E70_133A_41AA_80ED_05990568463F'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '1AFB3FDC_B8C4_49BF_9477_77BE2F7283A0' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegSecurityExchange', 'Leg Security Exchange', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 18, NULL, 0, NULL, '1AFB3FDC_B8C4_49BF_9477_77BE2F7283A0'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegSecurityExchange'
				,column_descriptions  = 'Leg Security Exchange'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 18
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '1AFB3FDC_B8C4_49BF_9477_77BE2F7283A0'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '403D2A11_977B_4A95_B4EE_47B4D53C6403' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegSecurityID', 'Leg Security ID', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 19, NULL, 0, NULL, '403D2A11_977B_4A95_B4EE_47B4D53C6403'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegSecurityID'
				,column_descriptions  = 'Leg Security ID'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 19
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '403D2A11_977B_4A95_B4EE_47B4D53C6403'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '22CE2286_91F2_4FB2_A0F3_0E936B8AD2C1' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegSecuritySubType', 'Leg Security Sub Type', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 21, NULL, 0, NULL, '22CE2286_91F2_4FB2_A0F3_0E936B8AD2C1'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegSecuritySubType'
				,column_descriptions  = 'Leg Security Sub Type'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 21
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '22CE2286_91F2_4FB2_A0F3_0E936B8AD2C1'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'BD1DA25E_2ED5_467A_A27B_4D3FB510D203' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegSecurityType', 'Leg Security Type', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 22, NULL, 0, NULL, 'BD1DA25E_2ED5_467A_A27B_4D3FB510D203'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegSecurityType'
				,column_descriptions  = 'Leg Security Type'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 22
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'BD1DA25E_2ED5_467A_A27B_4D3FB510D203'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'FDEDC48F_328B_4E67_B220_533B9E167F74' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegSecurityIDSource', 'Leg SecurityI D Source', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 20, NULL, 0, NULL, 'FDEDC48F_328B_4E67_B220_533B9E167F74'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegSecurityIDSource'
				,column_descriptions  = 'Leg SecurityI D Source'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 20
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'FDEDC48F_328B_4E67_B220_533B9E167F74'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'EEEF4618_31F2_4283_807F_584704A903C1' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegSide', 'Leg Side', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 23, NULL, 0, NULL, 'EEEF4618_31F2_4283_807F_584704A903C1'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegSide'
				,column_descriptions  = 'Leg Side'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 23
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'EEEF4618_31F2_4283_807F_584704A903C1'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '4ABBDB9C_F9A4_41C1_8C37_44273521114E' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegStartDate', 'Leg Start Date', '104304', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 24, NULL, 0, NULL, '4ABBDB9C_F9A4_41C1_8C37_44273521114E'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegStartDate'
				,column_descriptions  = 'Leg Start Date'
				,column_type  = '104304'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 24
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '4ABBDB9C_F9A4_41C1_8C37_44273521114E'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '72088176_E061_480B_834B_F821C7DDF70B' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegStrikePrice', 'Leg Strike Price', '104303', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 25, NULL, 0, NULL, '72088176_E061_480B_834B_F821C7DDF70B'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegStrikePrice'
				,column_descriptions  = 'Leg Strike Price'
				,column_type  = '104303'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 25
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '72088176_E061_480B_834B_F821C7DDF70B'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'EDB745E5_FB4B_4FB0_B3B1_84DCB43AF50D' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegSymbol', 'Leg Symbol', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 26, NULL, 0, NULL, 'EDB745E5_FB4B_4FB0_B3B1_84DCB43AF50D'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegSymbol'
				,column_descriptions  = 'Leg Symbol'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 26
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'EDB745E5_FB4B_4FB0_B3B1_84DCB43AF50D'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'EFF036B9_8E9A_4D66_AF48_FFFA9BCC942C' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'LegUnitOfMeasure', 'Leg Unit Of Measure', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 27, NULL, 0, NULL, 'EFF036B9_8E9A_4D66_AF48_FFFA9BCC942C'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'LegUnitOfMeasure'
				,column_descriptions  = 'Leg Unit Of Measure'
				,column_type  = '104301'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 27
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'EFF036B9_8E9A_4D66_AF48_FFFA9BCC942C'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '51F5852F_F6B3_444B_B1C0_B4B398953C1D' )
		BEGIN
			INSERT INTO user_defined_tables_metadata( udt_id
													, column_name
													, column_descriptions
													, column_type
													, column_length
													, column_prec
													, column_scale
													, column_nullable
													, is_primary
													, is_identity
													, static_data_type_id
													, has_value
													, use_as_filter
													, sequence_no
													, rounding
													, unique_combination
													, custom_validation
													, udt_column_hash
													)
			SELECT		  @udt_id_new, 
						'TradeDate', 'Trade Date', '104304', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 28, NULL, 0, NULL, '51F5852F_F6B3_444B_B1C0_B4B398953C1D'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'TradeDate'
				,column_descriptions  = 'Trade Date'
				,column_type  = '104304'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 28
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '51F5852F_F6B3_444B_B1C0_B4B398953C1D'
		END
	 
		DELETE FROM user_defined_tables_metadata
		WHERE udt_column_hash NOT IN ('EAF01005_3717_4DAE_AFEA_0021B20AFCB6','23C2E905_BED2_4622_A3AA_E7F4830E606A','98A7DE26_1E86_4A8E_85AE_A0A121AD54F0','BD545A38_BA75_43CC_A0F0_AFC7BCB61A5B','73DBE2C2_7F0C_4977_A5BE_B42CDE435B46','04EEBE23_95A9_40ED_95CC_D8F284C738E5','AD871F40_3C04_4B1E_B7A6_12D530C904BB','91C090E2_F1DE_4FCA_8638_FBCB5260836E','31F93C73_900A_4040_992F_C8C0A55876B8','27D395E9_1C56_4D24_BAA7_71E8061AEF86','6C0A2361_15DA_4F78_B9E5_38612F25C2FD','1D01CE8C_A101_407D_BD55_64A916D511DB','41426E5A_FA34_4580_B36A_FB7473E18443','AE4223ED_E0EE_4A08_B145_7CF893BA9E40','718DA8D2_B797_489C_822D_874FFA729A55','67B9D3D9_E29A_44C4_8BCA_3D305D58E7A8','69E2641F_EA47_4AAE_A299_FEC2F5CC243C','4CD79E70_133A_41AA_80ED_05990568463F','1AFB3FDC_B8C4_49BF_9477_77BE2F7283A0','403D2A11_977B_4A95_B4EE_47B4D53C6403','22CE2286_91F2_4FB2_A0F3_0E936B8AD2C1','BD1DA25E_2ED5_467A_A27B_4D3FB510D203','FDEDC48F_328B_4E67_B220_533B9E167F74','EEEF4618_31F2_4283_807F_584704A903C1','4ABBDB9C_F9A4_41C1_8C37_44273521114E','72088176_E061_480B_834B_F821C7DDF70B','EDB745E5_FB4B_4FB0_B3B1_84DCB43AF50D','EFF036B9_8E9A_4D66_AF48_FFFA9BCC942C','51F5852F_F6B3_444B_B1C0_B4B398953C1D')
			AND udt_id = @udt_id_new
	 
		EXEC spa_ErrorHandler 0,
			'User defined table import',
			'User defined table import',
			'Success',
			'Data has been imported successfully.',
			''
		COMMIT TRAN 
	END TRY 
	BEGIN CATCH
		EXEC spa_ErrorHandler 1,
				'User defined table import',
				'User defined table import',
				'DB Error',
				'Fail to import data',
				''
		ROLLBACK TRAN
	END CATCH 
	
		DECLARE @udt_id INT
			  , @udt_name NVARCHAR(200)
	
		SELECT @udt_id = udt_id
			 , @udt_name = udt_name
		FROM user_defined_tables
		WHERE udt_hash = '8C1E0BC9_A10F_475B_BF47_8E2513FE3CEC'

		-- Rename table if modified
		IF EXISTS ( SELECT 1
					FROM SYS.EXTENDED_PROPERTIES sep
					INNER JOIN sys.tables st 
						ON sep.major_id = st.object_id
					WHERE sep.minor_id = 0
						AND sep.[name] = 'udt_hash'
						AND sep.[value] = '8C1E0BC9_A10F_475B_BF47_8E2513FE3CEC'
						AND st.[name] <> 'udt_' + @udt_name )
		BEGIN
			-- Get modified udt name and rename it
			SELECT @udt_name = st.[name]
			FROM SYS.EXTENDED_PROPERTIES sep
			INNER JOIN sys.tables st 
				ON sep.major_id = st.object_id
			WHERE sep.minor_id = 0
				AND sep.[name] = 'udt_hash'
				AND sep.[value] = '8C1E0BC9_A10F_475B_BF47_8E2513FE3CEC'

			EXEC ('EXEC sp_rename ''[dbo].[' + @udt_name + ']'', ''udt_ice_deal_price''')
		END

		IF OBJECT_ID(N'[dbo].[udt_ice_deal_price]', N'U') IS NULL
		BEGIN
			CREATE TABLE [dbo].[udt_ice_deal_price]
			(	
			[id] INT  PRIMARY KEY  IDENTITY(1, 1)  NOT NULL,
			[TradeId1] VARCHAR(100)  NULL,
			[LegCFICode] VARCHAR(100)  NULL,
			[LegContractMultiplier] INT  NULL,
			[LegCurrency] VARCHAR(100)  NULL,
			[LegEndDate] DATETIME  NULL,
			[LegExDestination] VARCHAR(100)  NULL,
			[LegLastPx] FLOAT  NULL,
			[LegMaturityDate] DATETIME  NULL,
			[LegMaturityMonthYear] VARCHAR(100)  NULL,
			[LegMemoField] VARCHAR(100)  NULL,
			[LegNumOfCycles] INT  NULL,
			[LegNumOfLots] INT  NULL,
			[LegPrice] FLOAT  NULL,
			[LegQty] INT  NULL,
			[LegRefID] VARCHAR(100)  NULL,
			[LegSecurityAltID] VARCHAR(100)  NULL,
			[LegSecurityAltIDSource] VARCHAR(100)  NULL,
			[LegSecurityExchange] VARCHAR(100)  NULL,
			[LegSecurityID] VARCHAR(100)  NULL,
			[LegSecurityIDSource] VARCHAR(100)  NULL,
			[LegSecuritySubType] VARCHAR(100)  NULL,
			[LegSecurityType] VARCHAR(100)  NULL,
			[LegSide] VARCHAR(100)  NULL,
			[LegStartDate] DATETIME  NULL,
			[LegStrikePrice] FLOAT  NULL,
			[LegSymbol] VARCHAR(100)  NULL,
			[LegUnitOfMeasure] VARCHAR(100)  NULL,
			[TradeDate] DATETIME  NULL,
    			[create_user] NVARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    			[create_ts] DATETIME NULL DEFAULT GETDATE(),
    			[update_user] NVARCHAR(50) NULL,
    			[update_ts]	DATETIME NULL
			)
		END
		ELSE
		BEGIN
			-- Rename columns
			DECLARE @column_name NVARCHAR(200)
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = 'EAF01005_3717_4DAE_AFEA_0021B20AFCB6'
							AND sc.[name] <> 'TradeId1'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = 'EAF01005_3717_4DAE_AFEA_0021B20AFCB6'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''TradeId1'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '23C2E905_BED2_4622_A3AA_E7F4830E606A'
							AND sc.[name] <> 'id'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '23C2E905_BED2_4622_A3AA_E7F4830E606A'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''id'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '98A7DE26_1E86_4A8E_85AE_A0A121AD54F0'
							AND sc.[name] <> 'LegCFICode'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '98A7DE26_1E86_4A8E_85AE_A0A121AD54F0'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegCFICode'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = 'BD545A38_BA75_43CC_A0F0_AFC7BCB61A5B'
							AND sc.[name] <> 'LegContractMultiplier'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = 'BD545A38_BA75_43CC_A0F0_AFC7BCB61A5B'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegContractMultiplier'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '73DBE2C2_7F0C_4977_A5BE_B42CDE435B46'
							AND sc.[name] <> 'LegCurrency'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '73DBE2C2_7F0C_4977_A5BE_B42CDE435B46'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegCurrency'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '04EEBE23_95A9_40ED_95CC_D8F284C738E5'
							AND sc.[name] <> 'LegEndDate'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '04EEBE23_95A9_40ED_95CC_D8F284C738E5'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegEndDate'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = 'AD871F40_3C04_4B1E_B7A6_12D530C904BB'
							AND sc.[name] <> 'LegExDestination'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = 'AD871F40_3C04_4B1E_B7A6_12D530C904BB'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegExDestination'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '91C090E2_F1DE_4FCA_8638_FBCB5260836E'
							AND sc.[name] <> 'LegLastPx'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '91C090E2_F1DE_4FCA_8638_FBCB5260836E'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegLastPx'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '31F93C73_900A_4040_992F_C8C0A55876B8'
							AND sc.[name] <> 'LegMaturityDate'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '31F93C73_900A_4040_992F_C8C0A55876B8'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegMaturityDate'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '27D395E9_1C56_4D24_BAA7_71E8061AEF86'
							AND sc.[name] <> 'LegMaturityMonthYear'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '27D395E9_1C56_4D24_BAA7_71E8061AEF86'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegMaturityMonthYear'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '6C0A2361_15DA_4F78_B9E5_38612F25C2FD'
							AND sc.[name] <> 'LegMemoField'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '6C0A2361_15DA_4F78_B9E5_38612F25C2FD'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegMemoField'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '1D01CE8C_A101_407D_BD55_64A916D511DB'
							AND sc.[name] <> 'LegNumOfCycles'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '1D01CE8C_A101_407D_BD55_64A916D511DB'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegNumOfCycles'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '41426E5A_FA34_4580_B36A_FB7473E18443'
							AND sc.[name] <> 'LegNumOfLots'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '41426E5A_FA34_4580_B36A_FB7473E18443'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegNumOfLots'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = 'AE4223ED_E0EE_4A08_B145_7CF893BA9E40'
							AND sc.[name] <> 'LegPrice'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = 'AE4223ED_E0EE_4A08_B145_7CF893BA9E40'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegPrice'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '718DA8D2_B797_489C_822D_874FFA729A55'
							AND sc.[name] <> 'LegQty'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '718DA8D2_B797_489C_822D_874FFA729A55'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegQty'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '67B9D3D9_E29A_44C4_8BCA_3D305D58E7A8'
							AND sc.[name] <> 'LegRefID'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '67B9D3D9_E29A_44C4_8BCA_3D305D58E7A8'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegRefID'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '69E2641F_EA47_4AAE_A299_FEC2F5CC243C'
							AND sc.[name] <> 'LegSecurityAltID'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '69E2641F_EA47_4AAE_A299_FEC2F5CC243C'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegSecurityAltID'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '4CD79E70_133A_41AA_80ED_05990568463F'
							AND sc.[name] <> 'LegSecurityAltIDSource'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '4CD79E70_133A_41AA_80ED_05990568463F'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegSecurityAltIDSource'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '1AFB3FDC_B8C4_49BF_9477_77BE2F7283A0'
							AND sc.[name] <> 'LegSecurityExchange'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '1AFB3FDC_B8C4_49BF_9477_77BE2F7283A0'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegSecurityExchange'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '403D2A11_977B_4A95_B4EE_47B4D53C6403'
							AND sc.[name] <> 'LegSecurityID'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '403D2A11_977B_4A95_B4EE_47B4D53C6403'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegSecurityID'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '22CE2286_91F2_4FB2_A0F3_0E936B8AD2C1'
							AND sc.[name] <> 'LegSecuritySubType'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '22CE2286_91F2_4FB2_A0F3_0E936B8AD2C1'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegSecuritySubType'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = 'BD1DA25E_2ED5_467A_A27B_4D3FB510D203'
							AND sc.[name] <> 'LegSecurityType'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = 'BD1DA25E_2ED5_467A_A27B_4D3FB510D203'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegSecurityType'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = 'FDEDC48F_328B_4E67_B220_533B9E167F74'
							AND sc.[name] <> 'LegSecurityIDSource'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = 'FDEDC48F_328B_4E67_B220_533B9E167F74'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegSecurityIDSource'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = 'EEEF4618_31F2_4283_807F_584704A903C1'
							AND sc.[name] <> 'LegSide'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = 'EEEF4618_31F2_4283_807F_584704A903C1'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegSide'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '4ABBDB9C_F9A4_41C1_8C37_44273521114E'
							AND sc.[name] <> 'LegStartDate'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '4ABBDB9C_F9A4_41C1_8C37_44273521114E'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegStartDate'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '72088176_E061_480B_834B_F821C7DDF70B'
							AND sc.[name] <> 'LegStrikePrice'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '72088176_E061_480B_834B_F821C7DDF70B'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegStrikePrice'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = 'EDB745E5_FB4B_4FB0_B3B1_84DCB43AF50D'
							AND sc.[name] <> 'LegSymbol'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = 'EDB745E5_FB4B_4FB0_B3B1_84DCB43AF50D'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegSymbol'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = 'EFF036B9_8E9A_4D66_AF48_FFFA9BCC942C'
							AND sc.[name] <> 'LegUnitOfMeasure'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = 'EFF036B9_8E9A_4D66_AF48_FFFA9BCC942C'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''LegUnitOfMeasure'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_ice_deal_price'
							AND sep.[value] = '51F5852F_F6B3_444B_B1C0_B4B398953C1D'
							AND sc.[name] <> 'TradeDate'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_ice_deal_price'
					AND sep.[value] = '51F5852F_F6B3_444B_B1C0_B4B398953C1D'

				EXEC ('EXEC sp_rename ''[dbo].[udt_ice_deal_price].[' + @column_name + ']'', ''TradeDate'', ''COLUMN''')
			END
		
			
			-- Add/Alter columns
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'TradeId1') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [TradeId1] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [TradeId1] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'id') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [id] INT NOT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [id] INT NOT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegCFICode') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegCFICode] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegCFICode] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegContractMultiplier') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegContractMultiplier] INT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegContractMultiplier] INT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegCurrency') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegCurrency] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegCurrency] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegEndDate') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegEndDate] DATETIME NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegEndDate] DATETIME NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegExDestination') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegExDestination] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegExDestination] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegLastPx') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegLastPx] FLOAT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegLastPx] FLOAT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegMaturityDate') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegMaturityDate] DATETIME NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegMaturityDate] DATETIME NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegMaturityMonthYear') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegMaturityMonthYear] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegMaturityMonthYear] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegMemoField') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegMemoField] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegMemoField] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegNumOfCycles') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegNumOfCycles] INT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegNumOfCycles] INT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegNumOfLots') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegNumOfLots] INT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegNumOfLots] INT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegPrice') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegPrice] FLOAT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegPrice] FLOAT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegQty') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegQty] INT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegQty] INT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegRefID') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegRefID] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegRefID] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegSecurityAltID') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegSecurityAltID] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegSecurityAltID] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegSecurityAltIDSource') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegSecurityAltIDSource] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegSecurityAltIDSource] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegSecurityExchange') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegSecurityExchange] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegSecurityExchange] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegSecurityID') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegSecurityID] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegSecurityID] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegSecuritySubType') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegSecuritySubType] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegSecuritySubType] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegSecurityType') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegSecurityType] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegSecurityType] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegSecurityIDSource') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegSecurityIDSource] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegSecurityIDSource] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegSide') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegSide] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegSide] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegStartDate') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegStartDate] DATETIME NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegStartDate] DATETIME NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegStrikePrice') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegStrikePrice] FLOAT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegStrikePrice] FLOAT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegSymbol') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegSymbol] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegSymbol] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'LegUnitOfMeasure') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [LegUnitOfMeasure] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [LegUnitOfMeasure] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'TradeDate') IS NULL
			BEGIN
				ALTER TABLE udt_ice_deal_price ADD [TradeDate] DATETIME NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_ice_deal_price ALTER COLUMN [TradeDate] DATETIME NULL
			END
		
				IF EXISTS ( SELECT 1
							FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
							WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
								AND TABLE_NAME = 'ice_deal_price' 
								AND TABLE_SCHEMA = 'dbo'
								AND COLUMN_NAME <> 'id'
				)
				BEGIN
					DECLARE @primary_key_constraint NVARCHAR(100) = NULL

					SELECT @primary_key_constraint = [name]
					FROM sys.key_constraints
					WHERE [type] = 'PK'
						AND [parent_object_id] = OBJECT_ID('dbo.udt_ice_deal_price')

					IF OBJECT_ID(N'[dbo].[udt_ice_deal_price]', N'U') IS NOT NULL
					AND @primary_key_constraint IS NOT NULL
					BEGIN
						EXEC ('ALTER TABLE udt_ice_deal_price DROP CONSTRAINT ' + @primary_key_constraint)
					END

					IF COL_LENGTH('[dbo].[udt_ice_deal_price]', 'id') IS NOT NULL
					BEGIN
						ALTER TABLE udt_ice_deal_price ADD PRIMARY KEY (id)
					END
				END 
			
			-- Drop unused/deleted columns
			DECLARE @column_drop_sql NVARCHAR(MAX) = ''

			SELECT @column_drop_sql += 'ALTER TABLE [dbo].[udt_ice_deal_price] DROP COLUMN [' + isc.COLUMN_NAME + '];' + NCHAR(13)
			FROM INFORMATION_SCHEMA.COLUMNS isc
			WHERE TABLE_NAME = N'udt_ice_deal_price'
				AND NOT EXISTS (
					SELECT udtm.column_name
					FROM user_defined_tables_metadata udtm
					INNER JOIN user_defined_tables udt
						ON udt.udt_id = udtm.udt_id
					WHERE udt.udt_name = 'ice_deal_price'
						AND udtm.column_name = isc.COLUMN_NAME
				)
				AND isc.COLUMN_NAME NOT IN ('create_user', 'create_ts', 'update_user', 'update_ts')
		
			EXEC (@column_drop_sql)
		
		END
		GO

		IF OBJECT_ID('[dbo].[TRGUPD_udt_ice_deal_price]', 'TR') IS NOT NULL
			DROP TRIGGER [dbo].[TRGUPD_udt_ice_deal_price]
		GO

		CREATE TRIGGER [dbo].[TRGUPD_udt_ice_deal_price]
		ON [dbo].[udt_ice_deal_price]
		FOR UPDATE
		AS
			UPDATE udt_ice_deal_price
			   SET update_user = dbo.FNADBUser(),
				   update_ts = GETDATE()
			FROM udt_ice_deal_price t
			  INNER JOIN DELETED u ON t.[id] = u.[id]
		GO
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						WHERE sep.minor_id = 0
							AND sep.[name] = 'udt_hash' )
		BEGIN
			-- Store udt hash in extended property of table so that it can be accessed later to indentify table for renaming purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_hash'
				, @value = '8C1E0BC9_A10F_475B_BF47_8E2513FE3CEC'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'TradeId1' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'EAF01005_3717_4DAE_AFEA_0021B20AFCB6'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'TradeId1'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'id' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '23C2E905_BED2_4622_A3AA_E7F4830E606A'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'id'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegCFICode' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '98A7DE26_1E86_4A8E_85AE_A0A121AD54F0'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegCFICode'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegContractMultiplier' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'BD545A38_BA75_43CC_A0F0_AFC7BCB61A5B'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegContractMultiplier'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegCurrency' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '73DBE2C2_7F0C_4977_A5BE_B42CDE435B46'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegCurrency'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegEndDate' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '04EEBE23_95A9_40ED_95CC_D8F284C738E5'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegEndDate'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegExDestination' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'AD871F40_3C04_4B1E_B7A6_12D530C904BB'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegExDestination'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegLastPx' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '91C090E2_F1DE_4FCA_8638_FBCB5260836E'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegLastPx'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegMaturityDate' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '31F93C73_900A_4040_992F_C8C0A55876B8'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegMaturityDate'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegMaturityMonthYear' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '27D395E9_1C56_4D24_BAA7_71E8061AEF86'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegMaturityMonthYear'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegMemoField' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '6C0A2361_15DA_4F78_B9E5_38612F25C2FD'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegMemoField'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegNumOfCycles' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '1D01CE8C_A101_407D_BD55_64A916D511DB'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegNumOfCycles'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegNumOfLots' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '41426E5A_FA34_4580_B36A_FB7473E18443'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegNumOfLots'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegPrice' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'AE4223ED_E0EE_4A08_B145_7CF893BA9E40'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegPrice'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegQty' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '718DA8D2_B797_489C_822D_874FFA729A55'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegQty'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegRefID' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '67B9D3D9_E29A_44C4_8BCA_3D305D58E7A8'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegRefID'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegSecurityAltID' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '69E2641F_EA47_4AAE_A299_FEC2F5CC243C'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegSecurityAltID'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegSecurityAltIDSource' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '4CD79E70_133A_41AA_80ED_05990568463F'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegSecurityAltIDSource'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegSecurityExchange' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '1AFB3FDC_B8C4_49BF_9477_77BE2F7283A0'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegSecurityExchange'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegSecurityID' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '403D2A11_977B_4A95_B4EE_47B4D53C6403'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegSecurityID'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegSecuritySubType' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '22CE2286_91F2_4FB2_A0F3_0E936B8AD2C1'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegSecuritySubType'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegSecurityType' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'BD1DA25E_2ED5_467A_A27B_4D3FB510D203'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegSecurityType'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegSecurityIDSource' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'FDEDC48F_328B_4E67_B220_533B9E167F74'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegSecurityIDSource'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegSide' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'EEEF4618_31F2_4283_807F_584704A903C1'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegSide'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegStartDate' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '4ABBDB9C_F9A4_41C1_8C37_44273521114E'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegStartDate'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegStrikePrice' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '72088176_E061_480B_834B_F821C7DDF70B'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegStrikePrice'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegSymbol' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'EDB745E5_FB4B_4FB0_B3B1_84DCB43AF50D'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegSymbol'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'LegUnitOfMeasure' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'EFF036B9_8E9A_4D66_AF48_FFFA9BCC942C'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'LegUnitOfMeasure'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_ice_deal_price'
							AND sc.name = 'TradeDate' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '51F5852F_F6B3_444B_B1C0_B4B398953C1D'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_ice_deal_price'
				, @level2type = N'COLUMN'
				, @level2name = 'TradeDate'
		END
		