IF OBJECT_ID('dbo.optimizer_header') IS NULL
BEGIN
	CREATE TABLE dbo.optimizer_header
	(
		optimizer_header_id	INT IDENTITY(1,1),
		flow_date datetime,	
		transport_deal_id int constraint FK_optimizer_header_transport_deal_id_source_deal_header_source_deal_header_id REFERENCES dbo.source_deal_header(source_deal_header_id)	ON DELETE CASCADE,
		package_id varchar(30),	
		SLN_id varchar(30),		
		receipt_location_id int constraint FK_optimizer_header_receipt_location_id_source_minor_location_source_minor_location_id REFERENCES dbo.source_minor_location(source_minor_location_id),	
		delivery_location_id int constraint FK_optimizer_header_delivery_location_id_source_minor_location_source_minor_location_id REFERENCES dbo.source_minor_location(source_minor_location_id),	
		rec_nom_volume	numeric(28,8),
		del_nom_volume	numeric(28,8),	
		rec_nom_cycle1	numeric(28,8),	
		del_nom_cycle1	numeric(28,8),	
		rec_nom_cycle2	numeric(28,8),	
		del_nom_cycle2	numeric(28,8),	
		rec_nom_cycle3	numeric(28,8),	
		del_nom_cycle3	numeric(28,8),	
		rec_nom_cycle4	numeric(28,8),	
		del_nom_cycle4	numeric(28,8),	
		rec_nom_cycle5	numeric(28,8),	
		del_nom_cycle5	numeric(28,8),	
		sch_rec_volume	numeric(28,8),	
		sch_del_volume	numeric(28,8),
		actual_rec_volume numeric(28,8),
		actual_del_volume numeric(28,8),
		[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME DEFAULT GETDATE(),
		[update_user]			VARCHAR(100) NULL,
		[update_ts]				DATETIME NULL
		,
		 CONSTRAINT [PK_optimizer_header] PRIMARY KEY CLUSTERED 
		(
			optimizer_header_id ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
		) ON [PRIMARY]
END
ELSE
	PRINT 'Table optimizer_header already Exists.'



IF OBJECT_ID('dbo.optimizer_detail') IS NULL
BEGIN
	CREATE TABLE dbo.optimizer_detail
	(
		optimizer_detail_id	INT IDENTITY(1,1),
		optimizer_header_id int constraint FK_optimizer_detail_optimizer_header_id_optimizer_header_optimizer_header_id REFERENCES dbo.optimizer_header(optimizer_header_id) ON DELETE CASCADE,
		flow_date datetime,	
		transport_deal_id int constraint FK_optimizer_detail_transport_deal_id_source_deal_header_source_deal_header_id REFERENCES dbo.source_deal_header(source_deal_header_id)	,
		up_down_stream varchar(1),
		source_deal_header_id int constraint FK_optimizer_detail_source_deal_header_id_source_deal_header_source_deal_header_id REFERENCES dbo.source_deal_header(source_deal_header_id) ,
		source_deal_detail_id int constraint FK_optimizer_detail_source_deal_detail_id_source_deal_detail_source_deal_detail_id REFERENCES dbo.source_deal_detail(source_deal_detail_id) on delete cascade,
		deal_volume	numeric(28,8),
		volume_used	numeric(28,8),
		sch_rec_volume	numeric(28,8),	
		sch_del_volume	numeric(28,8),
		actual_rec_volume numeric(28,8),
		actual_del_volume numeric(28,8),

		[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME DEFAULT GETDATE(),
		[update_user]			VARCHAR(100) NULL,
		[update_ts]				DATETIME NULL
	 )
END
ELSE
	PRINT 'Table optimizer_detail already Exists.'



	
--ALTER TABLE [dbo].[optimizer_detail]  WITH CHECK ADD  CONSTRAINT [FK_optimizer_detail_optimizer_header] FOREIGN KEY([optimizer_header_id])
--REFERENCES [dbo].[optimizer_header] ([optimizer_header_id])
--ON DELETE CASCADE
--GO

--ALTER TABLE [dbo].[optimizer_detail] CHECK CONSTRAINT [FK_optimizer_detail_optimizer_header]
--GO
