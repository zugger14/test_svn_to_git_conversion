--------------------------------Setup------------------------------------------------------
--Maintain Definition
SELECT * FROM setup_menu WHERE function_id = 10101100  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE sm.parent_menu_id = 10101099 AND product_category = 10000000
DELETE FROM setup_menu WHERE parent_menu_id = 10101099 AND function_id = 10101100 AND product_category = 10000000
--DELETE FROM setup_menu WHERE function_id = 10101100 AND product_category = 1000000

--Setup Netting Group
SELECT * FROM setup_menu WHERE function_id = 10101500  AND product_category = 10000000 AND parent_menu_id =10100000
DELETE FROM setup_menu WHERE function_id = 10101500  AND product_category = 10000000 AND parent_menu_id =10100000

--Setup Profile
SELECT * FROM setup_menu WHERE function_id = 10102800  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE sm.parent_menu_id = 10101099 AND product_category = 10000000
DELETE FROM setup_menu WHERE parent_menu_id = 10101099 AND function_id = 10102800  AND product_category = 10000000
--DELETE FROM setup_menu WHERE function_id = 10102800 AND product_category = 1000000

--Setup Deal Template
SELECT * FROM setup_menu WHERE parent_menu_id=10100000 AND  function_id = 10101499  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE sm.parent_menu_id = 10101499 AND product_category = 10000000
--Sub Menu
DELETE FROM setup_menu WHERE parent_menu_id = 10101499  AND product_category = 10000000
--Menu
DELETE FROM setup_menu  WHERE parent_menu_id=10100000 AND  function_id = 10101499  AND product_category = 10000000

--Setup Contract Components	(Setup Price)
SELECT * FROM setup_menu WHERE function_id = 10103399  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10103399  AND product_category = 10000000 AND function_id = 10104400
--DELETE FROM setup_menu WHERE function_id = 10101499 AND product_category = 1000000
DELETE FROM setup_menu WHERE  parent_menu_id = 10103399  AND product_category = 10000000 AND function_id = 10104400

--Maintain Source Generator
SELECT * FROM setup_menu WHERE function_id = 10103800  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10103800  AND product_category = 10000000 
DELETE FROM setup_menu WHERE  function_id = 10103800  AND product_category = 10000000

--Setup Logical Trade Lock
SELECT * FROM setup_menu WHERE function_id = 10101900  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10101900  AND product_category = 10000000 
DELETE FROM setup_menu WHERE  function_id = 10101900  AND product_category = 10000000

--Setup As of Date
SELECT * FROM setup_menu WHERE function_id = 10102200  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10102200  AND product_category = 10000000 
DELETE FROM setup_menu WHERE  function_id = 10102200  AND product_category = 10000000

--Setup Tenor Bucket
SELECT * FROM setup_menu WHERE function_id = 10102000  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10102000  AND product_category = 10000000 
DELETE FROM setup_menu WHERE  function_id = 10102000  AND product_category = 10000000

--Mapping Setup
SELECT * FROM setup_menu WHERE function_id = 13170000  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 13170000  AND product_category = 10000000
DELETE FROM setup_menu WHERE  function_id IN (10103100,10103200,13171000)  AND product_category = 10000000 
DELETE FROM setup_menu WHERE  function_id = 13170000  AND product_category = 10000000
UPDATE setup_menu SET parent_menu_id = 10100000 WHERE function_id  = 13102000 

--Setup Emissions Source/Sink Type
SELECT * FROM setup_menu WHERE function_id = 10102300  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10102300  AND product_category = 10000000 
DELETE FROM setup_menu WHERE  function_id = 10102300  AND product_category = 10000000

--maintain Renewable Sources
SELECT * FROM setup_menu WHERE function_id = 12101700  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 12101700  AND product_category = 10000000 
DELETE FROM setup_menu WHERE  function_id = 12101700  AND product_category = 10000000

--Lock As of Date
SELECT * FROM setup_menu WHERE function_id = 10105200  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10105200  AND product_category = 10000000
DELETE FROM setup_menu WHERE  function_id = 10105200  AND product_category = 10000000

--Manage Data
SELECT * FROM setup_menu WHERE function_id = 10102799  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10102799  AND product_category = 10000000
DELETE FROM setup_menu WHERE  parent_menu_id IN (10102799)  AND product_category = 10000000
DELETE FROM setup_menu WHERE  function_id = 10102799  AND product_category = 10000000

