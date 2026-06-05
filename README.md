# KOReader Acorny Highlight Sync

This plugin adds Acorny as a KOReader highlight export target and can automatically sync new highlights to Acorny when network is available.

## What to install

`provider-acorny-highlights.koplugin` is the plugin folder, not a single file.

After installation, the folder must contain files like this:

```text
plugins/
  provider-acorny-highlights.koplugin/
    _meta.lua
    main.lua
    acorny.lua
    acorny_helper.lua
    README.md
```

If you see `provider-acorny-highlights.koplugin.zip`, do not copy the zip file itself. Unzip it first.

## Download

### Option 1: Download ZIP from GitHub

1. Open https://github.com/momadacoding/provider-acorny-highlights.koplugin
2. Click `Code` > `Download ZIP`.
3. Unzip the downloaded file.
4. The unzipped folder may be named `provider-acorny-highlights.koplugin-master`. Rename it to:

```text
provider-acorny-highlights.koplugin
```

5. Copy that whole folder into KOReader's `plugins` directory.

### Option 2: Git clone

If you have Git on your computer:

```sh
git clone https://github.com/momadacoding/provider-acorny-highlights.koplugin.git
```

Then copy the cloned `provider-acorny-highlights.koplugin` folder into KOReader's `plugins` directory.

## Where to copy it

Copy the whole `provider-acorny-highlights.koplugin` folder into KOReader's user plugin directory.

The final path should be:

```text
<KOReader data directory>/plugins/provider-acorny-highlights.koplugin/
```

Common paths:

| Device / build | Plugin directory |
| --- | --- |
| Android | `/sdcard/koreader/plugins/` or `/storage/emulated/0/koreader/plugins/` |
| Kobo | `.adds/koreader/plugins/` on the Kobo USB storage |
| Kindle | `koreader/plugins/` on the Kindle USB storage |
| Linux AppImage / Flatpak / multi-user build | `~/.config/koreader/plugins/` |
| macOS desktop build | `~/Library/Application Support/koreader/plugins/` |
| Portable desktop build | `plugins/` next to the KOReader executable |

If the `plugins` directory does not exist, create it.

After copying, restart KOReader. The plugin should appear in KOReader's plugin management menu as `Acorny highlight sync`.

## Configure

1. Open KOReader.
2. Go to `Tools` > `Export highlights` > `Choose formats and services` > `Acorny`.
3. Select `Set authorization token`.
4. In Acorny, open `Settings` > `Import API tokens`, create a token, copy it, and paste it into KOReader.
5. Enable `Export to Acorny` for manual exports.
6. Enable `Automatically sync new highlights` to upload newly created highlights automatically.

Automatic sync only uploads while KOReader has network access. If the device is offline, new highlights are queued and synced after KOReader reports that the network is connected.

## Test

To verify the integration:

1. Configure the Acorny token.
2. Enable `Automatically sync new highlights`.
3. Open a book in KOReader.
4. Create a new highlight.
5. Confirm the highlight appears in Acorny.

You can also test manual export from `Tools` > `Export highlights` after enabling `Export to Acorny`.

## Troubleshooting

If Acorny does not appear in `Export highlights`:

1. Check the folder name is exactly `provider-acorny-highlights.koplugin`.
2. Check that `main.lua` is directly inside that folder, not inside another nested folder.
3. Restart KOReader after copying the folder.
4. Open KOReader's plugin management menu and make sure `Acorny highlight sync` is enabled.
