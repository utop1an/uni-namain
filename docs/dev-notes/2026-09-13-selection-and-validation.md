# 自动动作选择、独立验证与固定任务矩阵

日期：2026-09-13。续接 [执行基础](2026-09-13-execution-foundation.md)。

## 已实现

- `rcnc/validation.py` 使用 Unified Planning 1.3.0 独立解析导出的 domain/problem/plan，并调用 `sequential_plan_validator`。没有使用 RCNC 的 parser 或 replay 实现。
- `require_external_validation: true` 时，缺少验证器不能报告成功；INVALID/ERROR 改为验证失败。验证依旧相对于编译后的显式模型，不证明接口假设真实或源故事语义合理。
- `sources` 可以替代手工 `actions` 列表。逐动作审计逻辑片段、符号和类型，并记录未提供常量绑定、没有对应类型对象等不适用原因。不会猜测常量绑定或增加初始事实。
- `selection_mode: goal_relevance` 在 grounding 后先过滤静态前提不成立的动作，再从正负目标反向收集支持闭包，包括支持负前提的 delete effects。初态已有事实的其他支持动作仍保留，避免删掉威胁后的恢复路径。
- 未被任何已选动作引用、但已在源领域声明的事实，也可以出现在初态/目标中；它们不能被当作未声明符号拒绝。

完整性范围是显式对象、绑定和受支持的候选动作集合。当前裁剪发生在 grounding 后，因此只能减少搜索动作和搜索状态，不能声称降低 grounding 成本。

## 实际发现

原四步示例不是完整源动作池中的最短计划。自动选择发现三步路径：

1. `BIRT:travel_to_trysting_place(hero, tree, bench)`
2. `CHIC_NP:meet_character(hero, helper, tree)`
3. `CHIC_NP:inform_about_sky_fall(hero, helper)`

初态和目标保持不变。这证实需要以自动源池评价，不能用手工选定的四个动作推断规划长度或难度。

两个来源共 19 个动作；当前对象与显式常量绑定条件下 9 个适用，grounding 后 44 个动作。`separated` 任务裁剪至 21 个动作，发现状态数由 609 降至 76，最短计划均为 3 步，且通过独立验证。

## 固定开发矩阵

运行前写入 `data/rcnc/fixed_tasks_v1/manifest.json` 和 6 个任务文件。
原始输入与 SHA256 保存在各次输出中；这些仍是人工构造的开发任务，不是独立测试集。

命令：

```powershell
python -m venv .venv
.venv/Scripts/python.exe -m pip install -r requirements-planning.txt requests==2.32.5
.venv/Scripts/python.exe -m unittest discover -s tests -v
.venv/Scripts/python.exe run_rcnc_matrix.py --output data/rcnc/my_matrix
.venv/Scripts/python.exe run_rcnc_audit.py --output data/rcnc/my_audit
```

需从仓库根目录执行，并选择新的输出目录。requests 用于已有 UniDomain 单元测试；执行路径依赖在 `requirements-planning.txt`。实际安装版本记录在 `data/rcnc/fixed_matrix_v1/environment.freeze.txt`。

| 固定任务 | 全量动作 | 目标相关裁剪 | 来源隔离 |
|---|---|---|---|
| separated | solved，3 步 | solved，3 步 | state_limit |
| swapped_locations | solved，3 步 | solved，3 步 | state_limit |
| already_colocated | solved，2 步 | solved，2 步 | solved，2 步 |
| missing_sky_fact | state_limit | unsolvable | depth_limit |
| missing_helper_location | unsolvable | unsolvable | unsolvable |
| negative_location_goal | solved，3 步 | solved，3 步 | state_limit |

18 次尝试，9 个 solved 均获得独立 VALID。状态预算为 10000，深度预算为 10；预算截断不代表不可解。这里不报告总体“成功率提升”，因为任务包含故意构造的不可解条件且只有两个来源。

来源隔离基线将每个共享初始事实复制到对应的各源谓词命名空间，避免只给一方初态。存在共享目标谓词时会展开目标并标记 `goal_rewritten`；本矩阵的 `negative_location_goal` 存在此情况，应从严格相同目标的主比较中单列。

`missing_sky_fact` 的静态必要事实缺失使目标无法实现。裁剪得到空动作集合并判定不可解；全量方法在无关状态变化中耗尽预算。这是工程诊断，不足以支撑跨数据集性能结论。

## 源输入审计

`data/rcnc/source_audit_v1/audit.json`：15 个源 domain/problem 均能被独立解析；234 个动作中 4 个含当前执行子集不支持的 `exists/when/or`，其余通过本轮符号、参数类型检查。

这些 4 个属于“当前实现不支持”，不能称为源模型错误。独立解析成功也不等于源 problem 可解或动作符合故事语义。目前仍不能定量认定输入质量是主要瓶颈。

## 验证与下一步

28 项测试通过，包括独立验证正确计划及拒绝删掉首步的计划、缺少验证依赖不能报告成功、负前提支持、初始事实恢复，以及 60 个固定随机种子生成的小型 signed STRIPS 系统上的裁剪前后可解性与最短长度一致性。

下一阶段：

1. 将明确绑定扩展为有约束的通用 lifting；建立类型/身份/能力审计规则，不自动放宽类型。
2. 接入更成熟的搜索器，在相同 grounding 输入下比较搜索预算；当前 BFS 只是参考实现。
3. 增加真实固定初态任务及独立来源测试领域，冻结规则后再运行。先扩大因果规划证据，再引入叙事质量重排。
4. 对动作模型建立独立可执行见证和人工语义审计，区分模型问题、接口问题、绑定不足与搜索资源问题。

## 裁剪论证的边界

在本实现受支持的确定性 signed STRIPS、无轨迹约束、无额外成本/来源偏好条件下，反向闭包保留所有支持已需正事实的 add 动作及支持已需负事实的 delete 动作，并递归纳入这些动作的前提。未被选中的动作不能对该闭包提供有益支持，删除其执行可消除威胁，而不会损失闭包所需支持。静态前提不成立的动作永远不可执行。

这是后续形式化证明的起点，不是新颖性声明；若加入来源数量、叙事偏好、轨迹约束或 adapters，必须重新检查裁剪是否保留所需解。
