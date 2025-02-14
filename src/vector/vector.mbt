///|
/// Represents a double-precision floating-point vector with stride capability.
/// The stride feature allows for flexible memory access patterns, enabling
/// operations on subsequences of the vector without creating new memory
/// allocations.
///
/// Parameters:
///
/// * `data` : An array of double-precision floating-point numbers storing the
/// vector elements.
/// * `size` : The logical size of the vector (number of accessible elements).
/// * `stride` : The step size between consecutive elements in the vector. A
/// stride of 1 means elements are contiguous, while a stride of n means there
/// are n-1 elements skipped between each accessed element.
///
/// Example:
///
/// ```moonbit
/// test "Vector" {
///   let v = Vector::{ data: [1.0, 2.0, 3.0, 4.0], size: 2, stride: 2 }
///   // v effectively represents [1.0, 3.0] with stride 2
///   inspect!(v.at(0), content="1.0")
///   inspect!(v.at(1), content="3.0")
/// }
/// ```
pub(all) struct Vector {
  data : Array[Double]
  size : Int
  mut stride : Int
} derive(Show)

//oper

///|
pub fn Vector::map(self : Vector, f : (Double) -> Double) -> Vector {
  let data = self.data.map(f)
  { data, size: self.size, stride: self.stride }
}

///|
pub fn Vector::map_inplace(self : Vector, f : (Double) -> Double) -> Unit {
  self.data.map_inplace(f)
}

///|
pub fn Vector::scale(self : Vector, scalar : Double) -> Unit {
  self.map_inplace(fn(x) -> Double { x * scalar })
}

///|
pub fn Vector::add_constant(self : Vector, constant : Double) -> Unit {
  self.map_inplace(fn(x) -> Double { x + constant })
}

///|
pub fn Vector::ax_plus_by(
  self : Vector,
  y : Vector,
  a : Double,
  b : Double
) -> Vector {
  let n = self.size
  guard n == y.size
  let stride_self = self.stride
  let stride_y = y.stride
  let vector_ax_plus_by = Vector::new(n)
  for i = 0; i < n; i = i + 1 {
    vector_ax_plus_by.data.push(
      a * self.data[i * stride_self] + b * y.data[i * stride_y],
    )
  }
  vector_ax_plus_by
}

///|
pub fn Vector::ax_plus_by_inplace(
  self : Vector,
  y : Vector,
  a : Double,
  b : Double
) -> Unit {
  let n = self.size
  guard n == y.size
  let stride_self = self.stride
  let stride_y = y.stride
  for i = 0; i < n; i = i + 1 {
    self.data[i * stride_self] = a * self.data[i * stride_self] +
      b * y.data[i * stride_y]
  }
}

///|
pub fn Vector::sum(self : Vector) -> Double {
  @luna_utils.arr_sum(self.data)
}

///|
pub fn Vector::add_inplace(self : Vector, other : Vector) -> Unit {
  let n = self.size
  guard n == other.size
  let stride_self = self.stride
  let stride_other = other.stride
  for i = 0; i < n; i = i + 1 {
    self.data[i * stride_self] = self.data[i * stride_self] +
      other.data[i * stride_other]
  }
}

///|
pub fn Vector::sub_inplace(self : Vector, other : Vector) -> Unit {
  let n = self.size
  guard n == other.size
  let stride_self = self.stride
  let stride_other = other.stride
  for i = 0; i < n; i = i + 1 {
    self.data[i * stride_self] = self.data[i * stride_self] -
      other.data[i * stride_other]
  }
}

///|
pub fn Vector::mul_inplace(self : Vector, other : Vector) -> Unit {
  let n = self.size
  guard n == other.size
  let stride_self = self.stride
  let stride_other = other.stride
  for i = 0; i < n; i = i + 1 {
    self.data[i * stride_self] = self.data[i * stride_self] *
      other.data[i * stride_other]
  }
}

///|
pub fn Vector::div_inplace(self : Vector, other : Vector) -> Unit {
  let n = self.size
  guard n == other.size
  let stride_self = self.stride
  let stride_other = other.stride
  for i = 0; i < n; i = i + 1 {
    self.data[i * stride_self] = self.data[i * stride_self] /
      other.data[i * stride_other]
  }
}

///|
pub fn op_add(self : Vector, other : Vector) -> Vector {
  let n = self.size
  guard n == other.size
  let stride_self = self.stride
  let stride_other = other.stride
  let vector_add = Vector::new(n)
  for i = 0; i < n; i = i + 1 {
    vector_add.data.push(
      self.data[i * stride_self] + other.data[i * stride_other],
    )
  }
  vector_add
}

///|
pub fn op_sub(self : Vector, other : Vector) -> Vector {
  let n = self.size
  guard n == other.size
  let stride_self = self.stride
  let stride_other = other.stride
  let vector_sub = Vector::new(n)
  for i = 0; i < n; i = i + 1 {
    vector_sub.data.push(
      self.data[i * stride_self] - other.data[i * stride_other],
    )
  }
  vector_sub
}

