///|
/// Create a new type called `Vector[T]` that contains an `IArray[T]`.
/// 
struct Vector[T] {
  data : IArray[T]
} derive(Eq)

///|
/// Create a new vector with a given length and a given element.
/// 
/// Parameters
/// - `n`: The length of the vector.
/// - `elem`: The element to fill the vector with.
/// 
/// Example
/// ```moonbit
/// let v = Vector::make(3, 1)
/// inspect!(v, content="|1, 1, 1|")
/// ```
impl[T : Arbitrary] Arbitrary for Vector[T] with arbitrary(size, rng) {
  Vector::{ data: @immut/array.makei(size, fn { i => T::arbitrary(i, rng) }) }
}

///|
/// Apply `map` method to the `Vector` type.
/// 
/// Parameters
/// * `self`: The vector to apply the map method.
/// * `f`: The function to apply to each element of the vector.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// let v1 = v.map(fn(x) { x * 2 })
/// inspect!(v1, content="|2, 4, 6|")
/// ```
pub fn[T, U] Vector::map(self : Vector[T], f : (T) -> U) -> Vector[U] {
  Vector::{ data: self.data.map(f) }
}

///|
/// Import two vectors and apply a function to both of them.
/// 
/// Parameters
/// * `self`: The vector to apply the zip_with method.
/// * `other`: The vector to zip with.
/// * `f`: The function to apply to each element of the vector.
///
/// Example
/// ```moonbit
/// let v1 = Vector::from_array([1, 2, 3])
/// let v2 = Vector::from_array([4, 5, 6])
/// let v3 = v1.zip_with(v2, fn(x, y) { x + y })
/// inspect!(v3, content="|5, 7, 9|")
/// ```
pub fn[T, U, V] Vector::zip_with(
  self : Vector[T],
  other : Vector[U],
  f : (T, U) -> V
) -> Vector[V] {
  Vector::{ data: array_zip_with(self.data, other.data, f) }
}

///|
/// Convert a vector to a column matrix. Make this `Vector` to a column `Matrix`.
/// 
/// Parameters
/// * `self`: The vector to convert to a column matrix.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// let m = v.to_col_matrix()
/// inspect!(m, content=
///   #||1|
///   #||2|
///   #||3|
/// )
/// ```
pub fn[T] to_col_matrix(self : Vector[T]) -> Matrix[T] {
  Matrix::make(self.length(), 1, fn(i, _) { self[i] })
}

///|
/// Convert a vector to a row matrix. Make this `Vector` to a row `Matrix`.
/// 
/// Parameters
/// * `self`: The vector to convert to a row matrix.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// let m = v.to_row_matrix()
/// inspect!(m, content="|1, 2, 3|")
/// ```
pub fn[T] to_row_matrix(self : Vector[T]) -> Matrix[T] {
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
/// Create a new vector with a given length and a given element.
/// 
/// Parameters
/// - `n`: The length of the vector.
/// - `f`: The function to apply to each element of the vector.
/// 
/// Example
/// ```moonbit
/// let v = Vector::makei(3, fn(i) { i })
/// inspect!(v, content="|0, 1, 2|")
/// ```
pub fn[T] Vector::makei(n : Int, f : (Int) -> T) -> Vector[T] {
  Vector::{ data: @immut/array.makei(n, f) }
}

///|
/// Create a new vector with a given length and a given element.
/// 
/// Parameters
/// * `n`: The length of the vector.
/// * `elem`: The element to fill the vector with.
/// 
/// Example
/// ```moonbit
/// let v = Vector::make(3, 1)
/// inspect!(v, content="|1, 1, 1|")
/// ```
pub fn[T] Vector::make(n : Int, elem : T) -> Vector[T] {
  Vector::{ data: @immut/array.make(n, elem) }
}

///|
/// Get the length of the vector.
/// 
/// Parameters
/// * `self`: The vector to get the length of.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// inspect!(v.length(), content=3)
/// ```
pub fn[T] Vector::length(self : Vector[T]) -> Int {
  self.data.length()
}

///|
/// Get the element at index `i` of the vector.
/// 
/// Parameters
/// * `self`: The vector to get the element from.
/// * `i`: The index of the element to get.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// inspect!(v[1], content=2)
/// ```
pub fn[T] Vector::op_get(self : Vector[T], i : Int) -> T {
  self.data[i]
}

///|
/// Set the element at index `i` of the vector to `x`.
/// 
/// Parameters
/// * `self`: The vector to set the element of.
/// * `i`: The index of the element to set.
/// * `x`: The element to set the element to.
///
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// let v1 = v.set(1, 10)
/// inspect!(v1, content="|1, 10, 3|")
/// ```
pub fn[T] Vector::set(self : Vector[T], i : Int, x : T) -> Vector[T] {
  Vector::{ data: self.data.set(i, x) }
}

///|
/// Left scale the vector by a scalar.
/// 
/// Parameters
/// * `self`: The vector to left scale.
/// * `scalar`: The scalar to left scale the vector by.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// inspect!(v.left_scale(2), content="|2, 4, 6|")
/// ```
pub fn[T : Mul] left_scale(self : Vector[T], scalar : T) -> Vector[T] {
  self.map(fn { x => scalar * x })
}

///|
/// Right scale the vector by a scalar.
/// 
/// Parameters
/// * `self`: The vector to right scale.
/// * `scalar`: The scalar to right scale the vector by.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// inspect!(v.right_scale(2), content="|2, 4, 6|")
/// ```
pub fn[T : Mul] right_scale(self : Vector[T], scalar : T) -> Vector[T] {
  self.map(fn { x => x * scalar })
}

///|
/// Create a new vector from an array.
/// 
/// Parameters
/// * `arr`: The array to create the vector from.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// inspect!(v, content="|1, 2, 3|")
/// ```
pub fn[T] Vector::from_array(arr : Array[T]) -> Vector[T] {
  Vector::{ data: @immut/array.from_array(arr) }
}

///|
/// Iterate over the vector.
/// 
/// Parameters
/// * `self`: The vector to iterate over.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// for x in v.iter() {
///   inspect!(x, content=1)
/// }
/// ```
pub fn[T] Vector::iter(self : Vector[T]) -> Iter[T] {
  self.data.iter()
}

///|
test "from . to = identity" {
  fn prop(v : Vector[Int]) {
    v == Vector::from_array(v.iter().to_array())
  }

  quick_check_fn!(prop)
}

///|
/// Add two vectors.
/// 
/// Parameters
/// * `self`: The vector to add.
/// * `other`: The vector to add.
/// 
/// Example
/// ```moonbit
/// let v1 = Vector::from_array([1, 2, 3])
/// let v2 = Vector::from_array([4, 5, 6])
/// inspect!(v1 + v2, content="|5, 7, 9|")
/// ```
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

  quick_check_fn!(prop)
}

