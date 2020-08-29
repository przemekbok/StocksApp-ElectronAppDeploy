const { app, BrowserWindow } = require('electron');
const serve = require('electron-serve');
const loadURL = serve({
  directory: '../build',
});
//init-process
async function createWindow() {
  let win = new BrowserWindow({ width: 800, height: 600 });
  await loadURL(win);
  win.on('close', () => {
    win.webContents.send('stop-server');
    //kill-process
  });
  win.on('closed', () => {
    win = null;
  });
}

app.on('ready', createWindow);
