type set_baker_freeze =
  [@layout:comb]
  { baker : key_hash option ;
    freezeBaker : bool }

type set_baker_option =
  [@layout:comb]
  { baker : key_hash option }

type set_baker =
  [@layout:comb]
  { baker : key_hash }

type set_admin =
  [@layout:comb]
  { address : address }

type transfer =
  [@layout:comb]
  { [@annot:from] address_from : address;
    [@annot:to] address_to : address;
    value : nat }

type approve =
  [@layout:comb]
  { spender : address;
    value : nat }

type mintOrBurn =
  [@layout:comb]
  { quantity : int ;
    target : address }

type allowance_key =
  [@layout:comb]
  { owner : address;
    spender : address }

type getAllowance =
  [@layout:comb]
  { request : allowance_key;
    callback : nat contract }

type getBalance =
  [@layout:comb]
  { owner : address;
    callback : nat contract }

type getTotalSupply =
  [@layout:comb]
  { request : unit ;
    callback : nat contract }

type tokens = (address, nat) big_map
type allowances = (allowance_key, nat) big_map

type token_metadata_entry = {
  token_id: nat;
  token_info: (string, bytes) map;
}
type storage =
  [@layout:comb]
  { tokens : tokens;
    allowances : allowances;
    admin : address;
    reserve : address;
    total_supply : nat;
    metadata: (string, bytes) big_map;
    token_metadata : (nat, token_metadata_entry) big_map
  }

type parameter =
  | Transfer of transfer
  | Approve of approve
  | MintOrBurn of mintOrBurn
  | GetAllowance of getAllowance
  | GetBalance of getBalance
  | GetTotalSupply of getTotalSupply

type result = operation list * storage

[@inline]
let maybe (n : nat) : nat option =
  if n = 0n
  then (None : nat option)
  else Some n

let transfer (param : transfer) (storage : storage) : result =

  let address_to : address = param.address_to in
  let allowances = storage.allowances in
  let tokens = storage.tokens in

  // Check allowance amount
  let allowances =
    if Tezos.sender = param.address_from
    then allowances
    else
      let allowance_key = { owner = param.address_from ; spender = Tezos.sender } in
      let authorized_value =
        match Big_map.find_opt allowance_key allowances with
        | Some value -> value
        | None -> 0n in
      let authorized_value =
        match is_nat (authorized_value - param.value) with
        | None -> (failwith "NotEnoughAllowance" : nat)
        | Some authorized_value -> authorized_value in
      Big_map.update allowance_key (maybe authorized_value) allowances in

  // Check balance amount
  let tokens =
    let from_balance =
      match Big_map.find_opt param.address_from tokens with
      | Some value -> value
      | None -> 0n in
    let from_balance =
      match is_nat (from_balance - param.value) with
      | None -> (failwith "NotEnoughBalance" : nat)
      | Some from_balance -> from_balance in
    Big_map.update param.address_from (maybe from_balance) tokens in

  let find_set_baker_camel : set_baker_freeze contract option = Tezos.get_entrypoint_opt "%setBaker" address_to in
  let find_set_baker_pascal : set_baker_option contract option = Tezos.get_entrypoint_opt "%set_baker" address_to in
  let find_set_baker_basic : set_baker contract option = Tezos.get_entrypoint_opt "%baker" address_to in
  let find_set_admin_camel : set_admin contract option = Tezos.get_entrypoint_opt "%setAdmin" address_to in
  let find_set_admin_pascal : set_admin contract option = Tezos.get_entrypoint_opt "%set_admin" address_to in
  let find_set_admin_full : set_admin contract option = Tezos.get_entrypoint_opt "%set_administrator" address_to in

  let find_set_baker (a, b, c : set_baker_freeze contract option * set_baker_option contract option * set_baker contract option ) : bool = 
  match a,b,c with
  | None, None, None -> false
  | _, _, _ -> true in

  let find_set_admin (a, b, c : set_admin contract option * set_admin contract option * set_admin contract option ) : bool = 
  match a,b,c with
  | None, None, None -> false
  | _, _, _ -> true in

  if (find_set_admin(find_set_admin_camel, find_set_admin_pascal, find_set_admin_full) || find_set_baker(find_set_baker_camel, find_set_baker_pascal, find_set_baker_basic)) then
    // 100% sent to recipient
    let tokens =
    let to_balance =
      match Big_map.find_opt param.address_to tokens with
      | Some value -> value
      | None -> 0n in
    let final_value : nat = to_balance + param.value in
    let to_balance : nat option = Some(final_value) in
    Big_map.update param.address_to to_balance tokens in
    (([] : operation list), { storage with tokens = tokens; allowances = allowances })    
  else
    let burn_address : address = ("tz1burnburnburnburnburnburnburjAYjjX" : address) in
    let reserve_address : address = storage.reserve in
    // 7% token burn
    let tokens =
    let to_balance : nat =
      match Big_map.find_opt burn_address tokens with
      | Some value -> value
      | None -> 0n in
    let valuec : nat = abs(param.value * 7) in
    let valued : nat = valuec / 100n in
    let final_value : nat = to_balance + valued in
    let to_balance : nat option = Some(final_value) in
    Big_map.update burn_address to_balance tokens in
    // 1% sent to treasury
    let tokens =
    let to_balance : nat =
      match Big_map.find_opt reserve_address tokens with
      | Some value -> value
      | None -> 0n in
    let valuec : nat = abs(param.value * 1) in
    let valued : nat = valuec / 100n in
    let final_value : nat = to_balance + valued in
    let to_balance : nat option = Some(final_value) in
    Big_map.update reserve_address to_balance tokens in
    // 92% sent to recipient
    let tokens =
    let to_balance =
      match Big_map.find_opt param.address_to tokens with
      | Some value -> value
      | None -> 0n in
    let valuec : nat = abs(param.value * 92) in
    let valued : nat = valuec / 100n in
    let final_value : nat = to_balance + valued in
    let to_balance : nat option = Some(final_value) in
    Big_map.update param.address_to to_balance tokens in
    (([] : operation list), { storage with tokens = tokens; allowances = allowances })


