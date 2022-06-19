type storage = nat

type callback = nat

type parameter = callback

let main ((p,_):(parameter * storage)) =
  ([]: operation list), p