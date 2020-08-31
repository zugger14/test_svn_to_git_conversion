IF EXISTS (
       SELECT *
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[Master_Deal_View]')
   )
    ALTER FULLTEXT INDEX ON [dbo].[Master_Deal_View] DISABLE
GO

IF EXISTS (
       SELECT *
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[Master_Deal_View]')
   )
    DROP FULLTEXT INDEX ON [dbo].[Master_Deal_View]

GO

IF EXISTS (
       SELECT *
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[portfolio_hierarchy]')
   )
    ALTER FULLTEXT INDEX ON [dbo].[portfolio_hierarchy] DISABLE
GO

IF EXISTS (
       SELECT *
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[portfolio_hierarchy]')
   )
    DROP FULLTEXT INDEX ON [dbo].[portfolio_hierarchy]

GO

IF EXISTS (
       SELECT *
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[source_counterparty]')
   )
    ALTER FULLTEXT INDEX ON [dbo].[source_counterparty] DISABLE
GO

IF EXISTS (SELECT * FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[source_counterparty]'))
    DROP FULLTEXT INDEX ON [dbo].[source_counterparty]
GO


IF EXISTS (
       SELECT *
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[source_minor_location]')
   )
    ALTER FULLTEXT INDEX ON [dbo].[source_minor_location] DISABLE
GO

IF EXISTS (SELECT * FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[source_minor_location]'))
    DROP FULLTEXT INDEX ON [dbo].[source_minor_location]
GO

IF EXISTS (
       SELECT *
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[source_commodity]')
   )
    ALTER FULLTEXT INDEX ON [dbo].[source_commodity] DISABLE
GO

IF EXISTS (SELECT * FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[source_commodity]'))
    DROP FULLTEXT INDEX ON [dbo].[source_commodity]
GO

IF EXISTS (
       SELECT *
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[workflow_activities_audit_summary]')
   )
    ALTER FULLTEXT INDEX ON [dbo].[workflow_activities_audit_summary] DISABLE
GO

IF EXISTS (SELECT * FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[workflow_activities_audit_summary]'))
    DROP FULLTEXT INDEX ON [dbo].[workflow_activities_audit_summary]
GO


IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[counterparty_bank_info]'))   
BEGIN        
	ALTER FULLTEXT INDEX ON [dbo].[counterparty_bank_info] DISABLE         
	DROP FULLTEXT INDEX ON [dbo].[counterparty_bank_info]     
END  
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[contract_group]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[contract_group] DISABLE         
	DROP FULLTEXT INDEX ON [dbo].[contract_group]     
END   
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_counterparty_contract_address]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[master_view_counterparty_contract_address] DISABLE         
	DROP FULLTEXT INDEX ON [dbo].[master_view_counterparty_contract_address]     
END   
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_counterparty_credit_info]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_info] DISABLE         
	DROP FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_info]     
END   
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[email_notes]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[email_notes] DISABLE         
	DROP FULLTEXT INDEX ON [dbo].[email_notes]     
END   
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_counterparty_credit_enhancements]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_enhancements] DISABLE         
	DROP FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_enhancements]     
END   
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[application_notes]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[application_notes] DISABLE         
	DROP FULLTEXT INDEX ON [dbo].[application_notes]     
END   
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_counterparty_credit_limits]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_limits] DISABLE         
	DROP FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_limits]     
END   
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[attachment_detail_info]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[attachment_detail_info] DISABLE         
	DROP FULLTEXT INDEX ON [dbo].[attachment_detail_info]     
END   
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_counterparty_epa_account]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[master_view_counterparty_epa_account] DISABLE         
	DROP FULLTEXT INDEX ON [dbo].[master_view_counterparty_epa_account]     
END   
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_counterparty_products]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[master_view_counterparty_products] DISABLE        
	DROP FULLTEXT INDEX ON [dbo].[master_view_counterparty_products]     
END  
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_counterparty_credit_migration]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_migration] DISABLE       
	DROP FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_migration]     
