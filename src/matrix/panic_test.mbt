///|
test "panic_new" {
  Matrix::new(-2, 3) |> ignore
}

///|
test "panic_at" {
  let m = Matrix::zero_matrix(2, 3)
  m.at(2, 0) |> ignore
}

///|
test "panic_add_diagonal" {
  let m = Matrix::zero_matrix(2, 3)
  m.add_diagonal(2.0) |> ignore
}

///|
test "panic_scale_col&row" {
  let m = Matrix::filled_matrix(3, 3, 1.0)
  let v = @vector.Vector::new(4)
  v.data.push(1.0)
  v.data.push(2.0)
  v.data.push(3.0)
  v.data.push(4.0)
  m.scale_col(v) |> ignore
  m.scale_row(v) |> ignore
}

///|
test "panic_mul_elements" {
  let m1 = Matrix::filled_matrix(2, 3, 1.0)
  let m2 = Matrix::filled_matrix(2, 4, 2.0)
  m1.mul_elements(m2) |> ignore
}

///|
test "panic_div_elements" {
  let m1 = Matrix::filled_matrix(2, 3, 2.0)
  let m2 = Matrix::filled_matrix(2, 4, 1.0)
  m1.div_elements(m2) |> ignore
}

///|
test "panic_op_add" {
  let m1 = Matrix::filled_matrix(2, 3, 1.0)
  let m2 = Matrix::filled_matrix(2, 4, 2.0)
  m1.op_add(m2) |> ignore
}

///|
test "panic_op_sub" {
  let m1 = Matrix::filled_matrix(2, 3, 1.0)
  let m2 = Matrix::filled_matrix(2, 4, 2.0)
  m1.op_sub(m2) |> ignore
}

///|
test "panic_op_mul" {
  let m1 = Matrix::filled_matrix(2, 3, 1.0)
  let m2 = Matrix::filled_matrix(2, 4, 2.0)
  m1.op_mul(m2) |> ignore
}

///|
test "panic_row & col_vec" {
  let m = Matrix::filled_matrix(2, 3, 1.0)
  m.row_vec(2) |> ignore
  m.col_vec(3) |> ignore
}