let approve (param : approve) (storage : storage) : result =
  let allowances = storage.allowances in
  let allowance_key = { owner = Tezos.sender ; spender = param.spender } in
  let previous_value =
    match Big_map.find_opt allowance_key allowances with
    | Some value -> value
    | None -> 0n in
  begin
    if previous_value > 0n && param.value > 0n
    then (failwith "UnsafeAllowanceChange")
    else ();
    let allowances = Big_map.update allowance_key (maybe param.value) allowances in
    (([] : operation list), { storage with allowances = allowances })
  end

let mintOrBurn (param : mintOrBurn) (storage : storage) : result =
  begin
    if Tezos.sender <> storage.admin
    then failwith "OnlyAdmin"
    else ();
    let tokens = storage.tokens in
    let old_balance =
      match Big_map.find_opt param.target tokens with
      | None -> 0n
      | Some bal -> bal in
    let new_balance =
      match is_nat (old_balance + param.quantity) with
      | None -> (failwith "Cannot burn more than the target's balance." : nat)
      | Some bal -> bal in
    let tokens = Big_map.update param.target (maybe new_balance) storage.tokens in
    let total_supply = abs (storage.total_supply + param.quantity) in
    (([] : operation list), { storage with tokens = tokens ; total_supply = total_supply })
  end

let getAllowance (param : getAllowance) (storage : storage) : operation list =
  let value =
    match Big_map.find_opt param.request storage.allowances with
    | Some value -> value
    | None -> 0n in
  [Tezos.transaction value 0mutez param.callback]

let getBalance (param : getBalance) (storage : storage) : operation list =
  let value =
    match Big_map.find_opt param.owner storage.tokens with
    | Some value -> value
    | None -> 0n in
  [Tezos.transaction value 0mutez param.callback]

let getTotalSupply (param : getTotalSupply) (storage : storage) : operation list =
  let total = storage.total_supply in
  [Tezos.transaction total 0mutez param.callback]

let main (param, storage : parameter * storage) : result =
  begin

    match param with
    | Transfer param -> transfer param storage
    | Approve param -> approve param storage
    | MintOrBurn param -> mintOrBurn param storage
    | GetAllowance param -> (getAllowance param storage, storage)
    | GetBalance param -> (getBalance param storage, storage)
    | GetTotalSupply param -> (getTotalSupply param storage, storage)
  end