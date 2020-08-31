IF OBJECT_ID('[fas_link_detail_audit]') IS NOT NULL
DROP TABLE [fas_link_detail_audit]
GO
CREATE TABLE [dbo].[fas_link_detail_audit](
	[link_id] [int] NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[percentage_included] [money] NULL,
	[hedge_or_item] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
	[effective_date] [datetime] NULL,
	[user_action] VARCHAR(50)
) ON [PRIMARY]

GO
IF OBJECT_ID('[fas_link_header_audit]') IS NOT NULL
DROP TABLE [fas_link_header_audit]
GO
CREATE TABLE [dbo].[fas_link_header_audit](
	[link_id] [int]  NOT NULL,
	[fas_book_id] [int] NOT NULL,
	[perfect_hedge] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[fully_dedesignated] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[link_description] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[eff_test_profile_id] [int] NOT NULL,
	[link_effective_date] [datetime] NOT NULL,
	[link_type_value_id] [int] NOT NULL,
	[link_active] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
	[original_link_id] [int] NULL,
	[link_end_date] [datetime] NULL,
	[dedesignated_percentage] [float] NULL,
	[user_action] VARCHAR(50)

) ON [PRIMARY]



GO
IF OBJECT_ID('TRGDEL_fas_link_detail_audit') IS NOT NULL
DROP TRIGGER TRGDEL_fas_link_detail_audit


GO


CREATE TRIGGER [dbo].TRGDEL_fas_link_detail_audit
ON [dbo].[fas_link_detail_audit]
FOR Delete
AS

INSERT INTO [dbo].[fas_link_detail_audit]
	([link_id],
	[source_deal_header_id],
	[percentage_included] ,
	[hedge_or_item],
	[create_user],
	[create_ts],
	[update_user],
	[update_ts],
	[effective_date],
	[user_action])
SELECT 
	[link_id],
	[source_deal_header_id],
	[percentage_included] ,
	[hedge_or_item],
	dbo.fnadbuser(),
	GETDATE(),
	dbo.fnadbuser(),
	GETDATE(),
	[effective_date],
	'delete' [user_action]
FROM DELETED



go


ALTER TRIGGER [dbo].[TRGUPD_FAS_LINK_DETAIL]
ON [dbo].[fas_link_detail]
FOR UPDATE
AS
UPDATE FAS_LINK_DETAIL SET update_user = dbo.FNADBUser(), update_ts = getdate() where  FAS_LINK_DETAIL.link_id in (select link_id from deleted) AND FAS_LINK_DETAIL.source_deal_header_id in (select source_deal_header_id from deleted)

INSERT INTO [dbo].[fas_link_detail_audit]
	([link_id],
	[source_deal_header_id],
	[percentage_included] ,
	[hedge_or_item],
	[create_user],
	[create_ts],
	[update_user],
	[update_ts],
	[effective_date],
	[user_action])
SELECT 
	[link_id],
	[source_deal_header_id],
	[percentage_included] ,
	[hedge_or_item],
	dbo.fnadbuser(),
	GETDATE(),
	dbo.fnadbuser(),
	GETDATE(),
	[effective_date],
	'update' [user_action]
FROM INSERTED




go


ALTER TRIGGER [dbo].[TRGINS_FAS_LINK_DETAIL]
ON [dbo].[fas_link_detail]
FOR INSERT
AS
UPDATE FAS_LINK_DETAIL SET create_user = dbo.FNADBUser(), create_ts = getdate() where  FAS_LINK_DETAIL.link_id in (select link_id from inserted) AND FAS_LINK_DETAIL.source_deal_header_id in (select source_deal_header_id from inserted)

INSERT INTO [dbo].[fas_link_detail_audit]
	([link_id],
	[source_deal_header_id],
	[percentage_included] ,
	[hedge_or_item],
	[create_user],
	[create_ts],
	[update_user],
	[update_ts],
	[effective_date],
	[user_action])
