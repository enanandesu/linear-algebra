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
/// Demonstrates basic operations of the Matrix type, including matrix creation
/// and element access.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Matrix/basic_operations" {
///   // Create a 2x3 matrix from a 2D array
///   let m = Matrix::from_2d_array([[2, 3, 4], [1, 2, 3]])
///
///   // Verify matrix content and formatting
///   inspect!(
///     m,
///     content=
///       #||2, 3, 4|
///       #||1, 2, 3|
///     ,
///   )
///
///   // Demonstrate element access using row and column indices
///   inspect!(m[0][1], content="3")
/// }
/// ```
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
/// Performs matrix multiplication between two matrices.
///
/// Parameters:
///
/// * `left` : The left matrix in the multiplication.
/// * `right` : The right matrix in the multiplication. The number of columns in
/// the left matrix must equal the number of rows in the right matrix.
///
/// Returns a new matrix that is the product of the multiplication. The resulting
/// matrix has the same number of rows as the left matrix and the same number of
/// columns as the right matrix.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Matrix::op_mul" {
///   let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
///   let m2 = Matrix::from_2d_array([[5, 6], [7, 8]])
///   inspect!(
///     m1 * m2,
///     content=
///       #||19, 22|
///       #||43, 50|
///     ,
///   )
/// }
/// ```
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
/// Adds two matrices of the same dimensions element-wise. The matrices must have
/// the same number of rows and columns.
///
/// Parameters:
///
/// * `self` : The first matrix to be added.
/// * `other` : The second matrix to be added.
///
/// Returns a new matrix where each element is the sum of the corresponding
/// elements from the input matrices.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Matrix::op_add" {
///   let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
///   let m2 = Matrix::from_2d_array([[5, 6], [7, 8]])
///   inspect!(
///     m1 + m2,
///     content=
///       #||6, 8|
///       #||10, 12|
///     ,
///   )
/// }
/// ```
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
/// Negates all elements in a matrix. Produces a new matrix where each element is
/// the negation of the corresponding element in the input matrix.
///
/// Parameters:
///
/// * `matrix` : The matrix to be negated. The elements in the matrix must
/// implement the `Neg` trait.
///
/// Returns a new matrix with all elements negated.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Matrix::op_neg" {
///   let m = Matrix::from_2d_array([[1, 2], [3, 4]])
///   inspect!(
///     -m,
///     content=
///       #||-1, -2|
///       #||-3, -4|
///     ,
///   )
/// }
/// ```
pub fn op_neg[T : @luna_generic.Neg](self : Matrix[T]) -> Matrix[T] {
  self.map(T::op_neg)
}

///|
/// Subtracts one matrix from another element-wise. The matrices must have the
/// same number of rows and columns.
///
/// Parameters:
///
/// * `matrix1` : The matrix from which to subtract.
/// * `matrix2` : The matrix to be subtracted.
///
/// Returns a new matrix where each element is the difference of the
/// corresponding elements from the input matrices.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Matrix::op_sub" {
///   let m1 = Matrix::from_2d_array([[5, 6], [7, 8]])
///   let m2 = Matrix::from_2d_array([[1, 2], [3, 4]])
///   inspect!(
///     m1 - m2,
///     content=
///       #||4, 4|
///       #||4, 4|
///     ,
///   )
/// }
/// ```
pub fn op_sub[T : @luna_generic.Add + @luna_generic.Neg](
  self : Matrix[T],
  other : Matrix[T]
) -> Matrix[T] {
  self + -other
}

///|
/// Performs scalar multiplication on a matrix, multiplying each element by a
/// constant value.
///
/// Parameters:
///
/// * `matrix` : The input matrix to be scaled.
/// * `constant` : The scalar value to multiply with each element of the matrix.
///
/// Returns a new matrix where each element is the product of the corresponding
/// element in the input matrix and the constant value.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Matrix::scale" {
///   let m = Matrix::from_2d_array([[1, 2], [3, 4]])
///   inspect!(
///     m.scale(2),
///     content=
///       #||2, 4|
///       #||6, 8|
///     ,
///   )
/// }
/// ```
pub fn scale[T : @luna_generic.Mul](self : Matrix[T], cst : T) -> Matrix[T] {
  self.map(fn(x) { x * cst })
}

