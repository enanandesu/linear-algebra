///|
/// Represents a matrix of double-precision floating-point numbers with optimized
/// stride-based memory layout.
///
/// Fields:
///
/// * `data` : The array storing matrix elements in row-major order.
/// * `col` : Number of columns in the matrix.
/// * `row` : Number of rows in the matrix.
/// * `stride` : The distance between the start of consecutive rows in memory.
/// Usually equals to the number of columns but can be larger to optimize memory
/// alignment and operations.
///
/// Example:
///
/// ```moonbit
/// test "Matrix" {
///   let m = Matrix::new(2, 3) // Creates a 2x3 matrix
///   inspect!(m.row, content="2")
///   inspect!(m.col, content="3")
/// }
/// ```
pub(all) struct Matrix {
  data : Array[Double]
  col : Int
  row : Int
  stride : Int
} derive(Show)

//oper

///|
pub fn Matrix::new(row : Int, col : Int, stride~ : Int = col) -> Matrix {
  guard row > 0 && col > 0
  let data : Array[Double] = []
  { data, col, row, stride }
}

///|
pub fn Matrix::at(self : Matrix, row : Int, col : Int) -> Double {
  guard row < self.row && col < self.col && row >= 0 && col >= 0
  let index = row * self.stride + col
  guard index < self.data.length()
  self.data[index]
}

///|
pub fn Matrix::map(self : Matrix, f : (Double) -> Double) -> Matrix {
  let stride = self.stride
  let data = self.data.map(f)
  { data, col: self.col, row: self.row, stride }
}

///|
pub fn Matrix::map_inplace(self : Matrix, f : (Double) -> Double) -> Unit {
  self.data.map_inplace(f)
}

///|
pub fn Matrix::scale(self : Matrix, scalar : Double) -> Unit {
  self.map_inplace(fn(x) -> Double { x * scalar })
}

///|
pub fn Matrix::add_constant(self : Matrix, constant : Double) -> Unit {
  self.map_inplace(fn(x) -> Double { x + constant })
}

///|
pub fn Matrix::add_diagonal(self : Matrix, constant : Double) -> Unit {
  guard self.row == self.col
  let stride = self.stride
  for i = 0; i < self.row; i = i + 1 {
    self.data[i * stride + i] = self.data[i * stride + i] + constant
  }
}

///|
pub fn Matrix::scale_col(self : Matrix, scalar : Vector) -> Unit {
  guard self.col == scalar.size
  for i = 0; i < self.row; i = i + 1 {
    for j = 0; j < self.col; j = j + 1 {
      self.data[i * self.stride + j] = self.data[i * self.stride + j] *
        scalar.data[j]
    }
  }
}

///|
pub fn Matrix::scale_row(self : Matrix, scalar : Vector) -> Unit {
  guard self.row == scalar.size
  for i = 0; i < self.row; i = i + 1 {
    for j = 0; j < self.col; j = j + 1 {
      self.data[i * self.stride + j] = self.data[i * self.stride + j] *
        scalar.data[i]
    }
  }
}

///|
pub fn Matrix::mul_elements(self : Matrix, other : Matrix) -> Matrix {
  guard self.col == other.col && self.row == other.row
  let stride_self = self.stride
  let stride_other = other.stride
  let matrix_mul = Matrix::new(self.row, self.col)
  for i = 0; i < self.row; i = i + 1 {
    for j = 0; j < self.col; j = j + 1 {
      matrix_mul.data.push(
        self.data[i * stride_self + j] * other.data[i * stride_other + j],
      )
    }
  }
  matrix_mul
}

///|
pub fn Matrix::mul_elements_inplace(self : Matrix, other : Matrix) -> Unit {
  guard self.col == other.col && self.row == other.row
  let stride_self = self.stride
  let stride_other = other.stride
  for i = 0; i < self.row; i = i + 1 {
    for j = 0; j < self.col; j = j + 1 {
      self.data[i * stride_self + j] = self.data[i * stride_self + j] *
        other.data[i * stride_other + j]
    }
  }
}

///|
pub fn Matrix::div_elements(self : Matrix, other : Matrix) -> Matrix {
  guard self.col == other.col && self.row == other.row
  let stride_self = self.stride
  let stride_other = other.stride
  let matrix_div = Matrix::new(self.row, self.col)
  for i = 0; i < self.row; i = i + 1 {
    for j = 0; j < self.col; j = j + 1 {
      matrix_div.data.push(
        self.data[i * stride_self + j] / other.data[i * stride_other + j],
      )
    }
  }
  matrix_div
}

