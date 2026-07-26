# ADR-0001: Two codebases and a modular Laravel monolith

Status: Accepted

CodeVault will use exactly one Laravel backend repository and one Flutter repository. Laravel begins as a modular monolith with explicit module/application contracts. This minimizes deployment and transaction complexity while preserving boundaries that could support later extraction if proven necessary. Separate platform backends or duplicated Flutter applications are rejected.
