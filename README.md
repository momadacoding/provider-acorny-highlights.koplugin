# KOReader Acorny Highlight Sync

This plugin adds Acorny as a KOReader highlight export target and can automatically sync new highlights to Acorny when network is available.

## Install

Copy `provider-acorny-highlights.koplugin` into KOReader's `plugins` directory, then restart KOReader.

The final path should look like:

```text
koreader/plugins/provider-acorny-highlights.koplugin
```

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
