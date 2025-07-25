///|
/// Two-dimensional matrix with mutable elements stored in row-major order.
///
/// Fields:
///
/// Since this struct is not marked with any visibility modifier, it is abstract
/// and users can only pass its value around without direct access to its
/// internal structure.
///
/// Example:
///
/// ```moonbit
/// // Create a 2x3 matrix filled with zeros
/// let m = @mutable.Matrix::new(2, 3, 0)
///
/// // Create from a 2D array
/// let m2 = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
///
/// // Access and modify elements
/// m2[0][1] = 10
/// inspect(m2[0][1], content="10")
///
/// // Get dimensions
/// inspect(m2.row(), content="2")
/// inspect(m2.col(), content="3")
///
/// // Create identity matrix
/// let id : Matrix[Int] = @mutable.identity(3)
/// ```
///
struct Matrix[T] {
  row : Int
  col : Int
  data : Array[T]
} derive(Eq)

///|
/// Indexing interface that provides mutable access to elements along a matrix
/// row.
///
/// Fields:
///
/// Since this struct is not marked with any visibility modifier, it is abstract
/// and users cannot directly access its fields. The struct can only be used
/// through its associated methods.
///
/// Example:
///
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// let row_lens = m[0]  // Get lens for first row
/// inspect(row_lens[1], content="2")  // Access element at column 1
/// row_lens[1] = 9     // Modify element at column 1
/// inspect(row_lens[1], content="9")
/// ```
///
struct Lens[T] {
  set : (Int, T) -> Unit
  get : (Int) -> T
}

///|
/// Returns the number of rows in the matrix.
///
/// Parameters:
///
/// * `self` : The matrix to query.
///
/// Returns the number of rows as an `Int`.
///
/// Example:
///
/// ```moonbit
/// let matrix =Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// inspect(matrix.row(), content="2")
/// ```
///
pub fn[T] row(self : Matrix[T]) -> Int {
  self.row
}

///|
/// Returns the number of columns in the matrix.
///
/// Parameters:
///
/// * `self` : The matrix to query.
///
/// Returns:
///
/// `Int` - The number of columns in the matrix.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// inspect(m.col(), content="3")
/// ```
///
pub fn[T] col(self : Matrix[T]) -> Int {
  self.col
}

///|
/// Converts a matrix to its string representation in a readable format.
///
/// Parameters:
///
/// * `s` : The matrix to convert to a string.
///
/// Returns a string representation of the matrix where each row is enclosed in
/// vertical bars (`|`), elements are separated by commas and spaces, and rows
/// are separated by newlines.
///
/// Example:
///
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// inspect(m.to_string(), content="|1, 2, 3|\n|4, 5, 6|")
/// ```
///
pub impl[T : Show] Show for Matrix[T] with to_string(s) {
  let res = StringBuilder::new()
  for i in 0..<s.row {
    res.write_char('|')
    s.eachi_row(i, (c, x) => {
      res.write_string(x.to_string())
      if c < s.col - 1 {
        res.write_string(", ")
      }
    })
    res.write_char('|')
    if i < s.row - 1 {
      res.write_string("\n")
    }
  }
  res.to_string()
}

///|
/// Implements output functionality for `Matrix[T]` by writing its string
/// representation to a logger.
///
/// Parameters:
///
/// * `s` : The matrix to be output.
/// * `l` : The logger to write the matrix representation to.
///
pub impl[T : Show] Show for Matrix[T] with output(s, l) {
  l.write_string(s.to_string())
}

///|
/// Applies a function to every element of the matrix, creating a new matrix
/// with the transformed elements.
///
/// Parameters:
///
/// * `self` : The input matrix to transform.
/// * `f` : The function to apply to each element, taking a value of type `T`
///   and returning a value of type `U`.
///
/// Returns a new matrix with the same dimensions as the input matrix, where
/// each element is the result of applying the function `f` to the corresponding
/// element in the input matrix.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2], [3, 4]])
/// let doubled = m.map(fn(x) { x * 2 })
/// inspect(doubled, content="|2, 4|\n|6, 8|")
/// ```
///
pub fn[T, U] Matrix::map(self : Matrix[T], f : (T) -> U) -> Matrix[U] {
  { row: self.row, col: self.col, data: self.data.map(f) }
}

///|
/// Applies a transformation function to all elements in the matrix in-place,
/// modifying the original matrix.
///
/// Parameters:
///
/// * `self` : The matrix whose elements will be transformed.
/// * `f` : The transformation function to apply to each element, taking a value
///   of type `T` and returning a transformed value of the same type.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2], [3, 4]])
/// m.map_inplace(fn(x) { x * 2 })
/// inspect(m, content="|2, 4|\n|6, 8|")
/// ```
///
pub fn[T] Matrix::map_inplace(self : Matrix[T], f : (T) -> T) -> Unit {
  self.data.map_inplace(f)
}

///|
/// Converts a matrix to its transpose representation without copying the
/// underlying data.
///
/// Parameters:
///
/// * `self` : The matrix to convert to transpose form.
///
/// Returns a `Transpose[T]` that represents the transposed view of the original
/// matrix, where rows and columns are swapped but the underlying data array
/// remains shared.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// let t = m.to_transpose()
/// // The transpose has 3 rows and 2 columns (original was 2x3)
/// ```
///
pub fn[T] to_transpose(self : Matrix[T]) -> Transpose[T] {
  self
}

