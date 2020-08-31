if object_id('map_tagging') is not null
drop table [dbo].[map_tagging]
go

CREATE TABLE [dbo].[map_tagging]
(
[ias39_book] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[commodity_balance] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[portfolio] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ias39_scope] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO

if  object_id('[rdb_config]') is not null
drop table [dbo].[rdb_config]
go

CREATE TABLE [dbo].[rdb_config]
(
[provider_type] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[server_name] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_name] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_pwd] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[database_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO

if object_id('[risk_control_process_references]') is not null
drop table [dbo].[risk_control_process_references]
go

CREATE TABLE [dbo].[risk_control_process_references]
(
[type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[process_id] [int] NOT NULL
)
GO
ALTER TABLE [dbo].[risk_control_process_references] ADD CONSTRAINT [PK_risk_control_process_references] PRIMARY KEY CLUSTERED ([type], [id])
GO

if object_id('[tagging_endur]') is not null
drop table [dbo].[tagging_endur]
go

CREATE TABLE [dbo].[tagging_endur]
(
[deal_tracking_num] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ias39_book] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[commodity_balance] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[portfolio] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ias39_scope] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO