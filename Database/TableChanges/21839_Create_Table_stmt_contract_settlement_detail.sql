SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_contract_settlement_detail]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].stmt_contract_settlement_detail
    (
    	[stmt_contract_settlement_detail_id]     INT IDENTITY(1, 1) NOT NULL,
		[stmt_contract_settlement_id]   INT ,
 		term_date				   DATETIME,
		[hour]					   INT,
		[period]				   INT,
		[is_dst]				   BIT,
		formula_id				   INT,
		formula_squence			   INT,
		volume					   NUMERIC(38,20),
		value					   NUMERIC(38,20),			
    	[create_user]			   VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                DATETIME DEFAULT GETDATE(),
    	CONSTRAINT [pk_stmt_contract_settlement_detail_id] PRIMARY KEY CLUSTERED([stmt_contract_settlement_detail_id] ASC)
    	WITH (IGNORE_DUP_KEY = OFF) ON [Primary],
		CONSTRAINT FK_stmt_contract_settlement FOREIGN KEY (stmt_contract_settlement_id)     
			REFERENCES dbo.stmt_contract_settlement (stmt_contract_settlement_id)     
			ON DELETE CASCADE     
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table contract_settlement EXISTS'
END
GO

