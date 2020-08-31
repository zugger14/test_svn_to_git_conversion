IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_holiday_block]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_holiday_block]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_holiday_block]
	@flag CHAR(1),
	@block_value_id INT = NULL,
	@onpeak_offpeak CHAR(1) = NULL

AS 

IF @flag = 's'
BEGIN
	SELECT	holiday_block_id, block_value_id, onpeak_offpeak,
			hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, hr14, hr15,
			hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24 
	FROM holiday_block s
	WHERE block_value_id = @block_value_id 
		AND onpeak_offpeak = 'p'
	ORDER BY onpeak_offpeak
	
	/*
	IMPORTANT: 
	OnPeak/OffPeak data are stored in two tables (hourly_block & holiday_block).
	Previously we have only one block definition (in static_data_value) and both onpeak/offpeak data are stored in those tables
	, but are differentiated by onpeak_offpeak flag. Calculation logic correctly picks those flag according to the block type (type_id: 12000) assigned.
	For e.g. 
	
	PREVIOUS LOGIC
	
	Block Definition: Hourly_Block_NERC (block_value_id: 5500)
	Table: hourly_block
	block_value_id	onpeak_offpeak	Hr1	Hr2	Hr3 Hr4	Hr5	Hr6	Hr7..Hr22	Hr23	Hr24
	5500			p				0	0	0	0	0	0	1			0		0
	5500			o				1	1	1	1	1	1	0			1		1
	
	Table: holiday_block
	block_value_id	onpeak_offpeak	Hr1	Hr2	Hr3 Hr4	Hr5	Hr6	Hr7	...		Hr23	Hr24
	5500			p				0	0	0	0	0	0	0	...		0		0
	5500			o				1	1	1	1	1	1	1	...		1		1
	
	Note that both dataset uses same block definition id (onpeak/offpeak). Correct data is picked for correct block type.
	
	NEW LOGIC
	Block defintion will be created differently for onpeak & offpeak. So, there will be two block definition as follows:
	Hourly_Block_NERC(block_value_id: 5500) & Hourly_Block_NERC_Offpeak(block_value_id: 5501)
	
	And data will be stored as follows:
	
	Table: hourly_block
	block_value_id	onpeak_offpeak	Hr1	Hr2	Hr3 Hr4	Hr5	Hr6	Hr7..Hr22	Hr23	Hr24
	5500			p				0	0	0	0	0	0	1			0		0
	5500			o				1	1	1	1	1	1	0			1		1
	5501			p				1	1	1	1	1	1	0			1		1
	5501			o				0	0	0	0	0	0	1			0		0
	
	Table: holiday_block
	block_value_id	onpeak_offpeak	Hr1	Hr2	Hr3 Hr4	Hr5	Hr6	Hr7	...		Hr23	Hr24
	5500			p				0	0	0	0	0	0	0	...		0		0
	5500			o				1	1	1	1	1	1	1	...		1		1
	5501			p				1	1	1	1	1	1	1	...		1		1
	5501			o				0	0	0	0	0	0	0	...		0		0
	
	Both offpeak and onpeak data will be saved for each block definition in pair, whether the block definition is an offpeak or onpeak.
	But the application only needs 'p' data only (both in case of onpeak and offpeak) and data of 'o' is not used. But it is not deleted
	for historical reasons (may be deleting was risky). So even when inserting new hourly data for a new block definition,
	a pair (one for 'p' & one for 'o') will be saved. Since only 'p' is required, this SP has been modified to return 'p' data only. Same is
	the case for spa_hourly_block.
	*/
END
