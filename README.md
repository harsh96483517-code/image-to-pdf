# Image to PDF

A tiny, single-file web app that turns photos into one PDF. Built for phones — on a Samsung device, tapping **Choose from Gallery** opens Samsung Gallery, Google Photos or Files, and the finished PDF is saved to your Downloads.

Everything runs inside the browser. No upload, no server, no account.

## Features

- **Pick from Gallery or Camera** — multi-select photos in one go
- **Reverse** — flip the whole page order with one tap (last photo becomes page 1)
- **Mirror / rotate** — flip an image left-to-right or turn it 90° per photo
- **Reorder** — move any photo left or right
- **Page size** — A4, Letter, or a page exactly the size of the photo
- **Quality** — Standard / High / Maximum JPEG quality
- **Dark mode** — follows your system theme

## Use it

Open `index.html` in any modern browser. That's it — one file, no build step, no dependencies to install (it loads `pdf-lib` from a CDN for the PDF writing).

Hosted version: enable GitHub Pages on this repo (Settings → Pages → Deploy from branch → `main` / root) and it will be live at `https://harsh96483517-code.github.io/image-to-pdf/`.

## Android APK

The `android/` folder holds a thin native wrapper: a single-activity WebView app that loads the same `index.html` from `assets/`, bundles `pdf-lib` locally (so it works with no internet), opens the Android photo picker for the Gallery/Camera buttons, and writes the finished PDF straight to **Downloads** through a JavaScript bridge.

- Package: `com.harsh.imagetopdf` · version 1.0
- minSdk 24 (Android 7.0) · targetSdk 34
- No internet permission — the app cannot send your photos anywhere
- Build without Gradle: `bash android/build.sh` (needs JDK 17 + Android SDK build-tools 34 / platform 34)

The APK is signed with a self-signed key, so Android will ask you to allow "install from unknown sources".

## Notes

- Supported input: any image format your browser can decode (JPG, PNG, WebP, BMP, GIF first frame).
- HEIC files straight from an iPhone may not decode in the browser; convert to JPG first.
- Images are downscaled to 3200 px on the long edge before embedding to keep PDFs a sensible size.
- Very large batches on an old phone: make the PDF in two or three runs.

## License

MIT
