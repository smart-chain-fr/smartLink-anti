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
    let anti_storage = Test.get_storage ant_addr in
    let storage_allowance = match Big_map.find_opt ({owner = _alice; spender = _james}) anti_storage.allowances with
        | Some value -> value
        | None -> 0n
    in
    let () = assert(_allwn_amount = storage_allowance) in
    Test.log("OK", storage_allowance)

let () = test_allowance_set ant_ctr (cbk_ctr, cbk_addr) (alice, james) 300n

// let (ant_ctr, ant_addr, cbk_ctr, cbk_addr, alice, bob, james) = BOOTSTRAP.bootstrap_with_allowance ANTI_HELPER.base_config.init_token_supply ANTI_HELPER.base_config.init_token_balance (alice, james, 300n)

(* OK : Testing GetAllowance Callback for James from Alice *)
let test_allowance_callback  (_cbk_ctr : nat contract)(_alice, _james : address * address) =
    let () = Test.log("--> test_allowance_callback : Testing GetAllowance Callback for James from Alice") in
    let allowance_request = ({
        request = { owner = _alice; spender = _james };
        callback = _cbk_ctr
    } : ANTI.getAllowance) in
    let result_cbk : test_exec_result = Test.transfer_to_contract ant_ctr (GetAllowance allowance_request) 0tez in
    let () = ASSERT.tx_success result_cbk in
    let cbk_storage = Test.get_storage cbk_addr in
    let anti_storage = Test.get_storage ant_addr in
    let storage_allowance = match Big_map.find_opt ({owner = _alice; spender = _james}) anti_storage.allowances with
        | Some value -> value
        | None -> 0n
    in
    let () = assert(cbk_storage = storage_allowance) in
    Test.log("OK", cbk_storage)

let () = test_allowance_callback cbk_ctr (alice, james)

(* OK : Transferring 200 from Alice to James initiated by James *)
let test_allowance_set_with_balance (_ant_ctr, _ant_addr : ANTI.parameter contract * (ANTI.parameter, ANTI.storage) typed_address)(_alice, _james : address * address)(_tsfr_amount : nat) =
    let () = Test.log("--> test_allowance_set_with_balance : Transferring 200 from Alice to James initiated by James") in
    let result : test_exec_result = ANTI_HELPER.approved_transfer(_ant_ctr, _alice, _james, _tsfr_amount) in
    let () = ASSERT.tx_success result in
    ASSERT.assert_transfer_account(_ant_addr, _alice, _james, ANTI_HELPER.base_config.init_token_balance, _tsfr_amount)

let () = test_allowance_set_with_balance (ant_ctr, ant_addr) (alice, james) 200n

(* KO : Transferring 10000 from Alice to James initiated by James *)
let test_allowance_set_with_no_balance (_ant_ctr : ANTI.parameter contract)(_alice, _james : address * address)(_tsfr_amount : nat) =
    let () = Test.log("--> test_allowance_set_with_no_balance : Transferring 10000 from Alice to James initiated by James") in
    let result : test_exec_result = ANTI_HELPER.approved_transfer(_ant_ctr, _alice, _james, _tsfr_amount) in
    ASSERT.string_failure result ERROR.err_not_enough_allowance

let () = test_allowance_set_with_no_balance ant_ctr (alice, james) 10000n

(* KO : Transferring 200 from Alice to Bob initiated by Bob *)
let test_allowance_not_set (_ant_ctr : ANTI.parameter contract)(_alice, _bob : address * address)(_tsfr_amount : nat) =
    let () = Test.log("--> test_allowance_not_set : Transferring 200 from Alice to Bob initiated by Bob") in
    let result : test_exec_result = ANTI_HELPER.approved_transfer(_ant_ctr, _alice, _bob, _tsfr_amount) in
    ASSERT.string_failure result ERROR.err_not_enough_allowance

let () = test_allowance_not_set ant_ctr (alice, bob) 200n

let () = Test.log("___ TEST ALLOWANCE ENDED ___")