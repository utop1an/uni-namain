# ICAPS 2027：执行基础与下一阶段

日期：2026-09-13。投稿目标：ICAPS 2027。

## 本轮交付

本轮完成第一阶段的受限执行基础；未完成论文实验矩阵。

- 候选图不再用 add effect 支持负前置条件。
- STRIPS 之外的逻辑结构显式隔离，不再将 `when/or/exists` 扁平化后用于候选搜索；当前隔离 4 个动作。
- 输出字段改为 `candidate_graph_connected` / `all_candidate_graph_connected`，不宣称执行有效。
- 新增 `rcnc/planning.py`：显式查询接口、类型检查、全局源常量替换、穷举 grounding、有限 BFS、状态回放和 grounded PDDL 导出。
- `rejected`、`unsolvable`、`depth_limit`、`state_limit`、`solved` 分开记录。只有状态空间穷尽且没有深度截断时才报告不可解。
- 保存任务、源文件及实现 SHA256、运行环境、搜索预算、源动作 provenance 和逐步状态。

旧 `experiment_1` 与 UniDomain 快照保留。修正结果位于 `data/rcnc/experiment_1_v2`。

| 指标 | 历史快照 | 修正版本 |
|---|---:|---:|
| 输入动作 | 234 | 234 |
| 可用于候选图的动作 | 234 | 230 |
| 跨源候选边 | 4973 | 4749 |
| 无 adapter 标记的候选边 | 4342 | 4138 |
| 有 adapter 标记的候选边 | 631 | 611 |

边数减少同时来自极性修正与非 STRIPS 动作隔离，不能全部归因于极性修正。候选图中的类型 adapter 仍只是标签；独立执行路径不采用这些标签。

## 可复现实验

```powershell
python -m unittest discover -s tests -v
python run_rcnc_experiment.py --output data/rcnc/my_candidate_run
python run_rcnc_planning.py --query data/rcnc/queries/fixed_initial_smoke.json --output data/rcnc/my_planning_run
python run_rcnc_smoke_suite.py --output data/rcnc/my_smoke_suite
```

从仓库根目录执行。执行查询和 suite 要求空输出目录，避免失败结果混入旧的成功产物。候选图入口仍保持原有输出覆盖行为，建议显式使用新目录。

当前执行对照产物：`data/rcnc/execution_smoke_v1/summary.json`。五项结果均符合设计预期：

| 对照 | 结果 |
|---|---|
| 显式共享位置接口 | solved，4 步，BIRT + CHIC_NP |
| 去掉天空落下的初始事实 | unsolvable |
| 去掉共享位置接口，初态保留各源命名空间 | unsolvable |
| bench 绑定到 entity | rejected |
| 请求条件效果动作 | rejected |

成功计划使用真实源动作：

1. `BIRT:hear_tapping_on_beech`
2. `BIRT:approach_beech_tree`
3. `CHIC_NP:meet_character`
4. `CHIC_NP:inform_about_sky_fall`

这是手工构造的固定初态冒烟任务：查询提前声明初态、目标、选中的动作和接口。`CHIC_NP:Chicken-licken -> hero` 是显式的源常量替换假设。它没有证明角色替换在文学或常识层面正确，也不是泛化测试或论文成功率统计。

验证：22 项 unittest 通过，包括删除效果、负前置条件、错误类型、缺少常量绑定、截断状态，以及重新读取导出的 PDDL/plan 并执行。没有接入独立外部 planner/VAL；BFS 与 replay 共享内部表示，因此尚有共同实现缺陷的风险。

## 查询契约

- `actions`：显式选择的 `SOURCE:action` 列表。当前没有自动检索或可达性闭包选择。
- `objects`：小写 PDDL object 名到类型的映射。
- `constant_bindings`：每个被使用的源常量必须提供 `SOURCE:constant -> object`，同一映射在所有步骤一致，并接受源类型检查。这是查询级实例化，不是已经完成的通用 lifting 学习。
- `interfaces`：`SOURCE:predicate -> {target, evidence}`，要求相同参数类型签名、同一位置语义。没有声明的谓词保持源命名空间。当前不支持参数置换、单向蕴含或动态 adapter。
- `initial`：正事实数组，闭世界解释；搜索不增加额外初始事实。
- `goal`：`positive` 与 `negative` 两组事实。
- `max_depth/max_states/max_ground_actions`：明确的资源预算。

当前假设类型名在源领域间共享含义；冲突的类型层次会被拒绝，但同名类型的语义一致性仍需审计。接口 evidence 是人工说明，不是自动证明。输出 PDDL 使用 grounded 零参数 operators，实例对象放在 domain constants；并未输出通用的参数化组合领域。

## 论文推进顺序与验收

1. **独立正确性与输入审计**：接入外部 PDDL 验证器；增加源模型类型、变量作用域、静态关系和实际可执行见证审计。明确支持片段与隔离比例。
2. **正式表示与算法**：定义接口、角色替换及全局约束；实现可执行 lifting 和闭合动作子集选择；在声明的接口解释下论证编译正确性。当前 BFS 是参考实现，不构成主要算法创新。
3. **冻结开发/测试划分**：当前 15 个故事用于开发，另外建立未调参的组合及独立来源测试集；预先固定初态和目标。原始与审计后输入分别报告。
4. **核心比较**：来源隔离 union、简单 alias、全量编译与局部编译、lifting/角色约束消融、重新生成的 UniDomain 本地适配基线。统一下游验证和资源预算。
5. **叙事评价**：仅对有效计划评价新奇性、角色合理性、结构多样性与人工偏好。creative/surreal 的旧结果相同问题尚未解决。

近期验收目标是：在不依赖手工挑选四个动作的情况下，对预先定义的一批固定初态任务输出成功或可解释失败，并提供独立验证证据。当前五项工程对照不得替代该验收。
