# Debian + NsCDE Workstation Setup

This is a working plan for turning a separate 1080p Linux box into a modern
terminal workstation with a deliberately old-school CDE interface:

```text
Debian 13 + Xorg
└── NsCDE / FVWM
    ├── Ghostty
    │   └── zsh → tmux → Neovim
    ├── Rofi application launcher
    ├── Picom compositor (terminal transparency only)
    └── Synergy server → MacBook client
```

This box is not intended to run a local LLM. The goal is the normal toolset in
this repository, a keyboard-driven desktop, and a CDE-style interface.

## Important choices

- Use **Debian 13**. Its GTK4 and libadwaita versions are new enough for current
  Ghostty releases.
- Use an **Xorg session**, not Wayland. NsCDE is an X11 environment, and Synergy
  has its most complete Linux support on X11.
- Start with **FVWM 2** (`fvwm` on Debian). NsCDE supports FVWM3 too, but its
  documentation describes FVWM 2.6/2.7 as the conservative choice.
- Keep the desktop and normal GUI applications opaque. Ghostty will request its
  own transparency; Picom merely provides X11 compositing.
- In Synergy terminology, the **server owns the physical keyboard and mouse**.
  The proposed Linux-server/Mac-client arrangement therefore means the keyboard
  and mouse connected to Linux will control both machines.

## 1. Install Debian and the X11 base

Install Debian 13 with a normal user account. A minimal graphical installation
is sufficient; a full GNOME installation is not required.

Install Xorg, a display manager, FVWM, and the main NsCDE dependencies:

```sh
sudo apt update
sudo apt full-upgrade
sudo apt install \
  xorg lightdm fvwm fvwm-icons xinit xterm \
  ksh x11-utils x11-xserver-utils xdotool xclip xsel \
  imagemagick xscreensaver stalonetray xsettingsd dunst \
  python3 python3-yaml python3-pyqt5 python3-xdg \
  qt5ct libstroke0 libfile-mimeinfo-perl \
  rofi picom gkrellm dex \
  git curl wget unzip gettext autoconf automake build-essential \
  libx11-dev libxext-dev libxpm-dev fonts-dejavu-core
```

Package names can change between Debian point releases. If one optional package
is unavailable, remove it from the command, finish installing the remainder,
and check the current [NsCDE installation guide][nscde-install].

## 2. Build and install NsCDE

NsCDE is not currently in the standard Debian repository. Build it from its
upstream repository:

```sh
mkdir -p ~/src
git clone https://github.com/NsCDE/NsCDE.git ~/src/NsCDE
cd ~/src/NsCDE
./configure
make
sudo make install
```

Reboot after installation. At the LightDM login screen, choose the **NsCDE**
session before logging in. If no session entry appears, consult the upstream
instructions for copying its `nscde.desktop` X session file into
`/usr/share/xsessions/`.

The first login runs NsCDE's bootstrap process and creates `~/.NsCDE`. Complete
the Color Style Manager step; several generated resources depend on it. Log out
and back in once after the bootstrap completes.

Useful configuration locations:

```text
~/.NsCDE/NsCDE.conf                 Main per-user settings
~/.NsCDE/NsCDE-Keybindings.local    Personal FVWM key bindings
~/.NsCDE/Picom.conf                 NsCDE's Picom configuration
~/.NsCDE/NsCDE.rasi                 NsCDE's Rofi theme
```

Do not put personal FVWM changes in `~/.fvwm`; NsCDE uses `~/.NsCDE` as its
FVWM user directory.

## 3. Install Ghostty

Ghostty supports X11, but the project does not publish an official Debian
binary. Choose one of the current options from the [Ghostty Linux installation
page][ghostty-install]:

- community Debian package;
- universal AppImage; or
- source build.

Verify that it starts inside NsCDE:

```sh
ghostty +show-config --default >/dev/null
ghostty
```

The repository config uses Hack Nerd Font Mono at 10 points. That should be a
comfortable starting size on a 1920×1080 display.

## 4. Install this terminal environment

Clone this repository on the Linux box if it is not present already:

```sh
mkdir -p ~/src/personal
git clone <repository-url> ~/src/personal/nvim-tmux-iterm2
cd ~/src/personal/nvim-tmux-iterm2
```

