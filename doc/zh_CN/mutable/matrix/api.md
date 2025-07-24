# @mutable.Matrix

---

## @mutable.Matrix[T]

```moonbit
struct Matrix[T] {
  row : Int
  col : Int
  data : Array[T]
} derive(Eq)
```

- **描述**
  这个结构体表示一个可变的矩阵，其数据存储在一维数组 `data` 中

- **字段**
  - `row` - 矩阵的行数
  - `col` - 矩阵的列数
  - `data` - 矩阵的数据

- **方法**

  - **`fn[T] Matrix::make(row, col, f) -> Matrix[T]`**
    - **描述**
        这个函数用于创建一个新的矩阵，并使用给定的函数初始化矩阵的数据

    - **参数**
      - `row: Int` - 矩阵的行数
      - `col: Int` - 矩阵的列数
      - `f: (Int, Int) -> T` - 用于初始化矩阵数据的函数，第一个参数是行索引，第二个参数是列索引

    - **返回值**
      `Matrix[T]` - 新创建的矩阵对象

  ---

  - **`fn[T] Matrix::new(row, col, elem) -> Matrix[T]`**
    - **描述**
        创建一个新的矩阵，所有元素都初始化为指定的值

    - **参数**
      - `row: Int` - 矩阵的行数
      - `col: Int` - 矩阵的列数
      - `elem: T` - 用于初始化所有元素的值

    - **返回值**
      `Matrix[T]` - 新创建的矩阵对象

  ---

  - **`fn[T] Matrix::from_2d_array(arr) -> Matrix[T]`**
    - **描述**
        从二维数组创建矩阵

    - **参数**
      - `arr: Array[Array[T]]` - 二维数组，每个子数组代表矩阵的一行

    - **返回值**
      `Matrix[T]` - 新创建的矩阵对象

  ---

  - **`fn[T] Matrix::from_array(row, col, data) -> Matrix[T]`**
    - **描述**
        从一维数组和指定的行列数创建矩阵，数据按行优先顺序存储

    - **参数**
      - `row: Int` - 矩阵的行数
      - `col: Int` - 矩阵的列数
      - `data: Array[T]` - 包含矩阵元素的一维数组

    - **返回值**
      `Matrix[T]` - 新创建的矩阵对象

  ---

  - **`fn[T] row(self) -> Int`**
    - **描述**
        获取矩阵的行数

    - **参数**
      - `self: Matrix[T]` - 要查询的矩阵

    - **返回值**
      `Int` - 矩阵的行数

  ---

  - **`fn[T] col(self) -> Int`**
    - **描述**
        获取矩阵的列数

    - **参数**
      - `self: Matrix[T]` - 要查询的矩阵

    - **返回值**
      `Int` - 矩阵的列数

  ---

  - **`fn[T] Matrix::op_get(self, row) -> Lens[T]`**
    - **描述**
        获取矩阵指定行的访问器，用于读取和修改该行的元素

    - **参数**
      - `self: Matrix[T]` - 要访问的矩阵
      - `row: Int` - 行索引（从0开始）

    - **返回值**
      `Lens[T]` - 该行的访问器对象

  ---

  - **`fn[T, U] Matrix::map(self, f) -> Matrix[U]`**
    - **描述**
        对矩阵的每个元素应用函数，创建一个新的矩阵

    - **参数**
      - `self: Matrix[T]` - 输入矩阵
      - `f: (T) -> U` - 应用于每个元素的函数

    - **返回值**
      `Matrix[U]` - 包含转换后元素的新矩阵

  ---

  - **`fn[T] Matrix::map_inplace(self, f) -> Unit`**
    - **描述**
        就地对矩阵的每个元素应用变换函数，修改原矩阵

    - **参数**
      - `self: Matrix[T]` - 要修改的矩阵
      - `f: (T) -> T` - 应用于每个元素的变换函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Matrix::map_row_inplace(self, row, f) -> Unit`**
    - **描述**
        就地对矩阵指定行的所有元素应用变换函数

    - **参数**
      - `self: Matrix[T]` - 要修改的矩阵
      - `row: Int` - 要变换的行索引
      - `f: (T) -> T` - 应用于行元素的变换函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Matrix::map_col_inplace(self, col, f) -> Unit`**
    - **描述**
        就地对矩阵指定列的所有元素应用变换函数

    - **参数**
      - `self: Matrix[T]` - 要修改的矩阵
      - `col: Int` - 要变换的列索引
      - `f: (T) -> T` - 应用于列元素的变换函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Matrix::each(self, f) -> Unit`**
    - **描述**
        对矩阵的每个元素执行函数

    - **参数**
      - `self: Matrix[T]` - 要遍历的矩阵
      - `f: (T) -> Unit` - 对每个元素执行的函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Matrix::eachi(self, f) -> Unit`**
    - **描述**
        对矩阵的每个元素及其索引执行函数

    - **参数**
      - `self: Matrix[T]` - 要遍历的矩阵
      - `f: (Int, T) -> Unit` - 对每个元素及其线性索引执行的函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Matrix::each_row_col(self, f) -> Unit`**
    - **描述**
        对矩阵的每个元素及其行列索引执行函数

    - **参数**
      - `self: Matrix[T]` - 要遍历的矩阵
      - `f: (Int, Int, T) -> Unit` - 对每个元素及其行列索引执行的函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Matrix::each_row(self, row, f) -> Unit`**
    - **描述**
        对矩阵指定行的每个元素执行函数

    - **参数**
      - `self: Matrix[T]` - 要遍历的矩阵
      - `row: Int` - 要遍历的行索引
      - `f: (T) -> Unit` - 对每个元素执行的函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Matrix::eachi_row(self, row, f) -> Unit`**
    - **描述**
        对矩阵指定行的每个元素及其列索引执行函数

    - **参数**
      - `self: Matrix[T]` - 要遍历的矩阵
      - `row: Int` - 要遍历的行索引
      - `f: (Int, T) -> Unit` - 对每个元素及其列索引执行的函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Matrix::each_col(self, col, f) -> Unit`**
    - **描述**
        对矩阵指定列的每个元素执行函数

    - **参数**
      - `self: Matrix[T]` - 要遍历的矩阵
      - `col: Int` - 要遍历的列索引
      - `f: (T) -> Unit` - 对每个元素执行的函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Matrix::eachi_col(self, col, f) -> Unit`**
    - **描述**
        对矩阵指定列的每个元素及其行索引执行函数

    - **参数**
      - `self: Matrix[T]` - 要遍历的矩阵
      - `col: Int` - 要遍历的列索引
      - `f: (Int, T) -> Unit` - 对每个元素及其行索引执行的函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Matrix::copy(self) -> Matrix[T]`**
    - **描述**
        创建矩阵的深拷贝

    - **参数**
      - `self: Matrix[T]` - 要复制的矩阵

    - **返回值**
      `Matrix[T]` - 原矩阵的独立副本

  ---

  - **`fn[T] to_transpose(self) -> Transpose[T]`**
    - **描述**
        将矩阵转换为转置视图，不复制底层数据

    - **参数**
      - `self: Matrix[T]` - 要转置的矩阵

    - **返回值**
      `Transpose[T]` - 转置视图对象

  ---

  - **`fn[T] transpose(self) -> Matrix[T]`**
    - **描述**
        计算矩阵的转置，创建新矩阵

    - **参数**
      - `self: Matrix[T]` - 要转置的矩阵

    - **返回值**
      `Matrix[T]` - 转置后的新矩阵

  ---

  - **`fn[T] swap_rows(self, r1, r2) -> Unit`**
    - **描述**
        交换矩阵中两行的位置

    - **参数**
      - `self: Matrix[T]` - 要修改的矩阵
      - `r1: Int` - 第一行的索引
      - `r2: Int` - 第二行的索引

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] swap_cols(self, c1, c2) -> Unit`**
    - **描述**
        交换矩阵中两列的位置

    - **参数**
      - `self: Matrix[T]` - 要修改的矩阵
      - `c1: Int` - 第一列的索引
      - `c2: Int` - 第二列的索引

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T : Mul] scale(self, cst) -> Matrix[T]`**
    - **描述**
        将矩阵的每个元素乘以标量值

    - **参数**
      - `self: Matrix[T]` - 要缩放的矩阵
      - `cst: T` - 标量值

    - **返回值**
      `Matrix[T]` - 缩放后的新矩阵

  ---

  - **`fn[T : Add] add_constant(self, cst) -> Matrix[T]`**
    - **描述**
        将常数值加到矩阵的每个元素上

    - **参数**
      - `self: Matrix[T]` - 要修改的矩阵
      - `cst: T` - 要添加的常数值

    - **返回值**
      `Matrix[T]` - 加法运算后的新矩阵

  ---

  - **`fn[T : One + Zero] identity(size) -> Matrix[T]`**
    - **描述**
        创建指定大小的单位矩阵

    - **参数**
      - `size: Int` - 单位矩阵的行数和列数

    - **返回值**
      `Matrix[T]` - 单位矩阵

  ---

  - **`fn[T : Compare + Zero] null(self) -> Bool`**
    - **描述**
        检查矩阵是否为零矩阵（所有元素都为零）

    - **参数**
      - `self: Matrix[T]` - 要检查的矩阵

    - **返回值**
      `Bool` - 如果是零矩阵返回true，否则返回false

  ---

  - **`fn[T : Conjugate] adjoint(self) -> Matrix[T]`**
    - **描述**
        计算矩阵的伴随（共轭转置）

    - **参数**
      - `self: Matrix[T]` - 要计算伴随的矩阵

    - **返回值**
      `Matrix[T]` - 伴随矩阵

  ---

  - **`fn[T : Semiring] pow(self, power) -> Matrix[T]`**
    - **描述**
        计算方阵的幂

    - **参数**
      - `self: Matrix[T]` - 要计算幂的方阵
      - `power: Int` - 非负整数指数

    - **返回值**
      `Matrix[T]` - 矩阵的幂

  ---

  - **`fn[T : Compare + Num + Sub + Inverse] reduce_row_elimination(self) -> Matrix[T]`**
    - **描述**
        使用高斯消元法将矩阵化简为行最简形

    - **参数**
      - `self: Matrix[T]` - 要化简的矩阵

    - **返回值**
      `Matrix[T]` - 化简后的矩阵

  ---

  - **`fn[T] horizontal_combine(self, other) -> Matrix[T]`**
    - **描述**
        水平合并两个矩阵（将第二个矩阵放在第一个矩阵右侧）

    - **参数**
      - `self: Matrix[T]` - 左侧矩阵
      - `other: Matrix[T]` - 右侧矩阵

    - **返回值**
      `Matrix[T]` - 合并后的新矩阵

  ---

  - **`fn[T] vertical_combine(self, other) -> Matrix[T]`**
    - **描述**
        垂直合并两个矩阵（将第二个矩阵放在第一个矩阵下方）

    - **参数**
      - `self: Matrix[T]` - 上方矩阵
      - `other: Matrix[T]` - 下方矩阵

    - **返回值**
      `Matrix[T]` - 合并后的新矩阵

  ---

  - **`fn[T] row_to_array(self, row) -> Array[T]`**
    - **描述**
        提取矩阵指定行并返回为数组

    - **参数**
      - `self: Matrix[T]` - 源矩阵
      - `row: Int` - 要提取的行索引

    - **返回值**
      `Array[T]` - 包含该行所有元素的数组

  ---

  - **`fn[T] col_to_array(self, col) -> Array[T]`**
    - **描述**
        提取矩阵指定列并返回为数组

    - **参数**
      - `self: Matrix[T]` - 源矩阵
      - `col: Int` - 要提取的列索引

    - **返回值**
      `Array[T]` - 包含该列所有元素的数组

  ---

  - **`fn[T] to_array(self) -> Array[T]`**
    - **描述**
        将矩阵转换为一维数组（按行优先顺序）

    - **参数**
      - `self: Matrix[T]` - 要转换的矩阵

    - **返回值**
      `Array[T]` - 包含矩阵所有元素的一维数组

  ---

  - **`fn[T] to_2d_array(self) -> Array[Array[T]]`**
    - **描述**
        将矩阵转换为二维数组

    - **参数**
      - `self: Matrix[T]` - 要转换的矩阵

    - **返回值**
      `Array[Array[T]]` - 二维数组表示

  ---

  - **`fn[T] row_to_vector(self, row) -> Vector[T]`**
    - **描述**
        提取矩阵指定行并返回为向量

    - **参数**
      - `self: Matrix[T]` - 源矩阵
      - `row: Int` - 要提取的行索引

    - **返回值**
      `Vector[T]` - 包含该行所有元素的向量

  ---

  - **`fn[T] col_to_vector(self, col) -> Vector[T]`**
    - **描述**
        提取矩阵指定列并返回为向量

    - **参数**
      - `self: Matrix[T]` - 源矩阵
      - `col: Int` - 要提取的列索引

    - **返回值**
      `Vector[T]` - 包含该列所有元素的向量

  ---

  - **`fn[T] to_vector(self) -> Vector[T]`**
    - **描述**
        将矩阵转换为向量（按行优先顺序）

    - **参数**
      - `self: Matrix[T]` - 要转换的矩阵

    - **返回值**
      `Vector[T]` - 包含矩阵所有元素的向量

---

## @mutable.Lens[T]

```moonbit
struct Lens[T] {
  set : (Int, T) -> Unit
  get : (Int) -> T
}
```

- **描述**
  这个结构体表示一个数据访问器，用于访问矩阵中的元素

- **字段**
  - `set` - 修改元素值的函数，接收行索引和值作为参数
  - `get` - 访问元素值的函数，接收行索引作为参数并返回元素值
