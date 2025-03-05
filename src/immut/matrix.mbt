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
/// Converts a matrix to its string representation. The resulting string displays
/// the matrix in a row-by-row format, with each row enclosed in vertical bars
/// (|) and elements separated by commas.
///
/// Parameters:
///
/// * `matrix` : The matrix to be converted to string. Elements in the matrix
/// must implement the `Show` trait.
///
/// Returns a string representation of the matrix.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Matrix::to_string" {
///   let m = Matrix::from_2d_array([[1, 2], [3, 4]])
///   inspect!(
///     m.to_string(),
///     content=
///       #||1, 2|
///       #||3, 4|
///     ,
///   )
/// }
/// ```
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
/// Writes the string representation of a matrix to a buffer.
///
/// Parameters:
///
/// * `matrix` : The matrix to be written to the buffer. The elements in the
/// matrix must implement the `Show` trait.
/// * `buffer` : A buffer to write the string representation to.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Matrix::output" {
///   let m = Matrix::from_2d_array([[1, 2], [3, 4]])
///   let buf = @buffer.new(size_hint=0)
///   m.output(buf)
///   inspect!(
///     buf.to_string(),
///     content=
///       #||1, 2|
///       #||3, 4|
///     ,
///   )
/// }
/// ```
pub impl[T : Show] Show for Matrix[T] with output(s, l) {
  l.write_string(s.to_string())
}

///|
/// Apply `map` method to the `Matrix` type.
/// 
/// Parameters
/// - `self`: The matrix to apply the map method.
/// - `f`: The function to apply to each element of the matrix.
/// 
/// Example
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
/// Parameters
/// - `row`: The number of rows in the matrix.
/// - `col`: The number of columns in the matrix.
/// - `f`: The function to apply to each element of the matrix.
///
/// Example
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
/// Parameters
/// - `row`: The number of rows in the matrix.
/// - `col`: The number of columns in the matrix.
/// - `elem`: The value to initialize the matrix with.
///
/// Example
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
/// Parameters
/// - `arr`: The array to shift to the `Matrix` type.
/// 
/// Example
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
/// Parameters
/// - `self`: The matrix to get the indexed type from.
/// - `row`: The row index to get the data from.
/// 
/// Example
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
/// Parameters
/// - `self`: The indexed type to get the element from.
/// - `col`: The column index to get the element from.
/// 
/// Example
/// ```moonbit
/// let m = Matrix::from_2d_array([[2, 3, 4], [1, 2, 3]])
/// inspect!(m[0][1], content="3")
/// ```
/// 
pub fn op_get[T](self : Indexed[T], col : Int) -> T {
  (self.index)(col)
}