Follow the Debian prerequisites in `README.md`. In particular, use
`libwebkit2gtk-4.1-dev` on modern Debian and install a clipboard-enabled Vim if
plain Vim should share the X11 clipboard:

```sh
sudo apt install \
  build-essential zsh git wget curl nodejs ncal unzip xsel \
  vim-gtk3 libwebkit2gtk-4.1-dev
```

Install Linuxbrew, then install the repository's Linux bundle:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew bundle install --file Brewfile.linux
```

Create the per-machine switches before running the setup script:

```sh
cp setup.conf.template setup.conf
```

Edit `setup.conf`. Keep the terminal components enabled. Disable anything not
wanted on this workstation; for example:

```sh
SETUP_GHOSTTY=true
SETUP_WEZTERM=false
SETUP_NVIM=true
SETUP_NVIM_SYNC=true
SETUP_TMUX=true
SETUP_VSCODE=false
```

The AI CLI toggles are independent of local model hosting. They may remain on
if those command-line clients are useful, or be disabled:

```sh
SETUP_CODEX_CLI=false
SETUP_CLAUDE_CODE=false
SETUP_CURSOR_CLI=false
```

Apply the configuration:

```sh
./setup.sh
```

Then start a new Ghostty window. The shell configuration recognizes Ghostty and
automatically creates or attaches to a tmux session.

## 5. Make Ghostty look native in NsCDE

Ghostty is a GTK4 application, so its internal widgets will not perfectly adopt
NsCDE's GTK2/GTK3 CDE theme. Let FVWM draw the outer window decoration instead.
Add these options to `configs/ghostty/config` if they are not already present:

```ini
window-decoration = server
gtk-titlebar = false
```

The repository config is symlinked rather than copied. Editing it changes the
tracked configuration shared by every machine, so commit that choice only if it
is desirable everywhere.

At 1080p, begin with:

```ini
font-family = "Hack Nerd Font Mono"
font-size = 10.0
```

If NsCDE's widgets are incorrectly sized, set its Xft DPI to 96 in
`~/.NsCDE/NsCDE.conf` using the existing `XFT_USE_DPI` example in that file.
NsCDE supports 96, 120, 144, and 192 DPI presets.

## 6. Enable transparency only in Ghostty

Picom is the compositor. It should not impose opacity on applications globally.
Enable Picom in the NsCDE Process Manager, or test it manually:

```sh
picom --config ~/.NsCDE/Picom.conf
```

Keep Picom's base configuration simple:

```conf
backend = "glx";
vsync = true;
```

Do **not** configure these globally:

```conf
# active-opacity
# inactive-opacity
# opacity-rule
```

Ghostty already requests its own opacity in `configs/ghostty/config`:

```ini
background-opacity = 0.9
```

For prolonged editing on a patterned CDE backdrop, `0.94` to `0.96` may be
easier to read. Other applications remain fully opaque because they do not
request an alpha channel and Picom has no opacity rules forcing one.

Blur is optional and is more backend-sensitive than transparency. Establish
stable opacity and tear-free rendering first; add Picom blur later if desired.

If NsCDE's Process Manager says Picom is stopped even though it works when
started manually, this is a [known NsCDE integration issue][nscde-picom-issue].

## 7. Add a GNOME-like keyboard launcher

NsCDE has a built-in command dialog on **Alt+F12**. With Rofi installed, use
Rofi's `drun` mode for a friendlier search over graphical `.desktop` entries:

```sh
rofi -show drun -show-icons -theme ~/.NsCDE/NsCDE.rasi
```

Test that typing `Ghostty` and `Brave` finds their launchers. If an application
does not appear, verify that it installed a `.desktop` file under either
`/usr/share/applications` or `~/.local/share/applications`.

Bind the launcher to **Super+Space** by adding this to
`~/.NsCDE/NsCDE-Keybindings.local`:

```fvwm
Key space A 4 Exec exec rofi -show drun -show-icons -theme "$[FVWM_USERDIR]/NsCDE.rasi"
```

Reload/restart FVWM from the NsCDE workspace menu. The resulting workflow is:

```text
Super+Space → type application name → Enter
```

Using Super+Space is more reliable than binding the bare Super key and leaves
Super available as a modifier for other shortcuts.

For a combined application launcher and window switcher, try:

```sh
rofi -show combi -combi-modes "drun,window" \
  -show-icons -theme ~/.NsCDE/NsCDE.rasi
