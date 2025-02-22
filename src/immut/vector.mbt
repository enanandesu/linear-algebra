///|
/// Create a new type called `Vector[T]` that contains an `IArray[T]`.
/// 
struct Vector[T] {
  data : IArray[T]
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
/// 
pub fn Vector::map[T, U](self : Vector[T], f : (T) -> U) -> Vector[U] {
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
pub fn Vector::zip_with[T, U, V](
  self : Vector[T],
  other : Vector[U],
  f : (T, U) -> V
) -> Vector[V] {
  Vector::{ data: array_zip_with(self.data, other.data, f) }
}

///|
/// Create a new vector with a given length and a function to apply to each element.
/// 
/// Parameters
/// * `n`: The length of the vector.
/// * `f`: The function to apply to each element of the vector.
/// 
/// Example
/// ```moonbit
/// let v = Vector::makei(3, fn(i) { i })
/// inspect!(v, content="|0, 1, 2|")
/// ```
pub fn Vector::makei[T](n : Int, f : (Int) -> T) -> Vector[T] {
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
pub fn Vector::make[T](n : Int, elem : T) -> Vector[T] {
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
pub fn Vector::length[T](self : Vector[T]) -> Int {
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
pub fn Vector::op_get[T](self : Vector[T], i : Int) -> T {
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
pub fn Vector::set[T](self : Vector[T], i : Int, x : T) -> Vector[T] {
  Vector::{ data: self.data.set(i, x) }
}

///|
/// Left scale the vector by a number.
/// 
/// Parameters
/// * `self`: The vector to scale.
/// * `scalar`: The number to scale the vector by.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// let v1 = 10 * v
/// inspect!(v1, content="|10, 20, 30|")
/// ```
pub fn left_scale[T : @luna_generic.Mul](
  self : Vector[T],
  scalar : T
) -> Vector[T] {
  self.map(fn { x => x * scalar })
}

///|
/// Right scale the vector by a number.
/// 
/// Parameters
/// * `self`: The vector to scale.
/// * `scalar`: The number to scale the vector by.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// let v1 = v * 10
/// inspect!(v1, content="|10, 20, 30|")
/// ```
pub fn right_scale[T : @luna_generic.Mul](
  self : Vector[T],
  scalar : T
) -> Vector[T] {
  self.map(fn { x => scalar * x })
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
pub fn Vector::from_array[T](arr : Array[T]) -> Vector[T] {
  Vector::{ data: @immut/array.from_array(arr) }
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
/// let v3 = v1 + v2
/// inspect!(v3, content="|5, 7, 9|")
/// ```
pub fn Vector::op_add[T : @luna_generic.Add](
  self : Vector[T],
  other : Vector[T]
) -> Vector[T] {
  self.zip_with(other, T::op_add)
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
/// let v3 = v1 * v2
/// inspect!(v3, content="|4, 10, 18|")
/// ```
pub fn Vector::op_mul[T : @luna_generic.Mul](
  self : Vector[T],
  other : Vector[T]
) -> Vector[T] {
  self.zip_with(other, T::op_mul)
}

///| 
/// Linearly interpolate between two vectors.
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
/// let v3 = lerp(v1, v2, 0.5)
/// inspect!(v3, content="|2.5, 3.5, 4.5|")
/// ```
pub fn lerp[T : @luna_generic.One + @luna_generic.Mul + @luna_generic.Add + @luna_generic.Neg](
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
  let mut re = ""
  for i = 0; i < self.length(); i = i + 1 {
    re = re + self[i].to_string()
    if i < self.length() - 1 {
      re = re + ", "
    }
  }
  "|\{re}|"
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
/// Shift the `Vector` type array to a diagonal `Matrix` type.
/// 
/// Parameters
/// * `self`: The vector to shift.
/// 
/// Example
/// ```moonbit
/// let v = Vector::from_array([1, 2, 3])
/// inspect!(
///   v.scaled_matrix(),
///   content=
///     #||1, 0, 0|
///     #||0, 2, 0|
///     #||0, 0, 3|
/// ,
/// )
/// ```
pub fn scaled_matrix[T : @luna_generic.Mul + @luna_generic.Zero](
  self : Vector[T]
) -> Matrix[T] {
  let n = self.length()
  Matrix::make(n, n, fn(i, j) { if i == j { self[i] } else { T::zero() } })
}

///|
/// Tensor product of two `Vectors` type then generate a `Matrix` type.
/// 
/// Parameters
/// * `self`: The vector to tensor product with.
/// * `other`: The vector to tensor product with.
/// 
/// Example
/// ```moonbit
/// let v1 = Vector::from_array([1, 2, 3])
/// let v2 = Vector::from_array([4, 5, 6])
/// inspect!(
///   tensor_product(v1, v2),
///   content=
///     #||4, 5, 6|
///     #||8, 10, 12|
///     #||12, 15, 18|
/// ,
pub fn tensor_product[T : @luna_generic.Mul](
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
fn array_zip_with[X, Y, Z](
  a1 : IArray[X],
  a2 : IArray[Y],
  f : (X, Y) -> Z
) -> IArray[Z] {
  let n = a1.length()
  guard n == a2.length()
  let result = @immut/array.makei(n, fn { i => f(a1[i], a2[i]) })
  result
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
