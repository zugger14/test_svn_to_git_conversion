/************************************************************
 * Code formatted by SoftTree SQL Assistant � v4.6.12
 * Time: 10/16/2012 1:23:08 AM
 ************************************************************/

IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FNAContractPriceCurve]')
              AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT')
   )
DROP FUNCTION [dbo].[FNAContractPriceCurve]

