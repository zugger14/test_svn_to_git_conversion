/**
The view is been re-created after altering the column counterparty_name
*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

if OBJECT_ID(N'dbo.VW_counterparty_certificate', N'V') is not null drop view dbo.VW_counterparty_certificate
go
CREATE VIEW dbo.VW_counterparty_certificate with schemabinding
	as
	select cc.counterparty_certificate_id, cc.counterparty_id, sc.counterparty_name,
	cc.comments [certificate_comment],certf.document_name [certificate]
	from dbo.counterparty_certificate cc
	inner join dbo.source_counterparty sc on sc.source_counterparty_id = cc.counterparty_id
	inner join dbo.documents_type certf on certf.document_id = cc.certificate_id
go

CREATE UNIQUE CLUSTERED INDEX UQI_VW_counterparty_certificate ON [dbo].[VW_counterparty_certificate](counterparty_certificate_id)
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('VW_counterparty_certificate'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON VW_counterparty_certificate (
		[certificate_comment],
		[certificate]
	) KEY INDEX UQI_VW_counterparty_certificate;
END
ELSE
    PRINT 'FULLTEXT INDEX ON VW_counterparty_certificate Already Exists.'
GO
