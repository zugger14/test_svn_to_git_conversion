GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[state_rec_requirement_detail]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].[state_rec_requirement_detail]
    (
    	[state_rec_requirement_detail_id]  INT IDENTITY(1, 1) NOT NULL,
    	[state_value_id]                   INT NOT NULL,
    	[compliance_year]                  INT NOT NULL,
    	[tier_type]                        INT NOT NULL,
    	[min_target]                       FLOAT NULL,
    	[min_absolute_target]              FLOAT NULL,
    	[max_target]                       FLOAT NULL,
    	[max_absolute_target]              FLOAT NULL,
    	[create_user]                      VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                        DATETIME DEFAULT GETDATE(),
    	[update_user]                      VARCHAR(100) NULL,
    	[update_ts]                        DATETIME NULL,
    	CONSTRAINT [pk_state_rec_requirement_detail] PRIMARY KEY CLUSTERED([state_rec_requirement_detail_id] ASC)
    	WITH (IGNORE_DUP_KEY = OFF) 
    	ON [PRIMARY]
    ) ON [PRIMARY]
    
    PRINT 'Table Successfully Created'
END

ALTER TABLE [dbo].[state_rec_requirement_detail]
  ADD CONSTRAINT FK_state_rec_requirement_detail
  FOREIGN KEY([state_value_id], [compliance_year]) REFERENCES [dbo].[state_rec_requirement_data]([state_value_id], [compliance_year])
