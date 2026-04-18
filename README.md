# Custom sql.js Build for Loop Habit Tracker

This repository contains a customized build of `sql.js` (SQLite compiled to WebAssembly) with the following patches:
- Exports the Emscripten `FS` (File System) API for direct filesystem access.
- Optimized for consistent builds via Docker.

## Why?
Loop Habit Tracker uses a persistent database file. By exporting `FS`, the web app can mount an IndexedDB file system or manipulate the database file directly without expensive buffer copies.

## Consumption
You can use this build in your `package.json` by referencing the `dist` branch or a specific tag:

```json
"dependencies": {
  "sql.js": "github:your-user/sql.js#v1.11.0-loop1"
}
```

## How to Build Locally
Ensure you have Docker installed, then run:
```bash
./build.sh
```
The artifacts will be in the `./output` folder.

## GitHub Actions
Every push to `main` builds and pushes the artifacts to the `dist` branch.
Every push of a tag (e.g., `v1.11.0-loop1`) builds and creates a corresponding tag on the `dist` branch.
