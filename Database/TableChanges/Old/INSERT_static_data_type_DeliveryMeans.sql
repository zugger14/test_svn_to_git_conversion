/*************************************************/
/* AUTHOR      : VISHWAS KHANAL					 */ 
/* DATED       : 20.JAN.2008					 */
/* PROJECT     : TRMTracker						 */
/* DESCRIPTION : CHANGE REQUEST AS ON 19 JAN 2004*/
/*************************************************/
IF NOT EXISTS(SELECT 'X' FROM dbo.static_data_type WHERE type_id = 11110)
BEGIN
	INSERT INTO dbo.static_data_type
			(type_id		,
			 type_name		,
			 internal		,
			 description	,
			 create_user	,
			 create_ts		,
			 update_user	,
			 update_ts)
	VALUES (11110			,
			'Delivery Means',
			0				,
			'Delivery Means',
			NULL			,
			NULL			,
			NULL			,
			NULL)
END
ELSE
BEGIN
	SELECT 'TYPE ID ALREADY EXISTS' AS "INFO"
END


