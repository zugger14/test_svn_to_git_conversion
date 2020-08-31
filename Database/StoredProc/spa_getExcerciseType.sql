
IF OBJECT_ID(N'spa_getExcerciseType', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getExcerciseType]
GO 
 
CREATE PROCEDURE [dbo].[spa_getExcerciseType]
AS
CREATE TABLE #temp_table
(
	[id]    CHAR(1) COLLATE DATABASE_DEFAULT,
	[name]  VARCHAR(50) COLLATE DATABASE_DEFAULT
)

INSERT INTO #temp_table VALUES('a','American')
INSERT INTO #temp_table VALUES('e','European')
INSERT INTO #temp_table VALUES('s','Asian')  -- s because a is used so, second character.

SELECT *
FROM   #temp_table
