# ADR-0006: Backup authority and printer adapters

Status: Accepted

Windows executes only local encrypted backup/restore. Android and Web may create cloud requests; only Super-Superadmin executes them. Printing uses a shared render/job model with platform transport adapters. Web supports PDF/browser printing unless a separately approved bridge is introduced. These boundaries keep privileged destructive operations and unsafe device APIs out of tenant/client authority.
