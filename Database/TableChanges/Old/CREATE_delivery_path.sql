/*************************************************/
/* AUTHOR      : VISHWAS KHANAL					 */ 
/* DATED       : 20.JAN.2008					 */
/* PROJECT     : TRMTracker						 */
/* DESCRIPTION : CHANGE REQUEST AS ON 19 JAN 2004*/
/*************************************************/

IF OBJECT_ID('dbo.delivery_path','u') IS NULL
BEGIN
	CREATE TABLE dbo.delivery_path 
			(path_id	     INT IDENTITY		,
			path_code		 VARCHAR(50)		,
			path_name		 VARCHAR(50)		,
			delivery_means   INT				,
			from_location_id INT CONSTRAINT[fk_from_location_id] FOREIGN KEY REFERENCES dbo.source_minor_location(source_minor_location_id),
			to_location_id	 INT CONSTRAINT[fk_to_location_id] FOREIGN KEY REFERENCES dbo.source_minor_location(source_minor_location_id))					
END
ELSE
BEGIN
		SELECT 'TABLE ALREADY EXISTS' AS "INFO"
END


