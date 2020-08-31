# Routes:

## API URI: http://sjdev01.farrms.us/TRMTracker_branch/api/

## Routes list:

* POST index.php?rquest=login
    * payload Example:

      <pre>
      {
          "username": "farrms_admin",
          "password": "upper@@"
      }
      </pre>

* GET index.php?rquest=deal-template
* GET index.php?rquest=trader
* GET index.php?rquest=counterparty
* GET index.php?rquest=contract
* GET index.php?rquest=uom
* GET index.php?rquest=location
* GET index.php?rquest=curve
* GET index.php?rquest=sub_book
* GET index.php?rquest=frequency

* GET index.php?rquest=deal
* GET index.php?rquest=deal&deal_id=$dealId
* POST index.php?rquest=deal
* PUT index.php?rquest=deal&deal_id=$dealId

* GET index.php?rquest=search&q=$searchTxt

* GET index.php?rquest=alert
* GET index.php?rquest=workflow

* GET index.php?rquest=report
* GET index.php?rquest=reportfilter&report_param_id=$reportParamId
* POST index.php?rquest=viewreport
    * JSON Structure:
        * report_name
        * report_filter
        * items_combined
        * paramset_id
    * payload Example:

      <pre>
      {
          "report_name": "Position Deal Level Report_Position Deal Level Report_page1",
          "report_filter": "as_of_date=2016-06-01,period_from=0,period_to=24,source_deal_header_id=NULL,sub_id=1471,stra_id=1472,book_id=1474,sub_book_id=281,user_defined_block_id=NULL",
          "items_combined": "ITEM_DealLevelReport:11085",
          "paramset_id": "10886"
      }
      </pre>

* GET index.php?rquest=tradeticket&deal_ids=$dealId
* GET index.php?rquest=confirmation&deal_ids=$dealId
