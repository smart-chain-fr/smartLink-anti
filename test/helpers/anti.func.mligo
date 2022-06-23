#import "../../src/anti.mligo" "ANTI"
#import "../contracts/CALLBACK.mligo" "CALLBACK"

let bootstrap (init_token_supply : nat)(init_token_balance : nat) =
    let _burn_address : address = ("tz1burnburnburnburnburnburnburjAYjjX" : address) in
    let _reserve_address : address = ("tz1djkbrkYiuWFTgd3qUiViijGUuz2wBGxQ2" : address) in
        
    (* Boostrapping accounts *)
    let () = Test.reset_state 3n ([] : tez list) in
    let alice: address = Test.nth_bootstrap_account 0 in
    let bob: address = Test.nth_bootstrap_account 1 in
    let james: address = Test.nth_bootstrap_account 2 in

    (* Boostrapping storage *)
    let init_storage : ANTI.storage = {
        admin = ("tz1aECt4ZEGaBFhviqE4b8tCSusmtbVSiCeK" : address);
        allowances = (Big_map.empty : ( ANTI.allowance_key , nat) big_map);
        burn_address = _burn_address;
        burned_supply = 0n;
        initial_supply = init_token_supply;
        ledger = (Big_map.literal [(alice, init_token_balance)]);
        metadata = (Big_map.empty : ( string, bytes ) big_map);
        reserve = _reserve_address;
        token_metadata = (Big_map.literal [( 0n, {token_id = 0n; token_info = (Map.empty : ( string, bytes ) map) }) ]);
        total_supply = init_token_supply
    } in

    (* Boostrapping ANTI contract *)
    let (anti_addr,_,_) = Test.originate ANTI.main init_storage 0tez in    
    let anti_contract : ANTI.parameter contract = Test.to_contract anti_addr in

    (* Boostrapping Callback contract *)
    let (callback_addr,_,_) = Test.originate CALLBACK.main (0n) 0tez in
    let callback_contract = Test.to_contract callback_addr in

    (anti_contract, anti_addr, callback_contract, callback_addr, alice, bob, james)

let get_balance_from_storage(anti_address, owner_address : (ANTI.parameter, ANTI.storage) typed_address * address) : nat =
    let anti_storage : ANTI.storage = Test.get_storage anti_address in
    let retrieved_balance_opt : nat option = Big_map.find_opt owner_address anti_storage.ledger in
    let retrieved_balance = match retrieved_balance_opt with    
        | Some x -> x
        | None -> 0n
    in
    retrieved_balance

let approve(contr, from_, spender_, amount_ : ANTI.parameter contract * address * address * nat) =
    let () = Test.set_source from_ in
    let approve_requests = ({spender=spender_; value=amount_} : ANTI.approve) in
    Test.transfer_to_contract contr (Approve approve_requests) 0tez

let transfer(contr, from_, to_, amount_ : ANTI.parameter contract * address * address * nat) =
    let () = Test.set_source from_ in
    let transfer_requests = ({address_from=from_; address_to=to_; value=amount_} : ANTI.transfer) in
    Test.transfer_to_contract contr (Transfer transfer_requests) 0tez

let approved_transfer(contr, from_, to_, amount_ : ANTI.parameter contract * address * address * nat) =
    let () = Test.set_source to_ in
    let approved_transfer_requests = ({address_from=from_; address_to=to_; value=amount_} : ANTI.transfer) in
    Test.transfer_to_contract contr (Transfer approved_transfer_requests) 0tez