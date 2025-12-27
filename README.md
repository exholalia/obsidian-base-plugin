# Exholalia's Obsidian Base Plugin

This is a plugin for Obsidian (https://obsidian.md).

## Plugin Setup

Run `perl name.pl` to update the plugin ID, names, and titles across the plugin structure.

Default behaviour is to use the folder name as the plugin ID, but you can override it with `--id <plugin-id>`. You can add a description with `-d <description>`.

## Installation

### BRAT (Recommended)

Until this plugin is made official, it can be installed via BRAT:

1. Install the BRAT plugin from "Community plugins" page.
2. Go to the BRAT settings.
3. Click the `Add beta plugin` button.
4. Add this repository (https://github.com/exholalia/obsidian-base-plugin) as a beta plugin.
5. Select the latest release (or another release, if you wish).
6. Click the `Add plugin` button.
7. Enable the plugin.

### Manually

1. Clone this repo.
2. Make sure your NodeJS is at least v16 (`node --version`).
3. `npm i` or `yarn` to install dependencies.
4. `npm run dev` to start compilation in watch mode.
5. Copy over `main.js`, `styles.css`, `manifest.json` to your vault `VaultFolder/.obsidian/plugins/obsidian-base-plugin/`.
