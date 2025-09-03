# ADR-0001: RAG-First Wissenshierarchie
Status: Accepted
Kontext: Halluzinationen vermeiden; verlässliche Quellen erzwingen.
Entscheidung: Reihenfolge 1) RAG/Docs, 2) Codebase, 3) Extern (Research), 4) LLM-Wissen.
Konsequenzen: Referenzen in /context/refs pflegen; Prompts verweisen auf RAG vor LLM.
