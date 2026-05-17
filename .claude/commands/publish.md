---
description: Publish the wiki snapshot — builds wiki.zip and opens the Drive folder so you can upload it. Teammates pick up your changes via /team-wiki:refresh.
---

Run the publish script:

```bash
.claude/scripts/publish.sh
```

After the script finishes, tell the user:

1. The new `wiki.zip` is built at the repo root with the page count and size shown above
2. The Drive folder is now open in their browser
3. They need to drag the new `wiki.zip` into the Drive folder window and click **"Replace existing file"** when prompted — this keeps the same file ID so teammates' `/team-wiki:refresh` continues to work without any plugin update

Do not attempt to upload to Drive yourself — that requires manual drag-and-drop in the browser.