///|
/// Applies a transformation function to all elements in a specific row of the
/// matrix in-place.
///
/// Parameters:
///
/// * `self` : The matrix to modify.
/// * `row` : The zero-based index of the row to transform.
/// * `f` : The transformation function to apply to each element in the row.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// m.map_row_inplace(0, fn(x) { x * 2 })
/// // The first row becomes [2, 4, 6], second row remains [4, 5, 6]
/// ```
///
pub fn[T] Matrix::map_row_inplace(
  self : Matrix[T],
  row : Int,
  f : (T) -> T,
) -> Unit {
  for i in 0..<self.col {
    self.data[row * self.col + i] = f(self.data[row * self.col + i])
  }
}

///|
/// Applies a transformation function to all elements in a specific column of
/// the matrix in-place.
///
/// Parameters:
///
/// * `self` : The matrix to modify.
/// * `col` : The index of the column to transform (0-based).
/// * `f` : The transformation function to apply to each element in the column.
///
/// Example:
///
/// ```moonbit
/// let matrix = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// matrix.map_col_inplace(1, fn(x) { x * 2 })
/// // matrix is now [[1, 4, 3], [4, 10, 6]]
/// ```
///
pub fn[T] Matrix::map_col_inplace(
  self : Matrix[T],
  col : Int,
  f : (T) -> T,
) -> Unit {
  for i in 0..<self.row {
    self.data[i * self.col + col] = f(self.data[i * self.col + col])
  }
}

///|
/// Applies a function to each element in the matrix.
///
/// Parameters:
///
/// * `self` : The matrix whose elements will be processed.
/// * `f` : The function to apply to each element.
pub fn[T] Matrix::each(self : Matrix[T], f : (T) -> Unit) -> Unit {
  self.data.each(f)
}

///|
/// Iterates over each element of the matrix with its index, calling the
/// provided function for each element.
///
/// Parameters:
///
/// * `self` : The matrix to iterate over.
/// * `f` : A function that takes an index and an element value. The index
///   represents the linear position in the underlying array (calculated as `row
///   * col_count + col`).
pub fn[T] Matrix::eachi(self : Matrix[T], f : (Int, T) -> Unit) -> Unit {
  self.data.eachi(f)
}

///|
/// Iterates through all elements of the matrix, calling the provided function
/// with the row index, column index, and value for each element.
///
/// Parameters:
///
/// * `self` : The matrix to iterate through.
/// * `f` : A function that takes three parameters: the row index (Int), the
///   column index (Int), and the element value (T). This function is called for
///   each element in the matrix.
pub fn[T] Matrix::each_row_col(
  self : Matrix[T],
  f : (Int, Int, T) -> Unit,
) -> Unit {
  self.data.eachi((index, data) => f(index / self.col, index % self.col, data))
}

///|
/// Applies a function to each element in the specified row of the matrix.
///
/// Parameters:
///
/// * `self` : The matrix to iterate over.
/// * `row` : The index of the row to iterate through.
/// * `f` : The function to apply to each element in the row.
pub fn[T] Matrix::each_row(
  self : Matrix[T],
  row : Int,
  f : (T) -> Unit,
) -> Unit {
  for i in 0..<self.col {
    f(self.data[row * self.col + i])
  }
}

///|
/// Iterates over all elements in a specific row of the matrix with their column
/// indices, applying a function to each element.
///
/// Parameters:
///
/// * `self` : The matrix to iterate over.
/// * `row` : The zero-based index of the row to iterate through.
/// * `f` : A function that takes two parameters: the column index (Int) and the
///   element value (T). This function is called for each element in the
///   specified row.
///
/// Example:
///
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// m.eachi_row(1, fn(col_index, value) {
///   println("Row 1, Column \{col_index}: \{value}")
/// })
/// // Prints:
/// // Row 1, Column 0: 4
/// // Row 1, Column 1: 5
/// // Row 1, Column 2: 6
/// ```
///
pub fn[T] Matrix::eachi_row(
  self : Matrix[T],
  row : Int,
  f : (Int, T) -> Unit,
) -> Unit {
  for i in 0..<self.col {
    f(i, self.data[row * self.col + i])
  }
}

///|
/// Iterates over all elements in a specific column of the matrix, applying a
/// function to each element.
///
/// Parameters:
///
/// * `self` : The matrix to iterate over.
/// * `col` : The column index to iterate over.
/// * `f` : The function to apply to each element in the column.
pub fn[T] Matrix::each_col(
  self : Matrix[T],
  col : Int,
  f : (T) -> Unit,
) -> Unit {
  for i in 0..<self.row {
    f(self.data[i * self.col + col])
  }
}

///|
/// Iterates over all elements in a specific column of the matrix with their row
/// indices, applying a function to each element and its corresponding row
/// index.
///
/// Parameters:
///
/// * `self` : The matrix to iterate over.
/// * `col` : The zero-based index of the column to iterate through.
/// * `f` : The function to apply to each element in the column, which takes the
///   row index and the element value as parameters.
///
/// Example:
///
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// m.eachi_col(1, fn(row_idx, value) {
///   println("Row \{row_idx}: \{value}")
/// })
/// // Output:
/// // Row 0: 2
/// // Row 1: 5
/// ```
///
pub fn[T] Matrix::eachi_col(
  self : Matrix[T],
  col : Int,
  f : (Int, T) -> Unit,
) -> Unit {
  for i in 0..<self.row {
    f(i, self.data[i * self.col + col])
  }
}

