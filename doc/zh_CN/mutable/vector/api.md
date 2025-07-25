# @mutable.Vector

---

## @mutable.Vector[T]

```moonbit
struct Vector[T] {
  length : Int
  data : Array[T]
} derive(Eq)
```

- **描述**
  这个结构体表示一个可变的向量，其数据存储在一维数组 `data` 中

- **字段**
  - `length` - 向量的长度
  - `data` - 向量的数据

- **方法**

  - **`fn[T] Vector::make(length, f) -> Vector[T]`**
    - **描述**
        这个函数用于创建一个新的向量，并使用给定的函数初始化向量的数据

    - **参数**
      - `length: Int` - 向量的长度
      - `f: (Int) -> T` - 用于初始化向量数据的函数，参数是索引

    - **返回值**
      `Vector[T]` - 新创建的向量对象

  ---

  - **`fn[T] Vector::new(length, elem) -> Vector[T]`**
    - **描述**
        创建一个新的向量，所有元素都初始化为指定的值

    - **参数**
      - `length: Int` - 向量的长度
      - `elem: T` - 用于初始化所有元素的值

    - **返回值**
      `Vector[T]` - 新创建的向量对象

  ---

  - **`fn[T] Vector::from_array(data) -> Vector[T]`**
    - **描述**
        从数组创建向量

    - **参数**
      - `data: Array[T]` - 包含向量元素的数组

    - **返回值**
      `Vector[T]` - 新创建的向量对象

  ---

  - **`fn[T] length(self) -> Int`**
    - **描述**
        获取向量的长度

    - **参数**
      - `self: Vector[T]` - 要查询的向量

    - **返回值**
      `Int` - 向量的长度

  ---

  - **`fn[T] Vector::op_get(self, index) -> T`**
    - **描述**
        获取向量指定索引位置的元素

    - **参数**
      - `self: Vector[T]` - 要访问的向量
      - `index: Int` - 元素索引（从0开始）

    - **返回值**
      `T` - 指定位置的元素值

  ---

  - **`fn[T] Vector::op_set(self, index, elem) -> Unit`**
    - **描述**
        设置向量指定索引位置的元素值

    - **参数**
      - `self: Vector[T]` - 要修改的向量
      - `index: Int` - 元素索引（从0开始）
      - `elem: T` - 要设置的新值

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T, U] Vector::map(self, f) -> Vector[U]`**
    - **描述**
        对向量的每个元素应用函数，创建一个新的向量

    - **参数**
      - `self: Vector[T]` - 输入向量
      - `f: (T) -> U` - 应用于每个元素的函数

    - **返回值**
      `Vector[U]` - 包含转换后元素的新向量

  ---

  - **`fn[T] Vector::map_inplace(self, f) -> Unit`**
    - **描述**
        就地对向量的每个元素应用变换函数，修改原向量

    - **参数**
      - `self: Vector[T]` - 要修改的向量
      - `f: (T) -> T` - 应用于每个元素的变换函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Vector::each(self, f) -> Unit`**
    - **描述**
        对向量的每个元素执行函数

    - **参数**
      - `self: Vector[T]` - 要遍历的向量
      - `f: (T) -> Unit` - 对每个元素执行的函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Vector::eachi(self, f) -> Unit`**
    - **描述**
        对向量的每个元素及其索引执行函数

    - **参数**
      - `self: Vector[T]` - 要遍历的向量
      - `f: (Int, T) -> Unit` - 对每个元素及其索引执行的函数

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] Vector::copy(self) -> Vector[T]`**
    - **描述**
        创建向量的深拷贝

    - **参数**
      - `self: Vector[T]` - 要复制的向量

    - **返回值**
      `Vector[T]` - 原向量的独立副本

  ---

  - **`fn[T : Mul] scale(self, cst) -> Vector[T]`**
    - **描述**
        将向量的每个元素乘以标量值

    - **参数**
      - `self: Vector[T]` - 要缩放的向量
      - `cst: T` - 标量值

    - **返回值**
      `Vector[T]` - 缩放后的新向量

  ---

  - **`fn[T : Add] add_constant(self, cst) -> Vector[T]`**
    - **描述**
        将常数值加到向量的每个元素上

    - **参数**
      - `self: Vector[T]` - 要修改的向量
      - `cst: T` - 要添加的常数值

    - **返回值**
      `Vector[T]` - 加法运算后的新向量

  ---

  - **`fn[T : Compare + Zero] null(self) -> Bool`**
    - **描述**
        检查向量是否为零向量（所有元素都为零）

    - **参数**
      - `self: Vector[T]` - 要检查的向量

    - **返回值**
      `Bool` - 如果是零向量返回true，否则返回false

  ---

  - **`fn[T : Conjugate] conjugate(self) -> Vector[T]`**
    - **描述**
        计算向量的共轭

    - **参数**
      - `self: Vector[T]` - 要计算共轭的向量

    - **返回值**
      `Vector[T]` - 共轭向量

  ---

  - **`fn[T : Add + Mul] dot(self, other) -> T`**
    - **描述**
        计算两个向量的点积（内积）

    - **参数**
      - `self: Vector[T]` - 第一个向量
      - `other: Vector[T]` - 第二个向量

    - **返回值**
      `T` - 点积结果

  ---

  - **`fn[T : Add + Mul + Zero] norm_squared(self) -> T`**
    - **描述**
        计算向量的模长的平方

    - **参数**
      - `self: Vector[T]` - 要计算的向量

    - **返回值**
      `T` - 模长的平方

  ---

  - **`fn[T : Add + Mul + Zero + Sqrt] norm(self) -> T`**
    - **描述**
        计算向量的模长（欧几里德范数）

    - **参数**
      - `self: Vector[T]` - 要计算的向量

    - **返回值**
      `T` - 向量的模长

  ---

  - **`fn[T : Add + Mul + Zero + Sqrt + Div] normalize(self) -> Vector[T]`**
    - **描述**
        计算向量的单位向量

    - **参数**
      - `self: Vector[T]` - 要标准化的向量

    - **返回值**
      `Vector[T]` - 标准化后的单位向量

  ---

  - **`fn[T : Add + Mul + Zero + Sqrt + Div] normalize_inplace(self) -> Unit`**
    - **描述**
        就地将向量标准化为单位向量

    - **参数**
      - `self: Vector[T]` - 要标准化的向量

    - **返回值**
      `Unit` - 无返回值

  ---

  - **`fn[T] to_array(self) -> Array[T]`**
    - **描述**
        将向量转换为数组

    - **参数**
      - `self: Vector[T]` - 要转换的向量

    - **返回值**
      `Array[T]` - 包含向量所有元素的数组

  ---
  
  - **`fn[T] Vector::op_get(self, index) -> T`**
    - **描述**
        使用方括号语法访问向量元素

    - **示例**

      ```moonbit
      let v = Vector::from_array([1, 2, 3])
      let value = v[1]  // 获取索引1处的元素，值为2
      ```

  - **`fn[T] Vector::op_set(self, index, elem) -> Unit`**
    - **描述**
        使用方括号语法设置向量元素

    - **示例**

      ```moonbit
      let v = Vector::from_array([1, 2, 3])
      v[1] = 10  // 设置索引1处的元素为10
      ```

