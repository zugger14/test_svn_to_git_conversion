
	SET ANSI_NULLS ON
	GO

	SET QUOTED_IDENTIFIER ON
	GO

	-- Check if destination UDT view is already in use
	IF EXISTS ( SELECT 1 FROM [data_source] ds
				INNER JOIN report_dataset rd
					ON ds.data_source_id = rd.source_id
				WHERE ds.[name] = 'udt_likron_market_results' )
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
					WHERE ds.[name] = 'udt_likron_market_results'
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

		IF NOT EXISTS(SELECT 1 FROM user_defined_tables WHERE udt_hash = '9E342A60_E46A_4DD2_9DC5_80413A263F85')
		BEGIN
			INSERT INTO user_defined_tables(udt_name, udt_descriptions, udt_hash)
			SELECT 'likron_market_results', 'Likron Market Results', '9E342A60_E46A_4DD2_9DC5_80413A263F85'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables
			SET udt_name = 'likron_market_results'
			  , udt_descriptions = 'Likron Market Results'
			WHERE udt_hash = '9E342A60_E46A_4DD2_9DC5_80413A263F85'
		END

		SELECT @udt_id_new = udt_id FROM user_defined_tables WHERE udt_name = 'likron_market_results'
		 
		IF OBJECT_ID('tempdb..#collect_all_column') IS NOT NULL
			DROP TABLE #collect_all_column
		CREATE TABLE #collect_all_column(
			id INT IDENTITY(1, 1),
			column_name NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)

		INSERT INTO #collect_all_column
		
		SELECT 'related_order_id' UNION ALL 
		SELECT 'underlying_start' UNION ALL 
		SELECT 'id' UNION ALL 
		SELECT 'trader_id' UNION ALL 
		SELECT 'delivery_start_local_time' UNION ALL 
		SELECT 'delivery_start_local_time_cet' UNION ALL 
		SELECT 'delivery_start_ticks' UNION ALL 
		SELECT 'delivery_start_utc_time' UNION ALL 
		SELECT 'underlying_end' UNION ALL 
		SELECT 'delivery_start_local_date' UNION ALL 
		SELECT 'delivery_end_local_time' UNION ALL 
		SELECT 'delivery_end_local_time_cet' UNION ALL 
		SELECT 'name' UNION ALL 
		SELECT 'type' UNION ALL 
		SELECT 'delivery_end_local_date' UNION ALL 
		SELECT 'delivery_end_ticks' UNION ALL 
		SELECT 'delivery_end_utc_time' UNION ALL 
		SELECT 'daylight_change_suffix' UNION ALL 
		SELECT 'short_name' UNION ALL 
		SELECT 'major_type' UNION ALL 
		SELECT 'is_block' UNION ALL 
		SELECT 'is_half_hour' UNION ALL 
		SELECT 'is_hour' UNION ALL 
		SELECT 'is_quarter' UNION ALL 
		SELECT 'traded_underlying_delivery_day' UNION ALL 
		SELECT 'delivery_hour' UNION ALL 
		SELECT 'scaling_factor' UNION ALL 
		SELECT 'target_tso' UNION ALL 
		SELECT 'tso' UNION ALL 
		SELECT 'tso_name' UNION ALL 
		SELECT 'price' UNION ALL 
		SELECT 'quantity' UNION ALL 
		SELECT 'is_buy_trade' UNION ALL 
		SELECT 'trade_id' UNION ALL 
		SELECT 'exchange_id' UNION ALL 
		SELECT 'external_trade_id' UNION ALL 
		SELECT 'execution_local_date' UNION ALL 
		SELECT 'execution_time_local_time' UNION ALL 
		SELECT 'execution_time_local_time_cet' UNION ALL 
		SELECT 'execution_utc_time' UNION ALL 
		SELECT 'execution_ticks' UNION ALL 
		SELECT 'analysis_info' UNION ALL 
		SELECT 'balance_group' UNION ALL 
		SELECT 'com_xerv_account_type' UNION ALL 
		SELECT 'com_xerv_eic' UNION ALL 
		SELECT 'external_order_id' UNION ALL 
		SELECT 'portfolio' UNION ALL 
		SELECT 'pre_arranged_type' UNION ALL 
		SELECT 'state' UNION ALL 
		SELECT 'strategy_name' UNION ALL 
		SELECT 'strategy_order_id' UNION ALL 
		SELECT 'text' UNION ALL 
		SELECT 'trading_cost_group' UNION ALL 
		SELECT 'user_code' UNION ALL 
		SELECT 'pre_arranged' UNION ALL 
		SELECT 'com_xerv_product' UNION ALL 
		SELECT 'contract' UNION ALL 
		SELECT 'contract_type' UNION ALL 
		SELECT 'exchange_key' UNION ALL 
		SELECT 'product_name' UNION ALL 
		SELECT 'buy_or_sell' UNION ALL 
		SELECT 'delivery_day' UNION ALL 
		SELECT 'scaled_quantity' UNION ALL 
		SELECT 'signed_quantity' UNION ALL 
		SELECT 'self_trade' UNION ALL 
		SELECT 'delivery_date' UNION ALL 
		SELECT 'hour' UNION ALL 
		SELECT 'minutes'
	
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
						WHERE udtm.udt_column_hash = '77023D47_C63C_40F2_B9B7_6F2E7C91FE7C' )
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
						'related_order_id', 'RelatedOrderId', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 2, NULL, 0, NULL, '77023D47_C63C_40F2_B9B7_6F2E7C91FE7C'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'related_order_id'
				,column_descriptions  = 'RelatedOrderId'
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
			WHERE udt_column_hash = '77023D47_C63C_40F2_B9B7_6F2E7C91FE7C'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'EF79F2F1_2B82_4E1C_8CB3_E9647AC50BAA' )
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
						'underlying_start', 'UnderlyingStart', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 3, NULL, 0, NULL, 'EF79F2F1_2B82_4E1C_8CB3_E9647AC50BAA'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'underlying_start'
				,column_descriptions  = 'UnderlyingStart'
				,column_type  = '104301'
				,column_length  = 50
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
			WHERE udt_column_hash = 'EF79F2F1_2B82_4E1C_8CB3_E9647AC50BAA'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'AF848EA3_10E7_4E1B_848E_3D8A9424E1F9' )
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
						'id', 'ID', '104302', 4, NULL, NULL, '0  ', 1,1,NULL, 0, 0, NULL, NULL, 0, NULL, 'AF848EA3_10E7_4E1B_848E_3D8A9424E1F9'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'id'
				,column_descriptions  = 'ID'
				,column_type  = '104302'
				,column_length  = 4
				,column_prec  = NULL
				,column_scale  = NULL
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
			WHERE udt_column_hash = 'AF848EA3_10E7_4E1B_848E_3D8A9424E1F9'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '1072A4F1_FC8A_4FF6_9E24_38DE96BAF3AC' )
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
						'trader_id', 'TraderId', '104302', 4, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 1, NULL, 0, NULL, '1072A4F1_FC8A_4FF6_9E24_38DE96BAF3AC'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'trader_id'
				,column_descriptions  = 'TraderId'
				,column_type  = '104302'
				,column_length  = 4
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 1
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '1072A4F1_FC8A_4FF6_9E24_38DE96BAF3AC'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '700D1845_DAF1_4B90_8601_CAD673809526' )
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
						'delivery_start_local_time', 'DeliveryStartLocalTime', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 5, NULL, 0, NULL, '700D1845_DAF1_4B90_8601_CAD673809526'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_start_local_time'
				,column_descriptions  = 'DeliveryStartLocalTime'
				,column_type  = '104301'
				,column_length  = 50
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
			WHERE udt_column_hash = '700D1845_DAF1_4B90_8601_CAD673809526'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '64DB1273_9A54_482D_AB10_EF6E33804611' )
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
						'delivery_start_local_time_cet', 'DeliveryStartLocalTimeCet', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 6, NULL, 0, NULL, '64DB1273_9A54_482D_AB10_EF6E33804611'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_start_local_time_cet'
				,column_descriptions  = 'DeliveryStartLocalTimeCet'
				,column_type  = '104301'
				,column_length  = 50
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
			WHERE udt_column_hash = '64DB1273_9A54_482D_AB10_EF6E33804611'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'B345E82C_63C9_418D_AA48_22F1721D7D3C' )
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
						'delivery_start_ticks', 'DeliveryStartTicks', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 8, NULL, 0, NULL, 'B345E82C_63C9_418D_AA48_22F1721D7D3C'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_start_ticks'
				,column_descriptions  = 'DeliveryStartTicks'
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
				,sequence_no  = 8
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'B345E82C_63C9_418D_AA48_22F1721D7D3C'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '82AABD18_DD8E_4FA6_B7AD_23B972985507' )
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
						'delivery_start_utc_time', 'DeliveryStartUtcTime', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 7, NULL, 0, NULL, '82AABD18_DD8E_4FA6_B7AD_23B972985507'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_start_utc_time'
				,column_descriptions  = 'DeliveryStartUtcTime'
				,column_type  = '104301'
				,column_length  = 50
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
			WHERE udt_column_hash = '82AABD18_DD8E_4FA6_B7AD_23B972985507'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '1E99C249_2B0F_467A_94BE_F14B7C6501B0' )
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
						'underlying_end', 'UnderlyingEnd', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 4, NULL, 0, NULL, '1E99C249_2B0F_467A_94BE_F14B7C6501B0'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'underlying_end'
				,column_descriptions  = 'UnderlyingEnd'
				,column_type  = '104301'
				,column_length  = 50
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
			WHERE udt_column_hash = '1E99C249_2B0F_467A_94BE_F14B7C6501B0'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '2079E428_4C31_4EAB_B7F3_A45B37955619' )
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
						'delivery_start_local_date', 'DeliveryStartLocalDate', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 9, NULL, 0, NULL, '2079E428_4C31_4EAB_B7F3_A45B37955619'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_start_local_date'
				,column_descriptions  = 'DeliveryStartLocalDate'
				,column_type  = '104301'
				,column_length  = 50
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
			WHERE udt_column_hash = '2079E428_4C31_4EAB_B7F3_A45B37955619'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '0671E48B_350D_4CC0_B169_AA10CA8F8977' )
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
						'delivery_end_local_time', 'DeliveryEndLocalTime', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 10, NULL, 0, NULL, '0671E48B_350D_4CC0_B169_AA10CA8F8977'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_end_local_time'
				,column_descriptions  = 'DeliveryEndLocalTime'
				,column_type  = '104301'
				,column_length  = 50
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
			WHERE udt_column_hash = '0671E48B_350D_4CC0_B169_AA10CA8F8977'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '9323F605_B3BA_4535_BB54_61C74416E0EF' )
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
						'delivery_end_local_time_cet', 'DeliveryEndLocalTimeCet', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 11, NULL, 0, NULL, '9323F605_B3BA_4535_BB54_61C74416E0EF'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_end_local_time_cet'
				,column_descriptions  = 'DeliveryEndLocalTimeCet'
				,column_type  = '104301'
				,column_length  = 50
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
			WHERE udt_column_hash = '9323F605_B3BA_4535_BB54_61C74416E0EF'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'A2AF291E_B223_4852_9D9E_4B95C6ED6D4B' )
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
						'name', 'Name', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 16, NULL, 0, NULL, 'A2AF291E_B223_4852_9D9E_4B95C6ED6D4B'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'name'
				,column_descriptions  = 'Name'
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
			WHERE udt_column_hash = 'A2AF291E_B223_4852_9D9E_4B95C6ED6D4B'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '9E936C23_8604_4DC3_9EF2_58ABA29B6E9B' )
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
						'type', 'Type', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 15, NULL, 0, NULL, '9E936C23_8604_4DC3_9EF2_58ABA29B6E9B'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'type'
				,column_descriptions  = 'Type'
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
			WHERE udt_column_hash = '9E936C23_8604_4DC3_9EF2_58ABA29B6E9B'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '2C7499AF_B7F2_479C_A013_0BE518226CB9' )
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
						'delivery_end_local_date', 'DeliveryEndLocalDate', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 14, NULL, 0, NULL, '2C7499AF_B7F2_479C_A013_0BE518226CB9'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_end_local_date'
				,column_descriptions  = 'DeliveryEndLocalDate'
				,column_type  = '104301'
				,column_length  = 50
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
			WHERE udt_column_hash = '2C7499AF_B7F2_479C_A013_0BE518226CB9'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '74B65DBC_CA85_485A_AE8E_35D42C7D9136' )
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
						'delivery_end_ticks', 'DeliveryEndTicks', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 13, NULL, 0, NULL, '74B65DBC_CA85_485A_AE8E_35D42C7D9136'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_end_ticks'
				,column_descriptions  = 'DeliveryEndTicks'
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
				,sequence_no  = 13
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '74B65DBC_CA85_485A_AE8E_35D42C7D9136'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'E179FEE0_55D3_4DC2_BA57_0D66B064F9C4' )
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
						'delivery_end_utc_time', 'DeliveryEndUtcTime', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 12, NULL, 0, NULL, 'E179FEE0_55D3_4DC2_BA57_0D66B064F9C4'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_end_utc_time'
				,column_descriptions  = 'DeliveryEndUtcTime'
				,column_type  = '104301'
				,column_length  = 50
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
			WHERE udt_column_hash = 'E179FEE0_55D3_4DC2_BA57_0D66B064F9C4'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '65D28D6C_0800_432F_B9DA_9D92C981264D' )
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
						'daylight_change_suffix', 'DaylightChangeSuffix', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 18, NULL, 0, NULL, '65D28D6C_0800_432F_B9DA_9D92C981264D'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'daylight_change_suffix'
				,column_descriptions  = 'DaylightChangeSuffix'
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
			WHERE udt_column_hash = '65D28D6C_0800_432F_B9DA_9D92C981264D'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '9F80F7DD_ED68_41A9_B048_C227077DCDD1' )
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
						'short_name', 'ShortName', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 17, NULL, 0, NULL, '9F80F7DD_ED68_41A9_B048_C227077DCDD1'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'short_name'
				,column_descriptions  = 'ShortName'
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
			WHERE udt_column_hash = '9F80F7DD_ED68_41A9_B048_C227077DCDD1'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '03E2D32D_23BC_48FD_A4F6_F596FEE70953' )
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
						'major_type', 'MajorType', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 23, NULL, 0, NULL, '03E2D32D_23BC_48FD_A4F6_F596FEE70953'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'major_type'
				,column_descriptions  = 'MajorType'
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
			WHERE udt_column_hash = '03E2D32D_23BC_48FD_A4F6_F596FEE70953'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'F65429AF_E9D8_4CEC_ADA6_AB1AD349B64F' )
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
						'is_block', 'IsBlock', '104301', 6, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 22, NULL, 0, NULL, 'F65429AF_E9D8_4CEC_ADA6_AB1AD349B64F'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'is_block'
				,column_descriptions  = 'IsBlock'
				,column_type  = '104301'
				,column_length  = 6
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
			WHERE udt_column_hash = 'F65429AF_E9D8_4CEC_ADA6_AB1AD349B64F'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '0F4C319D_D5A4_4265_AE48_DE811BC875D4' )
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
						'is_half_hour', 'IsHalfHour', '104301', 6, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 21, NULL, 0, NULL, '0F4C319D_D5A4_4265_AE48_DE811BC875D4'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'is_half_hour'
				,column_descriptions  = 'IsHalfHour'
				,column_type  = '104301'
				,column_length  = 6
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
			WHERE udt_column_hash = '0F4C319D_D5A4_4265_AE48_DE811BC875D4'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '01811C3E_F601_4FA0_82E5_445202062333' )
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
						'is_hour', 'IsHour', '104301', 6, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 19, NULL, 0, NULL, '01811C3E_F601_4FA0_82E5_445202062333'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'is_hour'
				,column_descriptions  = 'IsHour'
				,column_type  = '104301'
				,column_length  = 6
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
			WHERE udt_column_hash = '01811C3E_F601_4FA0_82E5_445202062333'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '1FF5147D_7907_4149_9F31_C8A94D29911B' )
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
						'is_quarter', 'IsQuarter', '104301', 6, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 20, NULL, 0, NULL, '1FF5147D_7907_4149_9F31_C8A94D29911B'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'is_quarter'
				,column_descriptions  = 'IsQuarter'
				,column_type  = '104301'
				,column_length  = 6
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
			WHERE udt_column_hash = '1FF5147D_7907_4149_9F31_C8A94D29911B'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '306B3FF8_AE21_4430_9CB1_5AD9C3216278' )
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
						'traded_underlying_delivery_day', 'TradedUnderlyingDeliveryDay', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 24, NULL, 0, NULL, '306B3FF8_AE21_4430_9CB1_5AD9C3216278'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'traded_underlying_delivery_day'
				,column_descriptions  = 'TradedUnderlyingDeliveryDay'
				,column_type  = '104301'
				,column_length  = 50
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
			WHERE udt_column_hash = '306B3FF8_AE21_4430_9CB1_5AD9C3216278'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'E294CCD5_0EA2_4646_9389_7B964FCD4BB3' )
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
						'delivery_hour', 'DeliveryHour', '104302', 4, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 25, NULL, 0, NULL, 'E294CCD5_0EA2_4646_9389_7B964FCD4BB3'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_hour'
				,column_descriptions  = 'DeliveryHour'
				,column_type  = '104302'
				,column_length  = 4
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
			WHERE udt_column_hash = 'E294CCD5_0EA2_4646_9389_7B964FCD4BB3'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '20E07820_1E8B_40A0_BF4A_4B19A6AB2CD0' )
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
						'scaling_factor', 'ScalingFactor', '104303', 4, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 26, NULL, 0, NULL, '20E07820_1E8B_40A0_BF4A_4B19A6AB2CD0'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'scaling_factor'
				,column_descriptions  = 'ScalingFactor'
				,column_type  = '104303'
				,column_length  = 4
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
			WHERE udt_column_hash = '20E07820_1E8B_40A0_BF4A_4B19A6AB2CD0'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'F9EC2D75_4895_4B8F_8762_3ECA5611D51E' )
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
						'target_tso', 'TargetTso', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 29, NULL, 0, NULL, 'F9EC2D75_4895_4B8F_8762_3ECA5611D51E'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'target_tso'
				,column_descriptions  = 'TargetTso'
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
				,sequence_no  = 29
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'F9EC2D75_4895_4B8F_8762_3ECA5611D51E'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'FDA92736_CDC1_4FBD_B0BD_0C561B9DBE81' )
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
						'tso', 'Tso', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 28, NULL, 0, NULL, 'FDA92736_CDC1_4FBD_B0BD_0C561B9DBE81'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'tso'
				,column_descriptions  = 'Tso'
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
				,sequence_no  = 28
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'FDA92736_CDC1_4FBD_B0BD_0C561B9DBE81'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'A5519F9E_8780_49AC_A050_95CC46EF4B36' )
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
						'tso_name', 'TsoName', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 27, NULL, 0, NULL, 'A5519F9E_8780_49AC_A050_95CC46EF4B36'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'tso_name'
				,column_descriptions  = 'TsoName'
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
			WHERE udt_column_hash = 'A5519F9E_8780_49AC_A050_95CC46EF4B36'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '2F3F9B27_737E_498A_8243_FA6BC2909F61' )
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
						'price', 'Price', '104303', 4, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 32, NULL, 0, NULL, '2F3F9B27_737E_498A_8243_FA6BC2909F61'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'price'
				,column_descriptions  = 'Price'
				,column_type  = '104303'
				,column_length  = 4
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 32
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '2F3F9B27_737E_498A_8243_FA6BC2909F61'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '43D33D53_E92A_4510_8993_24170ED578F0' )
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
						'quantity', 'Quantity', '104303', 4, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 31, NULL, 0, NULL, '43D33D53_E92A_4510_8993_24170ED578F0'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'quantity'
				,column_descriptions  = 'Quantity'
				,column_type  = '104303'
				,column_length  = 4
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 31
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '43D33D53_E92A_4510_8993_24170ED578F0'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '90339ACE_57C8_46C9_910B_E998CAD3A1EB' )
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
						'is_buy_trade', 'IsBuyTrade', '104301', 6, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 30, NULL, 0, NULL, '90339ACE_57C8_46C9_910B_E998CAD3A1EB'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'is_buy_trade'
				,column_descriptions  = 'IsBuyTrade'
				,column_type  = '104301'
				,column_length  = 6
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 30
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '90339ACE_57C8_46C9_910B_E998CAD3A1EB'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '35903EFD_5928_45A0_849A_848D7B4E6797' )
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
						'trade_id', 'TradeId', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 33, NULL, 0, NULL, '35903EFD_5928_45A0_849A_848D7B4E6797'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'trade_id'
				,column_descriptions  = 'TradeId'
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
				,sequence_no  = 33
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '35903EFD_5928_45A0_849A_848D7B4E6797'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '01DD373A_4001_4FAC_B66B_A3620BF3C55E' )
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
						'exchange_id', 'ExchangeId', '104302', 4, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 34, NULL, 0, NULL, '01DD373A_4001_4FAC_B66B_A3620BF3C55E'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'exchange_id'
				,column_descriptions  = 'ExchangeId'
				,column_type  = '104302'
				,column_length  = 4
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 34
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '01DD373A_4001_4FAC_B66B_A3620BF3C55E'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '8DDDF1D7_F12B_4877_A08F_55756212C8B9' )
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
						'external_trade_id', 'ExternalTradeId', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 35, NULL, 0, NULL, '8DDDF1D7_F12B_4877_A08F_55756212C8B9'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'external_trade_id'
				,column_descriptions  = 'ExternalTradeId'
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
				,sequence_no  = 35
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '8DDDF1D7_F12B_4877_A08F_55756212C8B9'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'BCB9E67B_FE4B_4D95_A838_1209FA1D25BB' )
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
						'execution_local_date', 'ExecutionTimeLocalDate', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 40, NULL, 0, NULL, 'BCB9E67B_FE4B_4D95_A838_1209FA1D25BB'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'execution_local_date'
				,column_descriptions  = 'ExecutionTimeLocalDate'
				,column_type  = '104301'
				,column_length  = 50
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 40
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'BCB9E67B_FE4B_4D95_A838_1209FA1D25BB'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '4B252B72_2EB8_4354_8F2F_F155E91145B8' )
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
						'execution_time_local_time', 'ExecutionTimeLocalTime', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 36, NULL, 0, NULL, '4B252B72_2EB8_4354_8F2F_F155E91145B8'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'execution_time_local_time'
				,column_descriptions  = 'ExecutionTimeLocalTime'
				,column_type  = '104301'
				,column_length  = 50
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 36
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '4B252B72_2EB8_4354_8F2F_F155E91145B8'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'C8B0954A_B0F2_4D1B_9B54_196E91A4732F' )
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
						'execution_time_local_time_cet', 'ExecutionTimeLocalTimeCet', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 37, NULL, 0, NULL, 'C8B0954A_B0F2_4D1B_9B54_196E91A4732F'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'execution_time_local_time_cet'
				,column_descriptions  = 'ExecutionTimeLocalTimeCet'
				,column_type  = '104301'
				,column_length  = 50
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 37
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'C8B0954A_B0F2_4D1B_9B54_196E91A4732F'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '44E86CE8_0D53_494D_9E63_F38521FFAF73' )
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
						'execution_utc_time', 'ExecutionTimeUtcTime', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 38, NULL, 0, NULL, '44E86CE8_0D53_494D_9E63_F38521FFAF73'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'execution_utc_time'
				,column_descriptions  = 'ExecutionTimeUtcTime'
				,column_type  = '104301'
				,column_length  = 50
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 38
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '44E86CE8_0D53_494D_9E63_F38521FFAF73'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'B216C489_D6D0_4E9B_ADEF_BF596513F937' )
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
						'execution_ticks', 'ExecutionTimeTicks', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 39, NULL, 0, NULL, 'B216C489_D6D0_4E9B_ADEF_BF596513F937'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'execution_ticks'
				,column_descriptions  = 'ExecutionTimeTicks'
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
				,sequence_no  = 39
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'B216C489_D6D0_4E9B_ADEF_BF596513F937'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '399E933D_5BF2_4D23_80A0_1F732A6AFB48' )
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
						'analysis_info', 'AnalysisInfo', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 54, NULL, 0, NULL, '399E933D_5BF2_4D23_80A0_1F732A6AFB48'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'analysis_info'
				,column_descriptions  = 'AnalysisInfo'
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
				,sequence_no  = 54
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '399E933D_5BF2_4D23_80A0_1F732A6AFB48'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '3A84E16D_DFFA_4B72_95DD_C972A6F3FA3F' )
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
						'balance_group', 'BalanceGroup', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 52, NULL, 0, NULL, '3A84E16D_DFFA_4B72_95DD_C972A6F3FA3F'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'balance_group'
				,column_descriptions  = 'BalanceGroup'
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
				,sequence_no  = 52
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '3A84E16D_DFFA_4B72_95DD_C972A6F3FA3F'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'E4C3D91E_FEA6_4471_8502_5DB3B80B67B3' )
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
						'com_xerv_account_type', 'ComXervAccountType', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 51, NULL, 0, NULL, 'E4C3D91E_FEA6_4471_8502_5DB3B80B67B3'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'com_xerv_account_type'
				,column_descriptions  = 'ComXervAccountType'
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
				,sequence_no  = 51
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'E4C3D91E_FEA6_4471_8502_5DB3B80B67B3'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '5636AB6C_D59B_47E1_807D_BE2723A3DFEE' )
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
						'com_xerv_eic', 'ComXervEic', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 49, NULL, 0, NULL, '5636AB6C_D59B_47E1_807D_BE2723A3DFEE'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'com_xerv_eic'
				,column_descriptions  = 'ComXervEic'
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
				,sequence_no  = 49
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '5636AB6C_D59B_47E1_807D_BE2723A3DFEE'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'DCF732F7_3A73_4AAD_A4F4_4E65EE70EF47' )
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
						'external_order_id', 'ExternalOrderId', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 42, NULL, 0, NULL, 'DCF732F7_3A73_4AAD_A4F4_4E65EE70EF47'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'external_order_id'
				,column_descriptions  = 'ExternalOrderId'
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
				,sequence_no  = 42
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'DCF732F7_3A73_4AAD_A4F4_4E65EE70EF47'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'DD668E47_7769_4D5D_98BF_C479F1C8963B' )
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
						'portfolio', 'Portfolio', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 53, NULL, 0, NULL, 'DD668E47_7769_4D5D_98BF_C479F1C8963B'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'portfolio'
				,column_descriptions  = 'Portfolio'
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
				,sequence_no  = 53
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'DD668E47_7769_4D5D_98BF_C479F1C8963B'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '1E10D9F4_2AA9_41B3_8300_42CB87AE001C' )
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
						'pre_arranged_type', 'PreArrangedType', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 48, NULL, 0, NULL, '1E10D9F4_2AA9_41B3_8300_42CB87AE001C'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'pre_arranged_type'
				,column_descriptions  = 'PreArrangedType'
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
				,sequence_no  = 48
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '1E10D9F4_2AA9_41B3_8300_42CB87AE001C'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'BACD5FA7_EFF6_49D7_9280_A437768F89A0' )
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
						'state', 'State', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 44, NULL, 0, NULL, 'BACD5FA7_EFF6_49D7_9280_A437768F89A0'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'state'
				,column_descriptions  = 'State'
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
				,sequence_no  = 44
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'BACD5FA7_EFF6_49D7_9280_A437768F89A0'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '2AB68F25_727C_4A8E_A61C_CF144E00B555' )
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
						'strategy_name', 'StrategyName', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 45, NULL, 0, NULL, '2AB68F25_727C_4A8E_A61C_CF144E00B555'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'strategy_name'
				,column_descriptions  = 'StrategyName'
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
				,sequence_no  = 45
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '2AB68F25_727C_4A8E_A61C_CF144E00B555'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '5B400AFD_5693_4B56_A48D_0F708C912DAF' )
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
						'strategy_order_id', 'StrategyOrderId', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 41, NULL, 0, NULL, '5B400AFD_5693_4B56_A48D_0F708C912DAF'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'strategy_order_id'
				,column_descriptions  = 'StrategyOrderId'
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
				,sequence_no  = 41
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '5B400AFD_5693_4B56_A48D_0F708C912DAF'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'D7AAC384_37A1_4B5A_A767_E8134D9AB3F8' )
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
						'text', 'Text', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 43, NULL, 0, NULL, 'D7AAC384_37A1_4B5A_A767_E8134D9AB3F8'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'text'
				,column_descriptions  = 'Text'
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
				,sequence_no  = 43
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'D7AAC384_37A1_4B5A_A767_E8134D9AB3F8'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '30F7B3C0_75C0_4BBC_AF8E_D03E72B85CE3' )
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
						'trading_cost_group', 'TradingCostGroup', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 46, NULL, 0, NULL, '30F7B3C0_75C0_4BBC_AF8E_D03E72B85CE3'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'trading_cost_group'
				,column_descriptions  = 'TradingCostGroup'
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
				,sequence_no  = 46
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '30F7B3C0_75C0_4BBC_AF8E_D03E72B85CE3'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '324CDF8D_0B56_427E_8492_D1E6742F45CB' )
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
						'user_code', 'UserCode', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 50, NULL, 0, NULL, '324CDF8D_0B56_427E_8492_D1E6742F45CB'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'user_code'
				,column_descriptions  = 'UserCode'
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
				,sequence_no  = 50
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '324CDF8D_0B56_427E_8492_D1E6742F45CB'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '7FA83817_CEB1_4793_976D_D2F855F76E84' )
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
						'pre_arranged', 'PreArranged', '104301', 6, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 47, NULL, 0, NULL, '7FA83817_CEB1_4793_976D_D2F855F76E84'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'pre_arranged'
				,column_descriptions  = 'PreArranged'
				,column_type  = '104301'
				,column_length  = 6
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 47
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '7FA83817_CEB1_4793_976D_D2F855F76E84'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '613B2019_B6C1_47FF_9C7A_1CBC9AB75741' )
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
						'com_xerv_product', 'ComXervProduct', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 56, NULL, 0, NULL, '613B2019_B6C1_47FF_9C7A_1CBC9AB75741'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'com_xerv_product'
				,column_descriptions  = 'ComXervProduct'
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
				,sequence_no  = 56
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '613B2019_B6C1_47FF_9C7A_1CBC9AB75741'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '2429279D_F861_4980_A504_93E383A96E01' )
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
						'contract', 'Contract', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 57, NULL, 0, NULL, '2429279D_F861_4980_A504_93E383A96E01'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'contract'
				,column_descriptions  = 'Contract'
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
				,sequence_no  = 57
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '2429279D_F861_4980_A504_93E383A96E01'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '4E5CCE7E_6CE7_4C63_A4F1_33E8E6019BCA' )
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
						'contract_type', 'ContractType', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 64, NULL, 0, NULL, '4E5CCE7E_6CE7_4C63_A4F1_33E8E6019BCA'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'contract_type'
				,column_descriptions  = 'ContractType'
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
				,sequence_no  = 64
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '4E5CCE7E_6CE7_4C63_A4F1_33E8E6019BCA'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'E211B502_5791_4CCA_A8E0_C152D43520AA' )
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
						'exchange_key', 'ExchangeKey', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 60, NULL, 0, NULL, 'E211B502_5791_4CCA_A8E0_C152D43520AA'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'exchange_key'
				,column_descriptions  = 'ExchangeKey'
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
				,sequence_no  = 60
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'E211B502_5791_4CCA_A8E0_C152D43520AA'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '492C0D62_AEFA_4E02_8F52_C7DB87549490' )
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
						'product_name', 'ProductName', '104301', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 61, NULL, 0, NULL, '492C0D62_AEFA_4E02_8F52_C7DB87549490'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'product_name'
				,column_descriptions  = 'ProductName'
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
				,sequence_no  = 61
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '492C0D62_AEFA_4E02_8F52_C7DB87549490'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '35D3E9C4_0F1D_41D6_8ECF_FEB2853BC409' )
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
						'buy_or_sell', 'BuyOrSell', '104301', 20, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 62, NULL, 0, NULL, '35D3E9C4_0F1D_41D6_8ECF_FEB2853BC409'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'buy_or_sell'
				,column_descriptions  = 'BuyOrSell'
				,column_type  = '104301'
				,column_length  = 20
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 62
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '35D3E9C4_0F1D_41D6_8ECF_FEB2853BC409'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '4C9507BF_599F_4C4C_BFF5_AF905F5DC9DD' )
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
						'delivery_day', 'DeliveryDay', '104301', 50, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 63, NULL, 0, NULL, '4C9507BF_599F_4C4C_BFF5_AF905F5DC9DD'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_day'
				,column_descriptions  = 'DeliveryDay'
				,column_type  = '104301'
				,column_length  = 50
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 63
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '4C9507BF_599F_4C4C_BFF5_AF905F5DC9DD'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'DA662CF5_3F41_440C_BC09_5581551A8F7D' )
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
						'scaled_quantity', 'ScaledQuantity', '104303', 4, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 59, NULL, 0, NULL, 'DA662CF5_3F41_440C_BC09_5581551A8F7D'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'scaled_quantity'
				,column_descriptions  = 'ScaledQuantity'
				,column_type  = '104303'
				,column_length  = 4
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 59
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'DA662CF5_3F41_440C_BC09_5581551A8F7D'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'D7E52FE1_9FDD_437C_AB78_15D89E28B513' )
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
						'signed_quantity', 'SignedQuantity', '104303', 4, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 58, NULL, 0, NULL, 'D7E52FE1_9FDD_437C_AB78_15D89E28B513'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'signed_quantity'
				,column_descriptions  = 'SignedQuantity'
				,column_type  = '104303'
				,column_length  = 4
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 58
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'D7E52FE1_9FDD_437C_AB78_15D89E28B513'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '7F8E471D_F638_4D95_9022_70EA94A4EF36' )
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
						'self_trade', 'SelfTrade', '104301', 6, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 55, NULL, 0, NULL, '7F8E471D_F638_4D95_9022_70EA94A4EF36'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'self_trade'
				,column_descriptions  = 'SelfTrade'
				,column_type  = '104301'
				,column_length  = 6
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 0
				,sequence_no  = 55
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '7F8E471D_F638_4D95_9022_70EA94A4EF36'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'B00C0646_9134_4202_AD32_4BACBC2E462A' )
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
						'delivery_date', 'Delivery Date', '104304', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 1, 65, NULL, 0, NULL, 'B00C0646_9134_4202_AD32_4BACBC2E462A'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'delivery_date'
				,column_descriptions  = 'Delivery Date'
				,column_type  = '104304'
				,column_length  = 100
				,column_prec  = NULL
				,column_scale  = NULL
				,column_nullable  = '1  '
				,is_primary  = 0
				,is_identity  = 0
				,static_data_type_id  = NULL
				,has_value  = 0
				,use_as_filter  = 1
				,sequence_no  = 65
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'B00C0646_9134_4202_AD32_4BACBC2E462A'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = 'E7BD8856_1093_4BD2_9D79_90741DBC5F87' )
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
						'hour', 'Hour', '104302', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 66, NULL, 0, NULL, 'E7BD8856_1093_4BD2_9D79_90741DBC5F87'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'hour'
				,column_descriptions  = 'Hour'
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
				,sequence_no  = 66
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = 'E7BD8856_1093_4BD2_9D79_90741DBC5F87'
		END
	 
		IF NOT EXISTS ( SELECT 1 
						FROM user_defined_tables_metadata udtm
						INNER JOIN user_defined_tables udt
				  			ON udt.udt_id = udtm.udt_id
						WHERE udtm.udt_column_hash = '6492A3BA_DEAE_4272_9921_79E1908D25B7' )
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
						'minutes', 'Minutes', '104302', 100, NULL, NULL, '1  ', 0,0,NULL, 0, 0, 67, NULL, 0, NULL, '6492A3BA_DEAE_4272_9921_79E1908D25B7'
		END
		ELSE
		BEGIN
			UPDATE user_defined_tables_metadata
			SET  column_name  = 'minutes'
				,column_descriptions  = 'Minutes'
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
				,sequence_no  = 67
				,rounding  = NULL
				,unique_combination  = 0
				,custom_validation  = NULL
			WHERE udt_column_hash = '6492A3BA_DEAE_4272_9921_79E1908D25B7'
		END
	 
		DELETE FROM user_defined_tables_metadata
		WHERE udt_column_hash NOT IN ('77023D47_C63C_40F2_B9B7_6F2E7C91FE7C','EF79F2F1_2B82_4E1C_8CB3_E9647AC50BAA','AF848EA3_10E7_4E1B_848E_3D8A9424E1F9','1072A4F1_FC8A_4FF6_9E24_38DE96BAF3AC','700D1845_DAF1_4B90_8601_CAD673809526','64DB1273_9A54_482D_AB10_EF6E33804611','B345E82C_63C9_418D_AA48_22F1721D7D3C','82AABD18_DD8E_4FA6_B7AD_23B972985507','1E99C249_2B0F_467A_94BE_F14B7C6501B0','2079E428_4C31_4EAB_B7F3_A45B37955619','0671E48B_350D_4CC0_B169_AA10CA8F8977','9323F605_B3BA_4535_BB54_61C74416E0EF','A2AF291E_B223_4852_9D9E_4B95C6ED6D4B','9E936C23_8604_4DC3_9EF2_58ABA29B6E9B','2C7499AF_B7F2_479C_A013_0BE518226CB9','74B65DBC_CA85_485A_AE8E_35D42C7D9136','E179FEE0_55D3_4DC2_BA57_0D66B064F9C4','65D28D6C_0800_432F_B9DA_9D92C981264D','9F80F7DD_ED68_41A9_B048_C227077DCDD1','03E2D32D_23BC_48FD_A4F6_F596FEE70953','F65429AF_E9D8_4CEC_ADA6_AB1AD349B64F','0F4C319D_D5A4_4265_AE48_DE811BC875D4','01811C3E_F601_4FA0_82E5_445202062333','1FF5147D_7907_4149_9F31_C8A94D29911B','306B3FF8_AE21_4430_9CB1_5AD9C3216278','E294CCD5_0EA2_4646_9389_7B964FCD4BB3','20E07820_1E8B_40A0_BF4A_4B19A6AB2CD0','F9EC2D75_4895_4B8F_8762_3ECA5611D51E','FDA92736_CDC1_4FBD_B0BD_0C561B9DBE81','A5519F9E_8780_49AC_A050_95CC46EF4B36','2F3F9B27_737E_498A_8243_FA6BC2909F61','43D33D53_E92A_4510_8993_24170ED578F0','90339ACE_57C8_46C9_910B_E998CAD3A1EB','35903EFD_5928_45A0_849A_848D7B4E6797','01DD373A_4001_4FAC_B66B_A3620BF3C55E','8DDDF1D7_F12B_4877_A08F_55756212C8B9','BCB9E67B_FE4B_4D95_A838_1209FA1D25BB','4B252B72_2EB8_4354_8F2F_F155E91145B8','C8B0954A_B0F2_4D1B_9B54_196E91A4732F','44E86CE8_0D53_494D_9E63_F38521FFAF73','B216C489_D6D0_4E9B_ADEF_BF596513F937','399E933D_5BF2_4D23_80A0_1F732A6AFB48','3A84E16D_DFFA_4B72_95DD_C972A6F3FA3F','E4C3D91E_FEA6_4471_8502_5DB3B80B67B3','5636AB6C_D59B_47E1_807D_BE2723A3DFEE','DCF732F7_3A73_4AAD_A4F4_4E65EE70EF47','DD668E47_7769_4D5D_98BF_C479F1C8963B','1E10D9F4_2AA9_41B3_8300_42CB87AE001C','BACD5FA7_EFF6_49D7_9280_A437768F89A0','2AB68F25_727C_4A8E_A61C_CF144E00B555','5B400AFD_5693_4B56_A48D_0F708C912DAF','D7AAC384_37A1_4B5A_A767_E8134D9AB3F8','30F7B3C0_75C0_4BBC_AF8E_D03E72B85CE3','324CDF8D_0B56_427E_8492_D1E6742F45CB','7FA83817_CEB1_4793_976D_D2F855F76E84','613B2019_B6C1_47FF_9C7A_1CBC9AB75741','2429279D_F861_4980_A504_93E383A96E01','4E5CCE7E_6CE7_4C63_A4F1_33E8E6019BCA','E211B502_5791_4CCA_A8E0_C152D43520AA','492C0D62_AEFA_4E02_8F52_C7DB87549490','35D3E9C4_0F1D_41D6_8ECF_FEB2853BC409','4C9507BF_599F_4C4C_BFF5_AF905F5DC9DD','DA662CF5_3F41_440C_BC09_5581551A8F7D','D7E52FE1_9FDD_437C_AB78_15D89E28B513','7F8E471D_F638_4D95_9022_70EA94A4EF36','B00C0646_9134_4202_AD32_4BACBC2E462A','E7BD8856_1093_4BD2_9D79_90741DBC5F87','6492A3BA_DEAE_4272_9921_79E1908D25B7')
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
		WHERE udt_hash = '9E342A60_E46A_4DD2_9DC5_80413A263F85'

		-- Rename table if modified
		IF EXISTS ( SELECT 1
					FROM SYS.EXTENDED_PROPERTIES sep
					INNER JOIN sys.tables st 
						ON sep.major_id = st.object_id
					WHERE sep.minor_id = 0
						AND sep.[name] = 'udt_hash'
						AND sep.[value] = '9E342A60_E46A_4DD2_9DC5_80413A263F85'
						AND st.[name] <> 'udt_' + @udt_name )
		BEGIN
			-- Get modified udt name and rename it
			SELECT @udt_name = st.[name]
			FROM SYS.EXTENDED_PROPERTIES sep
			INNER JOIN sys.tables st 
				ON sep.major_id = st.object_id
			WHERE sep.minor_id = 0
				AND sep.[name] = 'udt_hash'
				AND sep.[value] = '9E342A60_E46A_4DD2_9DC5_80413A263F85'

			EXEC ('EXEC sp_rename ''[dbo].[' + @udt_name + ']'', ''udt_likron_market_results''')
		END

		IF OBJECT_ID(N'[dbo].[udt_likron_market_results]', N'U') IS NULL
		BEGIN
			CREATE TABLE [dbo].[udt_likron_market_results]
			(	
			[id] INT  PRIMARY KEY  IDENTITY(1, 1)  NOT NULL,
			[trader_id] INT  NULL,
			[related_order_id] VARCHAR(100)  NULL,
			[underlying_start] VARCHAR(50)  NULL,
			[underlying_end] VARCHAR(50)  NULL,
			[delivery_start_local_time] VARCHAR(50)  NULL,
			[delivery_start_local_time_cet] VARCHAR(50)  NULL,
			[delivery_start_utc_time] VARCHAR(50)  NULL,
			[delivery_start_ticks] VARCHAR(100)  NULL,
			[delivery_start_local_date] VARCHAR(50)  NULL,
			[delivery_end_local_time] VARCHAR(50)  NULL,
			[delivery_end_local_time_cet] VARCHAR(50)  NULL,
			[delivery_end_utc_time] VARCHAR(50)  NULL,
			[delivery_end_ticks] VARCHAR(100)  NULL,
			[delivery_end_local_date] VARCHAR(50)  NULL,
			[type] VARCHAR(100)  NULL,
			[name] VARCHAR(100)  NULL,
			[short_name] VARCHAR(100)  NULL,
			[daylight_change_suffix] VARCHAR(100)  NULL,
			[is_hour] VARCHAR(6)  NULL,
			[is_quarter] VARCHAR(6)  NULL,
			[is_half_hour] VARCHAR(6)  NULL,
			[is_block] VARCHAR(6)  NULL,
			[major_type] VARCHAR(100)  NULL,
			[traded_underlying_delivery_day] VARCHAR(50)  NULL,
			[delivery_hour] INT  NULL,
			[scaling_factor] FLOAT  NULL,
			[tso_name] VARCHAR(100)  NULL,
			[tso] VARCHAR(100)  NULL,
			[target_tso] VARCHAR(100)  NULL,
			[is_buy_trade] VARCHAR(6)  NULL,
			[quantity] FLOAT  NULL,
			[price] FLOAT  NULL,
			[trade_id] VARCHAR(100)  NULL,
			[exchange_id] INT  NULL,
			[external_trade_id] VARCHAR(100)  NULL,
			[execution_time_local_time] VARCHAR(50)  NULL,
			[execution_time_local_time_cet] VARCHAR(50)  NULL,
			[execution_utc_time] VARCHAR(50)  NULL,
			[execution_ticks] VARCHAR(100)  NULL,
			[execution_local_date] VARCHAR(50)  NULL,
			[strategy_order_id] VARCHAR(100)  NULL,
			[external_order_id] VARCHAR(100)  NULL,
			[text] VARCHAR(100)  NULL,
			[state] VARCHAR(100)  NULL,
			[strategy_name] VARCHAR(100)  NULL,
			[trading_cost_group] VARCHAR(100)  NULL,
			[pre_arranged] VARCHAR(6)  NULL,
			[pre_arranged_type] VARCHAR(100)  NULL,
			[com_xerv_eic] VARCHAR(100)  NULL,
			[user_code] VARCHAR(100)  NULL,
			[com_xerv_account_type] VARCHAR(100)  NULL,
			[balance_group] VARCHAR(100)  NULL,
			[portfolio] VARCHAR(100)  NULL,
			[analysis_info] VARCHAR(100)  NULL,
			[self_trade] VARCHAR(6)  NULL,
			[com_xerv_product] VARCHAR(100)  NULL,
			[contract] VARCHAR(100)  NULL,
			[signed_quantity] FLOAT  NULL,
			[scaled_quantity] FLOAT  NULL,
			[exchange_key] VARCHAR(100)  NULL,
			[product_name] VARCHAR(100)  NULL,
			[buy_or_sell] VARCHAR(20)  NULL,
			[delivery_day] VARCHAR(50)  NULL,
			[contract_type] VARCHAR(100)  NULL,
			[delivery_date] DATETIME  NULL,
			[hour] INT  NULL,
			[minutes] INT  NULL,
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
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '77023D47_C63C_40F2_B9B7_6F2E7C91FE7C'
							AND sc.[name] <> 'related_order_id'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '77023D47_C63C_40F2_B9B7_6F2E7C91FE7C'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''related_order_id'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'EF79F2F1_2B82_4E1C_8CB3_E9647AC50BAA'
							AND sc.[name] <> 'underlying_start'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'EF79F2F1_2B82_4E1C_8CB3_E9647AC50BAA'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''underlying_start'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'AF848EA3_10E7_4E1B_848E_3D8A9424E1F9'
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
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'AF848EA3_10E7_4E1B_848E_3D8A9424E1F9'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''id'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '1072A4F1_FC8A_4FF6_9E24_38DE96BAF3AC'
							AND sc.[name] <> 'trader_id'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '1072A4F1_FC8A_4FF6_9E24_38DE96BAF3AC'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''trader_id'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '700D1845_DAF1_4B90_8601_CAD673809526'
							AND sc.[name] <> 'delivery_start_local_time'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '700D1845_DAF1_4B90_8601_CAD673809526'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_start_local_time'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '64DB1273_9A54_482D_AB10_EF6E33804611'
							AND sc.[name] <> 'delivery_start_local_time_cet'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '64DB1273_9A54_482D_AB10_EF6E33804611'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_start_local_time_cet'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'B345E82C_63C9_418D_AA48_22F1721D7D3C'
							AND sc.[name] <> 'delivery_start_ticks'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'B345E82C_63C9_418D_AA48_22F1721D7D3C'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_start_ticks'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '82AABD18_DD8E_4FA6_B7AD_23B972985507'
							AND sc.[name] <> 'delivery_start_utc_time'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '82AABD18_DD8E_4FA6_B7AD_23B972985507'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_start_utc_time'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '1E99C249_2B0F_467A_94BE_F14B7C6501B0'
							AND sc.[name] <> 'underlying_end'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '1E99C249_2B0F_467A_94BE_F14B7C6501B0'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''underlying_end'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '2079E428_4C31_4EAB_B7F3_A45B37955619'
							AND sc.[name] <> 'delivery_start_local_date'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '2079E428_4C31_4EAB_B7F3_A45B37955619'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_start_local_date'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '0671E48B_350D_4CC0_B169_AA10CA8F8977'
							AND sc.[name] <> 'delivery_end_local_time'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '0671E48B_350D_4CC0_B169_AA10CA8F8977'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_end_local_time'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '9323F605_B3BA_4535_BB54_61C74416E0EF'
							AND sc.[name] <> 'delivery_end_local_time_cet'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '9323F605_B3BA_4535_BB54_61C74416E0EF'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_end_local_time_cet'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'A2AF291E_B223_4852_9D9E_4B95C6ED6D4B'
							AND sc.[name] <> 'name'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'A2AF291E_B223_4852_9D9E_4B95C6ED6D4B'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''name'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '9E936C23_8604_4DC3_9EF2_58ABA29B6E9B'
							AND sc.[name] <> 'type'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '9E936C23_8604_4DC3_9EF2_58ABA29B6E9B'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''type'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '2C7499AF_B7F2_479C_A013_0BE518226CB9'
							AND sc.[name] <> 'delivery_end_local_date'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '2C7499AF_B7F2_479C_A013_0BE518226CB9'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_end_local_date'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '74B65DBC_CA85_485A_AE8E_35D42C7D9136'
							AND sc.[name] <> 'delivery_end_ticks'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '74B65DBC_CA85_485A_AE8E_35D42C7D9136'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_end_ticks'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'E179FEE0_55D3_4DC2_BA57_0D66B064F9C4'
							AND sc.[name] <> 'delivery_end_utc_time'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'E179FEE0_55D3_4DC2_BA57_0D66B064F9C4'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_end_utc_time'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '65D28D6C_0800_432F_B9DA_9D92C981264D'
							AND sc.[name] <> 'daylight_change_suffix'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '65D28D6C_0800_432F_B9DA_9D92C981264D'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''daylight_change_suffix'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '9F80F7DD_ED68_41A9_B048_C227077DCDD1'
							AND sc.[name] <> 'short_name'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '9F80F7DD_ED68_41A9_B048_C227077DCDD1'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''short_name'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '03E2D32D_23BC_48FD_A4F6_F596FEE70953'
							AND sc.[name] <> 'major_type'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '03E2D32D_23BC_48FD_A4F6_F596FEE70953'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''major_type'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'F65429AF_E9D8_4CEC_ADA6_AB1AD349B64F'
							AND sc.[name] <> 'is_block'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'F65429AF_E9D8_4CEC_ADA6_AB1AD349B64F'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''is_block'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '0F4C319D_D5A4_4265_AE48_DE811BC875D4'
							AND sc.[name] <> 'is_half_hour'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '0F4C319D_D5A4_4265_AE48_DE811BC875D4'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''is_half_hour'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '01811C3E_F601_4FA0_82E5_445202062333'
							AND sc.[name] <> 'is_hour'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '01811C3E_F601_4FA0_82E5_445202062333'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''is_hour'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '1FF5147D_7907_4149_9F31_C8A94D29911B'
							AND sc.[name] <> 'is_quarter'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '1FF5147D_7907_4149_9F31_C8A94D29911B'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''is_quarter'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '306B3FF8_AE21_4430_9CB1_5AD9C3216278'
							AND sc.[name] <> 'traded_underlying_delivery_day'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '306B3FF8_AE21_4430_9CB1_5AD9C3216278'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''traded_underlying_delivery_day'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'E294CCD5_0EA2_4646_9389_7B964FCD4BB3'
							AND sc.[name] <> 'delivery_hour'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'E294CCD5_0EA2_4646_9389_7B964FCD4BB3'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_hour'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '20E07820_1E8B_40A0_BF4A_4B19A6AB2CD0'
							AND sc.[name] <> 'scaling_factor'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '20E07820_1E8B_40A0_BF4A_4B19A6AB2CD0'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''scaling_factor'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'F9EC2D75_4895_4B8F_8762_3ECA5611D51E'
							AND sc.[name] <> 'target_tso'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'F9EC2D75_4895_4B8F_8762_3ECA5611D51E'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''target_tso'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'FDA92736_CDC1_4FBD_B0BD_0C561B9DBE81'
							AND sc.[name] <> 'tso'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'FDA92736_CDC1_4FBD_B0BD_0C561B9DBE81'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''tso'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'A5519F9E_8780_49AC_A050_95CC46EF4B36'
							AND sc.[name] <> 'tso_name'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'A5519F9E_8780_49AC_A050_95CC46EF4B36'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''tso_name'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '2F3F9B27_737E_498A_8243_FA6BC2909F61'
							AND sc.[name] <> 'price'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '2F3F9B27_737E_498A_8243_FA6BC2909F61'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''price'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '43D33D53_E92A_4510_8993_24170ED578F0'
							AND sc.[name] <> 'quantity'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '43D33D53_E92A_4510_8993_24170ED578F0'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''quantity'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '90339ACE_57C8_46C9_910B_E998CAD3A1EB'
							AND sc.[name] <> 'is_buy_trade'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '90339ACE_57C8_46C9_910B_E998CAD3A1EB'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''is_buy_trade'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '35903EFD_5928_45A0_849A_848D7B4E6797'
							AND sc.[name] <> 'trade_id'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '35903EFD_5928_45A0_849A_848D7B4E6797'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''trade_id'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '01DD373A_4001_4FAC_B66B_A3620BF3C55E'
							AND sc.[name] <> 'exchange_id'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '01DD373A_4001_4FAC_B66B_A3620BF3C55E'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''exchange_id'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '8DDDF1D7_F12B_4877_A08F_55756212C8B9'
							AND sc.[name] <> 'external_trade_id'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '8DDDF1D7_F12B_4877_A08F_55756212C8B9'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''external_trade_id'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'BCB9E67B_FE4B_4D95_A838_1209FA1D25BB'
							AND sc.[name] <> 'execution_local_date'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'BCB9E67B_FE4B_4D95_A838_1209FA1D25BB'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''execution_local_date'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '4B252B72_2EB8_4354_8F2F_F155E91145B8'
							AND sc.[name] <> 'execution_time_local_time'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '4B252B72_2EB8_4354_8F2F_F155E91145B8'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''execution_time_local_time'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'C8B0954A_B0F2_4D1B_9B54_196E91A4732F'
							AND sc.[name] <> 'execution_time_local_time_cet'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'C8B0954A_B0F2_4D1B_9B54_196E91A4732F'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''execution_time_local_time_cet'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '44E86CE8_0D53_494D_9E63_F38521FFAF73'
							AND sc.[name] <> 'execution_utc_time'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '44E86CE8_0D53_494D_9E63_F38521FFAF73'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''execution_utc_time'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'B216C489_D6D0_4E9B_ADEF_BF596513F937'
							AND sc.[name] <> 'execution_ticks'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'B216C489_D6D0_4E9B_ADEF_BF596513F937'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''execution_ticks'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '399E933D_5BF2_4D23_80A0_1F732A6AFB48'
							AND sc.[name] <> 'analysis_info'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '399E933D_5BF2_4D23_80A0_1F732A6AFB48'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''analysis_info'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '3A84E16D_DFFA_4B72_95DD_C972A6F3FA3F'
							AND sc.[name] <> 'balance_group'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '3A84E16D_DFFA_4B72_95DD_C972A6F3FA3F'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''balance_group'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'E4C3D91E_FEA6_4471_8502_5DB3B80B67B3'
							AND sc.[name] <> 'com_xerv_account_type'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'E4C3D91E_FEA6_4471_8502_5DB3B80B67B3'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''com_xerv_account_type'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '5636AB6C_D59B_47E1_807D_BE2723A3DFEE'
							AND sc.[name] <> 'com_xerv_eic'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '5636AB6C_D59B_47E1_807D_BE2723A3DFEE'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''com_xerv_eic'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'DCF732F7_3A73_4AAD_A4F4_4E65EE70EF47'
							AND sc.[name] <> 'external_order_id'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'DCF732F7_3A73_4AAD_A4F4_4E65EE70EF47'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''external_order_id'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'DD668E47_7769_4D5D_98BF_C479F1C8963B'
							AND sc.[name] <> 'portfolio'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'DD668E47_7769_4D5D_98BF_C479F1C8963B'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''portfolio'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '1E10D9F4_2AA9_41B3_8300_42CB87AE001C'
							AND sc.[name] <> 'pre_arranged_type'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '1E10D9F4_2AA9_41B3_8300_42CB87AE001C'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''pre_arranged_type'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'BACD5FA7_EFF6_49D7_9280_A437768F89A0'
							AND sc.[name] <> 'state'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'BACD5FA7_EFF6_49D7_9280_A437768F89A0'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''state'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '2AB68F25_727C_4A8E_A61C_CF144E00B555'
							AND sc.[name] <> 'strategy_name'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '2AB68F25_727C_4A8E_A61C_CF144E00B555'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''strategy_name'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '5B400AFD_5693_4B56_A48D_0F708C912DAF'
							AND sc.[name] <> 'strategy_order_id'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '5B400AFD_5693_4B56_A48D_0F708C912DAF'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''strategy_order_id'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'D7AAC384_37A1_4B5A_A767_E8134D9AB3F8'
							AND sc.[name] <> 'text'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'D7AAC384_37A1_4B5A_A767_E8134D9AB3F8'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''text'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '30F7B3C0_75C0_4BBC_AF8E_D03E72B85CE3'
							AND sc.[name] <> 'trading_cost_group'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '30F7B3C0_75C0_4BBC_AF8E_D03E72B85CE3'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''trading_cost_group'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '324CDF8D_0B56_427E_8492_D1E6742F45CB'
							AND sc.[name] <> 'user_code'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '324CDF8D_0B56_427E_8492_D1E6742F45CB'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''user_code'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '7FA83817_CEB1_4793_976D_D2F855F76E84'
							AND sc.[name] <> 'pre_arranged'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '7FA83817_CEB1_4793_976D_D2F855F76E84'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''pre_arranged'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '613B2019_B6C1_47FF_9C7A_1CBC9AB75741'
							AND sc.[name] <> 'com_xerv_product'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '613B2019_B6C1_47FF_9C7A_1CBC9AB75741'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''com_xerv_product'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '2429279D_F861_4980_A504_93E383A96E01'
							AND sc.[name] <> 'contract'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '2429279D_F861_4980_A504_93E383A96E01'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''contract'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '4E5CCE7E_6CE7_4C63_A4F1_33E8E6019BCA'
							AND sc.[name] <> 'contract_type'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '4E5CCE7E_6CE7_4C63_A4F1_33E8E6019BCA'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''contract_type'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'E211B502_5791_4CCA_A8E0_C152D43520AA'
							AND sc.[name] <> 'exchange_key'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'E211B502_5791_4CCA_A8E0_C152D43520AA'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''exchange_key'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '492C0D62_AEFA_4E02_8F52_C7DB87549490'
							AND sc.[name] <> 'product_name'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '492C0D62_AEFA_4E02_8F52_C7DB87549490'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''product_name'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '35D3E9C4_0F1D_41D6_8ECF_FEB2853BC409'
							AND sc.[name] <> 'buy_or_sell'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '35D3E9C4_0F1D_41D6_8ECF_FEB2853BC409'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''buy_or_sell'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '4C9507BF_599F_4C4C_BFF5_AF905F5DC9DD'
							AND sc.[name] <> 'delivery_day'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '4C9507BF_599F_4C4C_BFF5_AF905F5DC9DD'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_day'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'DA662CF5_3F41_440C_BC09_5581551A8F7D'
							AND sc.[name] <> 'scaled_quantity'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'DA662CF5_3F41_440C_BC09_5581551A8F7D'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''scaled_quantity'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'D7E52FE1_9FDD_437C_AB78_15D89E28B513'
							AND sc.[name] <> 'signed_quantity'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'D7E52FE1_9FDD_437C_AB78_15D89E28B513'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''signed_quantity'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '7F8E471D_F638_4D95_9022_70EA94A4EF36'
							AND sc.[name] <> 'self_trade'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '7F8E471D_F638_4D95_9022_70EA94A4EF36'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''self_trade'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'B00C0646_9134_4202_AD32_4BACBC2E462A'
							AND sc.[name] <> 'delivery_date'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'B00C0646_9134_4202_AD32_4BACBC2E462A'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''delivery_date'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = 'E7BD8856_1093_4BD2_9D79_90741DBC5F87'
							AND sc.[name] <> 'hour'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = 'E7BD8856_1093_4BD2_9D79_90741DBC5F87'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''hour'', ''COLUMN''')
			END
		
			IF EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON st.[object_id] = sep.major_id
						INNER JOIN sys.columns sc 
							ON sc.[object_id] = st.[object_id]
							AND sep.minor_id = sc.column_id
						WHERE st.[name] = 'udt_likron_market_results'
							AND sep.[value] = '6492A3BA_DEAE_4272_9921_79E1908D25B7'
							AND sc.[name] <> 'minutes'
			)
			BEGIN
				SELECT @column_name = sc.[name]
				FROM SYS.EXTENDED_PROPERTIES sep
				INNER JOIN sys.tables st 
					ON st.[object_id] = sep.major_id
				INNER JOIN sys.columns sc 
					ON sc.[object_id] = st.[object_id]
					AND sep.minor_id = sc.column_id
				WHERE st.[name] = 'udt_likron_market_results'
					AND sep.[value] = '6492A3BA_DEAE_4272_9921_79E1908D25B7'

				EXEC ('EXEC sp_rename ''[dbo].[udt_likron_market_results].[' + @column_name + ']'', ''minutes'', ''COLUMN''')
			END
		
			
			-- Add/Alter columns
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'related_order_id') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [related_order_id] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [related_order_id] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'underlying_start') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [underlying_start] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [underlying_start] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'id') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [id] INT NOT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [id] INT NOT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'trader_id') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [trader_id] INT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [trader_id] INT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_start_local_time') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_start_local_time] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_start_local_time] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_start_local_time_cet') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_start_local_time_cet] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_start_local_time_cet] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_start_ticks') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_start_ticks] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_start_ticks] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_start_utc_time') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_start_utc_time] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_start_utc_time] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'underlying_end') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [underlying_end] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [underlying_end] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_start_local_date') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_start_local_date] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_start_local_date] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_end_local_time') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_end_local_time] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_end_local_time] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_end_local_time_cet') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_end_local_time_cet] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_end_local_time_cet] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'name') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [name] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [name] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'type') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [type] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [type] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_end_local_date') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_end_local_date] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_end_local_date] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_end_ticks') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_end_ticks] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_end_ticks] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_end_utc_time') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_end_utc_time] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_end_utc_time] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'daylight_change_suffix') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [daylight_change_suffix] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [daylight_change_suffix] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'short_name') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [short_name] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [short_name] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'major_type') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [major_type] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [major_type] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'is_block') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [is_block] VARCHAR(6) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [is_block] VARCHAR(6) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'is_half_hour') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [is_half_hour] VARCHAR(6) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [is_half_hour] VARCHAR(6) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'is_hour') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [is_hour] VARCHAR(6) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [is_hour] VARCHAR(6) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'is_quarter') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [is_quarter] VARCHAR(6) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [is_quarter] VARCHAR(6) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'traded_underlying_delivery_day') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [traded_underlying_delivery_day] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [traded_underlying_delivery_day] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_hour') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_hour] INT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_hour] INT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'scaling_factor') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [scaling_factor] FLOAT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [scaling_factor] FLOAT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'target_tso') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [target_tso] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [target_tso] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'tso') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [tso] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [tso] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'tso_name') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [tso_name] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [tso_name] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'price') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [price] FLOAT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [price] FLOAT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'quantity') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [quantity] FLOAT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [quantity] FLOAT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'is_buy_trade') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [is_buy_trade] VARCHAR(6) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [is_buy_trade] VARCHAR(6) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'trade_id') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [trade_id] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [trade_id] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'exchange_id') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [exchange_id] INT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [exchange_id] INT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'external_trade_id') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [external_trade_id] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [external_trade_id] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'execution_local_date') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [execution_local_date] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [execution_local_date] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'execution_time_local_time') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [execution_time_local_time] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [execution_time_local_time] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'execution_time_local_time_cet') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [execution_time_local_time_cet] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [execution_time_local_time_cet] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'execution_utc_time') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [execution_utc_time] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [execution_utc_time] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'execution_ticks') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [execution_ticks] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [execution_ticks] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'analysis_info') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [analysis_info] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [analysis_info] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'balance_group') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [balance_group] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [balance_group] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'com_xerv_account_type') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [com_xerv_account_type] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [com_xerv_account_type] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'com_xerv_eic') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [com_xerv_eic] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [com_xerv_eic] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'external_order_id') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [external_order_id] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [external_order_id] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'portfolio') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [portfolio] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [portfolio] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'pre_arranged_type') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [pre_arranged_type] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [pre_arranged_type] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'state') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [state] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [state] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'strategy_name') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [strategy_name] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [strategy_name] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'strategy_order_id') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [strategy_order_id] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [strategy_order_id] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'text') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [text] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [text] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'trading_cost_group') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [trading_cost_group] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [trading_cost_group] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'user_code') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [user_code] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [user_code] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'pre_arranged') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [pre_arranged] VARCHAR(6) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [pre_arranged] VARCHAR(6) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'com_xerv_product') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [com_xerv_product] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [com_xerv_product] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'contract') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [contract] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [contract] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'contract_type') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [contract_type] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [contract_type] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'exchange_key') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [exchange_key] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [exchange_key] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'product_name') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [product_name] VARCHAR(100) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [product_name] VARCHAR(100) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'buy_or_sell') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [buy_or_sell] VARCHAR(20) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [buy_or_sell] VARCHAR(20) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_day') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_day] VARCHAR(50) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_day] VARCHAR(50) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'scaled_quantity') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [scaled_quantity] FLOAT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [scaled_quantity] FLOAT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'signed_quantity') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [signed_quantity] FLOAT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [signed_quantity] FLOAT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'self_trade') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [self_trade] VARCHAR(6) NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [self_trade] VARCHAR(6) NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'delivery_date') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [delivery_date] DATETIME NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [delivery_date] DATETIME NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'hour') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [hour] INT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [hour] INT NULL
			END
		
			IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'minutes') IS NULL
			BEGIN
				ALTER TABLE udt_likron_market_results ADD [minutes] INT NULL
			END
			ELSE
			BEGIN
				ALTER TABLE udt_likron_market_results ALTER COLUMN [minutes] INT NULL
			END
		
				IF EXISTS ( SELECT 1
							FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
							WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
								AND TABLE_NAME = 'likron_market_results' 
								AND TABLE_SCHEMA = 'dbo'
								AND COLUMN_NAME <> 'id'
				)
				BEGIN
					DECLARE @primary_key_constraint NVARCHAR(100) = NULL

					SELECT @primary_key_constraint = [name]
					FROM sys.key_constraints
					WHERE [type] = 'PK'
						AND [parent_object_id] = OBJECT_ID('dbo.udt_likron_market_results')

					IF OBJECT_ID(N'[dbo].[udt_likron_market_results]', N'U') IS NOT NULL
					AND @primary_key_constraint IS NOT NULL
					BEGIN
						EXEC ('ALTER TABLE udt_likron_market_results DROP CONSTRAINT ' + @primary_key_constraint)
					END

					IF COL_LENGTH('[dbo].[udt_likron_market_results]', 'id') IS NOT NULL
					BEGIN
						ALTER TABLE udt_likron_market_results ADD PRIMARY KEY (id)
					END
				END 
			
			-- Drop unused/deleted columns
			DECLARE @column_drop_sql NVARCHAR(MAX) = ''

			SELECT @column_drop_sql += 'ALTER TABLE [dbo].[udt_likron_market_results] DROP COLUMN [' + isc.COLUMN_NAME + '];' + NCHAR(13)
			FROM INFORMATION_SCHEMA.COLUMNS isc
			WHERE TABLE_NAME = N'udt_likron_market_results'
				AND NOT EXISTS (
					SELECT udtm.column_name
					FROM user_defined_tables_metadata udtm
					INNER JOIN user_defined_tables udt
						ON udt.udt_id = udtm.udt_id
					WHERE udt.udt_name = 'likron_market_results'
						AND udtm.column_name = isc.COLUMN_NAME
				)
				AND isc.COLUMN_NAME NOT IN ('create_user', 'create_ts', 'update_user', 'update_ts')
		
			EXEC (@column_drop_sql)
		
		END
		GO

		IF OBJECT_ID('[dbo].[TRGUPD_udt_likron_market_results]', 'TR') IS NOT NULL
			DROP TRIGGER [dbo].[TRGUPD_udt_likron_market_results]
		GO

		CREATE TRIGGER [dbo].[TRGUPD_udt_likron_market_results]
		ON [dbo].[udt_likron_market_results]
		FOR UPDATE
		AS
			UPDATE udt_likron_market_results
			   SET update_user = dbo.FNADBUser(),
				   update_ts = GETDATE()
			FROM udt_likron_market_results t
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
				, @value = '9E342A60_E46A_4DD2_9DC5_80413A263F85'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'related_order_id' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '77023D47_C63C_40F2_B9B7_6F2E7C91FE7C'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'related_order_id'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'underlying_start' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'EF79F2F1_2B82_4E1C_8CB3_E9647AC50BAA'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'underlying_start'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'id' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'AF848EA3_10E7_4E1B_848E_3D8A9424E1F9'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
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
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'trader_id' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '1072A4F1_FC8A_4FF6_9E24_38DE96BAF3AC'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'trader_id'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_start_local_time' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '700D1845_DAF1_4B90_8601_CAD673809526'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_start_local_time'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_start_local_time_cet' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '64DB1273_9A54_482D_AB10_EF6E33804611'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_start_local_time_cet'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_start_ticks' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'B345E82C_63C9_418D_AA48_22F1721D7D3C'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_start_ticks'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_start_utc_time' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '82AABD18_DD8E_4FA6_B7AD_23B972985507'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_start_utc_time'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'underlying_end' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '1E99C249_2B0F_467A_94BE_F14B7C6501B0'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'underlying_end'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_start_local_date' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '2079E428_4C31_4EAB_B7F3_A45B37955619'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_start_local_date'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_end_local_time' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '0671E48B_350D_4CC0_B169_AA10CA8F8977'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_end_local_time'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_end_local_time_cet' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '9323F605_B3BA_4535_BB54_61C74416E0EF'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_end_local_time_cet'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'name' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'A2AF291E_B223_4852_9D9E_4B95C6ED6D4B'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'name'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'type' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '9E936C23_8604_4DC3_9EF2_58ABA29B6E9B'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'type'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_end_local_date' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '2C7499AF_B7F2_479C_A013_0BE518226CB9'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_end_local_date'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_end_ticks' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '74B65DBC_CA85_485A_AE8E_35D42C7D9136'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_end_ticks'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_end_utc_time' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'E179FEE0_55D3_4DC2_BA57_0D66B064F9C4'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_end_utc_time'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'daylight_change_suffix' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '65D28D6C_0800_432F_B9DA_9D92C981264D'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'daylight_change_suffix'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'short_name' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '9F80F7DD_ED68_41A9_B048_C227077DCDD1'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'short_name'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'major_type' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '03E2D32D_23BC_48FD_A4F6_F596FEE70953'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'major_type'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'is_block' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'F65429AF_E9D8_4CEC_ADA6_AB1AD349B64F'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'is_block'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'is_half_hour' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '0F4C319D_D5A4_4265_AE48_DE811BC875D4'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'is_half_hour'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'is_hour' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '01811C3E_F601_4FA0_82E5_445202062333'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'is_hour'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'is_quarter' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '1FF5147D_7907_4149_9F31_C8A94D29911B'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'is_quarter'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'traded_underlying_delivery_day' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '306B3FF8_AE21_4430_9CB1_5AD9C3216278'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'traded_underlying_delivery_day'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_hour' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'E294CCD5_0EA2_4646_9389_7B964FCD4BB3'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_hour'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'scaling_factor' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '20E07820_1E8B_40A0_BF4A_4B19A6AB2CD0'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'scaling_factor'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'target_tso' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'F9EC2D75_4895_4B8F_8762_3ECA5611D51E'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'target_tso'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'tso' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'FDA92736_CDC1_4FBD_B0BD_0C561B9DBE81'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'tso'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'tso_name' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'A5519F9E_8780_49AC_A050_95CC46EF4B36'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'tso_name'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'price' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '2F3F9B27_737E_498A_8243_FA6BC2909F61'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'price'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'quantity' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '43D33D53_E92A_4510_8993_24170ED578F0'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'quantity'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'is_buy_trade' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '90339ACE_57C8_46C9_910B_E998CAD3A1EB'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'is_buy_trade'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'trade_id' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '35903EFD_5928_45A0_849A_848D7B4E6797'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'trade_id'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'exchange_id' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '01DD373A_4001_4FAC_B66B_A3620BF3C55E'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'exchange_id'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'external_trade_id' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '8DDDF1D7_F12B_4877_A08F_55756212C8B9'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'external_trade_id'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'execution_local_date' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'BCB9E67B_FE4B_4D95_A838_1209FA1D25BB'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'execution_local_date'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'execution_time_local_time' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '4B252B72_2EB8_4354_8F2F_F155E91145B8'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'execution_time_local_time'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'execution_time_local_time_cet' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'C8B0954A_B0F2_4D1B_9B54_196E91A4732F'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'execution_time_local_time_cet'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'execution_utc_time' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '44E86CE8_0D53_494D_9E63_F38521FFAF73'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'execution_utc_time'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'execution_ticks' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'B216C489_D6D0_4E9B_ADEF_BF596513F937'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'execution_ticks'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'analysis_info' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '399E933D_5BF2_4D23_80A0_1F732A6AFB48'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'analysis_info'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'balance_group' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '3A84E16D_DFFA_4B72_95DD_C972A6F3FA3F'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'balance_group'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'com_xerv_account_type' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'E4C3D91E_FEA6_4471_8502_5DB3B80B67B3'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'com_xerv_account_type'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'com_xerv_eic' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '5636AB6C_D59B_47E1_807D_BE2723A3DFEE'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'com_xerv_eic'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'external_order_id' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'DCF732F7_3A73_4AAD_A4F4_4E65EE70EF47'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'external_order_id'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'portfolio' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'DD668E47_7769_4D5D_98BF_C479F1C8963B'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'portfolio'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'pre_arranged_type' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '1E10D9F4_2AA9_41B3_8300_42CB87AE001C'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'pre_arranged_type'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'state' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'BACD5FA7_EFF6_49D7_9280_A437768F89A0'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'state'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'strategy_name' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '2AB68F25_727C_4A8E_A61C_CF144E00B555'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'strategy_name'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'strategy_order_id' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '5B400AFD_5693_4B56_A48D_0F708C912DAF'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'strategy_order_id'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'text' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'D7AAC384_37A1_4B5A_A767_E8134D9AB3F8'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'text'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'trading_cost_group' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '30F7B3C0_75C0_4BBC_AF8E_D03E72B85CE3'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'trading_cost_group'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'user_code' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '324CDF8D_0B56_427E_8492_D1E6742F45CB'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'user_code'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'pre_arranged' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '7FA83817_CEB1_4793_976D_D2F855F76E84'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'pre_arranged'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'com_xerv_product' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '613B2019_B6C1_47FF_9C7A_1CBC9AB75741'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'com_xerv_product'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'contract' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '2429279D_F861_4980_A504_93E383A96E01'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'contract'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'contract_type' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '4E5CCE7E_6CE7_4C63_A4F1_33E8E6019BCA'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'contract_type'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'exchange_key' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'E211B502_5791_4CCA_A8E0_C152D43520AA'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'exchange_key'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'product_name' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '492C0D62_AEFA_4E02_8F52_C7DB87549490'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'product_name'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'buy_or_sell' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '35D3E9C4_0F1D_41D6_8ECF_FEB2853BC409'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'buy_or_sell'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_day' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '4C9507BF_599F_4C4C_BFF5_AF905F5DC9DD'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_day'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'scaled_quantity' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'DA662CF5_3F41_440C_BC09_5581551A8F7D'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'scaled_quantity'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'signed_quantity' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'D7E52FE1_9FDD_437C_AB78_15D89E28B513'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'signed_quantity'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'self_trade' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '7F8E471D_F638_4D95_9022_70EA94A4EF36'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'self_trade'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'delivery_date' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'B00C0646_9134_4202_AD32_4BACBC2E462A'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'delivery_date'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'hour' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = 'E7BD8856_1093_4BD2_9D79_90741DBC5F87'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'hour'
		END
		
		IF NOT EXISTS ( SELECT 1
						FROM SYS.EXTENDED_PROPERTIES sep
						INNER JOIN sys.tables st 
							ON sep.major_id = st.object_id
						INNER JOIN sys.columns sc 
							ON st.object_id = sc.object_id
							AND sep.minor_id = sc.column_id
						WHERE st.name = 'udt_likron_market_results'
							AND sc.name = 'minutes' )
		BEGIN
			-- Store udt column in extended property of column so that it can be accessed later to indentify column name for renaming and deletion purpose
			EXEC sys.sp_addextendedproperty 
				  @name = 'udt_column_hash'
				, @value = '6492A3BA_DEAE_4272_9921_79E1908D25B7'
				, @level0type = N'SCHEMA'
				, @level0name = 'dbo'
				, @level1type = N'TABLE'
				, @level1name = 'udt_likron_market_results'
				, @level2type = N'COLUMN'
				, @level2name = 'minutes'
		END
		