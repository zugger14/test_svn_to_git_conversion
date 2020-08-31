/*************************************************/
/* AUTHOR      : VISHWAS KHANAL					 */ 
/* DATED       : 15.JAN.2008					 */
/* PROJECT     : TRMTracker						 */
/* DESCRIPTION : CHANGE REQUEST AS ON 14 JAN 2004*/
/*************************************************/
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'limit_tracking' AND COLUMN_NAME = 'counterparty_id')
BEGIN
	ALTER TABLE limit_tracking ADD  counterparty_id INT CONSTRAINT[FK_counterparty_id] FOREIGN KEY(counterparty_id)  REFERENCES dbo.source_counterparty(source_counterparty_id)
END