///|
test "a + b = b + a" {
  fn prop(a : Vector[Int], b) {
    a + b == b + a
  }

  quick_check_fn!(fn {
    ((a : Vector[Int]), (b : Vector[Int])) => {
      guard a.length() == b.length() else { true }
      prop(a, b)
    }
  })
}

///|
/// Multiply two vectors.
/// 
/// Parameters
/// * `self`: The vector to multiply.
/// * `other`: The vector to multiply.
/// 
/// Example
/// ```moonbit
/// let v1 = Vector::from_array([1, 2, 3])
/// let v2 = Vector::from_array([4, 5, 6])
/// inspect!(v1 * v2, content="|4, 10, 18|")
/// ```
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

  quick_check_fn!(fn {
    ((a : Vector[Int]), (b : Vector[Int]), (c : Vector[Int])) => {
      guard a.length() == b.length() && b.length() == c.length() else { true }
      prop(a, b, c)
    }
  })
}

///|
/// Linearly combine two vectors.
/// The fomular is `(1 - alpha) * self + alpha * other`.
/// 
/// Parameters
/// * `self`: The vector to interpolate from.
/// * `other`: The vector to interpolate to.
/// * `alpha`: The interpolation factor.
/// 
/// Example
/// ```moonbit
/// let v1 = Vector::from_array([1, 2, 3])
/// let v2 = Vector::from_array([4, 5, 6])
/// inspect!(v1.lerp(v2, 0.5), content="|2.5, 3.5, 4.5|")
/// ```
pub fn[T : One + Mul + Add + Neg] lerp(
  self : Vector[T],
  other : Vector[T],
  alpha : T
) -> Vector[T] {
  self.left_scale(T::one() + -alpha) + other.left_scale(alpha)
}

///|
/// Convert the vector to a string.
/// 
/// Parameters
/// * `self`: The vector to convert to a string.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// inspect!(v.to_string(), content="|1, 2, 3|")
/// ```
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
/// Produce a diagonal (scale) matrix from a vector.
/// 
/// Parameters
/// * `self`: The vector to produce the diagonal matrix from.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// inspect!(v.scaled_matrix(), content=
///   #||1, 0, 0|
///   #||0, 2, 0|
///   #||0, 0, 3|
/// )
/// ```
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

  quick_check_fn!(fn {
    ((a : Vector[Int]), (b : Vector[Int])) => {
      guard a.length() == b.length() else { true }
      prop(a, b)
    }
  })
}

///|
/// Tensor product of two vectors.
/// 
/// Parameters
/// * `self`: The vector to tensor product with.
/// * `other`: The vector to tensor product with.
/// 
/// Example
/// ```moonbit
/// let v1 = Vector::from_array([1, 2, 3])
/// let v2 = Vector::from_array([4, 5, 6])
/// inspect!(tensor_product(v1, v2), content=
///   #||4, 5, 6|
///   #||8, 10, 12|
///   #||12, 15, 18|
/// )
/// ```
pub fn[T : Mul] tensor_product(
  self : Vector[T],
  other : Vector[T]
) -> Matrix[T] {
  let n = self.length()
  let m = other.length()
  Matrix::make(n, m, fn(i, j) { self[i] * other[j] })
}

///| utils

///|
/// Internal function to zip two arrays with a function.
/// Used in `zip_with` method to zip two `Vectors` type.
/// 
/// Parameters
/// * `a1`: The first array to zip.
/// * `a2`: The second array to zip.
/// * `f`: The function to apply to each element of the arrays.
/// 
/// Example
/// ```moonbit
/// let v1 = Vector::from_array([1, 2, 3])
/// let v2 = Vector::from_array([4, 5, 6])
/// inspect!(array_zip_with(v1.data, v2.data, fn(x, y) { x * y }), content="|4, 10, 18|")
/// ```
fn[X, Y, Z] array_zip_with(
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
    v1.tensor_product(v2),
    content=
      #||4, 5, 6|
      #||8, 10, 12|
      #||12, 15, 18|
    ,
  )
  inspect!(v2.set(1, 10), content="|4, 10, 6|")
}
