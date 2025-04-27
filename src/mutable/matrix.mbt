///|
struct Matrix[T] {
  row : Int
  col : Int
  data : Array[T]
} derive(Eq)

///|
struct Lens[T] {
  set : (Int, T) -> Unit
  get : (Int) -> T
}

///|
pub impl[T : Show] Show for Matrix[T] with to_string(s) {
  let mut res = ""
  for i in 0..<s.row {
    res = res + "|"
    for j in 0..<s.col {
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
pub fn Matrix::map[T, U](self : Matrix[T], f : (T) -> U) -> Matrix[U] {
  { row: self.row, col: self.col, data: self.data.map(f) }
}

///|
pub fn matrix_to_transpose[T](self : Matrix[T]) -> Transpose[T] {
  { row: self.col, col: self.row, data: self.data }
}

///|
pub fn Matrix::map_row[T](self : Matrix[T], row : Int, f : (T) -> T) -> Unit {
  for i in 0..<self.col {
    self.data[row * self.col + i] = f(self.data[row * self.col + i])
  }
}

///|
pub fn Matrix::map_col[T](self : Matrix[T], col : Int, f : (T) -> T) -> Unit {
  for i in 0..<self.row {
    self.data[i * self.col + col] = f(self.data[i * self.col + col])
  }
}

///|
pub fn Matrix::copy[T](self : Matrix[T]) -> Matrix[T] {
  { row: self.row, col: self.col, data: self.data.copy() }
}

///|
test "map_function" {
  let m = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
  let m1 = m.copy()..map_row(0, fn(x) { x * 2 })
  let m2 = m.copy()..map_col(0, fn(x) { x * 2 })
  inspect!(m1.to_string(), content="|2, 4, 6|\n|4, 5, 6|")
  inspect!(m2.to_string(), content="|2, 2, 3|\n|8, 5, 6|")
}

///|
pub fn Matrix::make[A](row : Int, col : Int, f : (Int, Int) -> A) -> Matrix[A] {
  { row, col, data: Array::makei(row * col, fn(i) { f(i / col, i % col) }) }
}

///|
pub fn Matrix::new[T](row : Int, col : Int, elem : T) -> Matrix[T] {
  Matrix::make(row, col, fn { _, _ => elem })
}

///|
pub fn Matrix::from_2d_array[T](arr : Array[Array[T]]) -> Matrix[T] {
  Matrix::make(arr.length(), arr[0].length(), fn(i, j) { arr[i][j] })
}

///| 
pub fn Matrix::op_get[T](self : Matrix[T], row : Int) -> Lens[T] {
  {
    set: fn { c, v => self.data[c + self.col * row] = v },
    get: fn { c => self.data[c + self.col * row] },
  }
}

///|
pub fn op_get[T](self : Lens[T], col : Int) -> T {
  (self.get)(col)
}

///|
pub fn Lens::op_set[T](self : Lens[T], col : Int, elem : T) -> Unit {
  (self.set)(col, elem)
}

///|
test "op_set" {
  let m = Matrix::from_2d_array([[2, 3, 4], [1, 2, 3]])
  inspect!(m[0][1], content="3")
  m[0][1] = 4
  inspect!(m[0][1], content="4")
}

///|
pub impl[T : Mul + Add] Mul for Matrix[T] with op_mul(
  self : Matrix[T],
  other : Matrix[T]
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
pub impl[T : Add] Add for Matrix[T] with op_add(
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
pub impl[T : Neg] Neg for Matrix[T] with op_neg(self : Matrix[T]) -> Matrix[T] {
  self.map(T::op_neg)
}

///|
pub impl[T : Add + Neg] Sub for Matrix[T] with op_sub(
  self : Matrix[T],
  other : Matrix[T]
) -> Matrix[T] {
  self + -other
}

///|
pub fn scale[T : Mul](self : Matrix[T], cst : T) -> Matrix[T] {
  self.map(fn(x) { x * cst })
}

///|
pub fn add_constant[T : Add](self : Matrix[T], cst : T) -> Matrix[T] {
  self.map(fn(x) { x + cst })
}

///|
pub fn identity[T : One + Zero](size : Int) -> Matrix[T] {
  Matrix::make(size, size, fn(i, j) {
    guard i == j else { T::zero() }
    T::one()
  })
}

///|
pub fn null[T : Compare + Zero](self : Matrix[T]) -> Bool {
  not(self.data.iter().any(fn(x) { x != T::zero() }))
}

///|
pub fn adjoint[T : Conjugate](self : Matrix[T]) -> Matrix[T] {
  self.map(T::conjugate)
}

///|
pub fn transpose[T](self : Matrix[T]) -> Matrix[T] {
  Matrix::make(self.col, self.row, fn(i, j) { self[j][i] })
}

///|
pub fn swap_rows[T](self : Matrix[T], r1 : Int, r2 : Int) -> Unit {
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
pub fn swap_cols[T](self : Matrix[T], c1 : Int, c2 : Int) -> Unit {
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
test "swap" {
  let m = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]])
  let m1 = m.copy()..swap_rows(0, 1)
  let m2 = m.copy()..swap_cols(0, 1)
  inspect!(m1.to_string(), content="|4, 5, 6|\n|1, 2, 3|")
  inspect!(m2.to_string(), content="|2, 1, 3|\n|5, 4, 6|")
}

///|
pub fn pow[T : Semiring](self : Matrix[T], power : Int) -> Matrix[T] {
  loop identity(self.col), power, self {
    s, 0, _ => s
    s, 1, m => s * m
    s, p, m => continue if (p & 1) == 1 { s * m } else { s }, p >> 1, m * m
  }
}

///|
pub fn reduce_row_elimination[T : Compare + Num + Sub + Inverse](
  self : Matrix[T]
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
    ignore(self.map_row(i, fn(x) { x * val.inv() }))
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
test "reduce_row_elimination" {
  let m = Matrix::from_2d_array([
    [1.0, 2.0, 3.0, 7.0],
    [1.0, 1.0, 1.0, 2.0],
    [2.0, 3.0, 3.0, 5.0],
  ])
  inspect!(
    m.reduce_row_elimination(),
    content=
      #||1, 0, 0, 1|
      #||0, 1, 0, -3|
      #||0, 0, 1, 4|
    ,
  )
}

///|
pub fn horizontal_combine[T](self : Matrix[T], other : Matrix[T]) -> Matrix[T] {
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
pub fn vertical_combine[T](self : Matrix[T], other : Matrix[T]) -> Matrix[T] {
  guard self.col == other.col
  let array = self.data
  array.push_iter(other.data.iter())
  return { row: self.row + other.row, col: self.col, data: array }
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
