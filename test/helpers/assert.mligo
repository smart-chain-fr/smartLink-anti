(* Assert contract call results in failwith with given string *)
let string_failure (res : test_exec_result) (expected : string) : unit =
    let expected = Test.eval expected in
    match res with
        | Fail (Rejected (actual,_)) -> assert (actual = expected)
        | Fail (Balance_too_low err) -> failwith "contract failed: balance too low"
        | Fail (Other s) -> failwith s
        | Success _ -> failwith "Transaction should fail"

(* Assert contract result is successful *)
let tx_success (res: test_exec_result) : unit =
    match res with
        | Fail (Rejected (error,_)) -> let () = Test.log(error) in failwith "Transaction should not fail"
        | Fail _ -> failwith "Transaction should not fail"
        | Success(_) -> ()

(* Assert nat variable in failwith with expected nat *)
let nat_assert (_res : nat) (_expected : nat) : unit =
    if _res = _expected then
        assert (_res = _expected)
    else
        failwith "Expected nat result failed"