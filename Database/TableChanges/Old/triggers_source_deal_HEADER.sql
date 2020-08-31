if exists(select 1 from sys.triggers where [name]='TRGUPD_SOURCE_DEAL_HEADER')
drop trigger TRGUPD_SOURCE_DEAL_HEADER
go



CREATE TRIGGER [dbo].[TRGUPD_SOURCE_DEAL_HEADER]
ON [dbo].[source_deal_HEADER]
FOR UPDATE
AS

IF OBJECT_ID('tempdb..#updated_source_deal_HEADER') IS not NULL
begin
	delete s from  #inserted_source_deal_HEADER s  inner join deleted d on s.source_deal_header_id=d.source_deal_header_id
	insert into #updated_source_deal_HEADER SELECT * FROM inserted 
end



GO
if exists(select 1 from sys.triggers where [name]='TRGdel_source_deal_HEADER')
drop trigger TRGdel_source_deal_HEADER
go
CREATE TRIGGER [dbo].[TRGDEL_source_deal_HEADER]
ON [dbo].[source_deal_HEADER]
FOR Delete
AS
IF OBJECT_ID('tempdb..#deleted_source_deal_HEADER') IS not NULL
	insert into #deleted_source_deal_HEADER SELECT * FROM deleted

GO
if exists(select 1 from sys.triggers where [name]='TRGins_source_deal_HEADER')
drop trigger TRGins_source_deal_HEADER
go

CREATE TRIGGER [dbo].[TRGINS_source_deal_HEADER]
ON [dbo].[source_deal_HEADER]
FOR Insert
AS
	
IF OBJECT_ID('tempdb..#inserted_source_deal_HEADER') IS not NULL
	insert into #inserted_source_deal_HEADER SELECT * FROM inserted

