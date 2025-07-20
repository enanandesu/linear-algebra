///|
struct Transpose[T] {
  row : Int
  col : Int
  data : Array[T]
} derive(Eq)

///|
struct LenTranspose[T] {
  set : (Int, T) -> Unit
  get : (Int) -> T
}

///|
pub impl[T : Show] Show for Transpose[T] with to_string(s) {
  let mut res = ""
  for i in 0..<s.row {
    res = res + "|"
    for j in 0..<s.col {
      res = res + s.data[j * s.row + i].to_string()
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
pub impl[T : Show] Show for Transpose[T] with output(s, l) {
  l.write_string(s.to_string())
}

///|
fn[A] Transpose::make(
  row : Int,
  col : Int,
  f : (Int, Int) -> A
) -> Transpose[A] {
  { row, col, data: Array::makei(row * col, fn(i) { f(i / row, i % row) }) }
}

///|
pub fn[T, U] Transpose::map(self : Transpose[T], f : (T) -> U) -> Transpose[U] {
  { row: self.row, col: self.col, data: self.data.map(f) }
}

///|
pub fn[T] Transpose::map_col(
  self : Transpose[T],
  col : Int,
  f : (T) -> T
) -> Unit {
  for i in 0..<self.row {
    self.data[i + self.row * col] = f(self.data[i + self.row * col])
  }
}

///|
pub fn[T] Transpose::map_row(
  self : Transpose[T],
  row : Int,
  f : (T) -> T
) -> Unit {
  for i in 0..<self.col {
    self.data[row + self.row * i] = f(self.data[row + self.row * i])
  }
}

///|
test "map" {
  let m = Matrix::from_2d_array([[0, 1, 2], [3, 4, 5]]).matrix_to_transpose()
  let m1 = Transpose::make(3, 4, fn(i, j) { i + j })
  inspect(
    m1,
    content=(
      #||0, 1, 2, 3|
      #||0, 1, 2, 3|
      #||0, 1, 2, 3|
    ),
  )
  m.map_col(0, fn(x) { x * 2 })
  inspect(
    m,
    content=(
      #||0, 3|
      #||2, 4|
      #||4, 5|
    ),
  )
  m.map_row(0, fn(x) { x + 1 })
  inspect(
    m,
    content=(
      #||1, 4|
      #||2, 4|
      #||4, 5|
    ),
  )
}

///|
pub fn[T] Transpose::copy(self : Transpose[T]) -> Transpose[T] {
  { row: self.row, col: self.col, data: self.data.copy() }
}

///| 
pub fn[T] Transpose::op_get(self : Transpose[T], row : Int) -> LenTranspose[T] {
  {
    set: (c, v) => self.data[row + self.row * c] = v,
    get: c => self.data[row + self.row * c],
  }
}

///|
pub fn[T] LenTranspose::op_get(self : LenTranspose[T], col : Int) -> T {
  (self.get)(col)
}

///|
pub fn[T] LenTranspose::op_set(
  self : LenTranspose[T],
  col : Int,
  elem : T
) -> Unit {
  (self.set)(col, elem)
}

///|
test "op_set" {
  let m = Matrix::from_2d_array([[2, 3, 4], [1, 2, 3]]).matrix_to_transpose()
  inspect(m[0][1], content="1")
  m[0][1] = 4
  inspect(m[0][1], content="4")
}

///|
pub impl[T : Mul + Add] Mul for Transpose[T] with op_mul(
  self : Transpose[T],
  other : Transpose[T]
) -> Transpose[T] {
  let row = self.row
  let col = other.col
  let inner = self.col
  guard inner == other.row
  let data = Array::makei(row * col, fn(i) {
    let r = i / row
    let c = i % row
    let mut sum = self.data[c] * other.data[other.row * r]
    for k in 1..<inner {
      sum += self.data[c + self.row * k] * other.data[k + other.row * r]
    }
    sum
  })
  { row, col, data }
}

///|
pub impl[T : Add] Add for Transpose[T] with op_add(
  self : Transpose[T],
  other : Transpose[T]
) -> Transpose[T] {
  guard self.col == other.col
  guard self.row == other.row
  {
    data: array_zip_with(self.data, other.data, T::op_add),
    row: self.row,
    col: self.col,
  }
}

///|
pub impl[T : Neg] Neg for Transpose[T] with op_neg(self : Transpose[T]) -> Transpose[
  T,
] {
  self.map(T::op_neg)
}

///|
pub impl[T : Add + Neg] Sub for Transpose[T] with op_sub(
  self : Transpose[T],
  other : Transpose[T]
) -> Transpose[T] {
  self + -other
}

///|
pub fn[T : Mul] Transpose::scale(self : Transpose[T], cst : T) -> Transpose[T] {
  self.map(fn(x) { x * cst })
}

///|
pub fn[T : Add] Transpose::add_constant(
  self : Transpose[T],
  cst : T
) -> Transpose[T] {
  self.map(fn(x) { x + cst })
}

///|
pub fn[T : Compare + Zero] Transpose::null(self : Transpose[T]) -> Bool {
  not(self.data.iter().any(fn(x) { x != T::zero() }))
}

///|
pub fn[T : Conjugate] Transpose::adjoint(self : Transpose[T]) -> Transpose[T] {
  self.map(T::conjugate)
}

///|
pub fn[T] Transpose::swap_cols(self : Transpose[T], c1 : Int, c2 : Int) -> Unit {
  let r = self.row
  let c = self.col
  guard c1 < c && c2 < c && c1 >= 0 && c2 >= 0
  if c1 == c2 {
    return
  }
  let temp = Array::makei(r, fn(i) { self.data[i + r * c1] })
  for i in 0..<r {
    self.data[i + r * c1] = self.data[i + r * c2]
  }
  for i in 0..<r {
    self.data[i + r * c2] = temp[i]
  }
}

///|
pub fn[T] Transpose::swap_rows(self : Transpose[T], r1 : Int, r2 : Int) -> Unit {
  let r = self.row
  let c = self.col
  guard r1 < r && r2 < r && r1 >= 0 && r2 >= 0
  if r1 == r2 {
    return
  }
  let temp = Array::makei(c, fn(i) { self.data[r1 + r * i] })
  for i in 0..<c {
    self.data[r1 + r * i] = self.data[r2 + r * i]
  }
  for i in 0..<c {
    self.data[r2 + r * i] = temp[i]
  }
}

///|
pub fn[T : Semiring] Transpose::pow(
  self : Transpose[T],
  power : Int
) -> Transpose[T] {
  loop (identity(self.col).matrix_to_transpose(), power, self) {
    (s, 0, _) => s
    (s, 1, m) => s * m
    (s, p, m) => continue (if (p & 1) == 1 { s * m } else { s }, p >> 1, m * m)
  }
}

///|
pub fn[T : Compare + Num + Sub + Inverse] Transpose::reduce_row_elimination(
  self : Transpose[T]
) -> Transpose[T] {
  let r = self.row
  let c = self.col
  let mut col = 0
  for i in 0..<r {
    if col >= c {
      break
    }
    let mut max_row = i
    for j in (i + 1)..<r {
      if self.data[j + r * col].abs() > self.data[max_row + r * col].abs() {
        max_row = j
      }
    }
    ignore(self.swap_rows(i, max_row))
    if self.data[i + r * col] == T::zero() {
      col = col + 1
      continue
    }
    let val = self.data[i + r * col]
    ignore(self.map_row(i, fn(x) { x * val.inv() }))
    for j in 0..<r {
      if j == i {
        continue
      }
      let factor = self.data[j + r * col]
      for k in 0..<c {
        self.data[j + r * k] = self.data[j + r * k] -
          self.data[i + r * k] * factor
      }
    }
    col = col + 1
  }
  self
}

///|
pub fn[T] Transpose::horizontal_combine(
  self : Transpose[T],
  other : Transpose[T]
) -> Transpose[T] {
  guard self.row == other.row
  Transpose::make(self.row, self.col + other.col, fn(i, j) {
    if i < self.col {
      self.data[j + self.row * i]
    } else {
      other.data[j + self.row * (i - self.col)]
    }
  })
}

///|
pub fn[T] Transpose::vertical_combine(
  self : Transpose[T],
  other : Transpose[T]
) -> Transpose[T] {
  guard self.col == other.col
  Transpose::make(self.row + other.row, self.col, fn(i, j) {
    if j < self.row {
      self.data[j + self.row * i]
    } else {
      other.data[j - self.row + self.row * i]
    }
  })
}

///|
pub fn[T] Transpose::transpose_to_matrix(self : Transpose[T]) -> Matrix[T] {
  let data = Array::makei(self.col * self.row, fn(i) {
    let row = i / self.col
    let col = i % self.col
    self.data[row + self.row * col]
  })
  { row: self.col, col: self.row, data }
}

///|
test "add" {
  let m1 = Matrix::from_2d_array([[1], [1], [1]]).matrix_to_transpose()
  let m2 = Matrix::from_2d_array([[2], [3], [4]]).matrix_to_transpose()
  let m3 = (m1 + m2).transpose_to_matrix()
  inspect(m1 + m2, content="|3, 4, 5|")
  inspect(
    m3,
    content=(
      #||3|
      #||4|
      #||5|
    ),
  )
}

///|
test "swap" {
  let m = Matrix::from_2d_array([[1, 2, 3], [4, 5, 6]]).matrix_to_transpose()
  let m1 = {
    m.copy()..swap_rows(0, 1)
    m
  }
  let m2 = {
    m.copy()..swap_cols(0, 1)
    m
  }
  inspect(
    m,
    content=(
      #||1, 4|
      #||2, 5|
      #||3, 6|
    ),
  )
  inspect(
    m1,
    content=(
      #||2, 5|
      #||1, 4|
      #||3, 6|
    ),
  )
  inspect(
    m2,
    content=(
      #||4, 1|
      #||5, 2|
      #||6, 3|
    ),
  )
}

///|
test "matrix_combine" {
  let m1 = Matrix::from_2d_array([[1, 2], [3, 4]]).matrix_to_transpose()
  let m2 = Matrix::from_2d_array([[1, 0], [0, 1]]).matrix_to_transpose()
  let m3 = Transpose::horizontal_combine(m1, m2)
  let m4 = Transpose::vertical_combine(m1, m2)
  inspect(
    m3,
    content=(
      #||1, 3, 1, 0|
      #||2, 4, 0, 1|
    ),
  )
  inspect(
    m4,
    content=(
      #||1, 3|
      #||2, 4|
      #||1, 0|
      #||0, 1|
    ),
  )
}

///|
test "to transpose" {
  let m1 = Matrix::from_2d_array([[1, 2], [3, 4]]).matrix_to_transpose()
  inspect(
    m1,
    content=(
      #||1, 3|
      #||2, 4|
    ),
  )
}

///|
test "reduce_row_elimination" {
  let m = Matrix::from_2d_array([
    [1.0, 2.0, 3.0, 7.0],
    [1.0, 1.0, 1.0, 2.0],
    [2.0, 3.0, 3.0, 5.0],
    [2.2, 2.3, 2.1, 2.4],
    [2.4, 2.4, 2.5, 2.7],
  ]).matrix_to_transpose()
  inspect(
    m.reduce_row_elimination(),
    content=(
      #||1, 0, 0, 0, 0.48461538461538456|
      #||0, 1, 0, 0, -0.9615384615384615|
      #||0, 0, 1, 0, -0.6769230769230766|
      #||0, 0, 0, 1, 1.9230769230769227|
    ),
  )
}