///|
/// Creates a new matrix with the element at the specified position replaced with
/// a new value.
///
/// Parameters:
///
/// * `self` : The original matrix.
/// * `row` : The row index of the element to be replaced (zero-based).
/// * `col` : The column index of the element to be replaced (zero-based).
/// * `value` : The new value to replace the original element.
///
/// Returns a new matrix with the element at position (row, col) replaced with
/// the specified value.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Matrix::set" {
///   let m = Matrix::from_2d_array([[1, 2], [3, 4]])
///   let m2 = m.set(0, 1, 5)
///   inspect!(
///     m2,
///     content=
///       #||1, 5|
///       #||3, 4|
///     ,
///   )
/// }
/// ```
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
/// Multiplies two matrices.
/// 
/// Parameters
/// - `self`: The left matrix.
/// - `other`: The right matrix.
/// 
/// Example
/// ```moonbit
/// let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m2 = Matrix::from_2d_array([[1, 1], [0, 1]])
/// let m3 = m1 * m2
/// inspect!(m3, content=
///   #||1, 3|
///   #||3, 7|
/// )
/// ```
pub fn op_mul[T : @lg.Mul + @lg.Add](
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
/// Adds two matrices.
/// 
/// Parameters
/// - `self`: The left matrix.
/// - `other`: The right matrix.
///
/// Example
/// ```moonbit
/// let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m2 = Matrix::from_2d_array([[1, 1], [0, 1]])
/// let m3 = m1 + m2
/// inspect!(m3, content=
///   #||2, 3|
///   #||3, 5|
/// )
/// ```
pub fn op_add[T : @lg.Add](self : Matrix[T], other : Matrix[T]) -> Matrix[T] {
  guard self.col == other.col
  guard self.row == other.row
  {
    data: array_zip_with(self.data, other.data, T::op_add),
    row: self.row,
    col: self.col,
  }
}

///|
/// Negates all elements of a matrix.
/// 
/// Parameters
/// - `self`: The matrix to negate.
/// 
/// Example
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m1 = -m
/// inspect!(m1, content=
///   #||-1, -2|
///   #||-3, -4|
/// )
/// ```
pub fn op_neg[T : @lg.Neg](self : Matrix[T]) -> Matrix[T] {
  self.map(T::op_neg)
}

///|
/// Subtracts two matrices.
/// 
/// Parameters
/// - `self`: The left matrix.
/// - `other`: The right matrix.
/// 
/// Example
/// ```moonbit
/// let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m2 = Matrix::from_2d_array([[1, 1], [0, 1]])
/// let m3 = m1 - m2
/// inspect!(m3, content=
///   #||0, 1|
///   #||3, 3|
/// )
/// ```
pub fn op_sub[T : @lg.Add + @lg.Neg](
  self : Matrix[T],
  other : Matrix[T]
) -> Matrix[T] {
  self + -other
}

///|
/// Scales all elements of a matrix by a constant value.
/// 
/// Parameters
/// - `self`: The matrix to scale.
/// - `cst`: The constant value to scale the matrix by.
/// 
/// Example
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m1 = m.scale(10)
/// inspect!(m1, content=
///   #||10, 20|
///   #||30, 40|
/// )
/// ```
pub fn scale[T : @lg.Mul](self : Matrix[T], cst : T) -> Matrix[T] {
  self.map(fn(x) { x * cst })
}

///|
/// Adds a constant value to all elements of a matrix.
/// 
/// Parameters
/// - `self`: The matrix to add the constant value to.
/// - `cst`: The constant value to add to the matrix.
/// 
/// Example
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m1 = m.add_constant(10)
/// inspect!(m1, content=
///   #||11, 12|
///   #||13, 14|
/// )
/// ```
pub fn add_constant[T : @lg.Add](self : Matrix[T], cst : T) -> Matrix[T] {
  self.map(fn(x) { x + cst })
}

///|
/// Creates an identity matrix of a given size.
/// 
/// Parameters
/// - `size`: The size of the identity matrix to create.
/// 
/// Example
/// ```moonbit
/// let m = Matrix::identity(3)
/// inspect!(m, content=
///   #||1, 0, 0|
///   #||0, 1, 0|
///   #||0, 0, 1|
/// )
/// ```
pub fn identity[T : @lg.One + @lg.Zero](size : Int) -> Matrix[T] {
  Matrix::make(size, size, fn(i, j) {
    guard i == j else { T::zero() }
    T::one()
  })
}

///|
/// Checks if a matrix is a null matrix.
/// 
/// Parameters
/// - `self`: The matrix to check.
/// 
/// Example
/// ```moonbit
/// let m = Matrix::from_2d_array([[0, 0], [0, 0]])
/// inspect!(m.null(), content="true")
/// ```
pub fn null[T : Compare + @lg.Zero](self : Matrix[T]) -> Bool {
  not(self.data.iter().any(fn(x) { x != T::zero() }))
}

///|
/// Computes the adjoint of a matrix.
/// 
/// Parameters
/// - `self`: The matrix to compute the adjoint of.
/// 
/// Example
/// ```moonbit
/// let m = Matrix::from_2d_array([[1 + 2i, 2 + 3i], [3 + 4i, 4 + 5i]])
/// let m1 = m.adjoint()
/// inspect!(m1, content=
///   #||4 - 5i, -3 + 4i|
///   #||-2 + 3i, 1 - 2i|
/// )
/// ```
pub fn adjoint[T : @lg.Conjugate](self : Matrix[T]) -> Matrix[T] {
  self.map(T::conjugate)
}

///|
/// Computes the transpose of a matrix by swapping its rows and columns. The
/// transpose of an m × n matrix is an n × m matrix where the element at position
/// (i, j) in the original matrix becomes the element at position (j, i) in the
/// transposed matrix.
///
/// Parameters:
///
/// * `matrix` : The input matrix to be transposed.
///
/// Returns a new matrix that is the transpose of the input matrix.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "transpose" {
///   let m = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
///   inspect!(
///     m.transpose(),
///     content=
///       #||1, 4|
///       #||2, 5|
///       #||3, 6|
///     ,
///   )
/// }
/// ```
pub fn transpose[T](self : Matrix[T]) -> Matrix[T] {
  Matrix::make(self.col, self.row, fn(i, j) { self[j][i] })
}

///|
/// Compute the determinant of a matrix.
/// 
/// Parameters
/// - `self`: The matrix to compute the determinant of.
/// 
/// Example
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2], [3, 4]])
/// inspect!(m.determinant(), content="-2")
/// ```
pub fn determinant[T : @lg.Mul + @lg.Add + @lg.One + @lg.Neg + @lg.Zero](
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
        det += sign * f(0, i) * go(sub_view, n - 1)
      }
      det
    }
  }
  go(fn { i, j => self[i][j] }, n)
}

