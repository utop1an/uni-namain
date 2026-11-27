# 模型提示词索引

## NarraFuse 主实验

[主实验目录](narrafuse/main/)含 4 个模板。每个候选对使用其中 3 个。按以下顺序阅读即可还原一条请求。

1. [公共规则](narrafuse/main/compact_common.txt)规定如何比较语义、对齐参数和引用证据。
2. 按候选类型追加[谓词规则](narrafuse/main/compact_predicate.txt)或[动作规则](narrafuse/main/compact_action.txt)。
3. [输出契约](narrafuse/main/output_contract.txt)将上述指令、对应的 JSON Schema 和候选 PDDL 上下文拼成最终消息。

论文主实验的 [OpenAI 请求构造器](../scripts/experiments/prepare_union_full_openai.py)使用这套 compact 模板。[选择对比实验](../scripts/experiments/run_selection_comparison.py)也使用 compact 判断规则。复核某次实际调用时，以该次冻结的请求为准。

## NarraFuse 历史对齐实验

[请求构造器](../rcnc/model_semantics.py)按实验配置选择模板。

| 配置 | 模板 |
| --- | --- |
| `free_fields` | [基础判断](narrafuse/historical_alignment/base.txt) |
| `coupled_fields` | [基础判断](narrafuse/historical_alignment/base.txt) + [字段约束](narrafuse/historical_alignment/coupled_fields.txt) |
| `semantic_facets` | [分项语义判断](narrafuse/historical_alignment/facets.txt) |
| `semantic_facets_optional_roles` | [分项语义判断](narrafuse/historical_alignment/facets.txt) + [可选角色映射](narrafuse/historical_alignment/optional_roles.txt) |
| `role_identity_before_applicability` | [跟进实验脚本](../archive/scripts/experiments/prepare_role_identity_followup.py)用[角色澄清文本](narrafuse/historical_alignment/role_identity_clarification.txt)替换上一配置中的指定句子 |

需要在消息中显式提供输出格式的历史配置也复用[输出契约](narrafuse/main/output_contract.txt)。

## NarraFuse 标注预测

[标注预测脚本](../scripts/annotation/run_annotation_predictions.py)将[谓词判断提示词](narrafuse/annotation/annotation_predicate.txt)作为系统消息，另用一条用户消息传入候选数据。

## UniDomain

| 基线操作 | 模板 |
| --- | --- |
| 判断并合并谓词 | [check_merge_predicates.txt](unidomain/check_merge_predicates.txt) |
| 谓词变更后更新动作文本 | [update_action_string.txt](unidomain/update_action_string.txt) |
| 判断并合并动作 | [check_merge_actions.txt](unidomain/check_merge_actions.txt) |

三份模板来自 [UniDomain 官方提交 db464197](https://github.com/RoboticSJTU/UniDomain/tree/db46419732d5c8949f85c0dbcce5ab9c8a8a4d5c/src/unidomain/prompt_templates/domain_fusion)，由[本地基线](../unidomain/fusion.py)加载。[指纹测试](../tests/fusion/test_unidomain_official_alignment.py)核对标准化后的正文。旧实验归档中的 `prompts/domain_fusion/<文件名>` 对应现在的 `prompts/unidomain/<文件名>`。

## 如何记录修改

可复用的模型指令以 UTF-8 文本保存在相应方法目录。修改模板时，在上表注明配置、用途和调用入口。并行使用的实验变体各自命名，共用段落只维护一份。对已经执行的实验，按其原始请求、归档路径和哈希复核；新实验在自己的输出目录冻结输入与模板。
