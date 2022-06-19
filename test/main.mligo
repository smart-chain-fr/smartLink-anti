#import "../src/anti.mligo" "ANTI"
#import "./functions.mligo" "FUNC"
#import "./errors.mligo" "ERROR"
#import "./contracts/CALLBACK.mligo" "CALLBACK"
#import "./helpers/assert.mligo" "ASSERT"
#import "./helpers/log.mligo" "LOG"

let test =
    (* Boostrapping environment *)
    let init_token_supply = 777777777777n in
    let init_token_balance = 10000n in

    (* Boostrapping accounts *)
    let () = Test.reset_state 3n ([] : tez list) in
    let alice: address = Test.nth_bootstrap_account 0 in
    let bob: address = Test.nth_bootstrap_account 1 in
    let james: address = Test.nth_bootstrap_account 2 in

    (* Boostrapping storage *)
    let init_storage : ANTI.storage = {
        admin = ("tz1aECt4ZEGaBFhviqE4b8tCSusmtbVSiCeK" : address);
        allowances = (Big_map.empty : ( ANTI.allowance_key , nat) big_map);
        burn_address = ("tz1i5sBpcYFn9JmVUsrsULKJJPTskBg1MmZm" : address);
        burned_supply = 0n;
        initial_supply = init_token_supply;
        ledger = (Big_map.literal [(alice, init_token_balance)]);
        metadata = (Big_map.empty : ( string, bytes ) big_map);
        reserve = ("tz1YThQWeWuPRjFtpAzcsZeyzSkD8sEsRQiK" : address);
        token_metadata = (Big_map.literal [
            ( 0n, {token_id = 0n; token_info = (Map.empty : ( string, bytes ) map)} )
        ]);
        total_supply = init_token_supply
    } in

    (* Boostrapping ANTI contract *)
    let (addr,_,_) = Test.originate ANTI.main init_storage 0tez in    
    let x : ANTI.parameter contract = Test.to_contract addr in

    (* Boostrapping Callback contract *)
    let (callback_addr,_,_) = Test.originate CALLBACK.main (0n) 0tez in
    let callback_contract = Test.to_contract callback_addr in

    (* Showing ANTI initial storage *)
    let s_init = Test.get_storage addr in
    let () = Test.log("Initial Storage :", s_init) in

    (* Getting Balance of Alice *)
    let test_get_balance_from_storage =
        let () = Test.log("test_get_balance_from_storage ") in
        let retrieved_balance_opt : nat option = FUNC.get_balance_from_storage(addr, alice) in
        let retrieved_balance = match retrieved_balance_opt with    
        | Some x -> x
        | None -> 0n
        in
        let () = assert(retrieved_balance = 10000n) in
        Test.log("OK", retrieved_balance)
    in

    (* OK : Transferring 100 from Alice to Bob *)
    let test_transfer_with_balance =
        let () = Test.log("_transfer_with_balance") in
        let result : test_exec_result = FUNC.transfer(x, alice, bob, 100n) in
        let () = ASSERT.tx_success result in
        let retrieved_balance = match FUNC.get_balance_from_storage(addr, bob) with    
        | Some x -> x
        | None -> 0n
        in
        let () = assert(retrieved_balance = 92n) in
        Test.log("OK", retrieved_balance)
    in
    
    (* KO : Transferring 300 from Bob to Alice *)    
    let test_transfer_with_no_balance =
        let () = Test.log("_transfer_with_no_balance") in
        let result : test_exec_result = FUNC.transfer(x, bob, alice, 300n) in
        let () = ASSERT.string_failure result ERROR.err_not_enough_balance in
        let retrieved_balance = match FUNC.get_balance_from_storage(addr, bob) with    
        | Some x -> x
        | None -> 0n
        in
        let () = assert(retrieved_balance = 92n) in
        Test.log("OK", retrieved_balance)
    in

    (* KO : Transferring 300 from James to Alice *)    
    let test_transfer_with_no_ledger_entry =
        let () = Test.log("_transfer_with_no_ledger_entry") in
        let result : test_exec_result = FUNC.transfer(x, james, alice, 300n) in
        let () = ASSERT.string_failure result ERROR.err_not_enough_balance in
        let retrieved_balance = match FUNC.get_balance_from_storage(addr, alice) with    
        | Some x -> x
        | None -> 0n
        in
        let () = assert(retrieved_balance = 9900n) in
        Test.log("OK", retrieved_balance)
    in

    (* OK : Setting Allowance for James from Alice *)
    let test_allowance_set =
        let () = Test.log("_allowance_set") in
        let result : test_exec_result = FUNC.approve(x, alice, james, 3000n) in
        let () = ASSERT.tx_success result in
        let retrieved_balance = match FUNC.get_balance_from_storage(addr, bob) with    
        | None -> 0n
        | Some x -> x
        in
        let () = assert(retrieved_balance = 92n) in
        Test.log("OK", retrieved_balance)
    in

    (* OK : Testing GetAllowance for James from Alice *)
    let test_get_allowance_callback = 
        let () = Test.log("_get_allowance_callback") in
        let allowance_request = ({
            request =   { owner = alice; spender = james };
            callback = callback_contract;
        } : ANTI.getAllowance) in
        let _ = Test.transfer_to_contract_exn x (GetAllowance allowance_request) 0tez in
        let callback_storage = Test.get_storage callback_addr in
        let () = assert(callback_storage = 3000n) in
        Test.log("OK", callback_storage)
    in

    (* KO : Transferring 200 from Alice to Bob initiated by Bob *)
    let test_allowance_not_set =
        let () = Test.log("_allowance_not_set") in
        let result : test_exec_result = FUNC.approved_transfer(x, alice, bob, 200n) in
        let () = ASSERT.string_failure result ERROR.err_not_enough_allowance in
        let retrieved_balance = match FUNC.get_balance_from_storage(addr, bob) with    
        | Some x -> x
        | None -> 0n
        in
        let () = assert(retrieved_balance = 92n) in
        Test.log("OK", retrieved_balance)
    in

    (* OK : Transferring 200 from Alice to James initiated by James *)
    let test_allowance_set_with_balance =
        let () = Test.log("_allowance_set_with_balance") in
        let result : test_exec_result = FUNC.approved_transfer(x, alice, james, 200n) in
        let () = ASSERT.tx_success result in
        let retrieved_balance = match FUNC.get_balance_from_storage(addr, james) with    
        | Some x -> x
        | None -> 0n
        in
        let () = assert(retrieved_balance = 184n) in
        Test.log("OK", retrieved_balance)
    in

    (* KO : Transferring 10000 from Alice to James initiated by James *)
    let test_allowance_set_with_no_balance =
        let () = Test.log("_allowance_set_with_no_balance") in
        let result : test_exec_result = FUNC.approved_transfer(x, alice, james, 10000n) in
        let () = ASSERT.string_failure result ERROR.err_not_enough_allowance in
        let retrieved_balance = match FUNC.get_balance_from_storage(addr, james) with    
        | Some x -> x
        | None -> 0n
        in
        let () = assert(retrieved_balance = 184n) in
        Test.log("OK", retrieved_balance)
    in

    let test_get_balance_callback = 
        let () = Test.log("_get_balance_callback") in
        let balance_of_request = ({
            owner = alice;
            callback = callback_contract;
        } : ANTI.getBalance) in
        let _ = Test.transfer_to_contract_exn x (GetBalance balance_of_request) 0tez in
        let callback_storage = Test.get_storage callback_addr in
        let () = assert(callback_storage = 9700n) in
        Test.log("OK", callback_storage)
    in
    
    let test_get_supply_callback = 
        let () = Test.log("test_get_supply_callback") in
        let supply_request = ({
            request =  ();
            callback = callback_contract;
        } : ANTI.getTotalSupply) in
        let _ = Test.transfer_to_contract_exn x (GetTotalSupply supply_request) 0tez in
        let callback_storage = Test.get_storage callback_addr in
        let () = assert(callback_storage = 777777777756n) in
        Test.log("OK", callback_storage)
    in

    let s_current = Test.get_storage addr in
    let () = Test.log("Current Storage : ", s_current) in

    ()