IF EXISTS (
       SELECT *
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_counterparty_contacts]')
   )
BEGIN
	DROP FULLTEXT INDEX ON [dbo].[master_view_counterparty_contacts]

	CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_contacts] (
		title,name,address1,address2,city,state,zip,country,region,email,comment,telephone,fax,cell_no,email_cc,email_bcc
	) KEY INDEX PK_master_view_counterparty_contacts;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_contacts created.'
END
GO