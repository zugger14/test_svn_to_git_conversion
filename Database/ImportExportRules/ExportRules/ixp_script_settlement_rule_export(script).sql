IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'SETTLEMENT RULE (SCRIPT)') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
				VALUES( 
					'SETTLEMENT RULE (SCRIPT)' ,
					'y' ,
					NULL ,
					NULL,
					NULL,
					'e' ,
					'n' ,
					'farrms_admin' ,
					23500)
DECLARE @ixp_rules_id_new INT
				SET @ixp_rules_id_new = SCOPE_IDENTITY()
				PRINT 	@ixp_rules_id_new 
				
INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)  
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  0,
										  NULL,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL 
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  1,
										  NULL,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
											SELECT @ixp_rules_id_new,
											'contract_group',
											3072,
											'cg',
											NULL UNION ALL 
											SELECT @ixp_rules_id_new,
											'source_book',
											3073,
											'sb_group1',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'source_book',
											3074,
											'sb_group2',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'source_book',
											3075,
											'sb_group3',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'source_book',
											3076,
											'sb_group4',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'source_currency',
											3077,
											'sc_cgd_currency',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'source_currency',
											3078,
											'sc',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'source_deal_type',
											3079,
											'sdt_deal_type_cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'source_uom',
											3080,
											'su_uom_volume',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3081,
											'sdv_pnl_date_cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3082,
											'sdv_eqr_product_name_cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3083,
											'sdv_group_by_cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3084,
											'sdv_settlement_calendar_cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3085,
											'sdv_payment_calendar_cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3086,
											'sdv_calc_aggregation_cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3087,
											'sdv_deal_type_cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3088,
											'sdv_volume_granularity_cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3089,
											'sdv_units_for_rate',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3090,
											'sdv_product_type_name',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3091,
											'sdv_increment_peaking_name',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3092,
											'ssd_class_name',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3093,
											'sdv_time_of_use',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3094,
											'sdv_invoice_line_item_id',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3095,
											'sdv_alias',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3096,
											'sdv_contract_status',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3097,
											'sdv_pnl_calendar',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3098,
											'sdv_pnl_date',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3099,
											'sdv_holiday_id',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3100,
											'sdv_settlement_date',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3101,
											'sdv_settlement_calendar',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3102,
											'sdv_payment_calendar',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3103,
											'sdv_payment_date',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3104,
											'sdv_vol_granularity',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'static_data_value',
											3105,
											'sdv_billing_cycle',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'contract_group_detail',
											3106,
											'cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'source_system_description',
											3107,
											'ssd_source_system',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'Contract_report_template',
											3108,
											'crt_contract_report_template',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'Contract_report_template',
											3109,
											'crt_invoice_report_template',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'Contract_report_template',
											3110,
											'crt_netting_template',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'contract_charge_type',
											3111,
											'cc_contract_template_cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'contract_charge_type',
											3112,
											'cc_con_charge_type_id',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'contract_charge_type',
											3113,
											'cc_contract_charge_type',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'contract_charge_type_detail',
											3114,
											'ccd_contract_component_template_cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'adjustment_default_gl_codes',
											3115,
											'agc_default_gl_id_estimates_cgd',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'adjustment_default_gl_codes',
											3116,
											'agc_default_gl_id',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'adjustment_default_gl_codes',
											3117,
											'agd_adjustment_default_gl_codes',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'application_users',
											3118,
											'au_settlement_accountant_cg',
											7093 UNION ALL 
											SELECT @ixp_rules_id_new,
											'application_users',
											3119,
											'au_contract_specialist_cg',
											7093

			INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
			SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
			FROM #old_ixp_export_data_source old 
			INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
			
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)           SELECT           3000,          @ixp_rules_id_new,          3078,          3072,          'source_currency_id',          'currency',          3078 UNION ALL           SELECT           3001,          @ixp_rules_id_new,          3080,          3072,          'source_uom_id',          'volume_uom',          3080 UNION ALL           SELECT           3002,          @ixp_rules_id_new,          3096,          3072,          'value_id',          'contract_status',          3096 UNION ALL           SELECT           3003,          @ixp_rules_id_new,          3097,          3072,          'value_id',          'pnl_calendar',          3097 UNION ALL           SELECT           3004,          @ixp_rules_id_new,          3098,          3072,          'value_id',          'pnl_date',          3098 UNION ALL           SELECT           3005,          @ixp_rules_id_new,          3099,          3072,          'value_id',          'holiday_calendar_id',          3099 UNION ALL           SELECT           3006,          @ixp_rules_id_new,          3113,          3072,          'contract_charge_type_id',          'contract_charge_type_id',          3113 UNION ALL           SELECT           3007,          @ixp_rules_id_new,          3118,          3072,          'user_login_id',          'settlement_accountant',          3118 UNION ALL           SELECT           3008,          @ixp_rules_id_new,          3119,          3072,          'user_login_id',          'contract_specialist',          3119 UNION ALL           SELECT           3009,          @ixp_rules_id_new,          3106,          3072,          'contract_id',          'contract_id',          3106 UNION ALL           SELECT           3010,          @ixp_rules_id_new,          3107,          3072,          'source_system_id',          'source_system_id',          3107 UNION ALL           SELECT           3011,          @ixp_rules_id_new,          3108,          3072,          'template_id',          'contract_report_template',          3108 UNION ALL           SELECT           3012,          @ixp_rules_id_new,          3109,          3072,          'template_id',          'invoice_report_template',          3109 UNION ALL           SELECT           3013,          @ixp_rules_id_new,          3110,          3072,          'template_id',          'netting_template',          3110 UNION ALL           SELECT           3014,          @ixp_rules_id_new,          3112,          3072,          'contract_charge_type_id',          'contract_charge_type_id',          3112 UNION ALL           SELECT           3015,          @ixp_rules_id_new,          3100,          3072,          'value_id',          'settlement_date',          3100 UNION ALL           SELECT           3016,          @ixp_rules_id_new,          3101,          3072,          'value_id',          'settlement_calendar',          3101 UNION ALL           SELECT           3017,          @ixp_rules_id_new,          3102,          3072,          'value_id',          'payment_calendar',          3102 UNION ALL           SELECT           3018,          @ixp_rules_id_new,          3103,          3072,          'value_id',          'invoice_due_date',          3103 UNION ALL           SELECT           3019,          @ixp_rules_id_new,          3104,          3072,          'value_id',          'volume_granularity',          3104 UNION ALL           SELECT           3020,          @ixp_rules_id_new,          3105,          3072,          'value_id',          'billing_cycle',          3105 UNION ALL           SELECT           3021,          @ixp_rules_id_new,          3073,          3106,          'source_book_id',          'group1',          3073 UNION ALL           SELECT           3022,          @ixp_rules_id_new,          3074,          3106,          'source_book_id',          'group2',          3074 UNION ALL           SELECT           3023,          @ixp_rules_id_new,          3075,          3106,          'source_book_id',          'group3',          3075 UNION ALL           SELECT           3024,          @ixp_rules_id_new,          3076,          3106,          'source_book_id',          'group4',          3076 UNION ALL           SELECT           3025,          @ixp_rules_id_new,          3077,          3106,          'source_currency_id',          'currency',          3077 UNION ALL           SELECT           3026,          @ixp_rules_id_new,          3079,          3106,          'source_deal_type_id',          'deal_type',          3079 UNION ALL           SELECT           3027,          @ixp_rules_id_new,          3116,          3106,          'default_gl_id',          'default_gl_id',          3116 UNION ALL           SELECT           3028,          @ixp_rules_id_new,          3117,          3106,          'default_gl_id',          'default_gl_code_cash_applied',          3117 UNION ALL           SELECT           3029,          @ixp_rules_id_new,          3093,          3106,          'value_id',          'timeofuse',          3093 UNION ALL           SELECT           3030,          @ixp_rules_id_new,          3094,          3106,          'value_id',          'invoice_line_item_id',          3094 UNION ALL           SELECT           3031,          @ixp_rules_id_new,          3095,          3106,          'value_id',          'alias',          3095 UNION ALL           SELECT           3032,          @ixp_rules_id_new,          3111,          3106,          'contract_charge_type_id',          'contract_template',          3111 UNION ALL           SELECT           3033,          @ixp_rules_id_new,          3114,          3106,          'ID',          'contract_component_template',          3114 UNION ALL           SELECT           3034,          @ixp_rules_id_new,          3115,          3106,          'default_gl_id',          'default_gl_id_estimates',          3115 UNION ALL           SELECT           3035,          @ixp_rules_id_new,          3087,          3106,          'value_id',          'deal_type',          3087 UNION ALL           SELECT           3036,          @ixp_rules_id_new,          3088,          3106,          'value_id',          'volume_granularity',          3088 UNION ALL           SELECT           3037,          @ixp_rules_id_new,          3089,          3106,          'value_id',          'units_for_rate',          3089 UNION ALL           SELECT           3038,          @ixp_rules_id_new,          3090,          3106,          'value_id',          'product_type_name',          3090 UNION ALL           SELECT           3039,          @ixp_rules_id_new,          3091,          3106,          'value_id',          'increment_peaking_name',          3091 UNION ALL           SELECT           3040,          @ixp_rules_id_new,          3092,          3106,          'value_id',          'class_name',          3092 UNION ALL           SELECT           3041,          @ixp_rules_id_new,          3081,          3106,          'value_id',          'pnl_date',          3081 UNION ALL           SELECT           3042,          @ixp_rules_id_new,          3082,          3106,          'value_id',          'product_type_name',          3082 UNION ALL           SELECT           3043,          @ixp_rules_id_new,          3083,          3106,          'value_id',          'group_by',          3083 UNION ALL           SELECT           3044,          @ixp_rules_id_new,          3084,          3106,          'value_id',          'settlement_calendar',          3084 UNION ALL           SELECT           3045,          @ixp_rules_id_new,          3085,          3106,          'value_id',          'payment_calendar',          3085 UNION ALL           SELECT           3046,          @ixp_rules_id_new,          3086,          3106,          'value_id',          'calc_aggregation',          3086

			INSERT INTO ixp_export_relation (from_data_source, to_data_source, from_column, to_column, ixp_rules_id, data_source)
    		SELECT new_from.ixp_export_data_source_id,
					new_to.ixp_export_data_source_id,
					a.from_column,
					a.to_column,
					@ixp_rules_id_new,
					new_from.ixp_export_data_source_id
    		FROM #old_relation a 
    		INNER JOIN #old_ixp_export_data_source b_from ON b_from.ixp_export_data_source_id = a.from_data_source
    		INNER JOIN #old_ixp_export_data_source b_to ON b_to.ixp_export_data_source_id = a.to_data_source
    		LEFT JOIN ixp_exportable_table iet_from ON b_from.export_table_name = iet_from.ixp_exportable_table_name
    		LEFT JOIN ixp_exportable_table iet_to ON b_to.export_table_name = iet_to.ixp_exportable_table_name
    		LEFT JOIN ixp_export_data_source new_from ON new_from.export_table = iet_from.ixp_exportable_table_id AND new_from.export_table_alias = b_from.export_table_alias 
    		LEFT JOIN ixp_export_data_source new_to ON new_to.export_table = iet_to.ixp_exportable_table_id AND new_to.export_table_alias = b_to.export_table_alias
    		WHERE new_from.ixp_rules_id = @ixp_rules_id_new AND new_to.ixp_rules_id = @ixp_rules_id_new
			
 INSERT INTO ixp_data_mapping (ixp_rules_id, table_id, column_name, column_function, column_aggregation, column_filter, insert_type, enable_identity_insert, create_destination_table, source_column, export_folder, export_delim, generate_script, column_alias, main_table )  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'increment_name', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[increment_name]', 'D:\Contract\', NULL, 'y', 'increment_name', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'time_zone', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[time_zone]', 'D:\Contract\', NULL, 'y', 'time_zone', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'point_of_receipt_control_area', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[point_of_receipt_control_area]', 'D:\Contract\', NULL, 'y', 'point_of_receipt_control_area', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'holiday_calendar_id', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'sdv_holiday_id.[value_id]', 'D:\Contract\', NULL, 'y', 'holiday_calendar_id', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'pnl_date', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'sdv_pnl_calendar.[value_id]', 'D:\Contract\', NULL, 'y', 'pnl_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'pnl_calendar', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'sdv_pnl_calendar.[value_id]', 'D:\Contract\', NULL, 'y', 'pnl_calendar', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'term_name', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[term_name]', 'D:\Contract\', NULL, 'y', 'term_name', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'rec_uom', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[rec_uom]', 'D:\Contract\', NULL, 'y', 'rec_uom', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'pipeline', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[pipeline]', 'D:\Contract\', NULL, 'y', 'pipeline', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'point_of_delivery_control_area', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[point_of_delivery_control_area]', 'D:\Contract\', NULL, 'y', 'point_of_delivery_control_area', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'path', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[path]', 'D:\Contract\', NULL, 'y', 'path', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'maintain_rate_schedule', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[maintain_rate_schedule]', 'D:\Contract\', NULL, 'y', 'maintain_rate_schedule', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'block_type', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[block_type]', 'D:\Contract\', NULL, 'y', 'block_type', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'onpeak_mult', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[onpeak_mult]', 'D:\Contract\', NULL, 'y', 'onpeak_mult', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'offpeak_mult', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[offpeak_mult]', 'D:\Contract\', NULL, 'y', 'offpeak_mult', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'volume_mult', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[volume_mult]', 'D:\Contract\', NULL, 'y', 'volume_mult', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'settlement_rule', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[settlement_rule]', 'D:\Contract\', NULL, 'y', 'settlement_rule', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'transportation_contract', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[transportation_contract]', 'D:\Contract\', NULL, 'y', 'transportation_contract', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_status', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[contract_status]', 'D:\Contract\', NULL, 'y', 'contract_status', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'currency', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[currency]', 'D:\Contract\', NULL, 'y', 'currency', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_charge_type_id', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cc_con_charge_type_id.[contract_charge_type_id]', 'D:\Contract\', NULL, 'y', 'contract_charge_type_id', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'source_system_id', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'ssd_source_system.[source_system_id]', 'D:\Contract\', NULL, 'y', 'source_system_id', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'netting_template', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'crt_netting_template.[template_id]', 'D:\Contract\', NULL, 'y', 'netting_template', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'invoice_report_template', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'crt_invoice_report_template.[template_id]', 'D:\Contract\', NULL, 'y', 'invoice_report_template', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'volume_uom', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'su_uom_volume.[source_uom_id]', 'D:\Contract\', NULL, 'y', 'volume_uom', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'financial_rate_fees', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[financial_rate_fees]', 'D:\Contract\', NULL, 'y', 'financial_rate_fees', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_report_template', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'crt_contract_report_template.[template_id]', 'D:\Contract\', NULL, 'y', 'contract_report_template', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'sub_id', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[sub_id]', 'D:\Contract\', NULL, 'y', 'sub_id', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_name', NULL, NULL, 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[contract_name]', 'D:\Contract\', NULL, 'y', 'contract_name', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_date', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[contract_date]', 'D:\Contract\', NULL, 'y', 'contract_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'receive_invoice', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[receive_invoice]', 'D:\Contract\', NULL, 'y', 'receive_invoice', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'type', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[type]', 'D:\Contract\', NULL, 'y', 'type', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'reverse_entries', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[reverse_entries]', 'D:\Contract\', NULL, 'y', 'reverse_entries', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'term_start', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[term_start]', 'D:\Contract\', NULL, 'y', 'term_start', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'term_end', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[term_end]', 'D:\Contract\', NULL, 'y', 'term_end', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'name', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[name]', 'D:\Contract\', NULL, 'y', 'name', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'company', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[company]', 'D:\Contract\', NULL, 'y', 'company', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'state', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[state]', 'D:\Contract\', NULL, 'y', 'state', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'city', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[city]', 'D:\Contract\', NULL, 'y', 'city', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'zip', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[zip]', 'D:\Contract\', NULL, 'y', 'zip', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'address', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[address]', 'D:\Contract\', NULL, 'y', 'address', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'address2', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[address2]', 'D:\Contract\', NULL, 'y', 'address2', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'telephone', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[telephone]', 'D:\Contract\', NULL, 'y', 'telephone', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'email', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[email]', 'D:\Contract\', NULL, 'y', 'email', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'fax', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[fax]', 'D:\Contract\', NULL, 'y', 'fax', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'name2', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[name2]', 'D:\Contract\', NULL, 'y', 'name2', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'company2', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[company2]', 'D:\Contract\', NULL, 'y', 'company2', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'telephone2', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[telephone2]', 'D:\Contract\', NULL, 'y', 'telephone2', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'fax2', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[fax2]', 'D:\Contract\', NULL, 'y', 'fax2', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'email2', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[email2]', 'D:\Contract\', NULL, 'y', 'email2', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'source_contract_id', NULL, NULL, 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[source_contract_id]', 'D:\Contract\', NULL, 'y', 'source_contract_id', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_desc', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[contract_desc]', 'D:\Contract\', NULL, 'y', 'contract_desc', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'energy_type', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[energy_type]', 'D:\Contract\', NULL, 'y', 'energy_type', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'area_engineer', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[area_engineer]', 'D:\Contract\', NULL, 'y', 'area_engineer', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'metering_contract', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[metering_contract]', 'D:\Contract\', NULL, 'y', 'metering_contract', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'miso_queue_number', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[miso_queue_number]', 'D:\Contract\', NULL, 'y', 'miso_queue_number', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'substation_name', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[substation_name]', 'D:\Contract\', NULL, 'y', 'substation_name', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'project_county', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[project_county]', 'D:\Contract\', NULL, 'y', 'project_county', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'voltage', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[voltage]', 'D:\Contract\', NULL, 'y', 'voltage', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_service_agreement_id', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[contract_service_agreement_id]', 'D:\Contract\', NULL, 'y', 'contract_service_agreement_id', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'billing_from_date', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[billing_from_date]', 'D:\Contract\', NULL, 'y', 'billing_from_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'billing_to_date', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[billing_to_date]', 'D:\Contract\', NULL, 'y', 'billing_to_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'Subledger_code', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[Subledger_code]', 'D:\Contract\', NULL, 'y', 'Subledger_code', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'UD_Contract_id', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[UD_Contract_id]', 'D:\Contract\', NULL, 'y', 'UD_Contract_id', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'extension_provision_description', NULL, 'Min', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[extension_provision_description]', 'D:\Contract\', NULL, 'y', 'extension_provision_description', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'ferct_tarrif_reference', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[ferct_tarrif_reference]', 'D:\Contract\', NULL, 'y', 'ferct_tarrif_reference', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'point_of_delivery_specific_location', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[point_of_delivery_specific_location]', 'D:\Contract\', NULL, 'y', 'point_of_delivery_specific_location', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_affiliate', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[contract_affiliate]', 'D:\Contract\', NULL, 'y', 'contract_affiliate', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'point_of_receipt_specific_location', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[point_of_receipt_specific_location]', 'D:\Contract\', NULL, 'y', 'point_of_receipt_specific_location', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'no_meterdata', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[no_meterdata]', 'D:\Contract\', NULL, 'y', 'no_meterdata', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'billing_start_month', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[billing_start_month]', 'D:\Contract\', NULL, 'y', 'billing_start_month', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'increment_period', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[increment_period]', 'D:\Contract\', NULL, 'y', 'increment_period', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'bookout_provision', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[bookout_provision]', 'D:\Contract\', NULL, 'y', 'bookout_provision', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'billing_from_hour', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[billing_from_hour]', 'D:\Contract\', NULL, 'y', 'billing_from_hour', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'billing_to_hour', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[billing_to_hour]', 'D:\Contract\', NULL, 'y', 'billing_to_hour', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'is_active', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[is_active]', 'D:\Contract\', NULL, 'y', 'is_active', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'flow_start_date', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[flow_start_date]', 'D:\Contract\', NULL, 'y', 'flow_start_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'flow_end_date', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[flow_end_date]', 'D:\Contract\', NULL, 'y', 'flow_end_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'capacity_release', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[capacity_release]', 'D:\Contract\', NULL, 'y', 'capacity_release', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'deal', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[deal]', 'D:\Contract\', NULL, 'y', 'deal', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'interruptible', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[interruptible]', 'D:\Contract\', NULL, 'y', 'interruptible', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_type', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[contract_type]', 'D:\Contract\', NULL, 'y', 'contract_type', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'base_load', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[base_load]', 'D:\Contract\', NULL, 'y', 'base_load', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'standard_contract', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[standard_contract]', 'D:\Contract\', NULL, 'y', 'standard_contract', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'firm', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[firm]', 'D:\Contract\', NULL, 'y', 'firm', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'neting_rule', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[neting_rule]', 'D:\Contract\', NULL, 'y', 'neting_rule', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'payment_days', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[payment_days]', 'D:\Contract\', NULL, 'y', 'payment_days', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'settlement_days', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[settlement_days]', 'D:\Contract\', NULL, 'y', 'settlement_days', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'self_billing', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[self_billing]', 'D:\Contract\', NULL, 'y', 'self_billing', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'billing_cycle', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'sdv_billing_cycle.[value_id]', 'D:\Contract\', NULL, 'y', 'billing_cycle', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'volume_granularity', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'sdv_vol_granularity.[value_id]', 'D:\Contract\', NULL, 'y', 'volume_granularity', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'invoice_due_date', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'sdv_payment_date.[value_id]', 'D:\Contract\', NULL, 'y', 'invoice_due_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'payment_calendar', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'sdv_payment_calendar.[value_id]', 'D:\Contract\', NULL, 'y', 'payment_calendar', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'settlement_calendar', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'sdv_settlement_calendar.[value_id]', 'D:\Contract\', NULL, 'y', 'settlement_calendar', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'settlement_date', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'sdv_settlement_date.[value_id]', 'D:\Contract\', NULL, 'y', 'settlement_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'hourly_block', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'cg.[hourly_block]', 'D:\Contract\', NULL, 'y', 'hourly_block', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_specialist', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'au_contract_specialist_cg.[user_login_id]', 'D:\Contract\', NULL, 'y', 'contract_specialist', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'settlement_accountant', NULL, 'Max', 'cg.source_system_id = 2', NULL, NULL, NULL, 'au_settlement_accountant_cg.[user_login_id]', 'D:\Contract\', NULL, 'y', 'settlement_accountant', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cg'
									WHERE it.ixp_tables_name = 'ixp_contract_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'group3', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sb_group3.[source_book_id]', 'D:\Contract\', NULL, 'y', 'group3', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'group4', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sb_group4.[source_book_id]', 'D:\Contract\', NULL, 'y', 'group4', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'leg', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[leg]', 'D:\Contract\', NULL, 'y', 'leg', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'include_invoice', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[include_invoice]', 'D:\Contract\', NULL, 'y', 'include_invoice', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'default_gl_code_cash_applied', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'agd_adjustment_default_gl_codes.[default_gl_id]', 'D:\Contract\', NULL, 'y', 'default_gl_code_cash_applied', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_id', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cg.[contract_id]', 'D:\Contract\', NULL, 'y', 'contract_id', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'invoice_line_item_id', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdv_invoice_line_item_id.[value_id]', 'D:\Contract\', NULL, 'y', 'invoice_line_item_id', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'default_gl_id', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'agc_default_gl_id.[default_gl_id]', 'D:\Contract\', NULL, 'y', 'default_gl_id', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'price', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[price]', 'D:\Contract\', NULL, 'y', 'price', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'formula_id', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[formula_id]', 'D:\Contract\', NULL, 'y', 'formula_id', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'manual', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[manual]', 'D:\Contract\', NULL, 'y', 'manual', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'currency', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sc_cgd_currency.[source_currency_id]', 'D:\Contract\', NULL, 'y', 'currency', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'Prod_type', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[Prod_type]', 'D:\Contract\', NULL, 'y', 'Prod_type', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'sequence_order', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[sequence_order]', 'D:\Contract\', NULL, 'y', 'sequence_order', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'inventory_item', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[inventory_item]', 'D:\Contract\', NULL, 'y', 'inventory_item', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'class_name', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'ssd_class_name.[value_id]', 'D:\Contract\', NULL, 'y', 'class_name', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'increment_peaking_name', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdv_increment_peaking_name.[value_id]', 'D:\Contract\', NULL, 'y', 'increment_peaking_name', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'product_type_name', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdv_product_type_name.[value_id]', 'D:\Contract\', NULL, 'y', 'product_type_name', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'rate_description', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[rate_description]', 'D:\Contract\', NULL, 'y', 'rate_description', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'units_for_rate', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdv_units_for_rate.[value_id]', 'D:\Contract\', NULL, 'y', 'units_for_rate', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'begin_date', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[begin_date]', 'D:\Contract\', NULL, 'y', 'begin_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'end_date', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[end_date]', 'D:\Contract\', NULL, 'y', 'end_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'default_gl_id_estimates', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'agc_default_gl_id_estimates_cgd.[default_gl_id]', 'D:\Contract\', NULL, 'y', 'default_gl_id_estimates', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'eqr_product_name', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdv_eqr_product_name_cgd.[value_id]', 'D:\Contract\', NULL, 'y', 'eqr_product_name', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'group_by', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdv_group_by_cgd.[value_id]', 'D:\Contract\', NULL, 'y', 'group_by', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'alias', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdv_alias.[value_id]', 'D:\Contract\', NULL, 'y', 'alias', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'hideInInvoice', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[hideInInvoice]', 'D:\Contract\', NULL, 'y', 'hideInInvoice', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'int_begin_month', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[int_begin_month]', 'D:\Contract\', NULL, 'y', 'int_begin_month', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'int_end_month', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[int_end_month]', 'D:\Contract\', NULL, 'y', 'int_end_month', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'volume_granularity', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdv_volume_granularity_cgd.[value_id]', 'D:\Contract\', NULL, 'y', 'volume_granularity', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'deal_type', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdt_deal_type_cgd.[source_deal_type_id]', 'D:\Contract\', NULL, 'y', 'deal_type', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'time_bucket_formula_id', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[time_bucket_formula_id]', 'D:\Contract\', NULL, 'y', 'time_bucket_formula_id', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'calc_aggregation', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdv_calc_aggregation_cgd.[value_id]', 'D:\Contract\', NULL, 'y', 'calc_aggregation', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'payment_date', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[payment_date]', 'D:\Contract\', NULL, 'y', 'payment_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'pnl_date', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdv_pnl_date_cgd.[value_id]', 'D:\Contract\', NULL, 'y', 'pnl_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'timeofuse', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdv_time_of_use.[value_id]', 'D:\Contract\', NULL, 'y', 'timeofuse', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'include_charges', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[include_charges]', 'D:\Contract\', NULL, 'y', 'include_charges', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_template', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cc_contract_template_cgd.[contract_charge_type_id]', 'D:\Contract\', NULL, 'y', 'contract_template', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'contract_component_template', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'ccd_contract_component_template_cgd.[ID]', 'D:\Contract\', NULL, 'y', 'contract_component_template', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'radio_automatic_manual', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[radio_automatic_manual]', 'D:\Contract\', NULL, 'y', 'radio_automatic_manual', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'settlement_date', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[settlement_date]', 'D:\Contract\', NULL, 'y', 'settlement_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'settlement_calendar', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sdv_settlement_calendar_cgd.[value_id]', 'D:\Contract\', NULL, 'y', 'settlement_calendar', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'effective_date', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'cgd.[effective_date]', 'D:\Contract\', NULL, 'y', 'effective_date', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'group1', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sb_group1.[source_book_id]', 'D:\Contract\', NULL, 'y', 'group1', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									 UNION ALL  SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, 'group2', NULL, NULL, 'cgd.[contract_id] IS NOT NULL', NULL, NULL, NULL, 'sb_group2.[source_book_id]', 'D:\Contract\', NULL, 'y', 'group2', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'contract_group_detail'
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cgd'
									WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
									
COMMIT 

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
					
				PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH
			END