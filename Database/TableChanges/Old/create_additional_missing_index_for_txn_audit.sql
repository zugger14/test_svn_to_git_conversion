/************************************************************
 Author: S Gupta 
 Date: 2014-01-10
 
 ************************************************************/

/*
Missing Index in Audit tables
*/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_detail_audit]') AND name = N'IX_PT_sdda1')
DROP INDEX [IX_PT_sdda1] ON [dbo].[source_deal_detail_audit] WITH ( ONLINE = OFF )
GO

CREATE NONCLUSTERED INDEX [IX_PT_sdda1]
ON [dbo].[source_deal_detail_audit] ([header_audit_id])
INCLUDE([audit_id])
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_detail_audit]') AND name = N'IX_PT_source_deal_detail_audit_source_deal_detail_id')
DROP INDEX [IX_PT_source_deal_detail_audit_source_deal_detail_id] ON [dbo].[source_deal_detail_audit] WITH ( ONLINE = OFF )
GO

CREATE INDEX [IX_PT_source_deal_detail_audit_source_deal_detail_id] ON 
[source_deal_detail_audit] ([source_deal_detail_id]) 
INCLUDE([audit_id])
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields_audit]') AND name = N'IX_PT_user_defined_deal_fields_audit_source_deal_header_id')
DROP INDEX [IX_PT_user_defined_deal_fields_audit_source_deal_header_id] ON [dbo].[user_defined_deal_fields_audit] WITH ( ONLINE = OFF )
GO

CREATE INDEX [IX_PT_user_defined_deal_fields_audit_source_deal_header_id] ON 
[user_defined_deal_fields_audit] ([source_deal_header_id]) 
INCLUDE([udf_audit_id])
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_counterparty]') AND name = N'IX_PT_source_counterparty_netting_parent_counterparty_id')
DROP INDEX [IX_PT_source_counterparty_netting_parent_counterparty_id] ON [dbo].[source_counterparty] WITH ( ONLINE = OFF )
GO

CREATE INDEX [IX_PT_source_counterparty_netting_parent_counterparty_id] ON 
[source_counterparty] ([netting_parent_counterparty_id])
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[contract_group]') AND name = N'IX_PT_contract_group_source_system_id')
DROP INDEX [IX_PT_contract_group_source_system_id] ON [dbo].[contract_group] WITH ( ONLINE = OFF )
GO

CREATE INDEX [IX_PT_contract_group_source_system_id] ON 
[contract_group] ([source_system_id]) INCLUDE(
                                                                                  [contract_id],
                                                                                  [contract_name],
                                                                                  [source_contract_id],
                                                                                  [contract_desc],
                                                                                  [create_user],
                                                                                  [create_ts],
                                                                                  [update_user],
                                                                                  [update_ts]
)
GO


IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_header]') AND name = N'IX_PT_source_deal_header_deal_id')
DROP INDEX [IX_PT_source_deal_header_deal_id] ON [dbo].[source_deal_header] WITH ( ONLINE = OFF )
GO


CREATE INDEX [IX_PT_source_deal_header_deal_id] ON [source_deal_header] ([deal_id]) 
INCLUDE(
           [source_deal_header_id],
           [physical_financial_flag],
           [header_buy_sell_flag],
           [term_frequency]
)
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_header]') AND name = N'IX_PT_source_deal_header_close_reference_id')
DROP INDEX [IX_PT_source_deal_header_close_reference_id] ON [dbo].[source_deal_header] WITH ( ONLINE = OFF )
GO

CREATE INDEX [IX_PT_source_deal_header_close_reference_id] ON 
[source_deal_header] ([close_reference_id]) 
INCLUDE([source_deal_header_id])
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields_audit]') AND name = N'IX_PT_user_defined_deal_fields_audit_source_deal_header_id_udf_audit_id')
DROP INDEX [IX_PT_user_defined_deal_fields_audit_source_deal_header_id_udf_audit_id] ON [dbo].[user_defined_deal_fields_audit] WITH ( ONLINE = OFF )
GO

CREATE INDEX 
[IX_PT_user_defined_deal_fields_audit_source_deal_header_id_udf_audit_id] ON 
[user_defined_deal_fields_audit] ([source_deal_header_id], [udf_audit_id])
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_counterparty]') AND name = N'IX_PT_source_counterparty_int_ext_flag')
DROP INDEX [IX_PT_source_counterparty_int_ext_flag] ON [dbo].[source_counterparty] WITH ( ONLINE = OFF )
GO

