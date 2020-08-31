IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[maintain_location_routes]') AND TYPE IN (N'U'))
BEGIN
    IF COL_LENGTH('maintain_location_routes', 'route_description') IS NULL
	BEGIN
		ALTER TABLE maintain_location_routes ADD route_description VARCHAR(500)
	END
	
	IF COL_LENGTH('maintain_location_routes', 'source_curve_def_id') IS NULL
	BEGIN
		ALTER TABLE maintain_location_routes ADD source_curve_def_id INT
	END
END
ELSE
BEGIN
    CREATE TABLE [dbo].maintain_location_routes
    (
    	[maintain_location_routes_id]     INT IDENTITY(1, 1) NOT NULL,
    	[route_id]                        INT,
    	[route_name]                      VARCHAR(250),
    	[delivery_location]               INT NULL,
    	[delivery_meter_id]               INT NULL,
    	[pipeline]                        INT NULL,
    	[contract_id]                     INT NULL,
    	[effective_date]                  DATETIME,
    	[fuel_loss]                       FLOAT,
    	[primary_secondary]               CHAR(1) NULL,
    	[is_group]                        CHAR(1) NULL,
    	[maintain_location_routes_detail_id] INT NULL,
    	[route_order_in]                  TINYINT,
    	[create_user]                     VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                       DATETIME DEFAULT GETDATE(),
    	[update_user]                     VARCHAR(100) NULL,
    	[update_ts]                       DATETIME NULL,
    	route_description				  VARCHAR(500),
    	[source_curve_def_id]			  INT NULL,
    	CONSTRAINT [pk_maintain_location_routes_id] PRIMARY KEY CLUSTERED([maintain_location_routes_id] ASC)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END

GO