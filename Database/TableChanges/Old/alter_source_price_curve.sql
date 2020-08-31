/*****************************************************************************************/
/* Modified By : Vishwas Khanal															 */
/* Date		   : 18.Dec.2008															 */
/* Description : Added the columns bid_value and ask_value								 */				
/* Purpose     : TRM Demo Requirement.													 */ 
/* Key		   : VK03TRN																 */
/*****************************************************************************************/

ALTER TABLE source_price_curve ADD bid_value FLOAT
ALTER TABLE source_price_curve ADD ask_value FLOAT


