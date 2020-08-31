<?php

class ExcelAddinController extends REST {
	
    public function getQueryJson($body) {
        $xml_parameter = $body->xml_parameter;
		// var_dump($body);
		// echo $xml_parameter;die();
        $results = ExcelAddin::QueryJson($xml_parameter);
		
		// var_dump($results[0]['ResultJson']); die();
        $this->response($results[0]['ResultJson'], 200);
		// $this->response($this->json($results[0]),200);
    }
}
