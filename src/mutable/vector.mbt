///|
type Vector[A] Array[A]

///|
impl[T : Arbitrary] Arbitrary for Vector[T] with arbitrary(size, rng) {
  Vector::makei(size, fn { i => T::arbitrary(i, rng) })
}

///|
impl[T : Eq] Eq for Vector[T] with op_equal(self, other) {
  self.inner() == other.inner()
}

///|
pub impl[T : Show] Show for Vector[T] with to_string(self) {
  let sep = ", "
  "|\{self._.map(T::to_string).join(sep)}|"
}

///|
pub impl[T : Show] Show for Vector[T] with output(self, l) {
  l.write_string(self.to_string())
}

///|
fn[A, B, C] array_zip_with(
  a1 : Array[A],
  a2 : Array[B],
  f : (A, B) -> C
) -> Array[C] {
  let n = a1.length()
  guard n == a2.length()
  let result = Array::makei(n, fn { i => f(a1[i], a2[i]) })
  result
}

///|
pub fn[A, U, V] Vector::zip_with(
  self : Vector[A],
  other : Vector[U],
  f : (A, U) -> V
) -> Vector[V] {
  array_zip_with(self.inner(), other.inner(), f)
}

///|
pub fn[T] to_col_matrix(self : Vector[T]) -> Matrix[T] {
  Matrix::make(self.length(), 1, fn(i, _) { self[i] })
}

///|
pub fn[T] to_row_matrix(self : Vector[T]) -> Matrix[T] {
  { data: self.inner(), row: 1, col: self.length() }
}

///|
pub fn[A] Vector::length(self : Vector[A]) -> Int {
  self.inner().length()
}

///|
pub fn[A] Vector::makei(n : Int, f : (Int) -> A) -> Vector[A] {
  Array::makei(n, f)
}

///|
pub fn[A] Vector::make(n : Int, elem : A) -> Vector[A] {
  Array::make(n, elem)
}

///|
pub fn[A] Vector::copy(self : Vector[A]) -> Vector[A] {
  self.inner().copy()
}

///|
pub fn[A] Vector::op_get(self : Vector[A], index : Int) -> A {
  self.inner()[index]
}

///|
pub fn[A] Vector::op_set(self : Vector[A], index : Int, value : A) -> Unit {
  self.inner()[index] = value
}

///|
pub fn[A, B] Vector::map(self : Vector[A], f : (A) -> B) -> Vector[B] {
  self.inner().map(f)
}

///|
pub fn[A] Vector::map_inplace(self : Vector[A], f : (A) -> A) -> Unit {
  self.inner().map_inplace(f)
}

///|
pub fn[A : Mul] Vector::left_scale(self : Vector[A], scalar : A) -> Vector[A] {
  self.map(fn { x => x * scalar })
}

///|
pub fn[A : Mul] Vector::right_scale(scalar : A, self : Vector[A]) -> Vector[A] {
  self.map(fn { x => scalar * x })
}

///|
pub fn[A : Mul] Vector::left_scale_inplace(
  self : Vector[A],
  scalar : A
) -> Unit {
  self.map_inplace(fn { x => x * scalar })
}

///|
pub fn[A : Mul] Vector::right_scale_inplace(
  scalar : A,
  self : Vector[A]
) -> Unit {
  self.map_inplace(fn { x => scalar * x })
}

///|
pub fn[T] Vector::from_array(a : Array[T]) -> Vector[T] {
  a
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

  quick_check_fn(fn {
    ((a : Vector[Int]), (b : Vector[Int])) => {
      guard a.length() == b.length() else { true }
      prop(a, b)
    }
  })
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

  quick_check_fn(fn {
    ((a : Vector[Int]), (b : Vector[Int]), (c : Vector[Int])) => {
      guard a.length() == b.length() && b.length() == c.length() else { true }
      prop(a, b, c)
    }
  })
}

///|
pub impl[T : Neg] Neg for Vector[T] with op_neg(self : Vector[T]) -> Vector[T] {
  self.map(T::op_neg)
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

  quick_check_fn(fn {
    ((a : Vector[Int]), (b : Vector[Int])) => {
      guard a.length() == b.length() else { true }
      prop(a, b)
    }
  })
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

///|
pub fn[T : Add] Vector::add_constant(self : Vector[T], cst : T) -> Vector[T] {
  self.map(fn(x) { x + cst })
}

///|
pub fn[T : Add + Mul] lin_comb(
  scalar_a : T,
  self : Vector[T],
  scalar_b : T,
  other : Vector[T]
) -> Vector[T] {
  self.left_scale(scalar_a) + other.left_scale(scalar_b)
}
