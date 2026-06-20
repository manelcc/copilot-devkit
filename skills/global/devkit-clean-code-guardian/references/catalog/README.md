# Clean Code Catalog (JSON)

This folder contains JSON catalogs for Clean Code rules.

## Files

- clean-code-kotlin-rules.json
- clean-code-java-rules.json
- clean-code-python-rules.json
- clean-code-rule.schema.json

## Hybrid execution

- Always load base rules from references/rules.md
- Also load language catalog:
  - clean-code-kotlin-rules.json for .kt files
  - clean-code-java-rules.json for .java files
  - clean-code-python-rules.json for .py files
- Do not mix rules of different languages for the same file

## Fill process

1. Add rules in rules[]
2. Keep id conventions:
   - Kotlin: CC-KT-001..CC-KT-100
   - Java: CC-JV-001..CC-JV-100
   - Python: CC-PY-001..CC-PY-100
3. Update rule_count to match rules length
4. Keep language consistent per file
5. Respect required fields from clean-code-rule.schema.json

## Why the schema exists

The schema validates structure and consistency:

- required fields
- valid id/category/severity values
- valid detection object format
- prevents malformed catalogs
