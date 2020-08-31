GO
IF EXISTS (
       SELECT 1
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[pipeline_up_down_service_k]')
              AND TYPE IN (N'U')
   )
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].pipeline_up_down_service_k
    (
    	[pipeline_up_down_service_k_id]     INT IDENTITY(1, 1) NOT NULL,
    	[counterparty_id]                   INT NOT NULL,
    	[receipt_point]                     INT,
    	[delivery_point]                    INT,
    	[receipt_poi]                       INT,
    	[delivery_poi]                      INT NOT NULL,
    	[serv_req_k]                        VARCHAR(100),
    	[up_k]                              VARCHAR(100),
    	[create_user]                       VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                         DATETIME DEFAULT GETDATE(),
    	[update_user]                       VARCHAR(100) NULL,
    	[update_ts]                         DATETIME NULL,
    	CONSTRAINT [pk_pipeline_up_down_service_k_id] PRIMARY KEY CLUSTERED([pipeline_up_down_service_k_id] ASC)
    	WITH (IGNORE_DUP_KEY = OFF) 
    	ON [PRIMARY]
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END

GO