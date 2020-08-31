
IF COL_LENGTH('source_deal_header_audit', 'formula_change') IS NULL
alter table [source_deal_header_audit] add formula_change varchar(1),mtm_effect_field varchar(1)


alter table dbo.explain_delivered_mtm alter column pnl_conversion_factor float