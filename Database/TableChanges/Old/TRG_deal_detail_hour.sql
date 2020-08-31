go

if exists(select 1 from sys.triggers where [name]='TRGUPD_deal_detail_hour')
drop trigger TRGUPD_deal_detail_hour
go
CREATE TRIGGER [dbo].[TRGUPD_deal_detail_hour]
ON [dbo].[deal_detail_hour]
FOR UPDATE
AS

IF OBJECT_ID('tempdb..#updated_deal_detail_hour') IS not NULL
begin
	delete s from  #inserted_deal_detail_hour s  inner join deleted d on s.deal_detail_hour_new_id=d.deal_detail_hour_new_id
	insert into #updated_deal_detail_hour SELECT * FROM inserted 
end
go

if exists(select 1 from sys.triggers where [name]='TRGdel_deal_detail_hour')
drop trigger TRGdel_deal_detail_hour
go
CREATE TRIGGER [dbo].[TRGDEL_deal_detail_hour]
ON [dbo].[deal_detail_hour]
FOR Delete
AS
IF OBJECT_ID('tempdb..#deleted_deal_detail_hour') IS not NULL
	insert into #deleted_deal_detail_hour SELECT * FROM deleted


GO
if exists(select 1 from sys.triggers where [name]='TRGins_deal_detail_hour')
drop trigger TRGins_deal_detail_hour
go

CREATE TRIGGER [dbo].[TRGINS_deal_detail_hour]
ON [dbo].[deal_detail_hour]
FOR Insert
AS
	
IF OBJECT_ID('tempdb..#inserted_deal_detail_hour') IS not NULL
	insert into #inserted_deal_detail_hour SELECT * FROM inserted

