///|
pub trait Mul {
  op_mul(Self, Self) -> Self
}

///|
pub trait Add {
  op_add(Self, Self) -> Self
}

///|
pub trait Neg {
  op_neg(Self) -> Self
}

///|
pub trait One {
  one() -> Self
}

///|
pub trait Zero {
  zero() -> Self
}

///|
pub trait Conjugate {
  conjugate(Self) -> Self
}

///|
pub impl Mul for Int with op_mul(a, b) -> Int {
  a * b
}

///|
pub impl Add for Int with op_add(a, b) -> Int {
  a + b
}

///|
pub impl Neg for Int with op_neg(a) -> Int {
  -a
}

///|
pub impl One for Int with one() -> Int {
  1
}

///|
pub impl Zero for Int with zero() -> Int {
  0
}
