# 受约束 lifting 与来源必要性对照

日期：2026-09-13。续接 [自动选择与独立验证](2026-09-13-selection-and-validation.md)。

## 本轮实现

入口 `run_rcnc_lifting.py`，实现 `rcnc/lifting.py`。

- 将显式声明的源常量 AST 出现位置改写为类型化参数 `?lifted_<role>`，保留其他原有参数、前提、效果和源动作身份。
- 每个角色声明 `allowed_objects`、依据 `evidence`，可选 `required_capabilities`。候选对象必须符合原常量类型并具有查询中明确声明的能力，不能自动放宽类型或猜测能力。
- 同一源常量在所有动作中使用同一全局角色赋值。多个常量共享角色时取候选集合交集；`distinct_roles` 可要求两个角色不能绑定到同一对象。
- 当前采用有预算的赋值枚举：每个赋值进入已有动作选择、grounding、BFS 和独立验证流程。这是参考实现，不是联合符号求解或可扩展算法贡献。
- 为每个成功赋值额外导出参数化 `lifted/domain.pddl`、`problem.pddl`、`plan.txt`、`lifting.json` 并独立验证。
- 参数化 PDDL 使用不可被动作修改的 `rcnc_role_<role>(object)` 静态守卫，阻止不同步骤改换角色对象。这些是编译辅助事实；从初态投影掉它们，叙事初态必须与输入一致。
- 没有被 lifting 的源常量仍使用显式固定绑定。只将这些固定对象留作 domain constants，其余实例对象放入 problem objects。

重要边界：当前“参数化领域”对应一个显式对象/接口模型，role guard 的具体值记录在 problem 中。对多个赋值的比较由外层枚举完成，尚未在单个 planner 调用内自动决定所有角色。能力声明仍是人工输入，不是从源故事证明出的事实。

## 命令与输出

```powershell
.venv/Scripts/python.exe run_rcnc_lifting.py --query data/rcnc/queries/lifting_smoke.json --output data/rcnc/my_lifting_run
.venv/Scripts/python.exe run_rcnc_lifting_matrix.py --output data/rcnc/my_lifting_matrix
.venv/Scripts/python.exe -m unittest discover -s tests -v
```

选择空输出目录。固定开发任务位于 `data/rcnc/lifting_tasks_v1/`，最新产物为 `data/rcnc/lifting_matrix_v2/`；v1 保留为加入来源移除对照前的记录。

顶层 `result.json` 保存所有赋值尝试、预算是否穷尽、最佳已验证方案及其目录。`unsolvable` 只在全部允许赋值完成且均不可解/违反显式角色约束时使用；赋值或搜索预算截断返回 `inconclusive`，若已有成功则仅能报告已找到解，不能声明全空间最短。

## 固定开发任务结果

六项任务、两组来源 BIRT/CHIC_NP 与 BIRT/PUSS；都是开发任务，没有新增独立数据来源。

| 任务 | 赋值尝试 | 可解赋值 | 最佳计划 | 顶层结果 |
|---|---:|---:|---:|---|
| witness_hero | 4 | 2 | 3 步 | solved |
| witness_helper | 4 | 2 | 3 步 | solved |
| missing_witness_fact | 4 | 0 | — | unsolvable |
| assignment_budget | 1 | 0 | — | inconclusive |
| possession_to_wearing | 4 | 4 | 2 步 | solved |
| missing_location | 4 | 4 | 2 步 | solved |

共 21 次赋值尝试，12 个可解赋值的 grounded 与参数化 PDDL 均通过独立验证。这个分母不是随机抽样，不能据此宣称论文成功率。

`witness_hero` 与 `witness_helper` 的叙事初态分别声明天空事件发生在对应角色。赋值必须遵循已有事实；缺少所有相关天空事实时不能通过角色重绑定创造它。

## 新发现：可执行跨源计划不等于需要跨源组合

在最佳赋值下，移除一个来源的全部动作，保持相同初态、目标和其他来源动作，重新求解并验证。统计字段 `necessary_within_fixed_assignment` 仅在当前固定角色赋值下解释；并未对移除来源后的所有其他角色赋值重新搜索。

- 两个 witness 任务：移除 BIRT 或 CHIC_NP 后均穷尽状态空间且不可解，因此当前赋值下两个来源都有必要。
- `possession_to_wearing`：搜索返回 `BIRT:turn_key_on_beech -> PUSS:master_wear_suit`，但移除 BIRT 后 PUSS 自己也能完成同一目标。
- `missing_location`：没有位置初态仍可执行 `PUSS:buy_boots -> PUSS:master_wear_suit`。独立验证通过。

原因在原始 `PUSS:buy_boots`：前提只有 `(not (has ?puss ?boots))`，效果是 `(has ?puss ?boots)`；`?boots` 类型仅为 item，所以 cloak 可以进入该参数。它不需要位置或支付条件。`?jack` 也没有参与实际条件。

这是一项可定位的建模宽松性证据，但不能仅凭动作名判断所有这些泛化都应被禁止。本轮没有为了让对照失败而修改源动作、偷偷增加前提或删除替代路径。

因此新来源对目前说明的是“能组合”，尚未说明“组合增加了求解覆盖”。不能把出现两个来源的 action 序列直接算作组合必要性收益。

## 验证

34 项测试通过。新增覆盖：

- 类型不匹配、能力未声明、固定/提升身份冲突。
- 两步分别只有 x/y 能满足条件时，不能通过跨步切换同一源常量来伪造计划。
- 两个不同角色不能因候选对象重合而违反 `distinct_roles`。
- 赋值预算耗尽不宣称不可解。
- 导出的参数化动作真实使用新增变量；去掉辅助事实后初态不变。
- 手工将第二步的角色参数改为另一对象，独立验证器返回 INVALID。

## 下一阶段重点

1. 对普通动作参数也建立可审计的能力/角色约束，重点分析 item 被当作 boots/key/suit 的宽泛类型问题；当前能力约束只用于显式 lifted constants。
2. 将来源必要性纳入任务设计，并对所有候选角色赋值展开来源移除对照；不要只报告来源数量。
3. 冻结接口与角色规则后扩展独立任务来源，区分语义审计前/后输入。
4. 在完整语义约束稳定后比较更成熟的 planner 和联合角色求解，避免把简单枚举本身包装成算法创新。
