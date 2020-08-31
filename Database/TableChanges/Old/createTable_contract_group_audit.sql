SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[contract_group_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[contract_group_audit]
    (
    	[audit_id]                             [INT] IDENTITY(1, 1) NOT NULL,
    	[contract_id]                          [int] NOT NULL,
    	[sub_id]                               [int] NULL,
    	[contract_name]                        [varchar](50) NULL,
    	[contract_date]                        [datetime] NULL,
    	[receive_invoice]                      [char](1) NULL,
    	[settlement_accountant]                [varchar](50) NULL,
    	[billing_cycle]                        [int] NULL,
    	[invoice_due_date]                     [int] NULL,
    	[volume_granularity]                   [int] NULL,
    	[hourly_block]                         [int] NULL,
    	[currency]                             [int] NULL,
    	[volume_mult]                          [float] NULL,
    	[onpeak_mult]                          [float] NULL,
    	[offpeak_mult]                         [float] NULL,
    	[type]                                 [char](1) NULL,
    	[reverse_entries]                      [char](1) NULL,
    	[volume_uom]                           [int] NULL,
    	[rec_uom]                              [int] NULL,
    	[contract_specialist]                  [varchar](50) NULL,
    	[term_start]                           [datetime] NULL,
    	[term_end]                             [datetime] NULL,
    	[name]                                 [varchar](50) NULL,
    	[company]                              [varchar](100) NULL,
    	[state]                                [int] NULL,
    	[city]                                 [varchar](50) NULL,
    	[zip]                                  [varchar](50) NULL,
    	[address]                              [varchar](50) NULL,
    	[address2]                             [char](10) NULL,
    	[telephone]                            [varchar](50) NULL,
    	[email]                                [varchar](50) NULL,
    	[fax]                                  [varchar](50) NULL,
    	[name2]                                [varchar](50) NULL,
    	[company2]                             [varchar](100) NULL,
    	[telephone2]                           [varchar](50) NULL,
    	[fax2]                                 [varchar](50) NULL,
    	[email2]                               [varchar](50) NULL,
    	[source_contract_id]                   [varchar](50) NULL,
    	[source_system_id]                     [int] NULL,
    	[contract_desc]                        [varchar](150) NULL,
    	[create_user]                          [varchar](50) NULL,
    	[create_ts]                            [datetime] NULL,
    	[update_user]                          [varchar](50) NULL,
    	[update_ts]                            [datetime] NULL,
    	[energy_type]                          [char](1) NULL,
    	[area_engineer]                        [varchar](100) NULL,
    	[metering_contract]                    [varchar](50) NULL,
    	[miso_queue_number]                    [varchar](50) NULL,
    	[substation_name]                      [varchar](100) NULL,
    	[project_county]                       [varchar](50) NULL,
    	[voltage]                              [varchar](50) NULL,
    	[time_zone]                            [int] NULL,
    	[contract_service_agreement_id]        [varchar](50) NULL,
    	[contract_charge_type_id]              [int] NULL,
    	[billing_from_date]                    [int] NULL,
    	[billing_to_date]                      [int] NULL,
    	[contract_report_template]             [int] NULL,
    	[Subledger_code]                       [varchar](20) NULL,
    	[UD_Contract_id]                       [varchar](50) NULL,
    	[extension_provision_description]      [varchar](100) NULL,
    	[term_name]                            [varchar](50) NULL,
    	[increment_name]                       [varchar](50) NULL,
    	[ferct_tarrif_reference]               [varchar](50) NULL,
    	[point_of_delivery_control_area]       [varchar](100) NULL,
    	[point_of_delivery_specific_location]  [varchar](100) NULL,
    	[contract_affiliate]                   [varchar](1) NULL,
    	[point_of_receipt_control_area]        [varchar](100) NULL,
    	[point_of_receipt_specific_location]   [varchar](100) NULL,
    	[no_meterdata]                         [varchar](1) NULL,
    	[billing_start_month]                  [int] NULL,
    	[increment_period]                     [int] NULL,
    	[bookout_provision]                    [char](1) NULL,
    	[contract_status]                      [int] NULL,
    	[holiday_calender_id]                  [int] NULL,
    	[holiday_calendar_id]                  [int] NULL,
    	[billing_from_hour]                    [int] NULL,
    	[billing_to_hour]                      [int] NULL,
    	[block_type]                           [int] NULL,
    	[is_active]                            [char](1) NULL,
    	[payment_calendar]                     [int] NULL,
    	[pnl_date]                             [int] NULL,
    	[pnl_calendar]                         [int] NULL,
    	[user_action]                          [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table contract_group_audit EXISTS'
END

GO

