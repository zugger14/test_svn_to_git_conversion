GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_container]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].[source_container]
    (
    	[source_container_id]      INT IDENTITY(1, 1) PRIMARY KEY,
		[source_system_id]		   INT REFERENCES [dbo].[source_system_description](source_system_id),
		[container_name]		   VARCHAR(500) NOT NULL UNIQUE,
		[description]			   VARCHAR(500), 
		container_type			   VARCHAR(500),
    	capacity                   VARCHAR(500),
    	capacity_uom               VARCHAR(500),
    	draw_depth                 INT,
    	draw_depth_uom             INT,
    	overall_length             INT,
		overall_length_uom         INT,
		location				   INT REFERENCES [dbo].[source_minor_location](source_minor_location_id),
		size_classification		   VARCHAR(500),
		year_built				   VARCHAR(10),
		flag					   VARCHAR(50),
		[owner]					   VARCHAR(50),
    	[create_user]			   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                VARCHAR(50),
    	[update_user]              VARCHAR(50) NULL,
    	[update_ts]                DATETIME NULL,
    
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
    END
GO