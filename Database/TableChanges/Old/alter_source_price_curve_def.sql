/*****************************************************************************************/
/* Modified By : Vishwas Khanal															 */
/* Date		   : 18.Dec.2008															 */
/* Description : Added the columns bid_value and ask_value								 */				
/* Purpose     : TRM Demo Requirement.													 */ 
/* Key		   : VK05TRN																 */
/*****************************************************************************************/
IF EXISTS(SELECT * from sys.columns WHERE [NAME]  = 'reference_curve_id'
AND OBJECT_ID = (SELECT OBJECT_ID FROM SYS.OBJECTS WHERE [NAME] = 'source_price_curve_def'))
BEGIN
	ALTER TABLE source_price_curve_def
	DROP COLUMN reference_curve_id 
END

ALTER TABLE source_price_curve_def
ADD reference_curve_id INT
	 


	




