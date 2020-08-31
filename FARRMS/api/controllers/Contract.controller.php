<?php

class ContractController extends REST {
    public function index() {
        $results = Contract::find();
        $this->response($this->json($results), 200);
    }

    public function get($contractId) {
        $results = Contract::findOne($contractId);
        $this->response($this->json($results[0]), 200);
    }
    
    public function getDependentContract($deal_template_id, $counterparty_id) {
        if ($deal_template_id != 'undefined')
            $results = Contract::findDependentContract($deal_template_id, $counterparty_id);
        else
            $results = Contract::find();
        $this->response($this->json($results), 200);
    }
}