///|
pub fn op_mul(self : Vector, other : Vector) -> Vector {
  let n = self.size
  guard n == other.size
  let stride_self = self.stride
  let stride_other = other.stride
  let vector_mul = Vector::new(n)
  for i = 0; i < n; i = i + 1 {
    vector_mul.data.push(
      self.data[i * stride_self] * other.data[i * stride_other],
    )
  }
  vector_mul
}

///|
pub fn op_div(self : Vector, other : Vector) -> Vector {
  let n = self.size
  guard n == other.size
  let stride_self = self.stride
  let stride_other = other.stride
  let vector_div = Vector::new(n)
  for i = 0; i < n; i = i + 1 {
    vector_div.data.push(
      self.data[i * stride_self] / other.data[i * stride_other],
    )
  }
  vector_div
}

//init
///|
pub fn Vector::new(size : Int, stride~ : Int = 1) -> Vector {
  guard size > 0 && stride > 0
  let data = []
  { data, size, stride }
}

///|
pub fn Vector::at(self : Vector, index : Int) -> Double {
  guard index < self.size && index >= 0
  self.data[index * self.stride]
}

///|
pub fn Vector::filled_vector(size : Int, num : Double) -> Vector {
  let data = (fn() -> Array[Double] {
    let filled_vector = []
    for i = 0; i < size; i = i + 1 {
      filled_vector.push(num)
    }
    filled_vector
  })()
  { data, size, stride: 1 }
}

///|
pub fn Vector::zero_vector(size : Int) -> Vector {
  Vector::filled_vector(size, 0.0)
}

///|
pub fn op_get(self : Vector, index : Int) -> Double {
  self.data[index * self.stride]
}

///|
pub fn Vector::set_all(self : Vector, num : Double) -> Unit {
  self.map_inplace(fn(_) -> Double { num })
}

///|
pub fn Vector::set_zero(self : Vector) -> Unit {
  self.set_all(0.0)
}

///|
pub fn Vector::set_at(self : Vector, index : Int, num : Double) -> Unit {
  guard index < self.size && index >= 0
  self.data[index * self.stride] = num
}

///|
pub fn Vector::set_basis(self : Vector, index : Int) -> Unit {
  self.set_zero()
  self.set_at(index, 1.0)
}

///|
pub fn Vector::copy(self : Vector) -> Vector {
  let data = self.data.copy()
  { data, size: self.size, stride: self.stride }
}

//prop

///|
pub impl Eq for Vector with op_equal(self, other) {
  let n = self.size
  guard n == other.size
  let stride_self = self.stride
  let stride_other = other.stride
  for i = 0; i < n; i = i + 1 {
    if self.data[i * stride_self] != other.data[i * stride_other] {
      return false
    }
  }
  true
}

///|
pub fn Vector::is_null(self : Vector) -> Bool {
  let n = self.size
  let stride = self.stride
  for i = 0; i < n; i = i + 1 {
    if self.data[i * stride] != 0.0 {
      return false
    }
  }
  true
}

///|
pub fn Vector::is_pos(self : Vector) -> Bool {
  let n = self.size
  let stride = self.stride
  for i = 0; i < n; i = i + 1 {
    if self.data[i * stride] <= 0.0 {
      return false
    }
  }
  true
}

///|
pub fn Vector::is_neg(self : Vector) -> Bool {
  let n = self.size
  let stride = self.stride
  for i = 0; i < n; i = i + 1 {
    if self.data[i * stride] >= 0.0 {
      return false
    }
  }
  true
}

///|
pub fn Vector::is_non_neg(self : Vector) -> Bool {
  let n = self.size
  let stride = self.stride
  for i = 0; i < n; i = i + 1 {
    if self.data[i * stride] < 0.0 {
      return false
    }
  }
  true
}

///|
pub fn Vector::swap(self : Vector, other : Vector) -> Unit {
  let n = self.size
  let m = other.size
  guard n == m
  let stride_self = self.stride
  let stride_other = other.stride
  for i = 0; i < n; i = i + 1 {
    let temp = self.data[i * stride_self]
    self.data[i * stride_self] = other.data[i * stride_other]
    other.data[i * stride_other] = temp
  }
}

///|
pub fn Vector::swap_elements(self : Vector, i : Int, j : Int) -> Unit {
  guard i < self.size && j < self.size
  let stride = self.stride
  let temp = self.data[i * stride]
  self.data[i * stride] = self.data[j * stride]
  self.data[j * stride] = temp
}

///|
pub fn Vector::reverse(self : Vector) -> Unit {
  let n = self.size
  let stride = self.stride
  let mut left = 0
  let mut right = n - stride
  while left < right {
    let temp = self.data[left]
    self.data[left] = self.data[right]
    self.data[right] = temp
    left = left + stride
    right = right - stride
  }
}