///|
/// Adds a constant value to each element of a matrix.
///
/// Parameters:
///
/// * `matrix` : The input matrix with elements of type `T`.
/// * `constant` : The value to be added to each element of the matrix.
///
/// Returns a new matrix where each element is the sum of the corresponding
/// element in the input matrix and the constant value.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Matrix::add_constant" {
///   let m = Matrix::from_2d_array([[1, 2], [3, 4]])
///   inspect!(
///     m.add_constant(10),
///     content=
///       #||11, 12|
///       #||13, 14|
///     ,
///   )
/// }
/// ```
pub fn add_constant[T : @luna_generic.Add](
  self : Matrix[T],
  cst : T
) -> Matrix[T] {
  self.map(fn(x) { x + cst })
}

///|
/// Creates an identity matrix of the specified size. An identity matrix is a
/// square matrix with ones on the main diagonal and zeros elsewhere.
///
/// Parameters:
///
/// * `size` : The dimension of the square matrix. Must be a non-negative
/// integer.
/// * `T` : The type parameter that must implement both `One` and `Zero` traits,
/// representing the type of elements in the matrix.
///
/// Returns a new identity matrix of type `Matrix[T]` with the specified size.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "identity" {
///   let m : Matrix[Int] = identity(3)
///   inspect!(
///     m,
///     content=
///       #||1, 0, 0|
///       #||0, 1, 0|
///       #||0, 0, 1|
///     ,
///   )
/// }
/// ```
pub fn identity[T : @luna_generic.One + @luna_generic.Zero](
  size : Int
) -> Matrix[T] {
  Matrix::make(size, size, fn(i, j) {
    guard i == j else { T::zero() }
    T::one()
  })
}

///|
/// Checks if a matrix is a null matrix (all elements are zero).
///
/// Parameters:
///
/// * `matrix` : The matrix to be checked. The elements in the matrix must
/// implement the `Compare` trait for equality comparison and the `Zero` trait to
/// provide a zero value.
///
/// Returns a boolean value indicating whether the matrix is a null matrix
/// (`true`) or not (`false`).
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "null" {
///   let zero_matrix = Matrix::make(2, 2, fn { _, _ => 0 })
///   let non_zero_matrix = Matrix::from_2d_array([[1, 0], [0, 0]])
///   inspect!(zero_matrix.null(), content="true")
///   inspect!(non_zero_matrix.null(), content="false")
/// }
/// ```
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
/// Computes the adjoint (conjugate transpose) of a matrix by applying the
/// conjugate operation to each element.
///
/// Parameters:
///
/// * `matrix` : The input matrix whose elements implement the `Conjugate` trait.
///
/// Returns a new matrix that is the adjoint of the input matrix.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Matrix::adjoint" {
///   let m = Matrix::from_2d_array([
///     [Complex::new(1.0, 2.0), Complex::new(3.0, 4.0)],
///   ])
///   inspect!(
///     m.adjoint(),
///     content=
///       #||1.0-2.0i|
///       #||3.0-4.0i|
///     ,
///   )
/// }
/// ```
pub fn adjoint[T : @luna_generic.Conjugate](self : Matrix[T]) -> Matrix[T] {
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
/// Computes the determinant of a square matrix using the Laplace expansion
/// method.
/// The calculation is performed recursively along the first row of the matrix.
///
/// Parameters:
///
/// * `matrix` : A square matrix whose elements implement the following traits:
///  * `Mul` for multiplication
///  * `Add` for addition
///  * `One` for multiplicative identity
///  * `Neg` for negation
///  * `Zero` for additive identity
///
/// Returns the determinant of the matrix.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "determinant" {
///   let m = Matrix::from_2d_array([[1, 2], [3, 4]])
///   inspect!(m.determinant(), content="-2")
/// }
/// ```
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
