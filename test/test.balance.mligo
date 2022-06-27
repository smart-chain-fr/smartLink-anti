#import "../src/anti.mligo" "ANTI"
#import "./contracts/callback.mligo" "CALLBACK"
#import "./helpers/anti_helper.mligo" "ANTI_HELPER"
#import "./helpers/bootstrap.mligo" "BOOTSTRAP"
#import "./helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST BALANCE STARTED ___")

let (ant_ctr, ant_addr, cbk_ctr, cbk_addr, alice, bob, james) = BOOTSTRAP.bootstrap_no_allowance ANTI_HELPER.base_config.init_token_supply ANTI_HELPER.base_config.init_token_balance

(* Getting Balance of Alice *)
let test_get_balance_from_storage (ant_addr : (ANTI.parameter, ANTI.storage) typed_address)(alice : address)(_init_token_balance : nat) =
    let () = Test.log("--> test_get_balance_from_storage : Alice should have ANTI_HELPER.base_config.init_token_balance = 1000n") in
    let retrieved_balance : nat = ANTI_HELPER.get_balance_from_storage(ant_addr, alice) in
    let () = assert(retrieved_balance = _init_token_balance) in
    Test.log("OK, Alice :", retrieved_balance)

let () = test_get_balance_from_storage ant_addr alice ANTI_HELPER.base_config.init_token_balance

(* Testing GetBalance Callback for Alice *)
let test_get_balance_callback (ant_ctr, ant_addr : ANTI.parameter contract * (ANTI.parameter, ANTI.storage) typed_address)(cbk_ctr, cbk_addr : nat contract * (CALLBACK.parameter, CALLBACK.storage) typed_address)(alice : address)(_init_token_balance : nat) =
    let () = Test.log("--> test_get_balance_callback : Testing GetBalance Callback for Alice") in
    let balance_of_request = ({
        owner = alice;
        callback = cbk_ctr;
    } : ANTI.getBalance) in
    let result_cbk = Test.transfer_to_contract ant_ctr (GetBalance balance_of_request) 0tez in
    let () = ASSERT.tx_success result_cbk in
    let cbk_storage = Test.get_storage cbk_addr in
    let () = assert(cbk_storage = _init_token_balance) in
    Test.log("OK, Alice :", cbk_storage)

let () = test_get_balance_callback (ant_ctr, ant_addr) (cbk_ctr, cbk_addr) alice ANTI_HELPER.base_config.init_token_balance

let () = Test.log("___ TEST BALANCE ENDED ___")