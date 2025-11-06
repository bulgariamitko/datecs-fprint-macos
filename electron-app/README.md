# Electron App (Under Development - Not Functional)

⚠️ **WARNING**: This Electron + React application is **NOT FUNCTIONAL** and is under development. It may never be completed.

**For a working solution, use the Wine-based approach documented in the main README.**

---

## About This Folder

This folder contains an experimental Electron + React application that was intended to provide:

- Native macOS UI for FPrint configuration
- Automatic Wine/FPrint management
- Activity monitoring and logging
- Integration with the monitor app

## Current Status 🚧

**NOT WORKING** - The application is incomplete and non-functional:

- ❌ Wine integration not implemented
- ❌ FPrint management not working
- ❌ UI incomplete
- ❌ No active development

## Why This Exists

This was an attempt to create a native macOS application that would eliminate the need for manual Wine commands. However, the Wine-based solution (documented in the main README) works perfectly well, making this Electron app unnecessary for most users.

## Structure

```
electron-app/
├── package.json          # Node dependencies
├── package-lock.json     # Locked dependencies
├── public/
│   ├── electron.js      # Electron main process (incomplete)
│   └── index.html       # HTML entry point
└── src/
    ├── App.js           # Main React component
    ├── index.js         # React entry point
    ├── index.css        # Styles
    └── components/      # React components
```

## If You Want to Try It Anyway

**Prerequisites:**
- Node.js 16+
- npm or yarn

**Install dependencies:**
```bash
cd electron-app
npm install
```

**Run in development mode:**
```bash
npm start
```

**Note:** Even if it runs, it won't actually manage FPrint or Wine correctly. This is for development/experimentation only.

## Future Development

There are no plans to complete this application. The current Wine-based solution with the monitor app provides all necessary functionality:

- ✅ FPrint works perfectly via Wine
- ✅ Monitor app provides status tracking
- ✅ Chrome extension handles file management
- ✅ Everything is documented and working

If you're interested in contributing to complete this Electron app, please open an issue on GitHub to discuss before investing time.

---

**For the working solution, see the main README in the root of this repository.**
