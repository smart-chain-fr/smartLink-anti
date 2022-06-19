#import "../src/anti.mligo" "ANTI"

let get_balance_from_storage(contract_address, owner_address : (ANTI.parameter, ANTI.storage) typed_address * address) : nat option =
    let anti_storage : ANTI.storage = Test.get_storage contract_address in
    Big_map.find_opt owner_address anti_storage.ledger

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