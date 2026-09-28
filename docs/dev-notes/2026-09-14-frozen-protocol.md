# 冻结标注登记与前瞻变体实验

日期：2026-09-14。

## 已交付

- 统一登记：`data/rcnc/frozen_protocol_v1/registry.json`，集中保存能力定义、接口、参数约束、对象能力配置及模板。
- 待审清单：`annotation_queue.json`，覆盖 15 个源领域的 571 个普通参数槽位。已有 3 项作者约束假设，独立复核 0 项，其余明确为 unreviewed。
- [标注规范](../research/annotation-protocol-v1.md)：记录证据类型、状态、独立复核流程和版本升级规则。
- `build_rcnc_frozen.py`：只生成任务和冻结文件，不调用 planner。
- `rcnc/protocol.py` 与 `run_rcnc_frozen.py`：执行前后校验 SHA256，拒绝任务、登记、源模型或实现漂移。

冻结指纹：`4e46db3a8045aeef8a642ab0722b22c090a6af16a08f0235711d9d7020664926`。

冻结并不意味着语义正确或独立标注完成。规则修订需建立新版本。

## 任务生成与边界

执行前确定两组笛卡尔积，全部保留：

- possession：4 种对象能力配置 × 有/无位置初态，共 8 项。对象统一使用 artifact 标识，避免把名字作为能力事实。
- witness：事件属于 hero/helper/无人/两人 × 同地/异地，共 8 项。

共 4 项 development 参照和 12 项 prospective_variant。后者是首次执行的规则变体，但仍来自已经研究过的 BIRT/CHIC_NP/PUSS，不能称为独立领域测试。

## 实际结果

输出 `data/rcnc/frozen_run_v1/summary.json`。

- 16 项任务，64 个全局角色赋值。
- 9 项任务可解，7 项在声明的赋值空间内不可解；没有资源截断或验证错误。
- development：2 项可解、2 项不可解。
- prospective_variant：7 项可解、5 项不可解。
- 28 个可解赋值均通过 grounded 和参数化 PDDL 独立验证。
- 可解任务中，4 项需要两个来源，5 项存在单来源完成方式，结论覆盖允许的角色赋值空间。

这些包含有意不可解控制，不能将 9/16 解读为一般任务成功率。

主要观察：

1. 明确具备钥匙与衣物能力的物品，在有位置初态时能跨源获得并穿戴；无位置初态时不可解。
2. 鞋类且可穿戴物品能由 PUSS 单独购买并穿戴，BIRT 不必要。
3. witness 任务在角色已同地时不需要 BIRT 移动；异地时两个来源都有必要。
4. 缺少所有相关事件事实时，重绑定不能补造事件，任务保持不可解。

运行后未依据这些结果修改任务、登记或算法。

## 复现

```powershell
.venv/Scripts/python.exe -m unittest discover -s tests -v
.venv/Scripts/python.exe run_rcnc_frozen.py --bundle data/rcnc/frozen_protocol_v1 --output data/rcnc/my_frozen_run
```

41 项测试通过，新增覆盖冻结后登记/任务变化拒绝、重复冻结拒绝及路径越界拒绝。

若代码或源模型更新，旧 bundle 将拒绝运行，这是预期行为。可使用原冻结版本，或明确生成新版本再执行：

```powershell
.venv/Scripts/python.exe build_rcnc_frozen.py --output data/rcnc/frozen_protocol_v2
```

生成器使用当前开发模板；因此新版本不能自动继承旧版本的前瞻性声明，需检查规则是否曾根据结果调整。

## 下一步

首先补独立标注和真实来源证据，扩大约束覆盖；随后建立独立来源的固定初态任务。当前任务框架和可审计产物已经具备，但论文仍缺独立标注、独立测试数据和强基线。不要把增加模板变体数量当作解决这些缺口。