///|
/// Creates a deep copy of the matrix with the same dimensions and element
/// values.
///
/// Parameters:
///
/// * `self` : The matrix to be copied.
///
/// Returns a new matrix that is an independent copy of the original matrix.
///
/// Example:
///
/// ```moonbit
/// let original = @mutable.Matrix::from_2d_array([[1, 2], [3, 4]])
/// let copy = original.copy()
/// copy[0][0] = 99
/// inspect(original[0][0], content="1") // Original remains unchanged
/// inspect(copy[0][0], content="99")    // Copy is modified
/// ```
///
pub fn[T] Matrix::copy(self : Matrix[T]) -> Matrix[T] {
  { row: self.row, col: self.col, data: self.data.copy() }
}

///|
/// Tests the functionality of row and column mapping operations on matrices.
///
/// This test verifies that `map_row` and `map_col` methods correctly apply
/// transformation functions to specific rows and columns of a matrix while
/// leaving other elements unchanged.
///
/// The test creates a 2x3 matrix with values `[[1, 2, 3], [4, 5, 6]]` and
/// performs two operations:
///
/// 1. **Row mapping test**: Applies a doubling function to row 0, transforming
/// `[1, 2, 3]` to `[2, 4, 6]` while keeping row 1 unchanged as `[4, 5, 6]`.
///
/// 2. **Column mapping test**: Applies a doubling function to column 0,
/// transforming the first column from `[1, 4]` to `[2, 8]` while keeping other
/// columns unchanged.
///
/// The test validates that:
///
/// * `map_row` only affects the specified row
/// * `map_col` only affects the specified column
/// * Matrix copying works correctly to preserve the original matrix
/// * The transformation functions are applied element-wise correctly
/// * String representation of matrices displays the expected format
///
/// Example output:
///
/// * After row 0 mapping: `"|2, 4, 6|\n|4, 5, 6|"`
/// * After column 0 mapping: `"|2, 2, 3|\n|8, 5, 6|"`
///
test "map_function" {
  let m = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
  let m1 = {
    let m_ = m.copy()
    m_.map_row_inplace(0, fn(x) { x * 2 })
    m_
  }
  let m2 = {
    let m_ = m.copy()
    m_.map_col_inplace(0, fn(x) { x * 2 })
    m_
  }
  inspect(m1.to_string(), content="|2, 4, 6|\n|4, 5, 6|")
  inspect(m2.to_string(), content="|2, 2, 3|\n|8, 5, 6|")
}

///|
/// Creates a new matrix with specified dimensions using a generator function.
///
/// Parameters:
///
/// * `row` : The number of rows in the matrix.
/// * `col` : The number of columns in the matrix.
/// * `f` : A function that takes row and column indices and returns the element
///   at that position.
///
/// Returns a new `Matrix[A]` with the specified dimensions where each element
/// is generated by calling the function with its row and column indices.
///
/// Example:
///
/// ```moonbit
/// // Create a 3x3 identity matrix
/// let identity = Matrix::make(3, 3, fn(i, j) { if i == j { 1 } else { 0 } })
///
/// // Create a matrix where each element equals its row index plus column index
/// let sum_matrix = Matrix::make(2, 3, fn(i, j) { i + j })
/// ```
///
pub fn[A] Matrix::make(row : Int, col : Int, f : (Int, Int) -> A) -> Matrix[A] {
  { row, col, data: Array::makei(row * col, fn(i) { f(i / col, i % col) }) }
}

///|
/// Creates a new matrix with the specified dimensions where all elements are
/// initialized to the same value.
///
/// Parameters:
///
/// * `row` : The number of rows in the matrix.
/// * `col` : The number of columns in the matrix.
/// * `elem` : The value to initialize all elements in the matrix.
///
/// Returns a new `Matrix[T]` with all elements set to `elem`.
///
/// Example:
///
/// ```moonbit
/// let m = Matrix::new(2, 3, 42)
/// inspect(m.to_string(), content="|42, 42, 42|\n|42, 42, 42|")
/// ```
///
pub fn[T] Matrix::new(row : Int, col : Int, elem : T) -> Matrix[T] {
  Matrix::make(row, col, (_, _) => elem)
}

///|
/// Creates a matrix from a 2D array.
///
/// Parameters:
///
/// * `arr` : A 2D array where each sub-array represents a row of the matrix.
///
/// Returns a new `Matrix[T]` with the same dimensions and elements as the input
/// 2D array.
///
/// Panics if the input array is empty or if any sub-array is empty.
///
/// Example:
///
/// ```moonbit
/// let data = [[1, 2, 3], [4, 5, 6]]
/// let matrix = Matrix::from_2d_array(data)
/// inspect(matrix.to_string(), content="|1, 2, 3|\n|4, 5, 6|")
/// ```
///
pub fn[T] Matrix::from_2d_array(arr : Array[Array[T]]) -> Matrix[T] {
  Matrix::make(arr.length(), arr[0].length(), fn(i, j) { arr[i][j] })
}

///|
/// Creates a matrix from a flat array with specified dimensions.
///
/// Parameters:
///
/// * `row` : The number of rows in the matrix.
/// * `col` : The number of columns in the matrix.
/// * `data` : A flat array containing the matrix elements in row-major order.
///
/// Returns a new matrix with the specified dimensions.
///
/// Panics if the product of `row` and `col` does not equal the length of
/// `data`.
///
/// Example:
///
/// ```moonbit
/// let data = [1, 2, 3, 4, 5, 6]
/// let matrix = @mutable.Matrix::from_array(2, 3, data)
/// inspect(matrix, content="|1, 2, 3|\n|4, 5, 6|")
/// ```
///
pub fn[T] Matrix::from_array(
  row : Int,
  col : Int,
  data : Array[T],
) -> Matrix[T] {
  guard row * col == data.length()
  { row, col, data }
}

