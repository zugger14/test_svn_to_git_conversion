GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[formula_function_mapping]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].formula_function_mapping
    (
		[formula_function_mapping_id]		INT IDENTITY(1,1) NOT NULL,
		[function_name]						VARCHAR(5000) NOT NULL,
		[eval_string]						VARCHAR(5000) NOT NULL,
		[arg1]								VARCHAR(5000),
		[arg2]								VARCHAR(5000),
		[arg3]								VARCHAR(5000),
		[arg4]								VARCHAR(5000),
		[arg5]								VARCHAR(5000),
		[arg6]								VARCHAR(5000),
		[arg7]								VARCHAR(5000),
		[arg8]								VARCHAR(5000),
		[arg9]								VARCHAR(5000),
		[arg10]								VARCHAR(5000),
		[arg11]								VARCHAR(5000),
		[arg12]								VARCHAR(5000),	
		[arg13]								VARCHAR(5000),
		[arg14]								VARCHAR(5000),
		[arg15]								VARCHAR(5000)	,
		[arg16]								VARCHAR(5000),
		[arg17]								VARCHAR(5000),
		[arg18]								VARCHAR(5000),
		[create_user]						VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]							DATETIME DEFAULT GETDATE(),
		[update_user]						VARCHAR(100) NULL,
		[update_ts]							DATETIME NULL,
		
		CONSTRAINT [pk_formula_function_mapping_id] PRIMARY KEY CLUSTERED([formula_function_mapping_id] ASC) WITH (IGNORE_DUP_KEY = OFF) 
		ON [PRIMARY]
    ) ON [PRIMARY]
    
    PRINT 'Table Successfully Created'
END

GO