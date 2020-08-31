IF NOT EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[deal_reference_id_prefix]')
              AND TYPE IN (N'U')
   )
BEGIN
    CREATE TABLE deal_reference_id_prefix
    (
    	[deal_reference_id_prefix_id]  INT IDENTITY(1, 1) NOT NULL,
    	[deal_type]                    INT NOT NULL,
    	[prefix]                       VARCHAR(500),
    	[create_user]                  VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                    DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                  VARCHAR(50) NULL,
    	[update_ts]                    DATETIME NULL
    )
END
ELSE
    PRINT 'Table deal_reference_id_prefix already exists.'
    
   