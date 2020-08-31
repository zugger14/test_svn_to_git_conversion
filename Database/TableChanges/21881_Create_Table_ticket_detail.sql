SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ticket_detail]', N'U') IS NULL
BEGIN
   CREATE TABLE [dbo].ticket_detail (
		ticket_detail_id INT IDENTITY(1, 1) NOT NULL,
		ticket_header_id INT,		
		line_item INT,
		term_start DATETIME,
		term_end DATETIME,
		carrier	INT,		
		vehicle_number VARCHAR(1000),
		movement_date_time DATETIME,		
		origin  VARCHAR(1000),
		destination	VARCHAR(1000),
		product_commodity INT,
		net_quantity NUMERIC(38,18),
		temperature	FLOAT,
		temp_scale_f_c CHAR(1),
		api_gravity FLOAT,	
		specific_gravity FLOAT,
		automatch_status CHAR(1),
		location_id INT,
		shipper INT,
		consginee INT,
		container_id INT,
		ticket_matching_no INT,
		lot VARCHAR(100),
		Batch_id VARCHAR(200),
		crop_year VARCHAR(4),
		incoterm INT,
		density FLOAT,
		density_uom INT,
		quantity_uom INT,	
		weight_uom INT,
		gross_quantity INT,
		gross_weight INT,
		net_weight INT,
		issued_year SMALLINT,
		bsw NUMERIC(38,20),
		lease_measurement INT,
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME NULL DEFAULT GETDATE(),
		[update_user] VARCHAR(50) NULL,
		[update_ts] DATETIME NULL
		
)
END
ELSE
BEGIN
    PRINT 'Table ticket_detail EXISTS'
END
 
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    AND   tc.Table_Name = 'ticket_detail' 
                    AND ccu.COLUMN_NAME = 'ticket_detail_id'
)
ALTER TABLE [dbo].ticket_detail WITH NOCHECK ADD CONSTRAINT pk_ticket_detail_id PRIMARY KEY(ticket_detail_id)
GO

IF NOT EXISTS (	SELECT 1 
				FROM sys.foreign_keys 
				WHERE object_id = OBJECT_ID(N'[dbo].[FK_ticket_header_id]') 
					AND parent_object_id = OBJECT_ID(N'[dbo].[ticket_detail]')
				)
ALTER TABLE [dbo].[ticket_detail]  WITH CHECK 
ADD  CONSTRAINT FK_ticket_header_id FOREIGN KEY([ticket_header_id])
REFERENCES [dbo].[ticket_header] ([ticket_header_id]) 
ON DELETE CASCADE
GO

IF OBJECT_ID('[dbo].[TRGUPD_ticket_detail]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ticket_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ticket_detail]
ON [dbo].[ticket_detail]
FOR UPDATE
AS
    UPDATE ticket_detail
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ticket_detail t
      INNER JOIN DELETED u 
		ON t.ticket_detail_id = u.ticket_detail_id
GO
