IF OBJECT_ID('dbo.shutin_header') IS NULL
BEGIN
	CREATE TABLE dbo.shutin_header
	(
		shutin_header_id	INT IDENTITY(1,1),
		nom_group_ids varchar(1000),
		flow_date_from datetime,
		flow_date_to datetime,	
		[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME DEFAULT GETDATE(),
		[update_user]			VARCHAR(100) NULL,
		[update_ts]				DATETIME NULL
		, CONSTRAINT [PK_shutin_header] PRIMARY KEY CLUSTERED 
		(
			shutin_header_id ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
		) ON [PRIMARY]
END
ELSE
	PRINT 'Table shutin_header already Exists.'



IF OBJECT_ID('dbo.shutin_detail') IS NULL
BEGIN
	CREATE TABLE dbo.shutin_detail
	(
		shutin_detail_id	INT IDENTITY(1,1),
		shutin_header_id int constraint FK_shutin_detail_shutin_header_id_shutin_header_shutin_header_id REFERENCES dbo.shutin_header(shutin_header_id) ON DELETE CASCADE,
		nom_group_id int,
		meter_id int constraint FK_shutin_detail_meter_id_meter_id REFERENCES dbo.meter_id(meter_id)	,
		flow_date datetime,	
		comments varchar(max),
		shutin_process	varchar(1) NULL DEFAULT 's',	--s=shutin; r=revert
		term_start datetime,
		term_end datetime,
		[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME DEFAULT GETDATE(),
		[update_user]			VARCHAR(100) NULL,
		[update_ts]				DATETIME NULL
	 )
END
ELSE
	PRINT 'Table shutin_detail already Exists.'
