if object_id('dbo.ins_trg_source_deal_detail_audit','tr') is not null
drop trigger dbo.ins_trg_source_deal_detail_audit
go
-- ================================================
-- Template generated from Template Explorer using:
-- Create Trigger (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- See additional Create Trigger templates for more
-- examples of different Trigger statements.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER dbo.ins_trg_source_deal_detail_audit 
   ON  dbo.source_deal_detail_audit
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare @audit_id int,@action varchar(100)



select @action = user_action from inserted

select @audit_id=IDENT_CURRENT('source_deal_header_audit')+ case when @action='Insert' then 0 else 1 end from source_deal_header_audit 

update source_deal_detail_audit set header_audit_id =@audit_id from  source_deal_detail_audit s 
inner join inserted i on i.audit_id=s.audit_id  and s.header_audit_id is null

END
GO

