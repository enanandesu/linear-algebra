///|
pub trait HomomorphismNat {
  from_nat(Int) -> Self
}

///|
pub impl HomomorphismNat for Float with from_nat(n : Int) -> Float {
  n.to_float()
}

///|
pub impl HomomorphismNat for Double with from_nat(n : Int) -> Double {
  n.to_double()
}
