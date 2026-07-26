# Printer Integration

Shared domain contracts:

```text
PrinterDiscovery -> PrinterDescriptor
PrinterConnection.test()
PrintRenderer.render(template, data, capabilities) -> PrintArtifact
PrintTransport.send(artifact, options) -> PrintReceipt
PrinterStatusProvider.watch()
```

The shared pipeline validates data, resolves an immutable template version, lays out in physical units, renders a device-language/PDF artifact, records a job, delegates transport, and records attempts/results. Transport plugins never own label business rules.

- Windows: system spooler and optional raw TCP/driver adapters; local port configuration.
- Android: modular Bluetooth, Wi-Fi/LAN TCP, system print, USB OTG, and isolated vendor SDK adapters. Runtime permissions are requested only when needed.
- Web: PDF generation/download and browser print. Raw printing is unsupported unless a separately approved secure bridge/local print agent is introduced.

Capabilities include DPI, media dimensions, gap/mark mode, supported symbologies/languages, cutter, copies, and density. Never assume printer language from a display name. Jobs carry UUIDs and attempt numbers to reduce accidental reprints, but physical printing cannot generally provide exactly-once guarantees.

Required tests include golden layout tests at supported DPIs, encoder fixtures, capability negotiation, disconnect/timeout behavior, duplicate submission, permission denial, and representative physical-device acceptance tests.
