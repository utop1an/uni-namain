# RCNC 对话总结与后续实验交接

日期：2026-09-05

## 用户目标与方法定位

目标不是只压缩等价的 domestic/indoor/household actions，而是组合不相关的 narrative domains，创造奇特、有因果结构的故事。RCNC（Role-Causal Narrative Composition）因此被提出为独立方法：保留源模型，通过常量提升、状态接口、事件模板和角色重绑定进行组合；UniDomain 保留为独立复现/比较路径。

最新目标：给定初始条件，生成真正可执行且有趣的 plan。用户认为初始 domain 质量是主要瓶颈；后续只假设输入质量略微提高，不假定输入完全正确。这一质量归因尚未由独立标注实验定量验证。

## 已实现：Experiment 1

入口 `run_rcnc_experiment.py`；核心 `rcnc/experiment.py`；产物 `data/rcnc/experiment_1/`。

- 复用 PDDL parser，但不使用 UniDomain 的 embedding、LLM、prompts 或二叉融合树。
- 提取 source-scoped constant profiles；为 action 中固定常量记录 lifting 候选槽位，尚未真正改写为参数化 PDDL。
- 用手工词表把 predicates 投影为 frame keys，把 actions 分类到 event families；未生成合并后的 executable operators。
- 用 add effect 与后继某个 precondition 的 frame key/arity 匹配构造跨源候选边，按参数位置记录局部对应。
- 类型不一致只标注 `adapt-type:X->Y`，不是已执行的角色转换。
- Beam search 从有出边的 actions 开始，保留 300 条高分路径，禁止重复 action，生成三档各 10 条长度 5 的骨架。

| 指标 | 现有 snapshot |
| --- | ---: |
| 源 domains / predicates / actions | 15 / 236 / 234 |
| Source-scoped constant profiles | 347 |
| 固定常量出现次数 / 含固定常量的 actions | 167 / 79 |
| 唯一 frame keys / 跨源共享 frame keys | 190 / 14 |
| 跨源候选边 | 4,973 |
| 无 adapter 标记 / 有标记 | 4,342 / 631 |
| 返回骨架最大来源数 | 4 |

这是抽象表示和候选图统计，不是正确 merge 数量或可执行 plan 成功率。

## 确定性规则的来源

Experiment 1 完全没有调用 LLM，也没有自然语言故事生成 prompt。以下都是原型启发式，不是复现某个论文或标准 narrative ontology：

- `at/located/entity_at/item_at/at_item`、`has/holds/possesses`：从当前数据词汇整理的 alias 表。
- `dead/alive/open/closed`：手工状态词表，保留不同状态值。
- `travel/move -> MOVE`、`shoot/eat -> HARM`：按顺序命中关键词分类。
- `king -> authority`、`wolf -> antagonist-candidate`：粗略常识标签，不是可靠的角色事实。
- 根据 predicate 的参数位置推断 capability，不能视为充分能力证据。
- 新奇度是 action 名 token 的 Jaccard 距离；搜索权重未经标注集校准。
- Entity profiles 目前主要用于描述输出，尚未作为完整语义约束参与搜索。

已知反例：`kissed_by` 与 `castle_owned_by` 因末尾 `by` 被映射为同一 frame；`eat_feast` 因 `eat` 被归为 HARM；MOVE 过宽。后续需要结构约束和可审计的语义标注，而非无限扩充词表。

## 生成结果及应如何解读

首轮 `located-at` 有 3,321 条边，`possesses` 有 1,509 条，合计约 97.1%。加入 frame 稀有度奖励、重复 connector 惩罚和来源/事件族多样性后，排名靠前的路径转向 `dead -> alive -> intact -> dead`。

代表性骨架：

```text
HANS_NP:push_witch_into_oven
→ SNOW:dwarfs_remove_comb_rescue_snow_white
→ PIGS_NP:wolf_fails_to_blow_house
→ JACK_NP:cut_beanstalk
→ SNOW:dwarfs_prepare_glass_coffin_for_snow_white
```

局部绑定提示“女巫成为营救对象、复活对象接狼角色、房屋接豆茎槽位”等重组可能性。这不是已验证的全局角色分配，也不能直接当作可执行故事。