--Maintain Settlement Netting Group
SELECT * FROM setup_menu WHERE function_id = 10104600  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10104600  AND product_category = 10000000
DELETE FROM setup_menu WHERE  function_id = 10104600  AND product_category = 10000000

--Compliance Management
SELECT * FROM setup_menu WHERE function_id = 10120000  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10120000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE function_id  = 10122500 AND parent_menu_id = 10100000
DELETE FROM setup_menu WHERE  function_id IN(10121300, 10121000, 10121400, 10121500, 10121200, 10121100, 10122300)  AND product_category = 10000000
DELETE FROM setup_menu WHERE  function_id = 10120000  AND product_category = 10000000
UPDATE setup_menu SET parent_menu_id = 10100000 WHERE function_id  = 10122500

--Setup User Defined Fields
SELECT * FROM setup_menu WHERE function_id = 10104700  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10100000  AND product_category = 10000000
DELETE FROM setup_menu WHERE  function_id = 10104700  AND product_category = 10000000

---Maintain Events Rules(Hide)
SELECT * FROM setup_menu AS sm WHERE sm.function_id = 10122500 AND product_category = 10000000
UPDATE setup_menu SET parent_menu_id = null where function_id = 10122500 AND product_category = 10000000
--------------------------------End Setup----------------------------------------------------------------------------------------

--------------------------------Deal Capture-------------------------------------------------------------------------------------

SELECT * FROM setup_menu WHERE function_id = 10130000  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10130000  AND product_category = 10000000
DELETE FROM setup_menu WHERE parent_menu_id = 10130000 AND  function_id IN (10131300,10131500,10131600,10234700)  AND product_category = 10000000
--------------------------------End Deal Capture-------------------------------------------------------------------------------------

--------------------------------Postion Reporting-------------------------------------------------------------------------------------

SELECT * FROM setup_menu WHERE function_id = 10140000  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10140000  AND product_category = 10000000
--SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10142300  AND product_category = 10000000
DELETE FROM setup_menu WHERE  parent_menu_id = 10140000  AND product_category = 10000000
DELETE FROM setup_menu WHERE  function_id = 10140000  AND product_category = 10000000
--------------------------------End Postion Reporting-------------------------------------------------------------------------------------

--------------------------------Price Curve Management------------------------------------------------------------------------------------
--Import Price
SELECT * FROM setup_menu WHERE function_id = 10150000  AND product_category = 10000000
SELECT * FROM setup_menu AS sm WHERE  parent_menu_id = 10150000  AND product_category = 10000000
DELETE FROM setup_menu WHERE  function_id = 10151100  AND product_category = 10000000
--------------------------------End Price Curve Management------------------------------------------------------------------------------------

----------------------------------Schedule and Delivery---------------------------------------------------------------------------------------
SELECT * FROM setup_menu WHERE function_id = 10160000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE parent_menu_id = 10160000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE function_id IN(10161000,10161400,10162600,10162100,10162500,10162400,10161300,10161800,10162200,10161200)   AND product_category = 10000000
DELETE FROM setup_menu WHERE function_id IN(10161000,10161400,10162600,10162100,10162500,10162400,10161300,10161800,10162200,10161200)  AND product_category = 10000000
----------------------------------End Schedule and Delivery---------------------------------------------------------------------------------------

----------------------------------Deal Verification and Confirmation------------------------------------------------------------------------------
SELECT * FROM setup_menu WHERE function_id = 10170000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE parent_menu_id = 10170000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE parent_menu_id IN(10171000,10171400,10171500,10171100,10171200,10171300,10171700)   AND product_category = 10000000
DELETE  setup_menu WHERE parent_menu_id  = 10170000  AND product_category = 10000000
DELETE  setup_menu WHERE function_id = 10170000  AND product_category = 10000000
----------------------------------End Deal Verification and Confirmation------------------------------------------------------------------------------

