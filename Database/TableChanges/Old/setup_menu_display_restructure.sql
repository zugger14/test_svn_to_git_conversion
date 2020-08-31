------------------------------------------------------------
--Admin
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106399 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (10106399, NULL, 'Data Import', '', 1, 10100000, 10000000, 1, 1)
    PRINT 'Run Report Group - 10106399 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10106399 already exists.'
END


UPDATE setup_menu SET parent_menu_id = 10106399 WHERE  function_id IN (10106300 ,10131300) AND product_category = 10000000
       
-----------------------------------------------------
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106699 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (10106699, NULL, 'Alert and Workflow', '', 1, 10100000, 10000000, 1, 1)
    PRINT 'Alert and Workflow - 10106699 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10106699 already exists.'
END
  
UPDATE setup_menu SET   parent_menu_id = 10106699 WHERE  function_id IN (10122500, 10106600,10106700)  AND product_category = 10000000   


-----------------------------------------------------
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106499 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (10106499, NULL, 'Mapping Setup', '', 1, 10100000, 10000000, 1, 1)
    PRINT 'Mapping Setup - 10106499 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10106499 already exists.'
END
  
UPDATE setup_menu SET   parent_menu_id = 10106499 WHERE  function_id IN (13102000,10106400) AND product_category = 10000000   


-----------------------------------------------------
  
UPDATE setup_menu SET   parent_menu_id = 10101099 WHERE  function_id IN (10101182) AND product_category = 10000000   

-----------------------------------------------------
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104099 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (10104099, NULL, 'Template', '', 1, 10100000, 10000000, 1, 1)
    PRINT 'Template - 10106499 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10106499 already exists.'
END
  
UPDATE setup_menu SET   parent_menu_id = 10104099 WHERE  function_id IN (10102400,10101400,10104200,10104900,10211213,10104100) AND product_category = 10000000   
UPDATE setup_menu SET display_name = 'Report Manager - Old' WHERE  function_id = 10201600 AND product_category = 10000000
UPDATE setup_menu SET display_name = 'Report Manager' WHERE  function_id = 10202500 AND product_category = 10000000

-----------------------------------------------------
--Front Office
UPDATE setup_menu SET   parent_menu_id = 10150000 WHERE  function_id IN (10166200,10106100) AND product_category = 10000000  
UPDATE setup_menu SET display_name = 'Price Curve/Time Series' WHERE function_id = 10150000 AND product_category = 10000000
---------------------------------------------------------
	    
	  
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10161199 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (10161199, NULL, 'Setup', '', 1, 10160000, 10000000, 1, 1)
    PRINT 'Setup - 10161199 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10161199 already exists.'
END
  
UPDATE setup_menu SET   parent_menu_id = 10161199 WHERE  function_id IN (10161100 ,10162000,10166100,10163300,10163900,10165000) AND product_category = 10000000 

---------------------------------------------------------
	    
	  
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10161299 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (10161299, NULL, 'Power Operations', '', 1, 10160000, 10000000, 1, 1)
    PRINT 'Setup - 10161299 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10161299 already exists.'
END
  
UPDATE setup_menu SET parent_menu_id = 10161299 WHERE  function_id IN (10163200 ,10166700,10161800,10163100,10167000) AND product_category = 10000000

---------------------------------------------------------
	    
	  
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10161399 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (10161399, NULL, 'Inventory', '', 1, 10160000, 10000000, 1, 1)
    PRINT 'Setup - 10161399 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10161399 already exists.'
END
  
UPDATE setup_menu SET   parent_menu_id = 10161399 WHERE  function_id IN (10162300,10162500,10162100)  AND product_category = 10000000
      

---------------------------------------------------------
	    
	  
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10161499 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (10161499, NULL, 'Gas Operations', '', 1, 10160000, 10000000, 1, 1)
    PRINT 'Setup - 10161499 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10161499 already exists.'
END
  
UPDATE setup_menu SET   parent_menu_id = 10161499 WHERE  function_id IN (10163400,10163800,10164000,10163600,10164100,10164200,10166000,10164300,10164400) AND product_category = 10000000
       

---------------------------------------------------------
	    
	  
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10161599 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (10161599, NULL, 'Hydrocarbon Operations', '', 1, 10160000, 10000000, 1, 1)
    PRINT 'Setup - 10161599 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10161599 already exists.'
END
  
UPDATE setup_menu SET   parent_menu_id = 10161599 WHERE  function_id IN (10163700,10166500)  AND product_category = 10000000
 
    
---------------------------------------------------------
	    -- Middle Office 
	  
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10181099 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (10181099, NULL, 'Setup', '', 1, 10180000, 10000000, 1, 1)
    PRINT 'Setup - 10181099 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10181099 already exists.'
END
  
