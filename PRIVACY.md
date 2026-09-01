# Privacy Documentation

- The CropCheckUp CLI runs on the computer where it is invoked.
- It reads the image path supplied on the command line and processes the image in memory.
- It makes no network requests and sends no image bytes to an application server or diagnosis API.
- It does not create accounts, collect analytics, or save diagnosis history.
- The CLI does not write image data. Shell history, operating-system logs, and any output redirected by the user are outside the CLI process.
