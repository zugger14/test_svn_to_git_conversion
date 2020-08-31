

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_generator
	DROP CONSTRAINT FK_source_generator_formula_editor
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_generator
	DROP CONSTRAINT FK_source_generator_fas_books
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_generator
	DROP CONSTRAINT FK_source_generator_source_uom
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_generator
	DROP CONSTRAINT FK_source_generator_static_data_value
GO
ALTER TABLE dbo.source_generator
	DROP CONSTRAINT FK_source_generator_static_data_value1
GO
ALTER TABLE dbo.source_generator
	DROP CONSTRAINT FK_source_generator_static_data_value2
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_generator
	DROP CONSTRAINT FK_source_generator_source_minor_location
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_source_generator
	(
	source_generator_id int NOT NULL IDENTITY (1, 1),
	generator_id varchar(50) NOT NULL,
	generator_name varchar(100) NOT NULL,
	generator_desc varchar(100) NULL,
	generator_owner varchar(100) NULL,
	generator_capacity varchar(20) NULL,
	generator_start_date datetime NULL,
	technology int NULL,
	fuel_type int NULL,
	facility_address1 varchar(100) NULL,
	facility_address2 varchar(100) NULL,
	facility_phone varchar(20) NULL,
	facility_email_address varchar(50) NULL,
	facility_country varchar(50) NULL,
	facility_city varchar(50) NULL,
	generation_state int NOT NULL,
	location_id int NOT NULL,
	max_rampup_rate varchar(20) NULL,
	max_rampdown_rate varchar(20) NULL,
	upper_operating_limit varchar(20) NULL,
	lower_operating_limit varchar(20) NULL,
	max_response_level varchar(20) NULL,
	max_interrupts varchar(20) NULL,
	max_dispatch_level varchar(20) NULL,
	min_dispatch_level varchar(20) NULL,
	must_run_unit char(1) NULL,
	generator_group_id int NULL,
	uom_id int NULL,
	book_id int NULL,
	generation_end_date datetime NULL,
	formula_id int NULL,
	technology_sub_type int NULL,
	udf_group_1 int NULL,
	udf_group_2 int NULL,
	udf_group_3 int NULL,
	create_user varchar(50) NULL,
	create_ts datetime NULL,
	update_user varchar(50) NULL,
	update_ts datetime NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_source_generator ON
GO
IF EXISTS(SELECT * FROM dbo.source_generator)
	 EXEC('INSERT INTO dbo.Tmp_source_generator (source_generator_id, generator_id, generator_name, generator_desc, generator_owner, generator_capacity, generator_start_date, technology, fuel_type, facility_address1, facility_address2, facility_phone, facility_email_address, facility_country, facility_city, generation_state, location_id, max_rampup_rate, max_rampdown_rate, upper_operating_limit, lower_operating_limit, max_response_level, max_interrupts, max_dispatch_level, min_dispatch_level, must_run_unit, generator_group_id, uom_id, book_id, generation_end_date, formula_id, create_user, create_ts, update_user, update_ts)
		SELECT source_generator_id, generator_id, generator_name, generator_desc, generator_owner, generator_capacity, generator_start_date, technology, fuel_type, facility_address1, facility_address2, facility_phone, facility_email_address, facility_country, facility_city, generation_state, location_id, max_rampup_rate, max_rampdown_rate, upper_operating_limit, lower_operating_limit, max_response_level, max_interrupts, max_dispatch_level, min_dispatch_level, must_run_unit, generator_group_id, uom_id, book_id, generation_end_date, formula_id, create_user, create_ts, update_user, update_ts FROM dbo.source_generator WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_source_generator OFF
GO
ALTER TABLE dbo.power_outage
	DROP CONSTRAINT FK_power_outage_source_generator
GO
DROP TABLE dbo.source_generator
GO
EXECUTE sp_rename N'dbo.Tmp_source_generator', N'source_generator', 'OBJECT' 
GO
ALTER TABLE dbo.source_generator ADD CONSTRAINT
	PK_source_generator PRIMARY KEY CLUSTERED 
	(
	source_generator_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.source_generator ADD CONSTRAINT
	FK_source_generator_source_minor_location FOREIGN KEY
	(
	location_id
	) REFERENCES dbo.source_minor_location
	(
	source_minor_location_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_generator ADD CONSTRAINT
	FK_source_generator_static_data_value FOREIGN KEY
	(
	technology
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_generator ADD CONSTRAINT
	FK_source_generator_static_data_value1 FOREIGN KEY
	(
	fuel_type
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_generator ADD CONSTRAINT
	FK_source_generator_static_data_value2 FOREIGN KEY
	(
	generation_state
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_generator ADD CONSTRAINT
	FK_source_generator_source_uom FOREIGN KEY
	(
	uom_id
	) REFERENCES dbo.source_uom
	(
	source_uom_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_generator ADD CONSTRAINT
	FK_source_generator_fas_books FOREIGN KEY
	(
	book_id
	) REFERENCES dbo.fas_books
	(
	fas_book_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_generator ADD CONSTRAINT
	FK_source_generator_formula_editor FOREIGN KEY
	(
	formula_id
	) REFERENCES dbo.formula_editor
	(
	formula_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_generator ADD CONSTRAINT
	FK_source_generator_static_data_value3 FOREIGN KEY
	(
	technology_sub_type
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_generator ADD CONSTRAINT
	FK_source_generator_static_data_value4 FOREIGN KEY
	(
	udf_group_1
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_generator ADD CONSTRAINT
	FK_source_generator_static_data_value5 FOREIGN KEY
	(
	udf_group_2
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_generator ADD CONSTRAINT
	FK_source_generator_static_data_value6 FOREIGN KEY
	(
	udf_group_3
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
CREATE TRIGGER [dbo].[TRGUPD_source_generator]
ON dbo.source_generator
FOR UPDATE
AS
UPDATE source_generator SET update_user =  dbo.FNADBUser(), update_ts = getdate()  where  source_generator.source_generator_id in (select source_generator_id from deleted)
GO
CREATE TRIGGER [dbo].[TRGINS_source_generator]
ON dbo.source_generator
FOR INSERT
AS
UPDATE source_generator SET create_user =  dbo.FNADBUser(), create_ts = getdate() 
FROM source_generator s INNER JOIN inserted i ON s.source_generator_id=i.source_generator_id
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.power_outage ADD CONSTRAINT
	FK_power_outage_source_generator FOREIGN KEY
	(
	source_generator_id
	) REFERENCES dbo.source_generator
	(
	source_generator_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
