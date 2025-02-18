///|
type Vector[A] Array[A]

///|
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
impl[T : Show] Show for Vector[T] with output(self, l) {
  l.write_string(self.to_string())
}

///|
fn array_zip_with[A, B, C](
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
pub fn Vector::zip_with[A, U, V](
  self : Vector[A],
  other : Vector[U],
  f : (A, U) -> V
) -> Vector[V] {
  array_zip_with(self._, other._, f)
}

///|
pub fn Vector::length[A](self : Vector[A]) -> Int {
  self._.length()
}

///|
pub fn Vector::makei[A](n : Int, f : (Int) -> A) -> Vector[A] {
  Array::makei(n, f)
}

///|
pub fn Vector::make[A](n : Int, elem : A) -> Vector[A] {
  Array::make(n, elem)
}

///|
pub fn Vector::copy[A](self : Vector[A]) -> Vector[A] {
  self._.copy()
}

///|
pub fn Vector::op_get[A](self : Vector[A], index : Int) -> A {
  self._[index]
}

///|
pub fn Vector::op_set[A](self : Vector[A], index : Int, value : A) -> Unit {
  self._[index] = value
}

///|
pub fn Vector::map[A, B](self : Vector[A], f : (A) -> B) -> Vector[B] {
  self._.map(f)
}

///|
pub fn Vector::map_inplace[A](self : Vector[A], f : (A) -> A) -> Unit {
  self._.map_inplace(f)
}

///|
pub fn Vector::left_scale[A : @internal.Mul](
  self : Vector[A],
  scalar : A
) -> Vector[A] {
  self.map(fn { x => x * scalar })
}

///|
pub fn Vector::right_scale[A : @internal.Mul](
  scalar : A,
  self : Vector[A]
) -> Vector[A] {
  self.map(fn { x => scalar * x })
}

///|
pub fn Vector::left_scale_inplace[A : @internal.Mul](
  self : Vector[A],
  scalar : A
) -> Unit {
  self.map_inplace(fn { x => x * scalar })
}

///|
pub fn Vector::right_scale_inplace[A : @internal.Mul](
  scalar : A,
  self : Vector[A]
) -> Unit {
  self.map_inplace(fn { x => scalar * x })
}

///|
pub fn Vector::from_array[T](a : Array[T]) -> Vector[T] {
  a
}

///|
pub fn Vector::op_add[T : @internal.Add](
  self : Vector[T],
  other : Vector[T]
) -> Vector[T] {
  self.zip_with(other, T::op_add)
}

///|
pub fn Vector::op_mul[T : @internal.Mul](
  self : Vector[T],
  other : Vector[T]
) -> Vector[T] {
  self.zip_with(other, T::op_mul)
}

///|
pub fn Vector::op_neg[T : @internal.Neg](self : Vector[T]) -> Vector[T] {
  self.map(T::op_neg)
}

///|
pub fn lerp[T : @internal.One + @internal.Mul + @internal.Add + @internal.Neg](
  self : Vector[T],
  other : Vector[T],
  alpha : T
) -> Vector[T] {
  self.left_scale(T::one() + -alpha) + other.left_scale(alpha)
}

///|
pub fn scaled_matrix[T : @internal.Mul + @internal.Zero](
  self : Vector[T]
) -> Matrix[T] {
  let n = self.length()
  Matrix::make(n, n, fn(i, j) { if i == j { self[i] } else { T::zero() } })
}

///|
pub fn tensor_product[T : @internal.Mul](
  self : Vector[T],
  other : Vector[T]
) -> Matrix[T] {
  let n = self.length()
  let m = other.length()
  Matrix::make(n, m, fn(i, j) { self[i] * other[j] })
}

///|
pub fn Vector::add_const[T : @internal.Add](
  self : Vector[T],
  constant : T
) -> Vector[T] {
  self.map(fn(x) -> T { x + constant })
}

///|
pub fn lin_comb[T : @internal.Add + @internal.Mul](
  scalar_a : T,
  self : Vector[T],
  scalar_b : T,
  other : Vector[T]
) -> Vector[T] {
  self.left_scale(scalar_a) + other.left_scale(scalar_b)
}