///|
pub fn Matrix::div_elements_inplace(self : Matrix, other : Matrix) -> Unit {
  guard self.col == other.col && self.row == other.row
  let stride_self = self.stride
  let stride_other = other.stride
  for i = 0; i < self.row; i = i + 1 {
    for j = 0; j < self.col; j = j + 1 {
      self.data[i * stride_self + j] = self.data[i * stride_self + j] /
        other.data[i * stride_other + j]
    }
  }
}

///|@coverage.skip
fn Matrix::std_mul(self : Matrix, other : Matrix) -> Matrix {
  let stride_self = self.stride
  let stride_other = other.stride
  let matrix_mul = Matrix::new(self.row, other.col)
  for i = 0; i < self.row; i = i + 1 {
    for j = 0; j < other.col; j = j + 1 {
      let mut sum = 0.0
      for k = 0; k < self.col; k = k + 1 {
        sum = sum +
          self.data[i * stride_self + k] * other.data[k * stride_other + j]
      }
      matrix_mul.data.push(sum)
    }
  }
  matrix_mul
}

///|
pub fn Matrix::op_add(self : Matrix, other : Matrix) -> Matrix {
  guard self.col == other.col && self.row == other.row
  let stride_self = self.stride
  let stride_other = other.stride
  let matrix_add = Matrix::new(self.row, self.col)
  for i = 0; i < self.row; i = i + 1 {
    for j = 0; j < self.col; j = j + 1 {
      matrix_add.data.push(
        self.data[i * stride_self + j] + other.data[i * stride_other + j],
      )
    }
  }
  matrix_add
}

///|
pub fn Matrix::op_sub(self : Matrix, other : Matrix) -> Matrix {
  guard self.col == other.col && self.row == other.row
  let stride_self = self.stride
  let stride_other = other.stride
  let matrix_sub = Matrix::new(self.row, self.col)
  for i = 0; i < self.row; i = i + 1 {
    for j = 0; j < self.col; j = j + 1 {
      matrix_sub.data.push(
        self.data[i * stride_self + j] - other.data[i * stride_other + j],
      )
    }
  }
  matrix_sub
}

///|
pub fn Matrix::op_mul(self : Matrix, other : Matrix) -> Matrix {
  guard self.col == other.row
  Matrix::std_mul(self, other)
}

//init

///|
pub fn Matrix::copy(self : Matrix) -> Matrix {
  let data = self.data.copy()
  { data, col: self.col, row: self.row, stride: self.stride }
}

///|
pub fn Matrix::filled_matrix(row : Int, col : Int, num : Double) -> Matrix {
  let stride = col
  let data : Array[Double] = (fn() -> Array[Double] {
    let filled_matrix = []
    for i = 0; i < row * col; i = i + 1 {
      filled_matrix.push(num)
    }
    filled_matrix
  })()
  { data, col, row, stride }
}

///|
pub fn Matrix::zero_matrix(row : Int, col : Int) -> Matrix {
  Matrix::filled_matrix(row, col, 0.0)
}

//prop
///|
pub impl Eq for Matrix with op_equal(self : Matrix, other : Matrix) -> Bool {
  self.row == other.row && self.col == other.col && self.data == other.data
}

///|
pub fn Matrix::is_null(self : Matrix) -> Bool {
  let n = self.row * self.col
  for i = 0; i < n; i = i + 1 {
    if self.data[i] != 0.0 {
      return false
    }
  }
  true
}

///|
pub fn Matrix::is_pos(self : Matrix) -> Bool {
  let n = self.row * self.col
  for i = 0; i < n; i = i + 1 {
    if self.data[i] <= 0.0 {
      return false
    }
  }
  true
}

///|
pub fn Matrix::is_neg(self : Matrix) -> Bool {
  let n = self.row * self.col
  for i = 0; i < n; i = i + 1 {
    if self.data[i] >= 0.0 {
      return false
    }
  }
  true
}

///|
pub fn Matrix::is_non_neg(self : Matrix) -> Bool {
  let n = self.row * self.col
  for i = 0; i < n; i = i + 1 {
    if self.data[i] < 0.0 {
      return false
    }
  }
  true
}

