
CREATE TABLE [dbo].[dedesignated_link_deal]
(
[rowid] [int] NOT NULL IDENTITY(1, 1),
[dedesignation_date] [datetime] NULL,
[link_id] [int] NULL,
[source_deal_header_id] [int] NULL,
[per_dedesignation] [float] NULL,
[volume_used] [float] NULL,
[hedged_item_deal] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[process_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_ts] [datetime] NULL CONSTRAINT [DF_dedesignated_link_deal_create_ts] DEFAULT (getdate()),
[create_usr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_dedesignated_link_deal_create_usr] DEFAULT ([dbo].[fnadbuser]())
)
GO
ALTER TABLE [dbo].[dedesignated_link_deal] ADD CONSTRAINT [PK_dedesignated_link_deal] PRIMARY KEY CLUSTERED ([rowid])
GO
CREATE NONCLUSTERED INDEX [idx_dedesignated_link_deal_link_id] ON [dbo].[dedesignated_link_deal] ([link_id])
GO
CREATE NONCLUSTERED INDEX [idx_dedesignated_link_deal_header_id] ON [dbo].[dedesignated_link_deal] ([source_deal_header_id])
GO


CREATE TABLE [dbo].[exclude_deal_auto_matching]
(
[rowid] [int] NOT NULL IDENTITY(1, 1),
[source_deal_header_id1] [int] NULL,
[source_deal_header_id2] [int] NULL,
[exclude_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[create_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_ts] [datetime] NULL,
[update_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_ts] [datetime] NULL
)
GO
ALTER TABLE [dbo].[exclude_deal_auto_matching] ADD CONSTRAINT [PK_exclude_deal_auto_matching] PRIMARY KEY CLUSTERED ([rowid])
GO

--CREATE TABLE [dbo].[exclude_deal_auto_matching]
--(
--[rowid] [int] NOT NULL IDENTITY(1, 1),
--[source_deal_header_id1] [int] NULL,
--[source_deal_header_id2] [int] NULL,
--[exclude_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
--[create_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
--[create_ts] [datetime] NULL,
--[update_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
--[update_ts] [datetime] NULL
--)
--GO
--ALTER TABLE [dbo].[exclude_deal_auto_matching] ADD CONSTRAINT [PK_exclude_deal_auto_matching] PRIMARY KEY CLUSTERED ([rowid])
--GO
CREATE TABLE [dbo].[inventory_cost_override]
(
[inventory_cost_id] [int] NOT NULL IDENTITY(1, 1),
[source_deal_header_id] [int] NOT NULL,
[price] [float] NULL,
[fixed_cost] [float] NULL,
[create_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_ts] [datetime] NULL,
[update_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_ts] [datetime] NULL
)
GO
ALTER TABLE [dbo].[inventory_cost_override] ADD CONSTRAINT [PK_inventory_cost_override] PRIMARY KEY CLUSTERED ([inventory_cost_id])
GO
ALTER TABLE [dbo].[inventory_cost_override] WITH NOCHECK ADD CONSTRAINT [FK_inventory_cost_override_source_deal_header] FOREIGN KEY ([source_deal_header_id]) REFERENCES [dbo].[source_deal_header] ([source_deal_header_id]) ON DELETE CASCADE


GO
CREATE TABLE [dbo].[manual_je_header]
(
[manual_je_id] [int] NOT NULL IDENTITY(1, 1),
[as_of_date] [datetime] NOT NULL,
[book_id] [int] NULL,
[frequency] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[until_date] [datetime] NULL,
[dr_cr_match] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[create_ts] [datetime] NULL,
[create_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_ts] [datetime] NULL,
[update_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [dbo].[manual_je_header] ADD CONSTRAINT [PK_manual_je_header] PRIMARY KEY CLUSTERED ([manual_je_id])
GO

--GO
--CREATE TABLE [dbo].[manual_je_detail]
--(
--[manual_je_detail_id] [int] NOT NULL IDENTITY(1, 1),
--[manual_je_id] [int] NOT NULL,
--[gl_account_id] [int] NULL,
--[volume] [float] NULL,
--[uom] [int] NULL,
--[debit_amount] [float] NULL,
--[credit_amount] [float] NULL,
--[frequency] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
--[until_date] [datetime] NULL,
--[create_inventory] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
--[generator_id] [int] NULL,
--[create_ts] [datetime] NULL,
--[create_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
--[update_ts] [datetime] NULL,
--[update_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
--[gl_number_id] [int] NULL
--)
--GO
--ALTER TABLE [dbo].[manual_je_detail] ADD CONSTRAINT [PK_manual_je_detail] PRIMARY KEY CLUSTERED ([manual_je_detail_id])
--GO
--ALTER TABLE [dbo].[manual_je_detail] WITH NOCHECK ADD CONSTRAINT [FK_manual_je_detail_manual_je_header] FOREIGN KEY ([manual_je_id]) REFERENCES [dbo].[manual_je_header] ([manual_je_id]) ON DELETE CASCADE
--GO
CREATE TABLE [dbo].[manual_je_detail]
(
[manual_je_detail_id] [int] NOT NULL IDENTITY(1, 1),
[manual_je_id] [int] NOT NULL,
[gl_account_id] [int] NULL,
[volume] [float] NULL,
[uom] [int] NULL,
[debit_amount] [float] NULL,
[credit_amount] [float] NULL,
[frequency] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[until_date] [datetime] NULL,
[create_inventory] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[generator_id] [int] NULL,
[create_ts] [datetime] NULL,
[create_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_ts] [datetime] NULL,
[update_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_number_id] [int] NULL
)
GO
ALTER TABLE [dbo].[manual_je_detail] ADD CONSTRAINT [PK_manual_je_detail] PRIMARY KEY CLUSTERED ([manual_je_detail_id])
GO
ALTER TABLE [dbo].[manual_je_detail] WITH NOCHECK ADD CONSTRAINT [FK_manual_je_detail_manual_je_header] FOREIGN KEY ([manual_je_id]) REFERENCES [dbo].[manual_je_header] ([manual_je_id]) ON DELETE CASCADE
--GO
--CREATE TABLE [dbo].[manual_je_detail]
--(
--[manual_je_detail_id] [int] NOT NULL IDENTITY(1, 1),
--[manual_je_id] [int] NOT NULL,
--[gl_account_id] [int] NULL,
--[volume] [float] NULL,
--[uom] [int] NULL,
--[debit_amount] [float] NULL,
--[credit_amount] [float] NULL,
--[frequency] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
--[until_date] [datetime] NULL,
--[create_inventory] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
--[generator_id] [int] NULL,
--[create_ts] [datetime] NULL,
--[create_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
--[update_ts] [datetime] NULL,
--[update_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
--[gl_number_id] [int] NULL
--)
--GO
--ALTER TABLE [dbo].[manual_je_detail] ADD CONSTRAINT [PK_manual_je_detail] PRIMARY KEY CLUSTERED ([manual_je_detail_id])
--GO
--ALTER TABLE [dbo].[manual_je_detail] WITH NOCHECK ADD CONSTRAINT [FK_manual_je_detail_manual_je_header] FOREIGN KEY ([manual_je_id]) REFERENCES [dbo].[manual_je_header] ([manual_je_id]) ON DELETE CASCADE
--GO

CREATE TABLE [dbo].[module_asofdate]
(
[module_type] [int] NOT NULL,
[as_of_date] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [dbo].[module_asofdate] ADD CONSTRAINT [pk_module_type] PRIMARY KEY CLUSTERED ([module_type])
GO
ALTER TABLE [dbo].[module_asofdate] WITH NOCHECK ADD CONSTRAINT [fk_module_type] FOREIGN KEY ([module_type]) REFERENCES [dbo].[static_data_value] ([value_id]) ON DELETE CASCADE
GO

CREATE TABLE [dbo].[price_curve_fv_mapping]
(
[spc_fv_id] [int] NOT NULL IDENTITY(1, 1),
[description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[source_curve_def_id] [int] NOT NULL,
[fv_reporting_group_id] [int] NOT NULL,
[effective_date] [datetime] NULL,
[from_no_of_months] [int] NULL,
[to_no_of_months] [int] NULL,
[create_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_ts] [datetime] NULL,
[update_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_ts] [datetime] NULL
)
GO
CREATE TRIGGER [dbo].[TRGINS_price_curve_fv_mapping]
ON [dbo].[price_curve_fv_mapping]
FOR INSERT
AS
UPDATE price_curve_fv_mapping SET create_user =dbo.FNADBUser(), create_ts = getdate() where  price_curve_fv_mapping.spc_fv_id in (select spc_fv_id from inserted)






GO

CREATE TRIGGER [dbo].[TRGUPD_price_curve_fv_mapping]
ON [dbo].[price_curve_fv_mapping]
FOR UPDATE
AS
UPDATE price_curve_fv_mapping SET update_user = dbo.FNADBUser(), update_ts = getdate() where  price_curve_fv_mapping.spc_fv_id in (select spc_fv_id from deleted)





GO
ALTER TABLE [dbo].[price_curve_fv_mapping] ADD CONSTRAINT [PK_price_curve_fv_mapping] PRIMARY KEY CLUSTERED ([spc_fv_id])
GO
ALTER TABLE [dbo].[price_curve_fv_mapping] WITH NOCHECK ADD CONSTRAINT [FK_price_curve_fv_mapping_source_price_curve_def] FOREIGN KEY ([source_curve_def_id]) REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
ALTER TABLE [dbo].[price_curve_fv_mapping] WITH NOCHECK ADD CONSTRAINT [FK_price_curve_fv_mapping_static_data_value] FOREIGN KEY ([fv_reporting_group_id]) REFERENCES [dbo].[static_data_value] ([value_id])
GO

CREATE TABLE [dbo].[stage_ddf]
(
[fileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[source_deal_header_id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[maturity] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[market_price] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_factor] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[create_user] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_ts] [datetime] NULL
)
GO



ALTER TABLE [dbo].[counterparty_credit_info] ADD [payment_contact_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL

GO

ALTER TABLE [dbo].[calcprocess_aoci_release] ADD
[d_aoci] [float] NULL

GO
GO
ALTER TABLE [dbo].[calcprocess_aoci_release_arch1] ADD
[d_aoci] [float] NULL
GO
GO
ALTER TABLE [dbo].[calcprocess_aoci_release_arch2] ADD
[d_aoci] [float] NULL
GO

GO
ALTER TABLE [dbo].[calcprocess_deals] ADD
[d_aoci] [float] NULL,
[d_pnl_ineffectiveness] [float] NULL,
[d_extrinsic_pnl] [float] NULL,
[d_pnl_mtm] [float] NULL,
[dis_pnl] [float] NULL
GO

GO
ALTER TABLE [dbo].[calcprocess_deals_arch1] ADD
[d_aoci] [float] NULL,
[d_pnl_ineffectiveness] [float] NULL,
[d_extrinsic_pnl] [float] NULL,
[d_pnl_mtm] [float] NULL,
[dis_pnl] [float] NULL
GO

ALTER TABLE [dbo].[calcprocess_deals_arch2] ADD
[d_aoci] [float] NULL,
[d_pnl_ineffectiveness] [float] NULL,
[d_extrinsic_pnl] [float] NULL,
[d_pnl_mtm] [float] NULL,
[dis_pnl] [float] NULL
GO

GO
ALTER TABLE [dbo].[calcprocess_deals_expired] ADD
[d_aoci] [float] NULL,
[d_pnl_ineffectiveness] [float] NULL,
[d_extrinsic_pnl] [float] NULL,
[d_pnl_mtm] [float] NULL,
[dis_pnl] [float] NULL
GO

GO
ALTER TABLE [dbo].[connection_string] ADD
[import_path] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO

GO
ALTER TABLE [dbo].[deal_voided_in_external] ADD
[source_deal_header_id] [int] NULL
GO

GO
ALTER TABLE [dbo].[fas_books] ADD
[hedge_item_same_sign] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO

GO
create TRIGGER [dbo].[TRGdel_FAS_LINK_HEADER]
ON [dbo].[fas_link_header]
FOR delete
AS
delete [dbo].[dedesignated_link_deal] from [dbo].[dedesignated_link_deal] d_l inner join deleted d 
on d_l.link_id=d.link_id 
delete [dbo].[dedesignated_link_deal] from [dbo].[dedesignated_link_deal] d_l inner join deleted d 
on d_l.link_id=d.original_link_id 



GO
ALTER TABLE [dbo].[source_deal_discount_factor] ADD CONSTRAINT [PK_source_deal_discount_factor] PRIMARY KEY CLUSTERED ([as_of_date], [source_deal_header_id], [maturity])
GO
GO
ALTER TABLE [dbo].[source_deal_error_log] ALTER COLUMN [as_of_date] [datetime] NULL
GO
GO
ALTER TABLE [dbo].[stage_sdd] ADD
[ExternalIndicator] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayIndex] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiveIndex] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[filename] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO

CREATE NONCLUSTERED INDEX [idx_deal_voided_in_external_source_deal_header_id] ON [dbo].[deal_voided_in_external] ([source_deal_header_id])
GO