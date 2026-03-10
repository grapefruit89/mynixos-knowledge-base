---
title: google-drive-recursive-ownership (mightyiam Nugget)
category: architecture/mightyiam-discovery
capabilities: [extracted-readme, traceability-secured]
sources: [https://github.com/mightyiam/google-drive-recursive-ownership]
---

Google Drive Recursive Ownership Tool
==

Setup
--

    git clone https://github.com/davidstrauss/google-drive-recursive-ownership
    pip install --upgrade google-api-python-client

Usage
--

    python transfer.py PATH-PREFIX NEW-OWNER-EMAIL SHOW-ALREADY-OWNER

- PATH-PREFIX assumes use of "/" or "\" as appropriate for your operating system.
- SHOW-ALREADY-OWNER "true"|"false" (default true) to hide feedback for files already set correctly