END   
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_counterparty_contacts]'))   
BEGIN        
	ALTER FULLTEXT INDEX ON [dbo].[master_view_counterparty_contacts] DISABLE       
	DROP FULLTEXT INDEX ON [dbo].[master_view_counterparty_contacts]    
END   
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_incident_log]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[master_view_incident_log] DISABLE        
	DROP FULLTEXT INDEX ON [dbo].[master_view_incident_log]     
END  
GO  

IF EXISTS (SELECT 1 FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_incident_log_detail]'))   
BEGIN         
	ALTER FULLTEXT INDEX ON [dbo].[master_view_incident_log_detail] DISABLE        
	DROP FULLTEXT INDEX ON [dbo].[master_view_incident_log_detail]     
END   
GO  

IF EXISTS (
       SELECT *
       FROM   sysfulltextcatalogs ftc
       WHERE  ftc.name = N'TRMTrackerFTI'
   )
     DROP FULLTEXT CATALOG [TRMTrackerFTI]
GO

CREATE FULLTEXT CATALOG [TRMTrackerFTI] WITH ACCENT_SENSITIVITY = ON
AUTHORIZATION [dbo]
GO

IF NOT EXISTS (
       SELECT 1
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[source_counterparty]')
   )
    CREATE FULLTEXT INDEX ON [dbo].[source_counterparty](
        [counterparty_desc] LANGUAGE [English],
        [counterparty_id] LANGUAGE [English],
        [counterparty_name] LANGUAGE [English]
    )
    KEY INDEX [PK_source_counterparty]ON ([TRMTrackerFTI], FILEGROUP [PRIMARY])
--WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
GO

IF NOT EXISTS (
       SELECT 1
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[portfolio_hierarchy]')
   )
    CREATE FULLTEXT INDEX ON [dbo].[portfolio_hierarchy]([entity_name] LANGUAGE [English])
    KEY INDEX [PK_portfolio_hierarchy]ON ([TRMTrackerFTI], FILEGROUP [PRIMARY])
--WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
GO

IF NOT EXISTS (
       SELECT 1
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[source_minor_location]')
   )
    CREATE FULLTEXT INDEX ON [dbo].[source_minor_location](
        [Location_Name] LANGUAGE [English],
        [Location_Description] LANGUAGE [English]
    )
    KEY INDEX [PK_source_minor_location]ON ([TRMTrackerFTI], FILEGROUP [PRIMARY])
--WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
GO

IF NOT EXISTS (
       SELECT 1
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[source_commodity]')
   )
    CREATE FULLTEXT INDEX ON [dbo].[source_commodity](
        [commodity_id] LANGUAGE [English],
        [commodity_name] LANGUAGE [English],
        [commodity_desc] LANGUAGE [English]
    )
    KEY INDEX [PK_source_commodity]ON ([TRMTrackerFTI], FILEGROUP [PRIMARY])
--WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
GO

