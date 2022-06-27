#import "../../src/anti.mligo" "ANTI"
#import "../contracts/callback.mligo" "CALLBACK"

let base_config = {
    init_token_supply = 777777777777n;
    init_token_balance = 1000n;
    burn_rate = 7n;
    reserve_rate = 1n;
    allwn_amount = 300n;
    tsfr_amount = 200n;
    burn_address = ("tz1burnburnburnburnburnburnburjAYjjX": address);
    reserve_address = ("tz1djkbrkYiuWFTgd3qUiViijGUuz2wBGxQ2": address);
    random_contract_address = ("KT1MsktCnwfS1nGZmf8QbaTpZ8euVijWdmkC": address)
}

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

let assert_transfer_account(ant_addr, sender, recipient, init_token_balance, tsfr_amount : (ANTI.parameter, ANTI.storage) typed_address * address * address * nat * nat) : unit =
    let rtr_bal_sender = get_balance_from_storage(ant_addr, sender) in
    let rtr_bal_recipient = get_balance_from_storage(ant_addr, recipient) in
    let rtr_bal_brn = get_balance_from_storage(ant_addr, base_config.burn_address) in
    let rtr_bal_res = get_balance_from_storage(ant_addr, base_config.reserve_address) in

    let () = assert(rtr_bal_sender = abs(init_token_balance - tsfr_amount )) in
    let () = assert(rtr_bal_recipient = abs(tsfr_amount - ((tsfr_amount * base_config.burn_rate) / 100) - ((tsfr_amount * base_config.reserve_rate) / 100))) in
    let () = assert(rtr_bal_brn = abs((tsfr_amount * base_config.burn_rate) / 100)) in
    let () = assert(rtr_bal_res = abs((tsfr_amount * base_config.reserve_rate) / 100)) in

    let () = Test.log("OK, Sender :", rtr_bal_sender) in
    let () = Test.log("OK, Recipient :", rtr_bal_recipient) in
    let () = Test.log("OK, Burn address :", rtr_bal_brn) in
    let () = Test.log("OK, Reserve address :", rtr_bal_res) in
    ()

let assert_transfer_contract(ant_addr, sender, recipient, init_token_balance, tsfr_amount : (ANTI.parameter, ANTI.storage) typed_address * address * address * nat * nat) : unit =
    let rtr_bal_sender = get_balance_from_storage(ant_addr, sender) in
    let rtr_bal_recipient = get_balance_from_storage(ant_addr, recipient) in
    let rtr_bal_brn = get_balance_from_storage(ant_addr, base_config.burn_address) in
    let rtr_bal_res = get_balance_from_storage(ant_addr, base_config.reserve_address) in

    let () = assert(rtr_bal_sender = abs(init_token_balance - tsfr_amount)) in
    let () = assert(rtr_bal_recipient = tsfr_amount) in
    let () = assert(rtr_bal_brn = 0n) in
    let () = assert(rtr_bal_res = 0n) in

    let () = Test.log("OK, Sender :", rtr_bal_sender) in
    let () = Test.log("OK, Recipient :", rtr_bal_recipient) in
    let () = Test.log("OK, Burn address :", rtr_bal_brn) in
    let () = Test.log("OK, Reserve address :", rtr_bal_res) in
    ()