- **特征实现**
  
  **运算符重载**

  - **`impl[T : Add] Add for Vector[T] with op_add`**
    - **描述**
        向量加法运算符重载，计算两个向量的元素级相加

    - **示例**

      ```moonbit
      let v1 = Vector::from_array([1, 2, 3])
      let v2 = Vector::from_array([4, 5, 6])
      let result = v1 + v2  // 向量加法
      ```

  ---

  - **`impl[T : Add + Neg] Sub for Vector[T] with op_sub`**
    - **描述**
        向量减法运算符重载，计算两个向量的元素级相减

    - **示例**

      ```moonbit
      let v1 = Vector::from_array([5, 7, 9])
      let v2 = Vector::from_array([1, 2, 3])
      let result = v1 - v2  // 向量减法
      ```

  ---

  - **`impl[T : Neg] Neg for Vector[T] with op_neg`**
    - **描述**
        向量取负运算符重载，对向量所有元素取负

    - **示例**

      ```moonbit
      let v = Vector::from_array([1, -2, 3])
      let negated = -v  // 向量取负
      ```

  **显示和输出**

  - **`impl[T : Show] Show for Vector[T] with to_string`**
    - **描述**
        将向量转换为可读的字符串表示

    - **示例**

      ```moonbit
      let v = Vector::from_array([1, 2, 3])
      inspect(v.to_string(), content="[1, 2, 3]")
      ```

  ---

  - **`impl[T : Show] Show for Vector[T] with output`**
    - **描述**
        将向量的字符串表示输出到日志记录器

---