///|
/// Returns a lens that provides indexed access to a specific row of the matrix.
///
/// Parameters:
///
/// * `self` : The matrix to access.
/// * `row` : The zero-based index of the row to access.
///
/// Returns a `Lens[T]` object that allows getting and setting elements in the
/// specified row by column index.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// let row_lens = m[1]  // Get lens for row 1
/// inspect(row_lens[0], content="4")  // Access element at column 0
/// row_lens[2] = 10  // Set element at column 2
/// inspect(m[1][2], content="10")
/// ```
///
pub fn[T] Matrix::op_get(self : Matrix[T], row : Int) -> Lens[T] {
  {
    set: (c, v) => self.data[c + self.col * row] = v,
    get: c => self.data[c + self.col * row],
  }
}

///|
/// Retrieves the value at the specified column index from the lens.
///
/// Parameters:
///
/// * `self` : The lens to access.
/// * `col` : The column index to retrieve the value from.
///
/// Returns the value at the specified column index.
///
pub fn[T] op_get(self : Lens[T], col : Int) -> T {
  (self.get)(col)
}

///|
/// Sets the value at the specified column index in the lens.
///
/// Parameters:
///
/// * `self` : The lens object to modify.
/// * `col` : The column index where the value should be set.
/// * `elem` : The value to set at the specified column index.
///
/// Example:
///
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// let lens = m[0]  // Get lens for first row
/// lens[1] = 10     // Set column 1 to value 10
/// inspect(m[0][1], content="10")
/// ```
///
pub fn[T] Lens::op_set(self : Lens[T], col : Int, elem : T) -> Unit {
  (self.set)(col, elem)
}

///|
/// Tests the matrix element assignment functionality through the `op_set`
/// operation.
///
/// This test verifies that matrix elements can be both read and modified using
/// the bracket notation syntax. It creates a 2x3 matrix, reads an element to
/// confirm its initial value, modifies that element, and then reads it again to
/// verify the change took effect.
///
/// Example:
///
/// ```moonbit
/// test {
///   let m = Matrix::from_2d_array([[2, 3, 4], [1, 2, 3]])
///   inspect(m[0][1], content="3")  // Read element at row 0, column 1
///   m[0][1] = 4                    // Modify element at row 0, column 1
///   inspect(m[0][1], content="4")  // Verify the modification
/// }
/// ```
///
test "op_set" {
  let m = Matrix::from_2d_array([[2, 3, 4], [1, 2, 3]])
  inspect(m[0][1], content="3")
  m[0][1] = 4
  inspect(m[0][1], content="4")
}

///|
/// Multiplies two matrices using standard matrix multiplication.
///
/// Parameters:
///
/// * `self` : The left matrix operand.
/// * `other` : The right matrix operand.
///
/// Returns a new matrix that is the product of `self` and `other`.
///
/// Panics if the number of columns in `self` does not equal the number of rows
/// in `other`.
///
/// Example:
///
/// ```moonbit
/// let a = @mutable.Matrix::from_2d_array([[1, 2], [3, 4]])
/// let b = @mutable.Matrix::from_2d_array([[5, 6], [7, 8]])
/// let result = a * b
/// inspect(result, content="|19, 22|\n|43, 50|")
/// ```
///
pub impl[T : Mul + Add] Mul for Matrix[T] with op_mul(
  self : Matrix[T],
  other : Matrix[T],
) -> Matrix[T] {
  let row = self.row
  let col = other.col
  let inner = self.col
  guard inner == other.row
  let data = Array::makei(row * col, fn(i) {
    let r = i / col
    let c = i % col
    let mut sum = self[r][0] * other[0][c]
    for k in 1..<inner {
      sum += self[r][k] * other[k][c]
    }
    sum
  })
  { row, col, data }
}

