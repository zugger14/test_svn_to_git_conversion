SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.[ice_interface_settings]', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[ice_interface_settings]
    (	
		[ID]			INT	IDENTITY(1, 1) NOT NULL,
		environment		VARCHAR(500),
		host			VARCHAR(500),
		port			VARCHAR(50),
		sender_comp_id  VARCHAR(50),
		sender_sub_id	VARCHAR(50),
		target_comp_id  VARCHAR(50),
		[user_id]		VARCHAR(50),
		user_password	VARBINARY(1000),
		config_file		VARCHAR(500),
		log_file_path	VARCHAR(500)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table ice_interface_settings EXISTS'
END

Go