#import "../../src/anti.mligo" "ANTI"
#import "./anti_func.mligo" "ANTI_HELPER"

(* Assert contract result is successful *)
let tx_success (res: test_exec_result) : unit =
    match res with
        | Fail (Rejected (error,_)) -> let () = Test.log(error) in failwith "Transaction should not fail"
        | Fail _ -> failwith "Transaction should not fail"
        | Success(_) -> Test.log("OK", res)

(* Assert contract call results in failwith with given string *)
let string_failure (res : test_exec_result) (expected : string) : unit =
    let _expected = Test.eval expected in
    let () = match res with
        | Fail (Rejected (actual,_)) -> assert (actual = _expected)
        | Fail (Balance_too_low err) -> failwith "Contract failed: Balance too low"
        | Fail (Other s) -> failwith s
        | Success _ -> failwith "Transaction should fail"
    in
    Test.log("OK", expected)

let assert_transfer_account(ant_addr, sender, recipient, init_token_balance, tsfr_amount : (ANTI.parameter, ANTI.storage) typed_address * address * address * nat * nat) : unit =
    let _burn_address : address = ("tz1burnburnburnburnburnburnburjAYjjX" : address) in
    let _reserve_address : address = ("tz1djkbrkYiuWFTgd3qUiViijGUuz2wBGxQ2" : address) in

    let rtr_bal_sender = ANTI_HELPER.get_balance_from_storage(ant_addr, sender) in
    let rtr_bal_recipient = ANTI_HELPER.get_balance_from_storage(ant_addr, recipient) in
    let rtr_bal_brn = ANTI_HELPER.get_balance_from_storage(ant_addr, _burn_address) in
    let rtr_bal_res = ANTI_HELPER.get_balance_from_storage(ant_addr, _reserve_address) in

    let () = assert(rtr_bal_sender = abs(init_token_balance - tsfr_amount )) in
    let () = assert(rtr_bal_recipient = abs(tsfr_amount - ((tsfr_amount * 7n) / 100) - ((tsfr_amount * 1n) / 100))) in
    let () = assert(rtr_bal_brn = abs((tsfr_amount * 7n) / 100)) in
    let () = assert(rtr_bal_res = abs((tsfr_amount * 1n) / 100)) in

    let () = Test.log("OK, Sender :", rtr_bal_sender) in
    let () = Test.log("OK, Recipient :", rtr_bal_recipient) in
    let () = Test.log("OK, Burn address :", rtr_bal_brn) in
    let () = Test.log("OK, Reserve address :", rtr_bal_res) in
    ()

let assert_transfer_contract(ant_addr, sender, recipient, init_token_balance, tsfr_amount : (ANTI.parameter, ANTI.storage) typed_address * address * address * nat * nat) : unit =
    let _burn_address : address = ("tz1burnburnburnburnburnburnburjAYjjX" : address) in
    let _reserve_address : address = ("tz1djkbrkYiuWFTgd3qUiViijGUuz2wBGxQ2" : address) in

    let rtr_bal_sender = ANTI_HELPER.get_balance_from_storage(ant_addr, sender) in
    let rtr_bal_recipient = ANTI_HELPER.get_balance_from_storage(ant_addr, recipient) in
    let rtr_bal_brn = ANTI_HELPER.get_balance_from_storage(ant_addr, _burn_address) in
    let rtr_bal_res = ANTI_HELPER.get_balance_from_storage(ant_addr, _reserve_address) in

    let () = assert(rtr_bal_sender = abs(init_token_balance - tsfr_amount)) in
    let () = assert(rtr_bal_recipient = tsfr_amount) in
    let () = assert(rtr_bal_brn = 0n) in
    let () = assert(rtr_bal_res = 0n) in

    let () = Test.log("OK, Sender :", rtr_bal_sender) in
    let () = Test.log("OK, Recipient :", rtr_bal_recipient) in
    let () = Test.log("OK, Burn address :", rtr_bal_brn) in
    let () = Test.log("OK, Reserve address :", rtr_bal_res) in
    ()