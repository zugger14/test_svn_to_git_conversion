UPDATE source_deal_detail_hour 
SET hr =  RIGHT('0' + hr, 2) + ':00'
WHERE ISNUMERIC(hr) = 1