```

## 8. Install frequently used desktop applications

NsCDE does not restrict ordinary X11 applications. Bitwarden, Discord, Signal,
Brave/Chrome, and Obsidian all provide Linux builds that should run normally.
Most are Electron or Chromium applications, so expect them to function well but
not to inherit the complete CDE widget theme.

Prefer vendor repositories or vendor-provided Debian packages over random
third-party repositories:

| Application | Debian/NsCDE status | Recommended installation |
| --- | --- | --- |
| Bitwarden | Native Linux build | Official `.deb` or Flatpak |
| Discord | Native Linux build | Official `.deb` |
| Signal Desktop | Native Linux build, amd64 only | Official Signal Apt repository |
| Brave | Native Linux build | Official Brave Apt repository |
| Google Chrome | Native Linux build | Official `.deb` |
| Obsidian | Native Linux build | Official `.deb` or AppImage |

### Bitwarden

Download the Linux `.deb` from [Bitwarden's download page][bitwarden-download]
and install it with Apt so dependencies are resolved:

```sh
cd ~/Downloads
sudo apt install ./Bitwarden-*.deb
```

The `.deb` integrates with the application menu and supports browser-extension
integration. Secure storage requires a Secret Service implementation such as
GNOME Keyring; biometric/system-authentication unlock additionally requires a
working polkit agent. Password/PIN unlock works without adding biometric
hardware.

Install the Bitwarden extension in Brave or Chrome separately.

### Discord

Download Discord's Linux `.deb` from the [official download page][discord] and
install it with:

```sh
cd ~/Downloads
sudo apt install ./discord-*.deb
```

Discord supports Debian 11 and newer. Voice, video, notifications, and tray
behavior should work under X11. Stalonetray provides the notification-area host
when Discord exposes a tray icon.

### Signal Desktop

Use Signal's [official Debian repository instructions][signal]. The repository
keeps Signal updated through normal `apt upgrade` operations. Signal Desktop is
available only for amd64/x86-64 Linux and must be linked to Signal on a phone.

The Debian package is preferable to the AppImage here because it installs its
polkit integration and desktop entry automatically.

### Brave or Google Chrome

Use the [official Brave Linux repository][brave] for Brave. It integrates with
Apt and installs a `.desktop` entry that Rofi can discover.

Google publishes an official Debian `.deb` from its [Chrome download
page][chrome]. Installing that package also configures Google's update source.

After installing either browser, set the XDG default browser:

```sh
xdg-settings set default-web-browser brave-browser.desktop
```

For Chrome instead:

```sh
xdg-settings set default-web-browser google-chrome.desktop
```

Confirm the selected browser before relying on Neovim's Peek integration:

```sh
xdg-settings get default-web-browser
xdg-open https://example.com
```

### Obsidian

Obsidian provides an official Linux `.deb`, Snap, and AppImage. Prefer its
official `.deb` on this workstation because it naturally supplies a desktop
entry for Rofi and avoids manual AppImage launcher maintenance. Download it
from the [Obsidian installation page][obsidian] and install it with:

```sh
cd ~/Downloads
sudo apt install ./obsidian_*.deb
```

Place or synchronize the vault under one of the paths already recognized by
this repository's Neovim configuration, such as:

```text
~/Documents/Obsidian
~/Documents/ObsidianVault/ServerNinja
~/Documents/Obsidian-Spirituality/Spirituality
~/Documents/ObsidianVaultSpirituality/Spirituality
```

Obsidian and `obsidian.nvim` can then work against the same local vault. Avoid
opening the same vault for simultaneous writes over a network filesystem; use a
normal synchronization mechanism and keep the working copy local.

### Check Rofi discovery

After installing the applications, refresh the desktop-entry cache and test the
launcher:

```sh
update-desktop-database ~/.local/share/applications 2>/dev/null || true
rofi -show drun -show-icons -theme ~/.NsCDE/NsCDE.rasi
```

Search for Bitwarden, Discord, Signal, Brave or Chrome, and Obsidian. System
`.deb` packages normally install their entries under `/usr/share/applications`,
so no hand-written launchers should be necessary.

## 9. Configure Synergy

Install the current Synergy Linux package from Symless rather than looking for
it in Debian's repositories. Debian 13 and NsCDE provide the X11 environment
that Synergy expects.

For the proposed arrangement:

```text
Linux NsCDE box = Synergy server = physical keyboard and mouse
MacBook          = Synergy client = controlled computer
```

In Synergy:

1. Configure the Linux machine as the server.
2. Add the MacBook screen and place it on the correct edge of the Linux screen.
3. Configure the MacBook as the client and point it at the Linux machine's LAN
   address.
4. Grant Synergy Accessibility and Input Monitoring permissions in macOS.
5. Permit TCP port `24800` through the Linux firewall only on the trusted LAN.
6. Give the Linux box a DHCP reservation or static LAN address.

If the intent changes and the MacBook keyboard/trackpad should control Linux,
reverse the roles: MacBook server, Linux client.

## 10. Validate the finished system

Run these checks from Ghostty:

```sh
echo "$XDG_SESSION_TYPE"       # expected: x11
echo "$TERM_PROGRAM"          # expected: ghostty
echo "$TERM"                  # expected by this repo: xterm-256color
tmux -V
nvim --version
xsel -o --clipboard
pgrep -a picom
```

Then verify behavior:

- Ghostty receives an NsCDE/FVWM title bar.
- Opening Ghostty automatically enters tmux.
- Neovim displays true color and Nerd Font icons correctly.
- Copying from Neovim reaches the X11 clipboard.
- Only Ghostty is transparent.
- Super+Space opens Rofi and launches Ghostty or Brave.
- Rofi finds Bitwarden, Discord, Signal, the browser, and Obsidian.
- Synergy crosses between the Linux display and MacBook in the intended
  direction.

## Troubleshooting notes

### Ghostty is opaque

Confirm Picom is running with `pgrep -a picom`. Run Picom in a terminal without
daemonizing it to see configuration or OpenGL errors.

### Ghostty is transparent but Neovim is not

The terminal emulator owns the transparent window, but a terminal application
can still paint an opaque background. Confirm that the Neovim transparency
plugin is enabled and that the selected colorscheme does not restore opaque
highlight backgrounds afterward.

### Rofi does not find an application

Use `rofi -show run` to test the executable name, then check for its `.desktop`
file. `drun` searches desktop entries; `run` searches `$PATH`.

### Clipboard integration fails

Confirm `xsel` is installed and `$DISPLAY` is set. For plain Vim, verify that
`vim --version` reports `+clipboard`; install `vim-gtk3` if it reports
`-clipboard`.

### Ghostty does not automatically start tmux

Check that `TERM_PROGRAM` is exactly `ghostty`, that tmux is installed, and that
the repository's `~/.zshrc` symlink is active. Do not test from inside an
existing tmux session.

## References

- [NsCDE repository][nscde]
- [NsCDE installation guide][nscde-install]
- [NsCDE FAQ][nscde-faq]
- [Ghostty Linux documentation][ghostty-linux]
- [Ghostty installation options][ghostty-install]
- [Rofi documentation][rofi]
- [Synergy Linux requirements][synergy]
- [Bitwarden Linux desktop support][bitwarden]
- [Discord Linux download][discord]
- [Signal Linux installation][signal]
- [Brave Linux installation][brave]
- [Google Chrome Linux installation][chrome]
- [Obsidian Linux installation][obsidian]

[nscde]: https://github.com/NsCDE/NsCDE
[nscde-install]: https://github.com/NsCDE/NsCDE/blob/master/INSTALL.md
[nscde-faq]: https://github.com/NsCDE/NsCDE/wiki/NsCDE---Frequently-Asked-Questions-%28FAQ%29
[nscde-picom-issue]: https://github.com/NsCDE/NsCDE/issues/185
[ghostty-linux]: https://ghostty.org/docs/linux
[ghostty-install]: https://ghostty.org/docs/install/binary
[rofi]: https://davatorium.github.io/rofi/current/rofi.1/
[synergy]: https://support.symless.com/hc/en-us/articles/33562793892497-Operating-system-and-hardware-requirements
[bitwarden]: https://bitwarden.com/help/desktop-app-feature-support/
[bitwarden-download]: https://bitwarden.com/download/
[discord]: https://discord.com/download
[signal]: https://signal.org/download/
[brave]: https://brave.com/linux/
[chrome]: https://support.google.com/chrome/answer/95346
[obsidian]: https://obsidian.md/help/install
