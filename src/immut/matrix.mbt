///|
/// Create a new type called IArray, which is an alias for 
/// the immutable array type.
/// 
typealias IArray[T] = @immut/array.T[T]

///|
/// Define a new type called Matrix, which is a 2D array of 
/// elements of type T and have derived the Eq trait.
/// 
/// Parameters:
/// - `row`: The number of rows in the matrix.
/// - `col`: The number of columns in the matrix.
/// - `data`: The data of the matrix, which is an immutable array of type `IArray[T]`.
/// 
struct Matrix[T] {
  row : Int
  col : Int
  data : IArray[T]
} derive(Eq)

///|
/// Define a new type called Indexed, which is a function
/// that takes an `integer` and returns a value of type `T`.
/// 
struct Indexed[T] {
  index : (Int) -> T
}

///|
pub impl[T : Show] Show for Matrix[T] with to_string(s) {
  let mut res = ""
  for i = 0; i < s.row; i = i + 1 {
    res = res + "|"
    for j = 0; j < s.col; j = j + 1 {
      res = res + s.data[i * s.col + j].to_string()
      if j < s.col - 1 {
        res = res + ", "
      }
    }
    res = res + "|"
    if i < s.row - 1 {
      res = res + "\n"
    }
  }
  res
}

///|
pub impl[T : Show] Show for Matrix[T] with output(s, l) {
  l.write_string(s.to_string())
}

///|
/// Apply `map` method to the `Matrix` type.
/// 
/// **Parameters**
/// - `self`: The matrix to apply the map method.
/// - `f`: The function to apply to each element of the matrix.
/// 
/// **Example**
/// ```moonbit
/// let m = Matrix::from_2d_array([[2, 3, 4], [1, 2, 3]])
/// let m2 = m.map(fn(x) { x * 2 })
/// inspect!(m2, content=
///   #||4, 6, 8|
///   #||2, 4, 6|
/// )
/// ```
/// 
pub fn map[T, U](self : Matrix[T], f : (T) -> U) -> Matrix[U] {
  { row: self.row, col: self.col, data: self.data.map(f) }
}

///|
/// Create a new `Matrix` type.
/// 
/// **Parameters**
/// - `row`: The number of rows in the matrix.
/// - `col`: The number of columns in the matrix.
/// - `f`: The function to apply to each element of the matrix.
///
/// **Example**
/// ```moonbit
/// let m = Matrix::make(2, 3, fn(i, j) { i + j })
/// inspect!(m, content=
///   #||0, 1, 2|
///   #||1, 2, 3|
/// )
/// ```
/// 
pub fn Matrix::make[T](row : Int, col : Int, f : (Int, Int) -> T) -> Matrix[T] {
  {
    row,
    col,
    data: @immut/array.makei(row * col, fn(i) { f(i / col, i % col) }),
  }
}

///|
/// Create a new `Matrix` type with all elements initialized 
/// to a given value.
/// 
/// **Parameters**
/// - `row`: The number of rows in the matrix.
/// - `col`: The number of columns in the matrix.
/// - `elem`: The value to initialize the matrix with.
///
/// **Example**
/// ```moonbit
/// let m = Matrix::new(2, 3, 0)
/// inspect!(m, content=
///   #||0, 0, 0|
///   #||0, 0, 0|
/// )
/// ```
/// 
pub fn Matrix::new[T](row : Int, col : Int, elem : T) -> Matrix[T] {
  Matrix::make(row, col, fn { _, _ => elem })
}

///|
/// Shift the `Array[Array[T]]` type to the `Matrix` type.
/// 
/// **Parameters**
/// - `arr`: The array to shift to the `Matrix` type.
/// 
/// **Example**
/// ```moonbit
/// let m = Matrix::from_2d_array([[2, 3, 4], [1, 2, 3]])
/// ```
/// 
pub fn Matrix::from_2d_array[T](arr : Array[Array[T]]) -> Matrix[T] {
  Matrix::make(arr.length(), arr[0].length(), fn(i, j) { arr[i][j] })
}

///|
/// Get the `Indexed` type from the `Matrix` type.
/// You can get the whole row data of the matrix by using the `Indexed` type.
/// 
/// **Parameters**
/// - `self`: The matrix to get the indexed type from.
/// - `row`: The row index to get the data from.
/// 
/// **Example**
/// ```moonbit
/// let m = Matrix::from_2d_array([[2, 3, 4], [1, 2, 3]])
/// inspect!(m[0], content=[2, 3, 4])
/// ```
/// 
pub fn Matrix::op_get[T](self : Matrix[T], row : Int) -> Indexed[T] {
  { index: fn { c => self.data[c + self.col * row] } }
}

///|
/// From the `Indexed` type, you can get the element of the 
/// matrix by using this method.
/// 
/// **Parameters**
/// - `self`: The indexed type to get the element from.
/// - `col`: The column index to get the element from.
/// 
/// **Example**
/// ```moonbit
/// let m = Matrix::from_2d_array([[2, 3, 4], [1, 2, 3]])
/// inspect!(m[0][1], content="3")
/// ```
/// 
pub fn op_get[T](self : Indexed[T], col : Int) -> T {
  (self.index)(col)
}

