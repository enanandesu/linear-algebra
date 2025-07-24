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

  - **`xxxx`**
    - **描述**
        xxxx

    - **参数**
      - `xxxx` - xxxx
      - `xxxx` - xxxx

    - **返回值**
      `xxxx` - xxxx

  ---

  - **`xxxx`**
    - **描述**
        xxxx

    - **参数**
      - `xxxx` - xxxx
      - `xxxx` - xxxx

    - **返回值**
      `xxxx` - xxxx

---

## @mutable.Lens[T]

```moonbit
struct Lens[T] {
  set : (Int, T) -> Unit
  get : (Int) -> T
}
```

- **描述**
  - 这个结构体表示一个数据访问器，用于访问矩阵中的元素

- **字段**
  - `set` - 修改元素值的函数，接收行索引和值作为参数
  - `get` - 访问元素值的函数，接收行索引作为参数并返回元素值
