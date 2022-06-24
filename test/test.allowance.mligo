#import "../src/anti.mligo" "ANTI"
#import "./contracts/callback.mligo" "CALLBACK"
#import "./helpers/anti_func.mligo" "ANTI_HELPER"
#import "./helpers/bootstrap.mligo" "BOOTSTRAP"
#import "./helpers/assert.mligo" "ASSERT"
#import "./helpers/errors.mligo" "ERROR"

let () = Test.log("___ TEST ALLOWANCE STARTED ___")

let (ant_ctr, ant_addr, cbk_ctr, cbk_addr, alice, bob, james) = BOOTSTRAP.bootstrap_no_allowance ANTI_HELPER.base_config.init_token_supply ANTI_HELPER.base_config.init_token_balance

(* OK : Setting Allowance for James from Alice *)
let test_allowance_set (_ant_ctr : ANTI.parameter contract)(_cbk_ctr, _cbk_addr : nat contract * (CALLBACK.parameter, CALLBACK.storage) typed_address)(_alice, _james : address * address)(_allwn_amount : nat) =
    let () = Test.log("--> test_allowance_set : Setting 300n Allowance for James from Alice") in
    let allowance_request = ({
        request = { owner = _alice; spender = _james };
        callback = _cbk_ctr
    } : ANTI.getAllowance) in
    let result : test_exec_result = ANTI_HELPER.approve(_ant_ctr, _alice, _james, _allwn_amount) in
    let () = ASSERT.tx_success result in
    let cbk_storage = Test.get_storage _cbk_addr in
    let () = Test.log(cbk_storage) in
    let () = assert(cbk_storage = _allwn_amount) in
    Test.log("OK", cbk_storage)

let (ant_ctr, ant_addr, cbk_ctr, cbk_addr, alice, bob, james) = BOOTSTRAP.bootstrap_with_allowance ANTI_HELPER.base_config.init_token_supply ANTI_HELPER.base_config.init_token_balance (alice, james, 300n)

(* OK : Testing GetAllowance Callback for James from Alice *)
let test_allowance_callback  (_cbk_ctr : nat contract)(_alice, _james : address * address)(_allwn_amount : nat) =
    let () = Test.log("--> test_allowance_callback : Testing GetAllowance Callback for James from Alice") in
    let allowance_request = ({
        request = { owner = _alice; spender = _james };
        callback = _cbk_ctr
    } : ANTI.getAllowance) in
    let result_cbk : test_exec_result = Test.transfer_to_contract ant_ctr (GetAllowance allowance_request) 0tez in
    let () = ASSERT.tx_success result_cbk in
    let cbk_storage = Test.get_storage cbk_addr in
    let () = assert(cbk_storage = _allwn_amount) in
    Test.log("OK", cbk_storage)

(* OK : Transferring 200 from Alice to James initiated by James *)
let test_allowance_set_with_balance =
    let () = Test.log("--> test_allowance_set_with_balance : Transferring 200 from Alice to James initiated by James") in
    let result : test_exec_result = ANTI_HELPER.approved_transfer(ant_ctr, alice, james, ANTI_HELPER.base_config.tsfr_amount) in
    let () = ASSERT.tx_success result in
    ASSERT.assert_transfer_account(ant_addr, alice, james, ANTI_HELPER.base_config.init_token_balance, ANTI_HELPER.base_config.tsfr_amount)

(* KO : Transferring 10000 from Alice to James initiated by James *)
let test_allowance_set_with_no_balance =
    let () = Test.log("--> test_allowance_set_with_no_balance : Transferring 10000 from Alice to James initiated by James") in
    let result : test_exec_result = ANTI_HELPER.approved_transfer(ant_ctr, alice, james, 10000n) in
    ASSERT.string_failure result ERROR.err_not_enough_allowance

(* KO : Transferring 200 from Alice to Bob initiated by Bob *)
let test_allowance_not_set =
    let () = Test.log("--> test_allowance_not_set : Transferring 200 from Alice to Bob initiated by Bob") in
    let result : test_exec_result = ANTI_HELPER.approved_transfer(ant_ctr, alice, bob, ANTI_HELPER.base_config.tsfr_amount) in
    ASSERT.string_failure result ERROR.err_not_enough_allowance

// let () = test_supply_callback

let () = Test.log("___ TEST ALLOWANCE ENDED ___")