----------------------------------Valuation and Risk Analysis----------------------------------------------------------------------------------------
SELECT * FROM setup_menu WHERE function_id = 10180000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE parent_menu_id = 10180000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE parent_menu_id IN(110181099,10183000,10183100,10181299,10181399,10181499,10182300,10182600,10182400,10182900,10183499,10183200) AND product_category = 10000000
--Sub Menu
DELETE FROM setup_menu WHERE parent_menu_id = 10181299  AND product_category = 10000000 
DELETE FROM setup_menu WHERE parent_menu_id = 10181399  AND product_category = 10000000
DELETE FROM setup_menu WHERE parent_menu_id = 10181499  AND product_category = 10000000
DELETE FROM setup_menu WHERE parent_menu_id = 10183499  AND product_category = 10000000
--Menu 
DELETE FROM setup_menu WHERE parent_menu_id = 10180000  AND product_category = 10000000 
--Module
DELETE FROM setup_menu WHERE function_id = 10180000  AND product_category = 10000000
----------------------------------End Valuation and Risk Analysis----------------------------------------------------------------------------------------

----------------------------------Credit Risk and Analysis-----------------------------------------------------------------------------------------------
SELECT * FROM setup_menu WHERE function_id = 10190000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE parent_menu_id = 10190000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE function_id IN(10191000,10192000,10191100,10191200,10191300,10191400,10191500,10191600,10191700,10191800,10191900,10192200,10192300) AND product_category = 10000000
DELETE FROM setup_menu WHERE parent_menu_id = 10190000 AND product_category = 10000000
DELETE FROM setup_menu WHERE function_id = 10190000  AND product_category = 10000000
----------------------------------End Credit Risk and Analysis-----------------------------------------------------------------------------------------------

------------------------------------Reporting----------------------------------------------------------------------------------------------------------------
SELECT * FROM setup_menu WHERE function_id = 10200000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE parent_menu_id = 10200000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE function_id IN(10201700,10201800,10111500,10201300,10201400,10201500,10201000,10201900,10201100,10201200) AND product_category = 10000000
DELETE FROM setup_menu WHERE function_id IN(10201700,10201800,10111500,10201300,10201400,10201500,10201000,10201900,10201100,10201200) AND product_category = 10000000
------------------------------------End Reporting----------------------------------------------------------------------------------------------------------------

--------------------------------Contract Administration------------------------------------------------------------------------------------------------
SELECT * FROM setup_menu WHERE function_id = 10210000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE parent_menu_id = 10210000  AND product_category = 10000000
DELETE FROM setup_menu WHERE function_id = 10211010 AND product_category = 10000000 -- Deleted Maintain Settlement Rules
--------------------------------End Contract Administration-----------------------------------------------------------------------------------------

-----------------------------------Settlement and Billing-------------------------------------------------------------------------------------
SELECT * FROM setup_menu WHERE function_id = 10220000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE parent_menu_id = 10220000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE parent_menu_id = 10221999  AND product_category = 10000000
DELETE FROM setup_menu WHERE parent_menu_id IN(10221999)  AND product_category = 10000000
DELETE FROM setup_menu WHERE function_id IN(10221600,10221999,10222400,10231700,10222500,10221400,10221700,10222000)  AND product_category = 10000000

--Run Inventory Calc
SELECT * FROM setup_menu WHERE function_id = 10221100  AND product_category = 10000000 AND parent_menu_id =10221099
DELETE FROM setup_menu WHERE function_id = 10221100  AND product_category = 10000000 AND parent_menu_id =10221099
-----------------------------------End Settlement and Billing-------------------------------------------------------------------------------------


------------------------------------------------Treasury------------------------------------------------------------------------------------------
SELECT * FROM setup_menu WHERE function_id = 10240000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE parent_menu_id = 10240000  AND product_category = 10000000
DELETE FROM setup_menu  WHERE parent_menu_id = 10240000  AND product_category = 10000000
DELETE FROM setup_menu  WHERE function_id = 10240000  AND product_category = 10000000
------------------------------------------------End Treasury------------------------------------------------------------------------------------------

------------------------------------Users Roles-------------------------------------------------------------------------------------
SELECT * FROM setup_menu WHERE function_id = 10110000  AND product_category = 10000000
SELECT * FROM setup_menu WHERE parent_menu_id  = 10110000  AND product_category = 10000000
DELETE FROM setup_menu  WHERE function_id IN ( 10111300,10111400)  AND product_category = 10000000 

-----------------------------------End Users Roles----------------------------------------------------------------------------




