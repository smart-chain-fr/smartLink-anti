#import "../src/anti.mligo" "ANTI"
#import "./contracts/CALLBACK.mligo" "CALLBACK"
#import "./helpers/anti.func.mligo" "Anti_helper"
#import "./helpers/assert.mligo" "ASSERT"
#import "./helpers/errors.mligo" "ERROR"

let test =
    let () = Test.log("___ TEST SEQUENCE STARTED ___") in

    let random_contract_addr : address = ("KT1MsktCnwfS1nGZmf8QbaTpZ8euVijWdmkC" : address) in
    let init_token_supply = 777777777777n in
    let init_token_balance = 1000n in

    let (ant_ctr, ant_addr, cbk_ctr, cbk_addr, alice, bob, james) = Anti_helper.bootstrap init_token_supply init_token_balance in

    (* Testing GetTotalSupply Callback on Origination *)
    let test_get_supply_callback_initial = 
        let () = Test.log("--> test_get_supply_callback_initial : Testing GetTotalSupply Callback on Origination") in
        let supply_request = ({
            request =  ();
            callback = cbk_ctr;
        } : ANTI.getTotalSupply) in
        let result_cbk = Test.transfer_to_contract ant_ctr (GetTotalSupply supply_request) 0tez in
        let () = ASSERT.tx_success result_cbk in
        let cbk_storage = Test.get_storage cbk_addr in
        let () = assert(cbk_storage = init_token_supply) in
        Test.log("OK", cbk_storage)
    in

    (* Getting Balance of Alice *)
    let test_get_balance_from_storage =
        let () = Test.log("--> test_get_balance_from_storage : Alice should have init_token_balance = 1000n") in
        let retrieved_balance : nat = Anti_helper.get_balance_from_storage(ant_addr, alice) in
        let () = assert(retrieved_balance = init_token_balance) in
        Test.log("OK, Alice :", retrieved_balance)
    in
    
    (* Testing GetBalance Callback for Alice *)
    let test_get_balance_callback = 
        let () = Test.log("--> test_get_balance_callback : Testing GetBalance Callback for Alice") in
        let balance_of_request = ({
            owner = alice;
            callback = cbk_ctr;
        } : ANTI.getBalance) in
        let result_cbk = Test.transfer_to_contract ant_ctr (GetBalance balance_of_request) 0tez in
        let () = ASSERT.tx_success result_cbk in
        let cbk_storage = Test.get_storage cbk_addr in
        let () = assert(cbk_storage = init_token_balance) in
        Test.log("OK, Alice :", cbk_storage)
    in

    (* OK : Transferring 100 from Alice to a random contract *)
    let test_transfer_to_contract =
        let () = Test.log("--> test_transfer_to_contract : Transferring 100n from Alice to a random contract") in
        let tsfr_amount = 100n in
        let result : test_exec_result = Anti_helper.transfer(ant_ctr, alice, random_contract_addr, tsfr_amount) in
        let () = ASSERT.tx_success result in
        ASSERT.assert_transfer_contract(ant_addr, alice, random_contract_addr, init_token_balance, tsfr_amount)
    in
    
    let (ant_ctr, ant_addr, cbk_ctr, cbk_addr, alice, bob, james) = Anti_helper.bootstrap init_token_supply init_token_balance in

    (* OK : Transferring 100 from Alice to Bob *)
    let test_transfer_with_balance =
        let () = Test.log("--> test_transfer_with_balance : Transferring 100n from Alice to Bob") in
        let tsfr_amount = 100n in
        let result : test_exec_result = Anti_helper.transfer(ant_ctr, alice, bob, tsfr_amount) in
        let () = ASSERT.tx_success result in
        ASSERT.assert_transfer_account(ant_addr, alice, bob, init_token_balance, tsfr_amount)
    in
    
    (* KO : Transferring 300 from Bob to Alice *)    
    let test_transfer_with_no_balance =
        let () = Test.log("--> test_transfer_with_no_balance : Transferring 300 from Bob to Alice") in
        let tsfr_amount = 300n in
        let result : test_exec_result = Anti_helper.transfer(ant_ctr, bob, alice, tsfr_amount) in
        ASSERT.string_failure result ERROR.err_not_enough_balance
    in

    let (ant_ctr, ant_addr, cbk_ctr, cbk_addr, alice, bob, james) = Anti_helper.bootstrap init_token_supply init_token_balance in

    (* KO : Transferring 300 from James to Alice *)    
    let test_transfer_with_no_ledger_entry =
        let () = Test.log("--> test_transfer_with_no_ledger_entry : Transferring 500 from James to Alice") in
        let tsfr_amount = 500n in
        let result : test_exec_result = Anti_helper.transfer(ant_ctr, james, alice, tsfr_amount) in
        ASSERT.string_failure result ERROR.err_not_enough_balance
    in

    let (ant_ctr, ant_addr, cbk_ctr, cbk_addr, alice, bob, james) = Anti_helper.bootstrap init_token_supply init_token_balance in

    (* OK : Setting Allowance for James from Alice *)
    let test_allowance_set =
        let () = Test.log("--> test_allowance_set : Setting 300n Allowance for James from Alice") in
        let allwn_amount = 300n in
        let result : test_exec_result = Anti_helper.approve(ant_ctr, alice, james, allwn_amount) in
        ASSERT.tx_success result
    in

    (* OK : Testing GetAllowance Callback for James from Alice *)
    let test_allowance_calllback =
        let () = Test.log("--> test_allowance_calllback : Testing GetAllowance Callback for James from Alice") in
        let allowance_request = ({
            request =   { owner = alice; spender = james };
            callback = cbk_ctr;
        } : ANTI.getAllowance) in
        let result_cbk : test_exec_result = Test.transfer_to_contract ant_ctr (GetAllowance allowance_request) 0tez in
        let () = ASSERT.tx_success result_cbk in
        let cbk_storage = Test.get_storage cbk_addr in
        let () = assert(cbk_storage = 300n) in
        Test.log("OK", cbk_storage)
    in

    (* OK : Transferring 200 from Alice to James initiated by James *)
    let test_allowance_set_with_balance =
        let () = Test.log("--> test_allowance_set_with_balance : Transferring 200 from Alice to James initiated by James") in
        let tsfr_amount = 200n in
        let result : test_exec_result = Anti_helper.approved_transfer(ant_ctr, alice, james, tsfr_amount) in
        let () = ASSERT.tx_success result in
        ASSERT.assert_transfer_account(ant_addr, alice, james, init_token_balance, tsfr_amount)
    in

    (* KO : Transferring 10000 from Alice to James initiated by James *)
    let test_allowance_set_with_no_balance =
        let () = Test.log("--> test_allowance_set_with_no_balance : Transferring 10000 from Alice to James initiated by James") in
        let result : test_exec_result = Anti_helper.approved_transfer(ant_ctr, alice, james, 10000n) in
        ASSERT.string_failure result ERROR.err_not_enough_allowance
    in

    (* KO : Transferring 200 from Alice to Bob initiated by Bob *)
    let test_allowance_not_set =
        let () = Test.log("--> test_allowance_not_set : Transferring 200 from Alice to Bob initiated by Bob") in
        let result : test_exec_result = Anti_helper.approved_transfer(ant_ctr, alice, bob, 200n) in
        ASSERT.string_failure result ERROR.err_not_enough_allowance
    in
    
    (* Testing GetTotalSupply Callback after transfers *)
    let test_get_supply_callback = 
        let () = Test.log("--> test_get_supply_callback : Testing GetTotalSupply Callback after transfers") in
        let _burn_address : address = ("tz1burnburnburnburnburnburnburjAYjjX" : address) in
        let burn_balance : nat = Anti_helper.get_balance_from_storage(ant_addr, _burn_address) in
        let supply_request = ({
            request =  ();
            callback = cbk_ctr;
        } : ANTI.getTotalSupply) in
        let result = Test.transfer_to_contract ant_ctr (GetTotalSupply supply_request) 0tez in
        let () = ASSERT.tx_success result in
        let ant_storage = Test.get_storage ant_addr in
        let cbk_storage = Test.get_storage cbk_addr in
        let () = assert(cbk_storage = ant_storage.total_supply) in
        let () = assert(cbk_storage = abs(init_token_supply - burn_balance)) in
        Test.log("OK", cbk_storage)
    in

    Test.log("___ END OF TEST SEQUENCE ___")