### 有效性澄清

本次核对代码发现 `build_causal_edges` 没有过滤负前置条件，因此不能保证匹配的 add effect 真正支持目标前置条件。

程序也没有检查全部前置条件、全局变量统一、删除效果的后续影响、给定初态或最终目标；逻辑表达式被扁平抽取，不能替代完整 PDDL 语义。类型不一致被允许并加标记，而非拒绝不合法绑定。

输出 `causally_valid` 主要检查路径节点/连接索引一致；`all_causally_connected` 检查连接数量。这些名称不代表 planner/replay 验证。旧报告的“因果连通”只能理解为候选图连通。测试通过亦不能证明故事语义正确。

## 展示缺口

当前 JSON 分散记录 frames、families、profiles、edges，没有统一的 `source -> generalized result` 报告。后续应展示：

1. Predicate groups：源声明、canonical frame、参数/状态值映射、依据。
2. Action groups：源 actions、event template、共同部分与保留 variants；分类不等于 executable merge。
3. Constants：源实例、profile/prototype、lifting slots；类型归类不等于实体身份合并。
4. Composition decisions：producer、connector、全局绑定、adapter、consumer。
5. Before/after PDDL 和逐步 validation trace。

## 后续方案（讨论建议，尚未实现或验证）

采用“可信子集 + 查询时局部编译 + planner/replay + 有趣度重排”，不要依赖一个无条件可用的巨大 merged domain。

- **质量门控**：区分结构有效、可执行见证、语义审计。source problem 可解不代表其全部 actions 正确。按证据划分 Trusted、Repairable、Quarantined。
- **Predicate registry**：高置信等价映射用于执行，弱映射仅用于检索；不可丢失极性、参数范围或关系方向。
- **Constant lifting**：真正改写 AST，将故事实例放入 problem objects，保留来源/默认绑定，并使用整条 plan 的全局绑定环境。
- **Action variants**：默认保留。只有经过映射后 transition 等价才合并；不能简单并集不同前置条件和效果。
- **显式 adapters**：有明确前提/效果/代价及来源或审计依据；找不到合理转换时拒绝绑定，不自动添加万能 adapter 制造可解性。
- **固定初态**：用户给定初态必须保持；缺少条件需报告或通过真实 action 达到，不能为了迎合候选故事偷偷添加初始事实。
- **目标机制**：有 goal 则求解；只有初态则提出可达、非平凡的候选 goals，再验证。合成初态 benchmark 与固定初态任务分开报告。
- **局部编译**：按可达性和目标依赖选取闭合 action 子集，保留必要前提支持；编译 PDDL、求解、逐步 replay、检查 goal。
- **有趣度**：只在有效 plans 中比较跨源组合、角色新奇性、事件变化与结局；惩罚重复、循环和过多 adapters，不以放松正确性换新奇性。
- **后续 LLM**：可提议语义映射、角色、goals、adapters 并附证据；不能替代类型检查、planner 或 replay。自然语言故事只根据通过验证的 trace 写作。

### Experiment 2 建议验收

从明确记录的初始状态出发，输出局部 `domain.pddl`、`problem.pddl`、grounded plan、全局 role bindings、provenance 和 replay trace。每条成功结果须满足所有前置条件、正确执行正负效果、保持绑定一致并达到 goal。

长度 4–10、至少两个来源、最多两个 adapters 可作为初步实验设置，不是已验证保证。报告总尝试数、求解/验证率、失败原因、来源覆盖及人工新奇性/连贯性评分，不能只挑成功案例。

优先次序：修复极性/逻辑与全局绑定验证 → 可执行 lifting/局部 PDDL 编译 → 固定初态规划 → 显式 adapters → 有趣度与 LLM 语义模块。

## 本次记录与验证

- 本次仅维护文档，不改算法、不重跑生成产物；后续设计未实现。
- 2026-09-05 重新运行 `python -m unittest discover -s tests -v`：12 项通过。
- 核对当前代码和 snapshot；算法修正后需重新生成产物并另记结果。
