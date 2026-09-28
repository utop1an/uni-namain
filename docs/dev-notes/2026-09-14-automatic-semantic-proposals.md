# 自动语义提议模块（2026-09-14）

新增 `rcnc/semantic_proposals.py` 与 `run_rcnc_semantics.py`，从源 PDDL 自动生成参数能力约束、跨源谓词接口和常量角色假设。输入只有动作、谓词、常量及源文件哈希，不读取任务目标、规划结果或人工规则。默认使用本地 Ollama `gemma3:4b`；不会下载模型，拒绝已识别的云端转发模型。

## 使用

```powershell
.venv/Scripts/python.exe run_rcnc_semantics.py --sources BIRT PUSS --output data/rcnc/my_semantics
.venv/Scripts/python.exe run_rcnc_semantics.py --sources BIRT PUSS --kind interface --output data/rcnc/my_interfaces
.venv/Scripts/python.exe run_rcnc_semantics.py --sources BIRT PUSS --kind role --output data/rcnc/my_roles
.venv/Scripts/python.exe run_rcnc_semantics.py --sources BIRT PUSS --response data/rcnc/semantic_proposals_v2/response.json --output data/rcnc/my_replay
```

输出目录必须为空。`--model` 可选择已安装模型，`--url` 可指定 Ollama 服务。离线重放只重新检查保存的回答，报告明确标记 replay，不能算作新的模型推理实验。

## 输出与检查边界

- `source_pack.json`：模型可见的记录、源文件 SHA256。
- `request.json`、`raw_response.json`、`response.json`：请求、原始服务回答和解析后的提议；重放没有原始服务回答。
- `report.json`：每条提议的结构错误、模型摘要、提示词与实现哈希、耗时。
- `draft_registry.json`：通过结构检查的假设草案。

生成 schema 根据源记录限制引用和提议字段；检查器验证引用存在、动作参数存在、引用片段确实来自对应记录、接口跨源且参数类型顺序兼容，并拒绝重复冲突的参数或接口条目。引用片段来自解析后序列化的 PDDL；常量记录的使用列表由程序生成，不是原文件逐字片段。

结构合法不代表语义成立，`semantically_verified` 始终为 0。参数与接口草案采用现有注册表字段，但不自动加载到规划器或覆盖冻结注册表。角色提议尚未绑定任务对象。模块不会凭空补充初始事实或对象能力；后续实验必须显式提供这些假设，否则参数约束可能阻断所有动作实例。

## 本地实测

源域 BIRT/PUSS，模型 gemma3:4b，temperature=0，固定 seed。以下是开发运行，不是独立测试或语义准确率。

| 输出目录 | 提议数 | 通过结构检查 | 耗时 |
| --- | ---: | ---: | ---: |
| semantic_proposals_v1 | 12 | 0 | 28.38 s |
| semantic_proposals_v2 | 6 | 4 | 9.17 s |
| semantic_interfaces_v1 | 6 | 0 | 10.66 s |
| semantic_roles_v1 | 6 | 6 | 9.64 s |

首轮格式和引用失败后，第二轮加入按类型限制的生成 schema。第二轮通过项均为参数提议，但 `hear_tapping_on_beech` 的解释误解了参数含义，说明即使引用真实也不能证明推断正确。接口专门运行出现同源重复引用、引文不匹配或类型不兼容，全部被拒绝。角色提议多数重复原常量名称，虽然结构合法，尚未证明能形成有用的可复用角色。

因此当前交付是可运行、可追溯、可拒绝不合法输出的自动提议管线；当前小模型的语义质量仍不足以支持无人审核地改变规划模型。后续应评估更强本地模型、动作上下文支撑的接口提议，以及少量独立评估样本。不要通过观察任务是否可解来反向挑选语义规则。

这些新输出不属于已有 frozen_protocol_v1。将自动提议纳入正式比较时，需要另建冻结版本，记录模型、提示、提议、采纳规则和能力事实。