///|
/// Adds two matrices element-wise.
///
/// Parameters:
///
/// * `self` : The first matrix.
/// * `other` : The second matrix to add to the first matrix.
///
/// Returns a new matrix where each element is the sum of the corresponding
/// elements from the input matrices.
///
/// Panics if the matrices have different dimensions (different number of rows
/// or columns).
///
/// Example:
///
/// ```moonbit
/// let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m2 = Matrix::from_2d_array([[5, 6], [7, 8]])
/// let result = m1 + m2
/// inspect(result, content="|6, 8|\n|10, 12|")
/// ```
///
pub impl[T : Add] Add for Matrix[T] with op_add(
  self : Matrix[T],
  other : Matrix[T],
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
/// Negates all elements in the matrix.
///
/// Parameters:
///
/// * `self` : The matrix to negate.
///
/// Returns a new matrix with all elements negated.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, -2], [3, -4]])
/// let negated = -m
/// inspect(negated.to_string(), content="|-1, 2|\n|-3, 4|")
/// ```
///
pub impl[T : Neg] Neg for Matrix[T] with op_neg(self : Matrix[T]) -> Matrix[T] {
  self.map(T::op_neg)
}

///|
/// Subtracts the second matrix from the first matrix element-wise.
///
/// Parameters:
///
/// * `self` : The matrix from which to subtract (minuend).
/// * `other` : The matrix to subtract (subtrahend).
///
/// Returns a new matrix containing the element-wise difference of the two
/// matrices.
///
/// Example:
///
/// ```moonbit
/// let m1 =Matrix::from_2d_array([[5, 7], [9, 11]])
/// let m2 =Matrix::from_2d_array([[1, 2], [3, 4]])
/// let result = m1 - m2
/// // result is |4, 5|
/// //           |6, 7|
/// ```
///
pub impl[T : Add + Neg] Sub for Matrix[T] with op_sub(
  self : Matrix[T],
  other : Matrix[T],
) -> Matrix[T] {
  self + -other
}

///|
/// Multiplies each element of the matrix by a scalar value.
///
/// Parameters:
///
/// * `self` : The matrix to be scaled.
/// * `cst` : The scalar value to multiply each element by.
///
/// Returns a new matrix where each element is the product of the corresponding
/// element in the original matrix and the scalar.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2], [3, 4]])
/// let scaled = m.scale(2)
/// inspect(scaled, content="|2, 4|\n|6, 8|")
/// ```
///
pub fn[T : Mul] scale(self : Matrix[T], cst : T) -> Matrix[T] {
  self.map(x => x * cst)
}

///|
/// Adds a constant value to each element of the matrix.
///
/// Parameters:
///
/// * `self` : The matrix to which the constant will be added.
/// * `cst` : The constant value to add to each element.
///
/// Returns a new matrix with the constant added to each element of the original
/// matrix.
///
/// Example:
///
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let result = m.add_constant(5)
/// inspect(result, content="|6, 7|\n|8, 9|")
/// ```
///
pub fn[T : Add] add_constant(self : Matrix[T], cst : T) -> Matrix[T] {
  self.map(x => x + cst)
}

///|
/// Creates an identity matrix of the specified size.
///
/// Parameters:
///
/// * `size` : The number of rows and columns of the identity matrix.
///
/// Returns a square matrix where diagonal elements are one and all other
/// elements are zero.
///
/// Panics if `size` is negative.
///
/// Example:
///
/// ```moonbit
/// let id : Matrix[Int] = @mutable.identity(3)
/// inspect(id, content="|1, 0, 0|\n|0, 1, 0|\n|0, 0, 1|")
/// ```
///
pub fn[T : One + Zero] identity(size : Int) -> Matrix[T] {
  Matrix::make(size, size, fn(i, j) {
    guard i == j else { T::zero() }
    T::one()
  })
}

///|
/// Checks whether the matrix is a null (zero) matrix by testing if all elements
/// are equal to zero.
///
/// Parameters:
///
/// * `self` : The matrix to check for nullity.
///
/// Returns `true` if all elements in the matrix are zero, `false` otherwise.
///
/// Example:
///
/// ```moonbit
/// let zero_matrix = @mutable.Matrix::new(2, 2, 0)
/// let non_zero_matrix = @mutable.Matrix::from_2d_array([[1, 0], [0, 1]])
/// inspect(zero_matrix.null(), content="true")
/// inspect(non_zero_matrix.null(), content="false")
/// ```
///
pub fn[T : Compare + Zero] null(self : Matrix[T]) -> Bool {
  not(self.data.iter().any(fn(x) { x != T::zero() }))
}

///|
/// Computes the adjoint (conjugate transpose) of the matrix by applying the
/// conjugate operation to each element.
///
/// Parameters:
///
/// * `self` : The matrix to compute the adjoint of.
///
/// Returns a new matrix where each element is the conjugate of the
/// corresponding element in the original matrix.
pub fn[T : Conjugate] adjoint(self : Matrix[T]) -> Matrix[T] {
  self.map(T::conjugate)
}

///|
/// Transposes the matrix by swapping rows and columns.
///
/// Parameters:
///
/// * `self` : The matrix to transpose.
///
/// Returns a new matrix that is the transpose of the input matrix, where the
/// element at position (i, j) in the original matrix becomes the element at
/// position (j, i) in the transposed matrix.
///
/// Example:
///
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// let transposed = m.transpose()
/// inspect(transposed, content="|1, 4|\n|2, 5|\n|3, 6|")
/// ```
///
pub fn[T] transpose(self : Matrix[T]) -> Matrix[T] {
  Matrix::make(self.col, self.row, fn(i, j) { self[j][i] })
}

///|
/// Swaps the positions of two rows in the matrix.
///
/// Parameters:
///
/// * `self` : The matrix to perform the row swap operation on.
/// * `r1` : The index of the first row to swap.
/// * `r2` : The index of the second row to swap.
///
/// Panics if either `r1` or `r2` is out of bounds (negative or greater than or
/// equal to the number of rows in the matrix).
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// m.swap_rows(0, 1)
/// inspect(m.to_string(), content="|4, 5, 6|\n|1, 2, 3|")
/// ```
///
pub fn[T] swap_rows(self : Matrix[T], r1 : Int, r2 : Int) -> Unit {
  let r = self.row
  let c = self.col
  guard r1 < r && r2 < r && r1 >= 0 && r2 >= 0
  if r1 == r2 {
    return
  }
  let temp = Array::makei(c, fn(i) { self.data[r1 * self.col + i] })
  for i in 0..<c {
    self.data[r1 * self.col + i] = self.data[r2 * self.col + i]
  }
  for i in 0..<c {
    self.data[r2 * self.col + i] = temp[i]
  }
}

///|
/// Swaps two columns in the matrix in-place.
///
/// Parameters:
///
/// * `self` : The matrix whose columns will be swapped.
/// * `c1` : The index of the first column to swap.
/// * `c2` : The index of the second column to swap.
///
/// Panics if either `c1` or `c2` is negative or greater than or equal to the
/// number of columns in the matrix.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// m.swap_cols(0, 2)
/// inspect(m, content="|3, 2, 1|\n|6, 5, 4|")
/// ```
///
pub fn[T] swap_cols(self : Matrix[T], c1 : Int, c2 : Int) -> Unit {
  let r = self.row
  let c = self.col
  guard c1 < c && c2 < c && c1 >= 0 && c2 >= 0
  if c1 == c2 {
    return
  }
  let temp = Array::makei(r, fn(i) { self.data[i * self.col + c1] })
  for i in 0..<r {
    self.data[i * self.col + c1] = self.data[i * self.col + c2]
  }
  for i in 0..<r {
    self.data[i * self.col + c2] = temp[i]
  }
}

///|
/// Tests the row and column swapping functionality of matrices.
///
/// This test verifies that the `swap_rows` and `swap_cols` methods correctly
/// exchange rows and columns in a matrix respectively. It creates a 2x3 matrix
/// and demonstrates:
///
/// 1. **Row swapping**: Exchanges rows 0 and 1, resulting in the first row
/// becoming the second row and vice versa.
/// 2. **Column swapping**: Exchanges columns 0 and 1, resulting in the first
/// column becoming the second column and vice versa.
///
/// The test uses `Matrix::from_2d_array` to create the initial matrix from a 2D
/// array, `copy()` to create independent copies for each operation, and
/// verifies the results using `inspect()` with the expected string
/// representations.
///
/// Example matrix transformations:
///
/// * Original: `|1, 2, 3|\n|4, 5, 6|`
/// * After row swap (0,1): `|4, 5, 6|\n|1, 2, 3|`
/// * After column swap (0,1): `|2, 1, 3|\n|5, 4, 6|`
///
test "swap" {
  let m = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
  let m1 = {
    let m_ = m.copy()
    m_.swap_rows(0, 1)
    m_
  }
  let m2 = {
    let m_ = m.copy()
    m_.swap_cols(0, 1)
    m_
  }
  inspect(m1.to_string(), content="|4, 5, 6|\n|1, 2, 3|")
  inspect(m2.to_string(), content="|2, 1, 3|\n|5, 4, 6|")
}

///|
/// Computes the power of a square matrix using fast exponentiation.
///
/// Parameters:
///
/// * `self` : The square matrix to be raised to a power.
/// * `power` : The non-negative integer exponent.
///
/// Returns the matrix raised to the specified power.
///
/// Example:
///
/// ```moonbit
/// let m = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m_squared = m.pow(2)
/// // Equivalent to m * m
/// ```
///
pub fn[T : Semiring] pow(self : Matrix[T], power : Int) -> Matrix[T] {
  loop (identity(self.col), power, self) {
    (s, 0, _) => s
    (s, 1, m) => s * m
    (s, p, m) => continue (if (p & 1) == 1 { s * m } else { s }, p >> 1, m * m)
  }
}

///|
/// Performs Gaussian elimination with partial pivoting to reduce the matrix to
/// reduced row echelon form (RREF).
///
/// This method applies the Gauss-Jordan elimination algorithm, which includes:
///
/// 1. Partial pivoting: selecting the row with the largest absolute value in
/// the current column as the pivot
/// 2. Row swapping to move the pivot to the diagonal position
/// 3. Scaling the pivot row to make the pivot element equal to 1
/// 4. Eliminating all other elements in the current column to make them zero
///
/// The matrix is modified in-place during the elimination process.
///
/// Parameters:
///
/// * `self` : The matrix to be reduced to row echelon form.
///
/// Returns the same matrix instance after performing the row elimination
/// operations.
///
/// Panics if any pivot element cannot be inverted (i.e., when `val.inv()` is
/// called on a zero element that wasn't properly handled).
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([
///   [1.0, 2.0, 3.0, 7.0],
///   [1.0, 1.0, 1.0, 2.0], 
///   [2.0, 3.0, 3.0, 5.0]
/// ])
/// let result = m.reduce_row_elimination()
/// // Result will be in reduced row echelon form:
/// // |1, 0, 0, 1|
/// // |0, 1, 0, -3|
/// // |0, 0, 1, 4|
/// ```
///
pub fn[T : Compare + Num + Sub + Inverse] reduce_row_elimination(
  self : Matrix[T],
) -> Matrix[T] {
  let r = self.row
  let c = self.col
  let mut col = 0
  for i in 0..<r {
    if col >= c {
      break
    }
    let mut max_row = i
    for j in (i + 1)..<r {
      if self[j][col].abs() > self[max_row][col].abs() {
        max_row = j
      }
    }
    ignore(self.swap_rows(i, max_row))
    if self[i][col] == T::zero() {
      col = col + 1
      continue
    }
    let val = self[i][col]
    ignore(self.map_row_inplace(i, fn(x) { x * val.inv() }))
    for j in 0..<r {
      if j == i {
        continue
      }
      let factor = self[j][col]
      for k in 0..<c {
        self[j][k] = self[j][k] - self[i][k] * factor
      }
    }
    col = col + 1
  }
  self
}

///|
/// Tests the row elimination reduction algorithm on a 3×4 matrix to verify it
/// produces the correct reduced row echelon form.
///
/// This test verifies that the `reduce_row_elimination` method correctly
/// performs Gaussian elimination with partial pivoting on a matrix. The test
/// uses a specific 3×4 matrix with known values and checks that the algorithm
/// produces the expected reduced row echelon form, where each row has a leading
/// 1 in a unique column and all other entries in those columns are zero.
///
/// The input matrix represents a system of linear equations:
///
/// * Row 1: 1x + 2y + 3z = 7
/// * Row 2: 1x + 1y + 1z = 2
/// * Row 3: 2x + 3y + 3z = 5
///
/// The expected output is the reduced row echelon form:
///
/// * Row 1: 1x + 0y + 0z = 1
/// * Row 2: 0x + 1y + 0z = -3
/// * Row 3: 0x + 0y + 1z = 4
///
/// This indicates the solution x = 1, y = -3, z = 4.
///
/// Example:
///
/// ```moonbit
/// let m = Matrix::from_2d_array([
///   [1.0, 2.0, 3.0, 7.0],
///   [1.0, 1.0, 1.0, 2.0],
///   [2.0, 3.0, 3.0, 5.0],
/// ])
/// let result = m.reduce_row_elimination()
/// // result should be in reduced row echelon form:
/// // |1, 0, 0, 1|
/// // |0, 1, 0, -3|
/// // |0, 0, 1, 4|
/// ```
///
test "reduce_row_elimination" {
  let m = Matrix::from_2d_array([
    [1.0, 2.0, 3.0, 7.0],
    [1.0, 1.0, 1.0, 2.0],
    [2.0, 3.0, 3.0, 5.0],
  ])
  inspect(
    m.reduce_row_elimination(),
    content=(
      #||1, 0, 0, 1|
      #||0, 1, 0, -3|
      #||0, 0, 1, 4|
    ),
  )
}

///|
/// Combines two matrices horizontally by placing them side by side.
///
/// Parameters:
///
/// * `self` : The left matrix to be combined.
/// * `other` : The right matrix to be combined.
///
/// Returns a new matrix with the same number of rows as the input matrices and
/// columns equal to the sum of both matrices' column counts.
///
/// Panics if the two matrices have different numbers of rows.
///
/// Example:
///
/// ```moonbit
/// let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m2 = Matrix::from_2d_array([[5, 6], [7, 8]])
/// let result = m1.horizontal_combine(m2)
/// inspect(result, content="|1, 2, 5, 6|\n|3, 4, 7, 8|")
/// ```
///
pub fn[T] horizontal_combine(self : Matrix[T], other : Matrix[T]) -> Matrix[T] {
  guard self.row == other.row
  Matrix::make(self.row, self.col + other.col, fn(i, j) {
    if j < self.col {
      self[i][j]
    } else {
      other[i][j - self.col]
    }
  })
}

///|
/// Combines two matrices vertically by stacking the second matrix below the
/// first matrix.
///
/// Parameters:
///
/// * `self` : The first matrix to be placed on top.
/// * `other` : The second matrix to be placed below the first matrix.
///
/// Returns a new matrix with the rows of `self` followed by the rows of
/// `other`.
///
/// Panics if the two matrices have different numbers of columns.
///
/// Example:
///
/// ```moonbit
/// let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
/// let m2 = Matrix::from_2d_array([[5, 6], [7, 8]])
/// let result = m1.vertical_combine(m2)
/// // Result is a 4x2 matrix: [[1, 2], [3, 4], [5, 6], [7, 8]]
/// ```
///
pub fn[T] vertical_combine(self : Matrix[T], other : Matrix[T]) -> Matrix[T] {
  guard self.col == other.col
  let array = self.data
  array.push_iter(other.data.iter())
  return { row: self.row + other.row, col: self.col, data: array }
}

///|
/// Tests the functionality of matrix combination operations.
///
/// This test verifies that both horizontal and vertical matrix combination
/// operations work correctly by:
///
/// 1. Creating two 2x2 matrices - one containing values `[[1, 2], [3, 4]]` and
/// another containing the identity matrix `[[1, 0], [0, 1]]`
/// 2. Testing horizontal combination, which should concatenate matrices side by
/// side, resulting in a 2x4 matrix
/// 3. Testing vertical combination, which should stack matrices vertically,
/// resulting in a 4x2 matrix
/// 4. Verifying that the resulting matrices have the expected structure and
/// values
///
/// The test demonstrates that:
///
/// * `horizontal_combine` preserves row count while adding column counts
/// * `vertical_combine` preserves column count while adding row counts
/// * Element positioning is maintained correctly during both operations
///
/// Example matrices used:
///
/// * `m1`: A 2x2 matrix with values `[[1, 2], [3, 4]]`
/// * `m2`: A 2x2 identity matrix `[[1, 0], [0, 1]]`
///
/// Expected results:
///
/// * Horizontal combination: `[[1, 2, 1, 0], [3, 4, 0, 1]]` (2x4 matrix)
/// * Vertical combination: `[[1, 2], [3, 4], [1, 0], [0, 1]]` (4x2 matrix)
///
test "matrix_combine" {
  let m1 = Matrix::from_2d_array([[1, 2], [3, 4]])
  let m2 = Matrix::from_2d_array([[1, 0], [0, 1]])
  let m3 = m1.horizontal_combine(m2)
  let m4 = m1.vertical_combine(m2)
  inspect(
    m3,
    content=(
      #||1, 2, 1, 0|
      #||3, 4, 0, 1|
    ),
  )
  inspect(
    m4,
    content=(
      #||1, 2|
      #||3, 4|
      #||1, 0|
      #||0, 1|
    ),
  )
}

///|
/// Extracts a specific row from the matrix and returns it as an array.
///
/// Parameters:
///
/// * `self` : The matrix from which to extract the row.
/// * `row` : The zero-based index of the row to extract.
///
/// Returns an array containing all elements from the specified row in column
/// order.
///
/// Panics if `row` is negative or greater than or equal to the number of rows
/// in the matrix.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// let row_array = m.row_to_array(1)
/// inspect(row_array, content="[4, 5, 6]")
/// ```
///
pub fn[T] row_to_array(self : Matrix[T], row : Int) -> Array[T] {
  guard row >= 0 && row < self.row
  let start = row * self.col
  let end = start + self.col
  self.data[start:end].to_array()
}

///|
/// Extracts a specific column from the matrix and returns it as an array.
///
/// Parameters:
///
/// * `self` : The matrix from which to extract the column.
/// * `col` : The zero-based index of the column to extract.
///
/// Returns an array containing all elements from the specified column, ordered
/// from top to bottom.
///
/// Panics if `col` is negative or greater than or equal to the number of
/// columns in the matrix.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// let col1 = m.col_to_array(1)
/// inspect(col1, content="[2, 5]")
/// ```
///
pub fn[T] col_to_array(self : Matrix[T], col : Int) -> Array[T] {
  guard col >= 0 && col < self.col
  let arr = []
  for i in 0..<self.row {
    arr.push(self.data[i * self.col + col])
  }
  arr
}

///|
/// Creates a copy of the matrix's underlying data as a new array.
///
/// Parameters:
///
/// * `self` : The matrix whose data will be copied.
///
/// Returns a new array containing all elements of the matrix in row-major
/// order.
///
/// Example:
///
/// ```moonbit
/// let matrix = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// let array = matrix.to_array()
/// inspect(array, content="[1, 2, 3, 4, 5, 6]")
/// ```
///
pub fn[T] to_array(self : Matrix[T]) -> Array[T] {
  self.data.copy()
}

///|
/// Converts a matrix to a 2D array representation where each sub-array
/// represents a row of the matrix.
///
/// Parameters:
///
/// * `self` : The matrix to convert to a 2D array.
///
/// Returns a 2D array where each element is an array representing a row from
/// the original matrix, preserving the order of rows and elements within each
/// row.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// let array_2d = m.to_2d_array()
/// inspect(array_2d, content="[[1, 2, 3], [4, 5, 6]]")
/// ```
///
pub fn[T] to_2d_array(self : Matrix[T]) -> Array[Array[T]] {
  let row = self.row
  let arr_2d = []
  for i in 0..<row {
    arr_2d.push(self.row_to_array(i))
  }
  arr_2d
}

///|
/// Extracts a specific row from the matrix and returns it as a vector.
///
/// Parameters:
///
/// * `self` : The matrix from which to extract the row.
/// * `row` : The zero-based index of the row to extract.
///
/// Returns a new vector containing all elements from the specified row in
/// column order.
///
/// Panics if `row` is negative or greater than or equal to the number of rows
/// in the matrix.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// let row_vector = m.row_to_vector(1)
/// // row_vector contains [4, 5, 6]
/// ```
///
pub fn[T] row_to_vector(self : Matrix[T], row : Int) -> Vector[T] {
  self.row_to_array(row)
}

///|
/// Extracts a specific column from the matrix and returns it as a Vector.
///
/// Parameters:
///
/// * `self` : The matrix from which to extract the column.
/// * `col` : The zero-based index of the column to extract.
///
/// Returns a Vector containing all elements from the specified column, ordered
/// from top to bottom.
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// let col1 = m.col_to_vector(1)
/// // col1 is a Vector containing [2, 5]
/// ```
///
pub fn[T] col_to_vector(self : Matrix[T], col : Int) -> Vector[T] {
  self.col_to_array(col)
}

///|
/// Converts the matrix to a vector by copying its internal array
/// representation.
///
/// Parameters:
///
/// * `self` : The matrix to be converted to a vector.
///
/// Returns a new vector containing all elements of the matrix in row-major
/// order (elements are stored row by row from left to right, top to bottom).
///
/// Example:
///
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
/// let vector = m.to_vector()
/// inspect(vector, content="|1, 2, 3, 4, 5, 6|")
/// ```
///
pub fn[T] to_vector(self : Matrix[T]) -> Vector[T] {
  self.data.copy()
}

///|
/// Calculates the rank of the matrix using row reduction.
/// 
/// Parameters:
/// 
/// * `self` : The matrix to get the rank of.
///
/// Returns the rank of the matrix, which is the dimension of the vector space
/// spanned by its rows or columns.
/// 
/// Example:
/// 
/// ```moonbit
/// let m = @mutable.Matrix::from_2d_array([[1.0, 2.0, 3.0], [2.0, 4.0, 6.0], [7.0, 8.0, 9.0]])
/// let rank = m.rank()
/// inspect(rank, content="2")  // The rank of the matrix is 2
/// ```
pub fn[T : Compare + Num + Inverse + Sub] Matrix::rank(self : Matrix[T]) -> Int {
  let m = self.copy()
  let _ = m.reduce_row_elimination()
  let mut rank = 0
  for i in 0..<m.row {
    let mut has_nonzero = false
    for j in 0..<m.col {
      if m[i][j] != T::zero() {
        has_nonzero = true
        break
      }
    }
    if has_nonzero {
      rank += 1
    }
  }
  rank
}

///|
/// Tests the rank calculation of a matrix.
test "rank of matrix" {
  let m1 = Matrix::from_2d_array([[1.0, 2.0], [3.0, 4.0]])
  let m2 = Matrix::from_2d_array([[1.0, 2.0], [2.0, 4.0]])
  let m3 = Matrix::from_2d_array([[0.0, 0.0], [0.0, 0.0]])
  let m4 = Matrix::from_2d_array([
    [1.0, 2.0, 3.0],
    [4.0, 5.0, 6.0],
    [7.0, 8.0, 9.0],
  ])
  let r1 = m1.rank()
  let r2 = m2.rank()
  let r3 = m3.rank()
  let r4 = m4.rank()
  inspect(r1, content="2")
  inspect(r2, content="1")
  inspect(r3, content="0")
  inspect(r4, content="2")
}
