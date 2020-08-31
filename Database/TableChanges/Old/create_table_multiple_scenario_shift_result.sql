/**
* Desc: New table to save multiple scenario shift result with criteria_id
* Owner: sbohara@pioneersolutionsglobal.com
* Date: 23rd Mar 2016
**/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID (N'dbo.multiple_scenario_shift_result', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.multiple_scenario_shift_result
	(
	[shift_id]					INT IDENTITY(1, 1) PRIMARY KEY,
	[as_of_date]				DATE,
	[criteria_id]				INT,
    [commodity_one]				INT,
    [commodity_two]				INT,
    [shift_one]					FLOAT,
	[shift_two]					FLOAT, 
	[value_one]					FLOAT,
	[value_two]					FLOAT, 
	[calc_value_one]			FLOAT,
	[calc_value_two]			FLOAT,
	[fixed_value]				FLOAT,
	[total_value]				FLOAT,
	[term_start]				DATE,
	[term_end]					DATE,
	[delta]						CHAR(1) DEFAULT 'n',
	[create_user]    			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      			DATETIME NULL DEFAULT GETDATE(),
    [update_user]    			VARCHAR(50) NULL,
    [update_ts]      			DATETIME NULL
    )
END
GO

IF NOT EXISTS (SELECT 1 
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[fk_criteria_id]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[multiple_scenario_shift_result]'))
BEGIN
    ALTER TABLE multiple_scenario_shift_result ADD CONSTRAINT fk_criteria_id FOREIGN KEY (criteria_id) REFERENCES maintain_whatif_criteria(criteria_id)
END

IF NOT EXISTS (SELECT 1 
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[fk_commodity_one]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[multiple_scenario_shift_result]'))
BEGIN
    ALTER TABLE multiple_scenario_shift_result ADD CONSTRAINT fk_commodity_one FOREIGN KEY (commodity_one) REFERENCES source_commodity(source_commodity_id)
END

IF NOT EXISTS (SELECT 1 
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[fk_commodity_two]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[multiple_scenario_shift_result]'))
BEGIN
    ALTER TABLE multiple_scenario_shift_result ADD CONSTRAINT fk_commodity_two FOREIGN KEY (commodity_two) REFERENCES source_commodity(source_commodity_id)
END


-- adding update trigger for above table
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_multiple_scenario_shift_result]'))
    DROP TRIGGER [dbo].[TRGUPD_multiple_scenario_shift_result]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_multiple_scenario_shift_result]
ON [dbo].[multiple_scenario_shift_result]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE multiple_scenario_shift_result
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM multiple_scenario_shift_result pmb
        INNER JOIN DELETED d ON d.shift_id = pmb.shift_id
    END
END
GO