///|
pub fn Matrix::norm_1(self : Matrix) -> Double {
  let mut max_sum = 0.0
  for j = 0; j < self.col; j = j + 1 {
    let mut sum = 0.0
    for i = 0; i < self.row; i = i + 1 {
      sum = sum + self.data[i * self.stride + j]
    }
    max_sum = @math.maximum(max_sum, sum)
  }
  max_sum
}

//vectorize
///|
pub fn Matrix::row_vec(self : Matrix, row : Int) -> Vector {
  guard row < self.row && row >= 0
  let size_vec = self.col
  let vec = Vector::new(size_vec)
  for i = 0; i < size_vec; i = i + 1 {
    vec.data.push(self.data[row * self.stride + i])
  }
  vec
}

///|
pub fn Matrix::col_vec(self : Matrix, col : Int) -> Vector {
  guard col < self.col && col >= 0
  let size_vec = self.row
  let vec = Vector::new(size_vec)
  for i = 0; i < size_vec; i = i + 1 {
    vec.data.push(self.data[i * self.stride + col])
  }
  vec
}

///|
pub fn Matrix::diagonal_vec(self : Matrix) -> Vector {
  let short_side = @math.minimum(self.row, self.col)
  let vec = Vector::new(short_side)
  for i = 0; i < short_side; i = i + 1 {
    vec.data.push(self.data[i * self.stride + i])
  }
  vec
}

///|
pub fn Matrix::subdiagonal_vec(self : Matrix) -> Vector {
  let short_side = @math.minimum(self.row, self.col)
  let vec = Vector::new(short_side - 1)
  for i = 0; i < short_side - 1; i = i + 1 {
    vec.data.push(self.data[(i + 1) * self.stride + i])
  }
  vec
}

///|
pub fn Matrix::superdiagonal_vec(self : Matrix) -> Vector {
  let short_side = @math.minimum(self.row, self.col)
  let vec = Vector::new(short_side - 1)
  for i = 0; i < short_side - 1; i = i + 1 {
    vec.data.push(self.data[i * self.stride + (i + 1)])
  }
  vec
}

///|
pub fn Matrix::subrow_vec(
  self : Matrix,
  row : Int,
  start : Int,
  num : Int
) -> Vector {
  guard row < self.row && row >= 0
  guard start >= 0 && num > 0 && start + num <= self.col
  let vec = Vector::new(num)
  for i = 0; i < num; i = i + 1 {
    vec.data.push(self.data[row * self.stride + start + i])
  }
  vec
}

///|
pub fn Matrix::subcol_vec(
  self : Matrix,
  col : Int,
  start : Int,
  num : Int
) -> Vector {
  guard col < self.col && col >= 0
  guard start >= 0 && num > 0 && start + num <= self.row
  let vec = Vector::new(num)
  for i = 0; i < num; i = i + 1 {
    vec.data.push(self.data[(start + i) * self.stride + col])
  }
  vec
}

//view

///|
pub enum ViewMode {
  Row
  Col
  Diagonal
  SubDiagonal
  SuperDiagonal
  SubRow
  SubCol
} derive(Show, Eq)

///|
pub(all) struct MatrixView {
  matrix : Matrix
  index : Int
  start : Int
  num : Int
  view_mode : ViewMode
}

///|
pub fn Matrix::op_as_view(
  self : Matrix,
  index~ : Int = 0,
  view_mode : ViewMode
) -> MatrixView {
  guard view_mode == ViewMode::SuperDiagonal ||
    view_mode == ViewMode::SubDiagonal ||
    view_mode == ViewMode::Diagonal ||
    (index >= 0 && index < self.row && view_mode == ViewMode::Row) ||
    (index >= 0 && index < self.col && view_mode == ViewMode::Col)
  MatrixView::{ matrix: self, index, start: 0, num: 0, view_mode }
}

///|
pub fn Matrix::view(
  self : Matrix,
  index~ : Int = 0,
  start~ : Int = 0,
  num~ : Int = 0,
  view_mode : ViewMode
) -> MatrixView {
  guard (
      index >= 0 &&
      (
        (
          num > 0 &&
          start >= 0 &&
          (
            (view_mode == ViewMode::SubRow && num < self.col) ||
            (view_mode == ViewMode::SubCol && num < self.row)
          )
        ) ||
        view_mode == ViewMode::Row ||
        view_mode == ViewMode::Col
      )
    ) ||
    view_mode == ViewMode::Diagonal ||
    view_mode == ViewMode::SubDiagonal ||
    view_mode == ViewMode::SuperDiagonal
  MatrixView::{ matrix: self, index, start, num, view_mode }
}

