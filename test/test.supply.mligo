#import "../src/anti.mligo" "ANTI"
#import "./contracts/callback.mligo" "CALLBACK"
#import "./helpers/anti_func.mligo" "ANTI_HELPER"
#import "./helpers/bootstrap.mligo" "BOOTSTRAP"
#import "./helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST SUPPLY STARTED ___")

let (ant_ctr, ant_addr, cbk_ctr, cbk_addr, alice, bob, james) = BOOTSTRAP.bootstrap_no_allowance ANTI_HELPER.base_config.init_token_supply ANTI_HELPER.base_config.init_token_balance

let test_supply_callback (ant_ctr, ant_addr : ANTI.parameter contract * (ANTI.parameter, ANTI.storage) typed_address)(cbk_ctr, cbk_addr : nat contract * (CALLBACK.parameter, CALLBACK.storage) typed_address) =
    let () = Test.log("--> test_get_supply_callback : Testing GetTotalSupply Callback after transfers") in
    let burn_balance : nat = ANTI_HELPER.get_balance_from_storage(ant_addr, ANTI_HELPER.base_config.burn_address) in
    let supply_request = ({
        request =  ();
        callback = cbk_ctr;
    } : ANTI.getTotalSupply) in
    let result = Test.transfer_to_contract ant_ctr (GetTotalSupply supply_request) 0tez in
    let () = ASSERT.tx_success result in
    let ant_storage = Test.get_storage ant_addr in
    let cbk_storage = Test.get_storage cbk_addr in
    let () = assert(cbk_storage = ant_storage.total_supply) in
    Test.log("OK", cbk_storage)

let () = test_supply_callback (ant_ctr, ant_addr)(cbk_ctr, cbk_addr)

let () = Test.log("___ TEST SUPPLY ENDED ___")