#import "../../src/anti.mligo" "ANTI"
#import "./anti_helper.mligo" "ANTI_HELPER"
#import "../contracts/callback.mligo" "CALLBACK"

let bootstrap (init_token_supply : nat)(init_token_balance : nat)(allowances_map : ( ANTI.allowance_key , nat) big_map) =
        
    (* Boostrapping accounts *)
    let () = Test.reset_state 3n ([] : tez list) in
    let alice: address = Test.nth_bootstrap_account 0 in
    let bob: address = Test.nth_bootstrap_account 1 in
    let james: address = Test.nth_bootstrap_account 2 in

    (* Boostrapping storage *)
    let init_storage : ANTI.storage = {
        admin = ("tz1aECt4ZEGaBFhviqE4b8tCSusmtbVSiCeK" : address);
        allowances = allowances_map;
        burn_address = ANTI_HELPER.base_config.burn_address;
        burned_supply = 0n;
        initial_supply = ANTI_HELPER.base_config.init_token_supply;
        ledger = (Big_map.literal [(alice, init_token_balance)]);
        metadata = (Big_map.empty : ( string, bytes ) big_map);
        reserve = ANTI_HELPER.base_config.reserve_address;
        token_metadata = (Big_map.literal [( 0n, {token_id = 0n; token_info = (Map.empty : ( string, bytes ) map) }) ]);
        total_supply = ANTI_HELPER.base_config.init_token_supply
    } in

    (* Boostrapping ANTI contract *)
    let (anti_addr,_,_) = Test.originate ANTI.main init_storage 0tez in    
    let anti_contract : ANTI.parameter contract = Test.to_contract anti_addr in

    (* Boostrapping Callback contract *)
    let (callback_addr,_,_) = Test.originate CALLBACK.main (0n) 0tez in
    let callback_contract = Test.to_contract callback_addr in

    (anti_contract, anti_addr, callback_contract, callback_addr, alice, bob, james)

let bootstrap_no_allowance (_init_token_supply : nat)(init_token_balance : nat) =
    let allowances = (Big_map.empty : ( ANTI.allowance_key , nat) big_map) in
    bootstrap _init_token_supply init_token_balance allowances

let bootstrap_with_allowance (_init_token_supply : nat)(init_token_balance : nat)(init_allowance : address * address * nat) =
    let allowances = (Big_map.literal [({owner = init_allowance.0; spender = init_allowance.1}, init_allowance.2)]: ( ANTI.allowance_key , nat) big_map) in
    bootstrap _init_token_supply init_token_balance allowances