//view oper

///|
pub fn MatrixView::map_inplace(
  self : MatrixView,
  f : (Double) -> Double
) -> Unit {
  match self.view_mode {
    ViewMode::Row =>
      for i = 0; i < self.matrix.col; i = i + 1 {
        self.matrix.data[self.index * self.matrix.stride + i] = f(
          self.matrix.data[self.index * self.matrix.stride + i],
        )
      }
    ViewMode::Col =>
      for i = 0; i < self.matrix.row; i = i + 1 {
        self.matrix.data[i * self.matrix.stride + self.index] = f(
          self.matrix.data[i * self.matrix.stride + self.index],
        )
      }
    ViewMode::Diagonal => {
      let short_side = @math.minimum(self.matrix.row, self.matrix.col)
      for i = 0; i < short_side; i = i + 1 {
        self.matrix.data[i * self.matrix.stride + i] = f(
          self.matrix.data[i * self.matrix.stride + i],
        )
      }
    }
    ViewMode::SubDiagonal => {
      let short_side = @math.minimum(self.matrix.row, self.matrix.col)
      for i = 0; i < short_side - 1; i = i + 1 {
        self.matrix.data[(i + 1) * self.matrix.stride + i] = f(
          self.matrix.data[(i + 1) * self.matrix.stride + i],
        )
      }
    }
    ViewMode::SuperDiagonal => {
      let short_side = @math.minimum(self.matrix.row, self.matrix.col)
      for i = 0; i < short_side - 1; i = i + 1 {
        self.matrix.data[i * self.matrix.stride + (i + 1)] = f(
          self.matrix.data[i * self.matrix.stride + (i + 1)],
        )
      }
    }
    ViewMode::SubRow =>
      for i = 0; i < self.num; i = i + 1 {
        self.matrix.data[self.index * self.matrix.stride + self.start + i] = f(
          self.matrix.data[self.index * self.matrix.stride + self.start + i],
        )
      }
    ViewMode::SubCol =>
      for i = 0; i < self.num; i = i + 1 {
        self.matrix.data[(self.start + i) * self.matrix.stride + self.index] = f(
          self.matrix.data[(self.start + i) * self.matrix.stride + self.index],
        )
      }
  }
}

///|
pub fn MatrixView::scale_view(self : MatrixView, scalar : Double) -> MatrixView {
  self.map_inplace(fn(x) -> Double { x * scalar })
  self
}

///|
test "panic_new" {
  Vector::new(0) |> ignore()
  Vector::new(1, stride=0) |> ignore()
}

///|
test "panic_calc" {
  let v = Vector::filled_vector(2, 1.0)
  let v2 = Vector::filled_vector(3, 2.0)
  v.add_inplace(v2) |> ignore()
  v.sub_inplace(v2) |> ignore()
  v.mul_inplace(v2) |> ignore()
  v.div_inplace(v2) |> ignore()
  v + v2 |> ignore()
  v - v2 |> ignore()
  v * v2 |> ignore()
  v / v2 |> ignore()
}

///|
test "panic_at" {
  let v = Vector::filled_vector(2, 1.0)
  v.at(2) |> ignore()
  v.at(-1) |> ignore()
}

///|
test "panic_op_get" {
  let v = Vector::filled_vector(2, 1.0)
  v[2] |> ignore()
  v[-1] |> ignore()
}

///|
test "panic_set_at" {
  let v = Vector::filled_vector(2, 1.0)
  v.set_at(2, 1.0) |> ignore()
  v.set_at(-1, 1.0) |> ignore()
}

///|
test "panic_set_basis" {
  let v = Vector::filled_vector(2, 1.0)
  v.set_basis(2) |> ignore()
  v.set_basis(-1) |> ignore()
}

///|
test "panic_op_eq" {
  let v = Vector::filled_vector(2, 1.0)
  let v2 = Vector::filled_vector(3, 2.0)
  v == v2 |> ignore()
}

///|
test "panic_swap" {
  let v = Vector::filled_vector(2, 1.0)
  let v2 = Vector::filled_vector(3, 2.0)
  v.swap(v2) |> ignore()
}

///|
test "panic_swap_elements" {
  let v = Vector::filled_vector(2, 1.0)
  v.swap_elements(0, 2) |> ignore()
  v.swap_elements(-1, 0) |> ignore()
}