CREATE INDEX [IX_PT_source_counterparty_int_ext_flag] ON 
[source_counterparty] ([int_ext_flag]) INCLUDE(
                                                                                   [source_counterparty_id],
                                                                                   [counterparty_name],
                                                                                   [netting_parent_counterparty_id]
)
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_counterparty]') AND name = N'IX_PT_source_counterparty_int_ext_flag1')
DROP INDEX [IX_PT_source_counterparty_int_ext_flag1] ON [dbo].[source_counterparty] WITH ( ONLINE = OFF )
GO

CREATE INDEX [IX_PT_source_counterparty_int_ext_flag1] ON 
[source_counterparty] ([int_ext_flag]) INCLUDE(
                                                                                   [source_counterparty_id],
                                                                                   [source_system_id],
                                                                                   [counterparty_name],
                                                                                   [counterparty_desc],
                                                                                   [create_user],
                                                                                   [create_ts],
                                                                                   [update_user],
                                                                                   [update_ts]
)
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_counterparty]') AND name = N'IX_PT_source_counterparty_int_ext_flag2')
DROP INDEX [IX_PT_source_counterparty_int_ext_flag2] ON [dbo].[source_counterparty] WITH ( ONLINE = OFF )
GO

CREATE INDEX [IX_PT_source_counterparty_int_ext_flag2] ON 
[source_counterparty] ([int_ext_flag]) INCLUDE(
                                                                                   [source_counterparty_id],
                                                                                   [source_system_id],
                                                                                   [counterparty_name]
)
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_header_audit]') AND name = N'IX_PT_source_deal_header_audit_user_action_update_ts')
DROP INDEX [IX_PT_source_deal_header_audit_user_action_update_ts] ON [dbo].[source_deal_header_audit] WITH ( ONLINE = OFF )
GO


CREATE INDEX [IX_PT_source_deal_header_audit_user_action_update_ts] ON 
[source_deal_header_audit] ([user_action], [update_ts]) 
INCLUDE(
           [audit_id],
           [source_deal_header_id],
           [source_system_book_id1],
           [source_system_book_id2],
           [source_system_book_id3],
           [source_system_book_id4]
)
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_header_audit]') AND name = N'IX_PT_source_deal_header_audit_update_ts')
DROP INDEX [IX_PT_source_deal_header_audit_update_ts] ON [dbo].[source_deal_header_audit] WITH ( ONLINE = OFF )
GO


CREATE INDEX [IX_PT_source_deal_header_audit_update_ts] ON 
[source_deal_header_audit] ([update_ts]) 
INCLUDE([audit_id], [source_deal_header_id])
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_detail_audit]') AND name = N'IX_PT_source_deal_detail_audit_source_deal_detail_id_header_audit_id')
DROP INDEX [IX_PT_source_deal_detail_audit_source_deal_detail_id_header_audit_id] ON [dbo].[source_deal_detail_audit] WITH ( ONLINE = OFF )
GO

CREATE INDEX 
[IX_PT_source_deal_detail_audit_source_deal_detail_id_header_audit_id] ON 
[source_deal_detail_audit] ([source_deal_detail_id], [header_audit_id]) 
INCLUDE(
           [source_deal_header_id],
           [term_start],
           [term_end],
           [Leg],
           [contract_expiration_date],
           [fixed_float_leg],
           [buy_sell_flag],
           [curve_id],
           [fixed_price],
           [fixed_price_currency_id],
           [option_strike_price],
           [deal_volume],
           [deal_volume_frequency],
           [deal_volume_uom_id],
           [block_description],
           [deal_detail_description],
           [settlement_volume],
           [settlement_uom],
           [update_user],
           [update_ts],
           [price_adder],
           [price_multiplier],
           [settlement_date],
           [day_count_id],
           [location_id],
           [physical_financial_flag],
           [Booked],
           [fixed_cost],
           [multiplier],
           [adder_currency_id],
           [fixed_cost_currency_id],
           [formula_currency_id],
           [price_adder2],
           [price_adder_currency2],
           [volume_multiplier2],
           [pay_opposite],
           [formula_text],
           [capacity],
           [meter_id],
           [settlement_currency],
           [standard_yearly_volume],
           [price_uom_id],
           [category],
           [profile_code],
           [pv_party],
           [status],
           [lock_deal_detail]
)
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_detail_audit]') AND name = N'IX_PT_source_deal_detail_audit_header_audit_id')
DROP INDEX [IX_PT_source_deal_detail_audit_header_audit_id] ON [dbo].[source_deal_detail_audit] WITH ( ONLINE = OFF )
GO