///|
/// Raises a matrix to a power. Power must be a non-negative integer.
/// 
/// Parameters
/// - `self`: The matrix to raise to a power.
/// - `power`: The power to raise the matrix to.
/// 
/// Example
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m1 = m.pow(2)
/// inspect!(m1, content=
///   #||7, 10|
///   #||15, 22|
/// )
/// ```
pub fn pow[T : @lg.Semiring](self : Matrix[T], power : Int) -> Matrix[T] {
  loop identity(self.col), power, self {
    s, 0, _ => s
    s, 1, m => s * m
    s, p, m => continue if (p & 1) == 1 { s * m } else { s }, p >> 1, m * m
  }
}

///|
/// Combines two matrices horizontally by concatenating their columns.
/// The rows of this two matrices must be the same.
/// 
/// Parameters
/// - `self`: The left matrix.
/// - `other`: The right matrix.
/// 
/// Example
/// ```moonbit
/// let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m2 = Matrix::from_2d_array([[1, 0], [0, 1]])
/// let m3 = horizontal_combine(m1, m2)
/// inspect!(m3, content=
///   #||1, 2, 1, 0|
///   #||3, 4, 0, 1|
/// )
/// ```
pub fn horizontal_combine[T](self : Matrix[T], other : Matrix[T]) -> Matrix[T] {
  let r1 = self.row
  let c1 = self.col
  let r2 = other.row
  let c2 = other.col
  guard r1 == r2
  Matrix::make(r1, c1 + c2, fn(i, j) {
    if j < c1 {
      self[i][j]
    } else {
      other[i][j - c1]
    }
  })
}

///|
/// Combines two matrices vertically by concatenating their rows.
/// The columns of this two matrices must be the same.
/// 
/// Parameters
/// - `self`: The left matrix.
/// - `other`: The right matrix.
/// 
/// Example
/// ```moonbit
/// let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m2 = Matrix::from_2d_array([[1, 0], [0, 1]])
/// let m3 = vertical_combine(m1, m2)
/// inspect!(m3, content=
///   #||1, 2|
///   #||3, 4|
///   #||1, 0|
///   #||0, 1|
/// )
/// ```
pub fn vertical_combine[T](self : Matrix[T], other : Matrix[T]) -> Matrix[T] {
  Matrix::horizontal_combine(self.transpose(), other.transpose()).transpose()
}

///|
test "matrix_combine" {
  let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
  let m2 = Matrix::from_2d_array([[1, 0], [0, 1]])
  let m3 = horizontal_combine(m1, m2)
  let m4 = vertical_combine(m1, m2)
  inspect!(
    m3,
    content=
      #||1, 2, 1, 0|
      #||3, 4, 0, 1|
    ,
  )
  inspect!(
    m4,
    content=
      #||1, 2|
      #||3, 4|
      #||1, 0|
      #||0, 1|
    ,
  )
}

///|
/// Swaps two rows of a matrix.
/// 
/// Parameters
/// - `self`: The matrix to swap the rows of.
/// - `r1`: The index of the first row to swap.
/// - `r2`: The index of the second row to swap.
///
/// Example
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m1 = swap_rows(m, 0, 1)
/// inspect!(m1, content=
///   #||3, 4|
///   #||1, 2|
/// )
/// ```
pub fn swap_rows[T](self : Matrix[T], r1 : Int, r2 : Int) -> Matrix[T] {
  guard r1 < self.row && r2 < self.row
  guard r1 >= 0 && r2 >= 0
  guard r1 != r2
  let new_matrix = Matrix::make(self.row, self.col, fn(i, j) {
    if i == r1 {
      self[r2][j]
    } else if i == r2 {
      self[r1][j]
    } else {
      self[i][j]
    }
  })
  new_matrix
}

///|
/// Swaps two columns of a matrix. The c1 and c2 must be less than
/// the number of columns in the matrix.
/// 
/// Parameters
/// - `self`: The matrix to swap the columns of.
/// - `c1`: The index of the first column to swap.
/// - `c2`: The index of the second column to swap.
///
/// Example
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m1 = swap_cols(m, 0, 1)
/// inspect!(m1, content=
///   #||2, 1|
///   #||4, 3|
/// )
/// ```
pub fn swap_cols[T](self : Matrix[T], c1 : Int, c2 : Int) -> Matrix[T] {
  self.transpose().swap_rows(c1, c2).transpose()
}

///|
test "swap_matrix" {
  let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
  let m2 = Matrix::from_2d_array([[1, 0], [0, 1]])
  let m3 = swap_rows(m1, 0, 1)
  let m4 = swap_cols(m2, 0, 1)
  inspect!(
    m3,
    content=
      #||3, 4|
      #||1, 2|
    ,
  )
  inspect!(
    m4,
    content=
      #||0, 1|
      #||1, 0|
    ,
  )
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
  let m = Matrix::make(3, 3, fn(i, _) -> Int { i }).pow(10)
  inspect!(
    m,
    content=
      #||0, 0, 0|
      #||19683, 19683, 19683|
      #||39366, 39366, 39366|
    ,
  )
}
