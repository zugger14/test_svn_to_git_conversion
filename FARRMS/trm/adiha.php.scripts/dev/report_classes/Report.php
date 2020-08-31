<?php

/**
 * @author Narendra Shrestha
 * @copyright 2011
 */

abstract class Report {
	/**
	 * getReportName()
	 * Gives report name
	 * @return string Returns name of report.
	 */
	abstract protected function getReportSPName();

	/**
	 * getReportDefinition()
	 * Defines structure of row and column, number format, total/subtotal structure.
	 * @param mixed $fields: No of columns.
	 * @param mixed $arrayR: Array of query filter.
	 * @return array
	 */
	abstract protected function getReportDefinition($fields, $arrayR = null);

	/**
	 * getReportFilterDefinition()
	 * Defines the name of filter applied in the report, displayed in report header
	 * @param mixed $arrayR: Array of query filter.
	 * @param mixed $callFrom: Called from parameter.
	 * @return array
	 */
	abstract protected function getReportFilterDefinition($arrayR, $callFrom = null);

	/**
	 * getDrillDownRef()
	 * Generates drill down for required columns in report.
	 * @param mixed $result: array of resultset/output of query.
	 * @param mixed $arrayR: Array of query filter.
	 * @param mixed $fields: No of columns.
	 * @param mixed $tmpIndex: Temporary index of resultset array.
	 * @param mixed $j: Column index of resultset array.
	 * @param mixed $i: Row index of resultset array.
	 * @return string
	 */
	public function getDrillDownRef($result, $arrayR, $fields, $i, $j, $tmpIndex) {
		return null;
	}

	/**
	 * getDrillDownRefSubTotal()
	 * Generates drill down for required columns in report.
	 * @param mixed $result: array of resultset/output of query.
	 * @param mixed $arrayR: Array of query filter.
	 * @param mixed $fields: No of columns.
	 * @param mixed $tmpIndex: Temporary index of resultset array.
	 * @param mixed $j: Column index of resultset array.
	 * @param mixed $i: Row index of resultset array.
	 * @return string
	 */
	public function getSubTotalDrillDownRef($result, $arrayR, $fields, $i, $j, $tmpIndex) {
		return null;
	}
}

?>