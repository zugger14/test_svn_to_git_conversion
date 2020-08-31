/* Script to insert section icons in default_parameter */
SET NOCOUNT ON

UPDATE setup_menu SET default_parameter = '<i class="fa fa-user icon_design" style="font-size:22px;"></i>' WHERE function_id = 20014000 AND product_category = 10000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-credit-card icon_design" style="font-size:20px;"></i>' WHERE function_id = 20014100 AND product_category = 10000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-area-chart icon_design"></i>' WHERE function_id = 20014200 AND product_category = 10000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-database icon_design"></i>' WHERE function_id = 20014300 AND product_category = 10000000

UPDATE setup_menu SET default_parameter = '<i class="fa fa-user icon_design" style="font-size:22px;"></i>' WHERE function_id = 20014000 AND product_category = 13000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-retweet icon_design" style="font-size:22px;"></i>' WHERE function_id = 20014400 AND product_category = 13000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-clipboard icon_design"></i>' WHERE function_id = 20014500 AND product_category = 13000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-newspaper-o icon_design"></i>' WHERE function_id = 20014600 AND product_category = 13000000

UPDATE setup_menu SET default_parameter = '<i class="fa fa-gears icon_design"></i>' WHERE function_id = 20014000 AND product_category = 14000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-bars icon_design"></i>' WHERE function_id = 20014700 AND product_category = 14000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-credit-card icon_design" style="font-size:20px;"></i>' WHERE function_id = 20014100 AND product_category = 14000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-area-chart icon_design"></i>' WHERE function_id = 20014200 AND product_category = 14000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-bank icon_design"></i>' WHERE function_id = 20014300 AND product_category = 14000000

UPDATE setup_menu SET default_parameter = '<i class="fa fa-user icon_design" style="font-size:22px;"></i>' WHERE function_id = 20014000 AND product_category = 15000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-file-text-o icon_design" style="font-size:20px;"></i>' WHERE function_id = 20014800 AND product_category = 15000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-money icon_design"></i>' WHERE function_id = 20014900 AND product_category = 15000000
UPDATE setup_menu SET default_parameter = '<i class="fa fa-calculator icon_design"></i>' WHERE function_id = 20015000 AND product_category = 15000000