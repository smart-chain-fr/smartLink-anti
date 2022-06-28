#import "../src/anti.mligo" "ANTI"
#import "./helpers/anti_helper.mligo" "ANTI_HELPER"
#import "./helpers/bootstrap.mligo" "BOOTSTRAP"
#import "./helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST TRANSFER STARTED ___")

let (ant_ctr, ant_addr, cbk_ctr, cbk_addr, alice, bob, james) = BOOTSTRAP.bootstrap_no_allowance ANTI_HELPER.base_config.init_token_supply ANTI_HELPER.base_config.init_token_balance

(* OK : Transferring 100 from Alice to a random contract *)
let test_transfer_to_contract (_ant_ctr : ANTI.parameter contract)(_alice : address)(_tsfr_amount : nat) =
    let () = Test.log("--> test_transfer_to_contract : Transferring 100 from Alice to a random contract") in
    let result : test_exec_result = ANTI_HELPER.transfer(_ant_ctr, _alice, ANTI_HELPER.base_config.random_contract_address, _tsfr_amount) in
    let () = ASSERT.tx_success result in
    let () = ANTI_HELPER.assert_transfer_contract (ant_addr, _alice, ANTI_HELPER.base_config.random_contract_address, ANTI_HELPER.base_config.init_token_balance, _tsfr_amount) in
    let () = ANTI_HELPER.assert_burn_address_balance (ant_addr, 0n) in
    let () = ANTI_HELPER.assert_reserve_address_balance (ant_addr, 0n) in
    ()

let () = test_transfer_to_contract ant_ctr alice 100n

(* OK : Transferring 100 from Alice to Bob *)
let test_transfer_with_balance (_ant_ctr, _ant_addr : ANTI.parameter contract * (ANTI.parameter, ANTI.storage) typed_address)(_alice, _bob : address * address)(_tsfr_amount : nat) =
    let () = Test.log("--> test_transfer_with_balance : Transferring 100 from Alice to Bob") in
    let result : test_exec_result = ANTI_HELPER.transfer(_ant_ctr, _alice, _bob, _tsfr_amount) in
    let () = ASSERT.tx_success result in
    let ant_storage = Test.get_storage _ant_addr in
    let () = ANTI_HELPER.assert_transfer_account (_ant_addr, _alice, _bob, ANTI_HELPER.base_config.init_token_balance, _tsfr_amount) in
    let () = ANTI_HELPER.assert_burn_address_balance (ant_addr,_tsfr_amount) in
    let () = ANTI_HELPER.assert_reserve_address_balance (ant_addr,_tsfr_amount) in
    ()

let (ant_ctr, ant_addr, cbk_ctr, cbk_addr, alice, bob, james) = BOOTSTRAP.bootstrap_no_allowance ANTI_HELPER.base_config.init_token_supply ANTI_HELPER.base_config.init_token_balance
let () = test_transfer_with_balance (ant_ctr, ant_addr) (alice, bob) 100n

(* KO : Transferring 300 from Bob to Alice *)    
let test_transfer_with_no_balance (_ant_ctr : ANTI.parameter contract)(_alice, _bob : address * address)(_tsfr_amount : nat) =
    let () = Test.log("--> test_transfer_with_no_balance : Transferring 300 from Bob to Alice") in
    let result : test_exec_result = ANTI_HELPER.transfer(_ant_ctr, _bob, _alice, _tsfr_amount) in
    ASSERT.string_failure result ANTI.ERROR.not_enough_balance

let () = test_transfer_with_no_balance ant_ctr (alice, bob) 300n

(* KO : Transferring 500 from James to Alice *)    
let test_transfer_with_no_ledger_entry (_ant_ctr : ANTI.parameter contract)(_alice, _james : address * address)(_tsfr_amount : nat) =
    let () = Test.log("--> test_transfer_with_no_ledger_entry : Transferring 500 from James to Alice") in
    let result : test_exec_result = ANTI_HELPER.transfer(_ant_ctr, _james, _alice, _tsfr_amount) in
    ASSERT.string_failure result ANTI.ERROR.not_enough_balance

let () = test_transfer_with_no_ledger_entry ant_ctr (alice, james) 500n

let () = Test.log("___ TEST TRANSFER ENDED ___")