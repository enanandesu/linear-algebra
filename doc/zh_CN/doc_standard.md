# 文档标准

## 文档类型与组织

### 主要文档类型

1. **API参考文档(api.md)** - 详细描述每个公开接口的规格说明
2. **用户指南(tutorial.md)** - 面向使用者的教程和最佳实践
3. **设计文档(design.md)** - 面向开发者的架构和算法说明
4. **性能报告(benchmark.md)** - 基准测试和性能分析文档

### 文档组织原则

- 按照包/文件来组织，例如
  
  ```txt
  docs/
    |- en_US
    |- ja_JP 
    |- zh_CN
        |- immut
        |   |- matrix
        |   |   |- api.md
        |   |   |- tutorial.md
        |   |   |- design.md
        |   |   |- benchmark.md
        |   |- ...
        |- mutable
        |   |- matrix
        |   |   |- ...
        |   |- ...
        |- ...
  ```

- 每个包下按`vector`、`matrix`等文件进一步细分
- 保持文档与代码结构的一致性