SELECT 
	[link_id],
	[source_deal_header_id],
	[percentage_included] ,
	[hedge_or_item],
	dbo.fnadbuser(),
	GETDATE(),
	dbo.fnadbuser(),
	GETDATE(),
	[effective_date],
	'Insert' [user_action]
FROM INSERTED

GO

ALTER TRIGGER [dbo].[TRGINS_FAS_LINK_HEADER]
ON [dbo].[fas_link_header]
FOR INSERT
AS
UPDATE FAS_LINK_HEADER SET create_user = dbo.FNADBUser(), create_ts = getdate() where  FAS_LINK_HEADER.link_id in (select link_id from inserted)


INSERT INTO [dbo].[fas_link_header_audit]
	(link_id,
	fas_book_id,
	perfect_hedge,
	fully_dedesignated,
	link_description,
	eff_test_profile_id,
	link_effective_date,
	link_type_value_id,
	link_active,
	create_user,
	create_ts,
	update_user,
	update_ts,
	original_link_id,
	link_end_date,
	dedesignated_percentage,
	user_action)
SELECT 
	link_id,
	fas_book_id,
	perfect_hedge,
	fully_dedesignated,
	link_description,
	eff_test_profile_id,
	link_effective_date,
	link_type_value_id,
	link_active,
	dbo.FNADBUser(),
	GETDATE(),
	dbo.FNADBUser(),
	GETDATE(),
	original_link_id,
	link_end_date,
	dedesignated_percentage,
	'Insert' [user_action]
FROM INSERTED


go



ALTER TRIGGER [dbo].[TRGUPD_FAS_LINK_HEADER]
ON [dbo].[fas_link_header]
FOR UPDATE
AS
UPDATE FAS_LINK_HEADER SET update_user = dbo.FNADBUser(), update_ts = getdate() where  FAS_LINK_HEADER.link_id in (select link_id from deleted)

INSERT INTO [dbo].[fas_link_header_audit]
	(link_id,
	fas_book_id,
	perfect_hedge,
	fully_dedesignated,
	link_description,
	eff_test_profile_id,
	link_effective_date,
	link_type_value_id,
	link_active,
	create_user,
	create_ts,
	update_user,
	update_ts,
	original_link_id,
	link_end_date,
	dedesignated_percentage,
	user_action)
SELECT 
	link_id,
	fas_book_id,
	perfect_hedge,
	fully_dedesignated,
	link_description,
	eff_test_profile_id,
	link_effective_date,
	link_type_value_id,
	link_active,
	dbo.FNADBUser(),
	GETDATE(),
	dbo.FNADBUser(),
	GETDATE(),
	original_link_id,
	link_end_date,
	dedesignated_percentage,
	'update' [user_action]
FROM INSERTED

GO

go

ALTER TRIGGER [dbo].[TRGdel_FAS_LINK_HEADER]
ON [dbo].[fas_link_header]
FOR delete
AS
delete [dbo].[dedesignated_link_deal] from [dbo].[dedesignated_link_deal] d_l inner join deleted d 
on d_l.link_id=d.link_id 
delete [dbo].[dedesignated_link_deal] from [dbo].[dedesignated_link_deal] d_l inner join deleted d 
on d_l.link_id=d.original_link_id 

INSERT INTO [dbo].[fas_link_header_audit]
	(link_id,
	fas_book_id,
	perfect_hedge,
	fully_dedesignated,
	link_description,
	eff_test_profile_id,
	link_effective_date,
	link_type_value_id,
	link_active,
	create_user,
	create_ts,
	update_user,
	update_ts,
	original_link_id,
	link_end_date,
	dedesignated_percentage,
	user_action)
SELECT 
	link_id,
	fas_book_id,
	perfect_hedge,
	fully_dedesignated,
	link_description,
	eff_test_profile_id,
	link_effective_date,
	link_type_value_id,
	link_active,
	dbo.FNADBUser(),
	GETDATE(),
	dbo.FNADBUser(),
	GETDATE(),
	original_link_id,
	link_end_date,
	dedesignated_percentage,
	'delete' [user_action]
FROM DELETED