UPDATE setup_menu SET   parent_menu_id = 10181099 WHERE  function_id IN (10182500,10183000,10183200,10181300) AND product_category = 10000000
UPDATE setup_menu SET  hide_show = 0 WHERE  function_id IN (10181100,10182200) AND product_category = 10000000 -- Made Hidded
-----------------------------------------------------------------------------------------------------------------------
	   
	  
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10181199 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (10181199, NULL, 'Run Analytical Process', '', 1, 10180000, 10000000, 1, 1)
    PRINT 'Setup - 10181199 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 10181199 already exists.'
END
  
UPDATE setup_menu SET   parent_menu_id = 10181199  WHERE  function_id IN (10181000,10183100,10181200,10181800,10184000,10183400,10181400) AND product_category = 10000000


---------------------------------------------------------
-- Back Office 
	 
IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 15190000 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (15190000, NULL, 'Accounting Setup', '', 1, 10000000, 10000000, 1, 1)
    PRINT 'Setup - 15190000 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 15190000 already exists.'
END
  
UPDATE setup_menu SET   parent_menu_id = 15190000 WHERE  function_id IN (10101300,10103400,10101500,10231000) AND product_category = 10000000
-----------------------------------------------------------------------------------------------
UPDATE setup_menu SET   parent_menu_id = 10210000 WHERE  function_id IN (10104300) AND product_category = 10000000
       
--------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 13210000 AND product_category = 10000000)
BEGIN
    INSERT INTO setup_menu(function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category,menu_order, menu_type) 
    VALUES (13210000, NULL, 'Hedge Ineffectivenesss Measurement', '', 1, 13240000, 10000000, 1, 1)
    PRINT 'Setup - 13210000 INSERTED.'
END
ELSE
BEGIN
    PRINT 'Function ID 13210000 already exists.'
END       

--------------------------------------------------------------------------------------------
UPDATE setup_menu SET parent_menu_id = 13210000, menu_type = 0 WHERE function_id IN (10233400,10233300,10234600)
UPDATE setup_menu SET parent_menu_id = 10220000 WHERE function_id =10104600 AND product_category = 10000000 
UPDATE setup_menu SET display_name = 'Setup Alert' WHERE function_id = 10122500 AND product_category = 10000000 
UPDATE setup_menu SET display_name = 'Manage Document' WHERE function_id = 10102900 AND product_category = 10000000 
UPDATE setup_menu SET parent_menu_id = 10101099 WHERE function_id = 10103000 AND product_category = 10000000 
UPDATE setup_menu SET display_name = 'Setup Deal Field Template' WHERE function_id = 10104200 AND product_category = 10000000 
UPDATE setup_menu SET display_name = 'Map Rate Schedule' WHERE function_id =10163300 AND product_category = 10000000
UPDATE setup_menu SET display_name = 'Actualize Schedule' WHERE function_id =10166500 AND product_category = 10000000
UPDATE setup_menu SET display_name = 'Calculate Credit Risk Exposure' WHERE function_id =10191800 AND product_category = 10000000
UPDATE setup_menu SET display_name = 'Setup Manual Journal Entry' WHERE function_id =10237000 AND product_category = 10000000
UPDATE setup_menu SET display_name = 'Automate Hedge Matching' WHERE function_id =10234400 AND product_category = 10000000
UPDATE setup_menu SET display_name = 'Setup Hedging Relationship Type' WHERE function_id =10231900 AND product_category = 10000000
UPDATE setup_menu SET display_name = 'View Outstanding Automation Result' WHERE function_id =10234500 AND product_category = 10000000
UPDATE setup_menu SET hide_show = 0 WHERE function_id = 10121000 AND product_category  = 10000000 -- Hide Maintain Compliance Groups
UPDATE setup_menu SET display_name = 'Create and View Deal' WHERE function_id =10132000 AND product_category = 10000000
UPDATE setup_menu SET hide_show = 0 WHERE function_id IN (10181299,10183499,10181399,10181499,10181599,10103399) AND product_category = 10000000
UPDATE setup_menu SET parent_menu_id = 10110000 WHERE function_id = 10104000 AND product_category = 10000000
UPDATE setup_menu SET parent_menu_id = 10104099 WHERE function_id = 10101161 AND product_category = 10000000
UPDATE setup_menu SET parent_menu_id = 10161499 WHERE function_id IN(10166300,10166900) AND product_category = 10000000 
UPDATE setup_menu SET parent_menu_id = 10106499 WHERE function_id =10167200  AND product_category = 10000000 
UPDATE setup_menu SET parent_menu_id = 10150000 WHERE function_id =10167100  AND product_category = 10000000 
UPDATE setup_menu SET display_name = 'Setup CNG Deal' WHERE function_id =10132300  AND product_category = 10000000 




 










	  
