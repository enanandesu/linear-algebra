///|
/// Create a new type called `Vector[T]` that contains an `IArray[T]`.
/// 
struct Vector[T] {
  data : IArray[T]
} derive(Eq)

///|
impl[T : Arbitrary] Arbitrary for Vector[T] with arbitrary(size, rng) {
  Vector::{ data: @immut/array.makei(size, i => T::arbitrary(i, rng)) }
}

///|
pub fn[T, U] Vector::map(self : Vector[T], f : (T) -> U) -> Vector[U] {
  Vector::{ data: self.data.map(f) }
}

///|
pub fn[T, U, V] Vector::zip_with(
  self : Vector[T],
  other : Vector[U],
  f : (T, U) -> V
) -> Vector[V] {
  Vector::{ data: array_zip_with(self.data, other.data, f) }
}

///|
pub fn[T] to_col_matrix(self : Vector[T]) -> Matrix[T] {
  Matrix::make(self.length(), 1, fn(i, _) { self[i] })
}

///|
pub fn[T] to_row_matrix(self : Vector[T]) -> Matrix[T] {
  { data: self.data, row: 1, col: self.length() }
}

///|
test "to matrix" {
  let v = Vector::from_array([1, 2, 3])
  let vc = v.to_col_matrix()
  inspect(
    vc,
    content=(
      #||1|
      #||2|
      #||3|
    ),
  )
  let rc = v.to_row_matrix()
  inspect(
    rc,
    content=(
      #||1, 2, 3|
    ),
  )
}

///|
pub fn[T] Vector::makei(n : Int, f : (Int) -> T) -> Vector[T] {
  Vector::{ data: @immut/array.makei(n, f) }
}

///|
pub fn[T] Vector::length(self : Vector[T]) -> Int {
  self.data.length()
}

///|
pub fn[T] Vector::op_get(self : Vector[T], i : Int) -> T {
  self.data[i]
}

///|
pub fn[T] Vector::set(self : Vector[T], i : Int, x : T) -> Vector[T] {
  Vector::{ data: self.data.set(i, x) }
}

///|
pub fn[T : Mul] left_scale(self : Vector[T], scalar : T) -> Vector[T] {
  self.map(x => scalar * x)
}

///|
pub fn[T : Mul] right_scale(self : Vector[T], scalar : T) -> Vector[T] {
  self.map(x => x * scalar)
}

///|
pub fn[T] Vector::from_array(arr : Array[T]) -> Vector[T] {
  Vector::{ data: @immut/array.from_array(arr) }
}

///|
pub fn[T] Vector::iter(self : Vector[T]) -> Iter[T] {
  self.data.iter()
}

///|
test "from . to = identity" {
  fn prop(v : Vector[Int]) {
    v == Vector::from_array(v.iter().to_array())
  }

  quick_check_fn(prop)
}

///|
pub impl[T : Add] Add for Vector[T] with op_add(
  self : Vector[T],
  other : Vector[T]
) -> Vector[T] {
  self.zip_with(other, T::op_add)
}

///|
test "a + a = 2 * a" {
  fn prop(v : Vector[Int]) {
    v + v == v.left_scale(2)
  }

  quick_check_fn(prop)
}

///|
test "a + b = b + a" {
  fn prop(a : Vector[Int], b) {
    a + b == b + a
  }

  fn check(x : (Vector[Int], Vector[Int])) {
    let (a, b) = x
    guard a.length() == b.length() else { true }
    prop(a, b)
  }

  quick_check_fn(check)
}

///|
pub impl[T : Mul] Mul for Vector[T] with op_mul(
  self : Vector[T],
  other : Vector[T]
) -> Vector[T] {
  self.zip_with(other, T::op_mul)
}

///|
test "a * b * c = a * (b * c)" {
  fn prop(a : Vector[Int], b, c) {
    a * b * c == a * (b * c)
  }

  fn check(x : (Vector[Int], Vector[Int], Vector[Int])) {
    let (a, b, c) = x
    guard a.length() == b.length() && b.length() == c.length() else { true }
    prop(a, b, c)
  }

  quick_check_fn(check)
}

///|
pub fn[T : One + Mul + Add + Neg] lerp(
  self : Vector[T],
  other : Vector[T],
  alpha : T
) -> Vector[T] {
  self.left_scale(T::one() + -alpha) + other.left_scale(alpha)
}

///|
impl[T : Show] Show for Vector[T] with to_string(self) {
  // Immutable array has no join method
  // we need to convert to mutable array first
  // wait for core to support immutable array join
  let sep = ", "
  "|\{self.data.to_array().map(T::to_string).join(sep)}|"
}

///|
/// Output the vector to a string.
/// 
/// Parameters
/// * `s`: The string to output the vector to.
/// * `l`: The length of the vector.
impl[T : Show] Show for Vector[T] with output(s, l) {
  l.write_string(s.to_string())
}

///|
pub fn[T : Mul + Zero] scaled_matrix(self : Vector[T]) -> Matrix[T] {
  let n = self.length()
  Matrix::make(n, n, fn(i, j) { if i == j { self[i] } else { T::zero() } })
}

///|
test "S_v * p = v * p" {
  fn prop(v : Vector[Int], p : Vector[Int]) {
    let m = v.scaled_matrix()
    m * p.to_col_matrix() == (v * p).to_col_matrix()
  }

  fn check(x : (Vector[Int], Vector[Int])) {
    let (a, b) = x
    guard a.length() == b.length() else { true }
    prop(a, b)
  }

  quick_check_fn(check)
}

///|
pub fn[T : Mul] tensor_product(
  self : Vector[T],
  other : Vector[T]
) -> Matrix[T] {
  let n = self.length()
  let m = other.length()
  Matrix::make(n, m, fn(i, j) { self[i] * other[j] })
}

///| utils
fn[X, Y, Z] array_zip_with(
  a1 : IArray[X],
  a2 : IArray[Y],
  f : (X, Y) -> Z
) -> IArray[Z] {
  let n = a1.length()
  guard n == a2.length()
  @immut/array.makei(n, i => f(a1[i], a2[i]))
}

///|
test {
  let v1 = Vector::from_array([1, 2, 3])
  let v2 = Vector::from_array([4, 5, 6])
  inspect(v1 + v2, content="|5, 7, 9|")
  inspect(v1 * v2, content="|4, 10, 18|")
  inspect(v1.left_scale(10), content="|10, 20, 30|")
  inspect(v2.right_scale(10), content="|40, 50, 60|")
  inspect(
    v1.scaled_matrix(),
    content=(
      #||1, 0, 0|
      #||0, 2, 0|
      #||0, 0, 3|
    ),
  )
  inspect(
    v1.tensor_product(v2),
    content=(
      #||4, 5, 6|
      #||8, 10, 12|
      #||12, 15, 18|
    ),
  )
  inspect(v2.set(1, 10), content="|4, 10, 6|")
}
