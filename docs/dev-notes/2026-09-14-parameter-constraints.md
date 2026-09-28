# 普通参数约束与语义假设敏感性

日期：2026-09-14。续接 [受约束 lifting](2026-09-13-constrained-lifting.md)。

## 本轮实现

`rcnc/constraints.py` 处理 `parameter_constraints`：

```json
{
  "parameter_constraints": {
    "PUSS:buy_boots": {
      "?boots": {
        "required_capabilities": ["footwear"],
        "evidence": "本实验作者明确假定该参数需要鞋类能力"
      }
    }
  }
}
```

可选 `allowed_objects` 进一步限定候选对象。未知动作、参数、对象、错误类型或缺少 evidence 都会被拒绝；能力未声明的对象不进入该参数的 grounding 候选集。此处采用保守的闭世界能力表，缺少标注不代表现实中没有能力。

- Grounded 执行路径过滤不合约束的绑定，原始叙事初态不增加事实。
- 参数化 PDDL 增加静态 `rcnc_allowed_<hash>` 守卫与允许对象事实，独立验证也执行这些约束。
- `lifting.json` 将角色与参数约束辅助事实单列；投影去掉辅助事实后，叙事初态仍与查询相同。
- provenance 保留约束依据和每个参数的允许对象。
- `source_removal_scope: all_solved` 对所有可解角色赋值进行来源移除对照。聚合结论字段 `source_necessity_across_assignments`：任一已验证反例即可证明非必要；证明必要要求赋值空间穷尽、其他赋值不可解/不合法且所有可解赋值的移除对照均不可解；否则返回 null。

这些能力要求是明确的模型强化，会改变源 PDDL 的可解集合，不是语义保持的源模型重写。当前只支持普通参数的一元静态能力/对象集合约束，不处理动态能力、关系型条件或所有普通参数间的身份约束。

## 预先定义的四种设置

输入 `data/rcnc/parameter_tasks_v1/manifest.json`；结果 `data/rcnc/parameter_matrix_v1/summary.json`。

四种设置都使用相同的物理对象、叙事初态、目标与角色候选空间；能力假设或启用的约束不同。因此这是模型假设敏感性分析，不是同一语义模型上的算法性能比较。

| 设置 | 假设变化 | 结果 | BIRT 是否必要 |
|---|---|---|---|
| raw | 保留原始普通参数类型约束 | 4/4 赋值可解，2 步 | 否 |
| one_sided_constraint | 只限制 buy_boots 的 footwear 能力 | 4/4 可解，2 步 | 是，但存在单边审计偏差 |
| consistent_constraints | 同时要求 turn_key 的 key 能力和 wear_suit 的 wearable 能力 | 0/4 可解 | 不评价必要性，因为任务本身不可解 |
| explicit_multifunction_object | 在上一设置中明确赋予 cloak 可穿戴及钥匙能力 | 4/4 可解，2 步 | 是，在明确的新能力假设下 |

总计 16 个角色赋值，12 个可解赋值的 grounded 与参数化 PDDL 均通过独立验证。所有可解赋值都进行了两个来源的移除对照，共 24 个对照。必要性结论相对于声明的完整候选赋值空间；不涉及范围外的其他对象/角色。

关键发现：只限制 PUSS 的 buy_boots，可以人为制造 BIRT 的必要性，但 BIRT 的 turn_key 仍允许把普通 cloak 当作 key。统一应用本实验声明的能力要求后，普通 cloak 任务不可解。显式的多功能 cloak 世界可以恢复可解性，但这是改变能力输入，不是算法凭空获得知识。

`consistent_constraints` 的命名只表示一致应用本次选定的三项约束，不表示已经完成所有动作或参数的语义审计。尚未由独立标注者确认这些要求。

## 复现

```powershell
.venv/Scripts/python.exe -m unittest discover -s tests -v
.venv/Scripts/python.exe run_rcnc_lifting_matrix.py --manifest data/rcnc/parameter_tasks_v1/manifest.json --output data/rcnc/my_parameter_matrix
```

原始源 PDDL、前几轮任务和实验结果均保留。新结果使用独立目录。

38 项测试通过。新增测试确认：普通 cloak 不被绑定为需 footwear 的参数；空能力表不能产生该绑定；未知参数/缺少依据/跨类型对象被拒绝；在参数化计划中把允许物品替换为不允许物品，独立验证器返回 INVALID。

## 对论文设计的影响

1. 语义约束、对象能力与接口标注应在看测试结果前冻结，并记录标注覆盖率与依据。
2. 用同一语义约束集比较不同算法；原始/强化模型的差异单独报告，避免将人工知识收益归给组合算法。
3. 保留单来源可解控制、真正需要多来源控制和不可解控制，不能只展示跨源序列。
4. 下一步应建立统一的参数约束登记和独立标注流程，扩展真实固定初态任务；不应依据当前四个结果继续逐例加条件。
