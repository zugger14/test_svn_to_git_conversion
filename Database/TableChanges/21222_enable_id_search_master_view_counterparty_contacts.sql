IF COL_LENGTH('master_view_counterparty_contacts', 'id') IS NULL
BEGIN
    ALTER TABLE master_view_counterparty_contacts ADD id VARCHAR(1000)
END
GO

/*
create insert trigger for counterparty_contacts to store data on master_view_counterparty_contacts.

*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[TRGINS_counterparty_contacts_master_view]', N'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_counterparty_contacts_master_view]
GO

CREATE TRIGGER [dbo].[TRGINS_counterparty_contacts_master_view]
ON [dbo].[counterparty_contacts]
AFTER INSERT, UPDATE
AS
	IF @@ROWCOUNT = 0
        RETURN
	if exists (select 1 from deleted) 
		and exists (select top 1 1 from master_view_counterparty_contacts m 
					inner join inserted i on i.counterparty_contact_id = m.counterparty_contact_id)  
		
		--update trigger title,name,address1,address2,city,state,zip,country,region,email,comment,telephone,fax,cell_no
	begin
	
		update mvcc
		set mvcc.title			=	cc.title
			, mvcc.name			=	cc.name
			, mvcc.address1		=	cc.address1
			, mvcc.address2		=	cc.address2
			, mvcc.city			=	cc.city
			, mvcc.[state]		=	state_sdv.code
			, mvcc.zip			=	cc.zip
			, mvcc.country		=	country_sdv.code
			, mvcc.region		=	region_sdv.code
			, mvcc.email		=	cc.email
			, mvcc.comment		=	cc.comment
			, mvcc.telephone	=	cc.telephone
			, mvcc.fax			=	cc.fax
			, mvcc.cell_no		=	cc.cell_no
			, mvcc.id			=	cc.id
		from master_view_counterparty_contacts mvcc
		inner join inserted cc on cc.counterparty_contact_id = mvcc.counterparty_contact_id
		left join static_data_value state_sdv on state_sdv.value_id = cc.[state]
		left join static_data_value country_sdv on country_sdv.value_id = cc.[country]
		left join static_data_value region_sdv on region_sdv.value_id = cc.[region]
	end
	else
	begin
	--title,name,address1,address2,city,state,zip,country,region,email,comment,telephone,fax,cell_no
		 
		INSERT into dbo.master_view_counterparty_contacts (counterparty_contact_id,counterparty_id,counterparty_name
			,title,name,address1,address2,city,state,zip,country,region,email,comment,telephone,fax,cell_no, id)
		select cc.counterparty_contact_id, cc.counterparty_id, sc.counterparty_name, cc.title, cc.name, cc.address1, cc.address2, cc.city, state_sdv.code [state], cc.zip [zip]
		, country_sdv.code [country], region_sdv.code [region], cc.email, cc.comment, cc.telephone, cc.fax, cc.cell_no, cc.id
		from inserted cc
		inner join source_counterparty sc on sc.source_counterparty_id = cc.counterparty_id
		left join static_data_value state_sdv on state_sdv.value_id = cc.[state]
		left join static_data_value country_sdv on country_sdv.value_id = cc.[country]
		left join static_data_value region_sdv on region_sdv.value_id = cc.[region]
	end

GO

IF EXISTS (
       SELECT *
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[master_view_counterparty_contacts]')
   )
BEGIN
	DROP FULLTEXT INDEX ON [dbo].[master_view_counterparty_contacts]

	CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_contacts] (
		title,name,address1,address2,city,state,zip,country,region,email,comment,telephone,fax,cell_no,email_cc,email_bcc,id
	) KEY INDEX PK_master_view_counterparty_contacts;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_contacts created.'
END
GO