IF NOT EXISTS (SELECT 1 FROM sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_deal_view]'))
	CREATE FULLTEXT INDEX ON [dbo].[master_deal_view](
	[assigned_user] LANGUAGE [English], 
	[assignment_type] LANGUAGE [English], 
	[block_definition] LANGUAGE [English], 
	[block_type] LANGUAGE [English], 
	[Book] LANGUAGE [English], 
	[broker] LANGUAGE [English], 
	[buy_sell] LANGUAGE [English], 
	[commodity] LANGUAGE [English], 
	[confirm_status_type] LANGUAGE [English], 
	[contract] LANGUAGE [English], 
	[counterparty] LANGUAGE [English], 
	[create_user] LANGUAGE [English], 
	[deal_category] LANGUAGE [English], 
	[deal_formula] LANGUAGE [English], 
	[deal_id] LANGUAGE [English], 
	[deal_profile] LANGUAGE [English], 
	[deal_status] LANGUAGE [English], 
	[deal_sub_type] LANGUAGE [English], 
	[deal_type] LANGUAGE [English], 
	[description1] LANGUAGE [English], 
	[description2] LANGUAGE [English], 
	[description3] LANGUAGE [English], 
	[expiration_calendar] LANGUAGE [English], 
	[ext_deal_id] LANGUAGE [English], 
	[fixation_type] LANGUAGE [English], 
	[fixed_float] LANGUAGE [English], 
	[forecast_profile] LANGUAGE [English], 
	[forecast_proxy_profile] LANGUAGE [English], 
	[generator] LANGUAGE [English], 
	[granularity] LANGUAGE [English], 
	[index_commodity] LANGUAGE [English], 
	[index_currency] LANGUAGE [English], 
	[index_name] LANGUAGE [English], 
	[index_proxy1] LANGUAGE [English], 
	[index_proxy2] LANGUAGE [English], 
	[index_proxy3] LANGUAGE [English], 
	[index_settlement] LANGUAGE [English], 
	[index_uom] LANGUAGE [English], 
	[internal_deal_subtype] LANGUAGE [English], 
	[internal_deal_type] LANGUAGE [English], 
	[internal_portfolio] LANGUAGE [English], 
	[legal_entity] LANGUAGE [English], 
	[location] LANGUAGE [English], 
	[location_country] LANGUAGE [English], 
	[location_grid] LANGUAGE [English], 
	[location_group] LANGUAGE [English], 
	[location_region] LANGUAGE [English], 
	[locked_deal] LANGUAGE [English], 
	[meter] LANGUAGE [English], 
	[option_excercise_type] LANGUAGE [English], 
	[option_flag] LANGUAGE [English], 
	[option_type] LANGUAGE [English], 
	[parent_counterparty] LANGUAGE [English], 
	[physical_financial] LANGUAGE [English], 
	[Pr_party] LANGUAGE [English], 
	[pricing] LANGUAGE [English], 
	[profile_code] LANGUAGE [English], 
	[profile_type] LANGUAGE [English], 
	[proxy_profile_type] LANGUAGE [English], 
	[reference] LANGUAGE [English], 
	[source_system_book_id1] LANGUAGE [English], 
	[source_system_book_id2] LANGUAGE [English], 
	[source_system_book_id3] LANGUAGE [English], 
	[source_system_book_id4] LANGUAGE [English], 
	[strategy] LANGUAGE [English], 
	[structured_deal_id] LANGUAGE [English], 
	[subsidiary] LANGUAGE [English], 
	[template] LANGUAGE [English], 
	[trader] LANGUAGE [English], 
	[update_user] LANGUAGE [English],
	[deal_date_varchar] LANGUAGE [English],
	[entire_term_start_varchar] LANGUAGE [English],
	[entire_term_end_varchar] LANGUAGE [English],
	[UDF] LANGUAGE [English],
	[source_deal_header_id] LANGUAGE [English],
	[reporting_group1] LANGUAGE [English],
	[reporting_group2] LANGUAGE [English],
	[reporting_group3] LANGUAGE [English],
	[reporting_group4] LANGUAGE [English],
	[reporting_group5] LANGUAGE [English]
	)
	KEY INDEX [PK_master_deal_view] ON ([TRMTrackerFTI], FILEGROUP [PRIMARY])
	--WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
GO
	
 
IF NOT EXISTS (
       SELECT 1
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[workflow_activities_audit_summary]')
   )
    CREATE FULLTEXT INDEX ON [dbo].[workflow_activities_audit_summary](
        [source_name] LANGUAGE [English],
        [source_id] LANGUAGE [English],
        [activity_name] LANGUAGE [English],
        [activity_detail] LANGUAGE [English],
        [run_as_of_date] LANGUAGE [English],
        [prior_status] LANGUAGE [English],
        [current_status] LANGUAGE [English],
        [activity_description] LANGUAGE [English],
        [run_by] LANGUAGE [English],
        [activity_create_date] LANGUAGE [English]
    )
    KEY INDEX [PK_workflow_activities_audit_summary] ON ([TRMTrackerFTI], FILEGROUP [PRIMARY])
--WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
GO