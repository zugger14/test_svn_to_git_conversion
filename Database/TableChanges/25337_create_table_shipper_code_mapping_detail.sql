SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[shipper_code_mapping_detail]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[shipper_code_mapping_detail] (
/**
	Contain shipper code mapping details

	Columns
	shipper_code_mapping_detail_id : primary key 
	shipper_code_id : Reference key of shipper code mapping table
	effective_date : Effective date 
    shipper_code : Shipper Code
    is_default :Is Default
	create_user : Specifies the username who creates the column
	create_ts : Specifies the date when column was created
	update_user : Specifies the username who updated the column
	update_ts : Specifies the date when column was updated

*/
		  [shipper_code_mapping_detail_id]		    INT IDENTITY(1,1) NOT NULL PRIMARY KEY
        , [shipper_code_id]                         INT NOT NULL
		, [effective_date]						    DATE  NOT NULL
		, [shipper_code]							NVARCHAR(400) NOT NULL
        , [is_default]                              NCHAR(2) NOT NULL
		, [create_user]							    VARCHAR(50) NULL DEFAULT dbo.FNADBUser()
		, [create_ts]								DATETIME NULL DEFAULT GETDATE()
		, [update_user]							    VARCHAR(50) NULL
		, [update_ts]								DATETIME NULL
		, CONSTRAINT fk_shipper_code_id FOREIGN KEY (shipper_code_id) REFERENCES shipper_code_mapping(shipper_code_id)
            ON DELETE CASCADE
	) ON [PRIMARY]

END
ELSE
BEGIN
    PRINT 'Table [dbo].shipper_code_mapping_detail EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_shipper_code_mapping_detail]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_shipper_code_mapping_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_shipper_code_mapping_detail]
ON [dbo].[shipper_code_mapping_detail]
FOR UPDATE
AS
    UPDATE shipper_code_mapping_detail
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM shipper_code_mapping_detail t
      INNER JOIN DELETED u 
		ON t.shipper_code_mapping_detail_id = u.shipper_code_mapping_detail_id
GO