///|
pub fn Matrix::set[T](
  self : Matrix[T],
  i : Int,
  j : Int,
  elem : T
) -> Matrix[T] {
  { row: self.row, col: self.col, data: self.data.set(i * self.col + j, elem) }
}

///|
test {
  let m = Matrix::from_2d_array([[2, 3, 4], [1, 2, 3]])
  inspect!(
    m,
    content=
      #||2, 3, 4|
      #||1, 2, 3|
    ,
  )
  inspect!(m[0][1], content="3")
}

///|
pub fn op_mul[T : @luna_generic.Mul + @luna_generic.Add](
  self : Matrix[T],
  other : Matrix[T]
) -> Matrix[T] {
  let row = self.row
  let col = other.col
  let inner = self.col
  guard inner == other.row
  let data = @immut/array.makei(row * col, fn(i) {
    let r = i / col
    let c = i % col
    let mut sum = self[r][0] * other[0][c]
    for k = 1; k < inner; k = k + 1 {
      sum = sum + self[r][k] * other[k][c]
    }
    sum
  })
  { row, col, data }
}

///|
pub fn op_add[T : @luna_generic.Add](
  self : Matrix[T],
  other : Matrix[T]
) -> Matrix[T] {
  guard self.col == other.col
  guard self.row == other.row
  {
    data: array_zip_with(self.data, other.data, T::op_add),
    row: self.row,
    col: self.col,
  }
}

///|
pub fn op_neg[T : @luna_generic.Neg](self : Matrix[T]) -> Matrix[T] {
  self.map(T::op_neg)
}

///|
pub fn op_sub[T : @luna_generic.Add + @luna_generic.Neg](
  self : Matrix[T],
  other : Matrix[T]
) -> Matrix[T] {
  self + -other
}

///|
pub fn scale[T : @luna_generic.Mul](self : Matrix[T], cst : T) -> Matrix[T] {
  self.map(fn(x) { x * cst })
}

///|
pub fn add_constant[T : @luna_generic.Add](
  self : Matrix[T],
  cst : T
) -> Matrix[T] {
  self.map(fn(x) { x + cst })
}

///|
pub fn identity[T : @luna_generic.One + @luna_generic.Zero](
  size : Int
) -> Matrix[T] {
  Matrix::make(size, size, fn(i, j) {
    guard i == j else { T::zero() }
    T::one()
  })
}

///|
pub fn null[T : Compare + @luna_generic.Zero](self : Matrix[T]) -> Bool {
  for x in self.data {
    if x != T::zero() {
      break false
    }
  } else {
    true
  }
}

///|
pub fn adjoint[T : @luna_generic.Conjugate](self : Matrix[T]) -> Matrix[T] {
  self.map(T::conjugate)
}

///| Compute the transpose of a matrix
pub fn transpose[T](self : Matrix[T]) -> Matrix[T] {
  Matrix::make(self.col, self.row, fn(i, j) { self[j][i] })
}

///| Compute the determinant of a matrix
pub fn determinant[T : @luna_generic.Mul + @luna_generic.Add + @luna_generic.One + @luna_generic.Neg + @luna_generic.Zero](
  self : Matrix[T]
) -> T {
  let n = self.row
  guard n == self.col
  fn go {
    f, 1 => f(0, 0)
    f, n => {
      let mut det = T::zero()
      for i in 0..<n {
        let sub_view = fn { j, k => f(j + 1, if k < i { k } else { k + 1 }) }
        let sign = if i % 2 == 0 { T::one() } else { -T::one() }
        det = det + sign * f(0, i) * go(sub_view, n - 1)
      }
      det
    }
  }

  go(fn { i, j => self[i][j] }, n)
}

///|
test {
  let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
  let m2 = Matrix::from_2d_array([[1, 0], [0, 1]])
  let m3 = m1 * m2
  let m4 = m1 + m2
  inspect!(
    m3,
    content=
      #||1, 2|
      #||3, 4|
    ,
  )
  inspect!(
    m4,
    content=
      #||2, 2|
      #||3, 5|
    ,
  )
  inspect!(
    -m1,
    content=
      #||-1, -2|
      #||-3, -4|
    ,
  )
  inspect!(
    m1.scale(10),
    content=
      #||10, 20|
      #||30, 40|
    ,
  )
  let m5 : Matrix[Int] = identity(5)
  inspect!(
    m5,
    content=
      #||1, 0, 0, 0, 0|
      #||0, 1, 0, 0, 0|
      #||0, 0, 1, 0, 0|
      #||0, 0, 0, 1, 0|
      #||0, 0, 0, 0, 1|
    ,
  )
  inspect!(
    m4.add_constant(10),
    content=
      #||12, 12|
      #||13, 15|
    ,
  )
  inspect!(m4.determinant(), content="4")
  inspect!(m1.determinant(), content="-2")
  inspect!(m5.determinant(), content="1")
}
