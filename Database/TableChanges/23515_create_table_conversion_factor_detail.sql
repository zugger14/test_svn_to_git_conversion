SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[conversion_factor_detail]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[conversion_factor_detail] (
/**
	Contain conversion factor details

	Columns
	conversion_factor_detail_id : primary key 
	conversion_factor_id : Reference key of conversion factor table
	effective_date : Effective date 
	Factor: Factor value
	create_user : Specifies the username who creates the column
	create_ts : Specifies the date when column was created
	update_user : Specifies the username who updated the column
	update_ts : Specifies the date when column was updated
	
*/
		  [conversion_factor_detail_id]		    INT IDENTITY(1,1) NOT NULL PRIMARY KEY
        , [conversion_factor_id]                  INT NOT NULL
		, [effective_date]						DATE  NOT NULL
		, [Factor]							    NUMERIC(37,20) NULL
		, [create_user]							VARCHAR(50) NULL DEFAULT dbo.FNADBUser()
		, [create_ts]								DATETIME NULL DEFAULT GETDATE()
		, [update_user]							VARCHAR(50) NULL
		, [update_ts]								DATETIME NULL
		, CONSTRAINT fk_conversion_factor_id FOREIGN KEY (conversion_factor_id) REFERENCES conversion_factor(conversion_factor_id)
	) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table [dbo].conversion_factor_detail EXISTS'
END


IF OBJECT_ID('[dbo].[TRGUPD_conversion_factor_detail]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_conversion_factor_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_conversion_factor_detail]
ON [dbo].[conversion_factor_detail]
FOR UPDATE
AS
    UPDATE conversion_factor_detail
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM conversion_factor_detail t
      INNER JOIN DELETED u 
		ON t.conversion_factor_detail_id = u.conversion_factor_detail_id
GO