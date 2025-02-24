///|
struct Vector[T] {
  data : IArray[T]
} derive(Eq)

///|
impl[T : @quickcheck.Arbitrary] @quickcheck.Arbitrary for Vector[T] with arbitrary(
  size,
  rng
) {
  Vector::{ data: @immut/array.makei(size, fn { i => T::arbitrary(i, rng) }) }
}

///|
pub fn Vector::map[T, U](self : Vector[T], f : (T) -> U) -> Vector[U] {
  Vector::{ data: self.data.map(f) }
}

///|
pub fn Vector::zip_with[T, U, V](
  self : Vector[T],
  other : Vector[U],
  f : (T, U) -> V
) -> Vector[V] {
  Vector::{ data: array_zip_with(self.data, other.data, f) }
}

///|
pub fn to_col_matrix[T](self : Vector[T]) -> Matrix[T] {
  Matrix::make(self.length(), 1, fn(i, _) { self[i] })
}

///|
pub fn to_row_matrix[T](self : Vector[T]) -> Matrix[T] {
  { data: self.data, row: 1, col: self.length() }
}

///|
test "to matrix" {
  let v = Vector::from_array([1, 2, 3])
  let vc = v.to_col_matrix()
  inspect!(
    vc,
    content=
      #||1|
      #||2|
      #||3|
    ,
  )
  let rc = v.to_row_matrix()
  inspect!(
    rc,
    content=
      #||1, 2, 3|
    ,
  )
}

///|
pub fn Vector::makei[T](n : Int, f : (Int) -> T) -> Vector[T] {
  Vector::{ data: @immut/array.makei(n, f) }
}

///|
pub fn Vector::make[T](n : Int, elem : T) -> Vector[T] {
  Vector::{ data: @immut/array.make(n, elem) }
}

///|
pub fn Vector::length[T](self : Vector[T]) -> Int {
  self.data.length()
}

///|
pub fn Vector::op_get[T](self : Vector[T], i : Int) -> T {
  self.data[i]
}

///|
pub fn Vector::set[T](self : Vector[T], i : Int, x : T) -> Vector[T] {
  Vector::{ data: self.data.set(i, x) }
}

///|
pub fn left_scale[T : @lg.Mul](self : Vector[T], scalar : T) -> Vector[T] {
  self.map(fn { x => x * scalar })
}

///|
pub fn right_scale[T : @lg.Mul](self : Vector[T], scalar : T) -> Vector[T] {
  self.map(fn { x => scalar * x })
}

///|
pub fn Vector::from_array[T](arr : Array[T]) -> Vector[T] {
  Vector::{ data: @immut/array.from_array(arr) }
}

///|
pub fn Vector::iter[T](self : Vector[T]) -> Iter[T] {
  self.data.iter()
}

///|
test "from . to = identity" {
  fn prop(v : Vector[Int]) {
    v == Vector::from_array(v.iter().to_array())
  }

  @qc.quick_check_fn!(prop)
}

///|
pub fn Vector::op_add[T : @lg.Add](
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

  @qc.quick_check_fn!(prop)
}

///|
test "a + b = b + a" {
  fn prop(a : Vector[Int], b) {
    a + b == b + a
  }

  @qc.quick_check_fn!(fn {
    ((a : Vector[Int]), (b : Vector[Int])) => {
      guard a.length() == b.length() else { true }
      prop(a, b)
    }
  })
}

///|
pub fn Vector::op_mul[T : @lg.Mul](
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

  @qc.quick_check_fn!(fn {
    ((a : Vector[Int]), (b : Vector[Int]), (c : Vector[Int])) => {
      guard a.length() == b.length() && b.length() == c.length() else { true }
      prop(a, b, c)
    }
  })
}

///| Linearly interpolate between two vectors
pub fn lerp[T : @lg.One + @lg.Mul + @lg.Add + @lg.Neg](
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
impl[T : Show] Show for Vector[T] with output(s, l) {
  l.write_string(s.to_string())
}

///| Produce a diagonal (scale) matrix from a vector
pub fn scaled_matrix[T : @lg.Mul + @lg.Zero](self : Vector[T]) -> Matrix[T] {
  let n = self.length()
  Matrix::make(n, n, fn(i, j) { if i == j { self[i] } else { T::zero() } })
}

///|
test "S_v * p = v * p" {
  
  fn prop(v : Vector[Int], p : Vector[Int]) {
    let m = v.scaled_matrix()
    m * p.to_col_matrix() == (v * p).to_col_matrix()
  }

  @qc.quick_check_fn!(fn {
    ((a : Vector[Int]), (b : Vector[Int])) => {
      guard a.length() == b.length() else { true }
      prop(a, b)
    }
  })
}

///| Tensor product of two vectors
pub fn tensor_product[T : @lg.Mul](
  self : Vector[T],
  other : Vector[T]
) -> Matrix[T] {
  let n = self.length()
  let m = other.length()
  Matrix::make(n, m, fn(i, j) { self[i] * other[j] })
}

///| utils

///|
fn array_zip_with[X, Y, Z](
  a1 : IArray[X],
  a2 : IArray[Y],
  f : (X, Y) -> Z
) -> IArray[Z] {
  let n = a1.length()
  guard n == a2.length()
  @immut/array.makei(n, fn { i => f(a1[i], a2[i]) })
}

///|
test {
  let v1 = Vector::from_array([1, 2, 3])
  let v2 = Vector::from_array([4, 5, 6])
  inspect!(v1 + v2, content="|5, 7, 9|")
  inspect!(v1 * v2, content="|4, 10, 18|")
  inspect!(v1.left_scale(10), content="|10, 20, 30|")
  inspect!(v2.right_scale(10), content="|40, 50, 60|")
  inspect!(
    v1.scaled_matrix(),
    content=
      #||1, 0, 0|
      #||0, 2, 0|
      #||0, 0, 3|
    ,
  )
  inspect!(
    tensor_product(v1, v2),
    content=
      #||4, 5, 6|
      #||8, 10, 12|
      #||12, 15, 18|
    ,
  )
  inspect!(v2.set(1, 10), content="|4, 10, 6|")
}
