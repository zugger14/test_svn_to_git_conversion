-- DROP TABLE [dbo].[regression_time_tracker]
-- TRUNCATE TABLE [dbo].[regression_time_tracker]
-- SELECT * FROM [dbo].[regression_time_tracker]

IF OBJECT_ID('[dbo].[regression_time_tracker]') IS NULL
BEGIN
	CREATE TABLE [dbo].[regression_time_tracker] (
		/**
			Save the regression benchmark and post regression timing details.

			Columns:
			regression_time_tracker_id : Unique Identifier for table.
			rule_id : Identifier of Regression Rule.
			module_detail_id : Identifier of Regression Module Detail.
			start_time : The time when the report/calculation running started.
			end_time : The time when the report/calculation running ended.
			process_id : Unique Identifier that identifies each run (benchmark/post regression).
			is_benchmark : Specify whether the process is benchmark or post regression.
			create_user : specifies the username who creates the column.
			create_ts : specifies the date when column was created.
			update_user : specifies the username who updated the column.
			update_ts : specifies the date when column was updated.
		*/
		regression_time_tracker_id INT IDENTITY(1,1),
		rule_id INT,
		module_detail_id INT,
		start_time DATETIME,
		end_time DATETIME,
		process_id VARCHAR(100),
		is_benchmark BIT SPARSE NULL,
		create_user NVARCHAR(255) DEFAULT dbo.FNADBUser(),
		create_ts DATETIME DEFAULT GETDATE(),
		update_user NVARCHAR(255),
		update_ts DATETIME,
		CONSTRAINT FK_regression_time_tracker_rule_id FOREIGN KEY (rule_id) REFERENCES regression_rule(regression_rule_id),
		CONSTRAINT FK_regression_time_tracker_regression_module_detail_id FOREIGN KEY (module_detail_id) REFERENCES regression_module_detail(regression_module_detail_id)
	)

	PRINT 'Table [dbo].[regression_time_tracker] is created.'
END
ELSE
BEGIN
	PRINT 'Table [dbo].[regression_time_tracker] already exists.'
END

GO

/*
	Update trigger for updating audit columns
*/
CREATE OR ALTER TRIGGER dbo.TRGUPD_regression_time_tracker
ON dbo.regression_time_tracker
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE fte
        SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
        FROM regression_time_tracker fte
        INNER JOIN DELETED d ON d.regression_time_tracker_id =  fte.regression_time_tracker_id
    END
END

GO