CREATE INDEX [IX_PT_source_deal_detail_audit_header_audit_id] ON 
[source_deal_detail_audit] ([header_audit_id]) 
INCLUDE(
           [source_deal_detail_id],
           [term_start],
           [term_end],
           [contract_expiration_date],
           [fixed_float_leg],
           [buy_sell_flag],
           [curve_id],
           [fixed_price],
           [fixed_price_currency_id],
           [option_strike_price],
           [deal_volume],
           [deal_volume_frequency],
           [deal_volume_uom_id],
           [block_description],
           [deal_detail_description],
           [settlement_volume],
           [settlement_uom],
           [price_adder],
           [price_multiplier],
           [settlement_date],
           [day_count_id],
           [location_id],
           [physical_financial_flag],
           [Booked],
           [fixed_cost],
           [multiplier],
           [adder_currency_id],
           [fixed_cost_currency_id],
           [formula_currency_id],
           [price_adder2],
           [price_adder_currency2],
           [volume_multiplier2],
           [pay_opposite],
           [formula_text],
           [capacity],
           [meter_id],
           [settlement_currency],
           [standard_yearly_volume],
           [price_uom_id],
           [category],
           [profile_code],
           [pv_party],
           [status],
           [lock_deal_detail]
)
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields_audit]') AND name = N'IX_PT_user_defined_deal_fields_audit_header_audit_id')
DROP INDEX [IX_PT_user_defined_deal_fields_audit_header_audit_id] ON [dbo].[user_defined_deal_fields_audit] WITH ( ONLINE = OFF )
GO

CREATE INDEX [IX_PT_user_defined_deal_fields_audit_header_audit_id] ON 
[user_defined_deal_fields_audit] ([header_audit_id]) 


INCLUDE([udf_template_id])
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_deal_detail_fields_audit]') AND name = N'IX_PT_user_defined_deal_detail_fields_audit_header_audit_id')
DROP INDEX [IX_PT_user_defined_deal_detail_fields_audit_header_audit_id] ON [dbo].[user_defined_deal_detail_fields_audit] WITH ( ONLINE = OFF )
GO

CREATE INDEX [IX_PT_user_defined_deal_detail_fields_audit_header_audit_id] ON 
[user_defined_deal_detail_fields_audit] ([header_audit_id]) 
INCLUDE([udf_template_id])
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields_audit]') AND name = N'IX_PT_user_defined_deal_fields_audit_source_deal_header_id_header_audit_id')
DROP INDEX [IX_PT_user_defined_deal_fields_audit_source_deal_header_id_header_audit_id] ON [dbo].[user_defined_deal_fields_audit] WITH ( ONLINE = OFF )
GO

CREATE INDEX 
[IX_PT_user_defined_deal_fields_audit_source_deal_header_id_header_audit_id] ON 
[user_defined_deal_fields_audit] ([source_deal_header_id], [header_audit_id])
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_deal_detail_fields_audit]') AND name = N'IX_PT_user_defined_deal_detail_fields_audit_source_deal_detail_id_header_audit_id')
DROP INDEX [IX_PT_user_defined_deal_detail_fields_audit_source_deal_detail_id_header_audit_id] ON [dbo].[user_defined_deal_detail_fields_audit] WITH ( ONLINE = OFF )
GO

CREATE INDEX 
[IX_PT_user_defined_deal_detail_fields_audit_source_deal_detail_id_header_audit_id] 
ON [user_defined_deal_detail_fields_audit] ([source_deal_detail_id], [header_audit_id])
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_header_audit]') AND name = N'IX_PT_SDHA11')
DROP INDEX [IX_PT_SDHA11] ON [dbo].[source_deal_header_audit] WITH ( ONLINE = OFF )
GO
CREATE NONCLUSTERED INDEX [IX_PT_SDHA11]
ON [dbo].[source_deal_header_audit] ([source_system_book_id1],[source_system_book_id2],[source_system_book_id3],[source_system_book_id4])
INCLUDE ([source_deal_header_id],[user_action])
GO