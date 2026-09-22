# BashBrowser

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Shell-Bash%204%2B-green.svg)](https://www.gnu.org/software/bash/)

A lightweight, terminal-based web browser built entirely in **Bash**. BashBrowser allows you to navigate websites, click hyperlinks, interact with web forms, manage bookmarks and browsing history, and perform web searches directly from your terminal.

---

## ✨ Features

- 🖥️ **Terminal Rendering**: Visualizes web pages with ANSI colors, bold typography for headers, and clear indicators for interactive elements.
- 🔗 **Numbered Link Navigation**: Numbered shortcuts for hyperlinks—type the number of any link on screen to navigate to it immediately.
- 📝 **Form Inputs & Submissions**:
  - Automatically identifies form fields and buttons.
  - Fill fields using `fill <field_id> <value>`.
  - Supports hidden form inputs and CSRF token preservation.
  - Submits forms (`GET` and `POST`) using `press`.
- 🔍 **Integrated Web Search**: Direct queries via DuckDuckGo Lite using `search <keywords>`.
- 🍪 **Session & Cookie Persistence**: Automatic cookie storage across requests in a local cookie jar (`data/cookies.txt`).
- 📚 **Linear History**: Browse back (`b`), forward (`f`), view full history (`h`), or jump directly to a visited index (`h <n>`).
- 🔖 **Persistent Bookmarks**: Save favorite pages (`bm add`), view bookmarks (`bm`), launch by number (`bm <n>`), and remove entries (`bm del <n>`).
- 🌐 **Robust URL Handling**: Resolves absolute, root-relative, scheme-relative, and relative paths (with `.` and `..` directory traversals).

---

## 🏗️ Architecture

BashBrowser follows a modular architecture separating concerns across dedicated shell scripts:

```
BashBrowser/
├── bashBrowser          # Executable entrypoint / launcher
├── init/
│   └── init.sh          # Application loop and terminal UI chrome
├── src/
│   ├── browser_engine.sh # Core state machine, element adapter & dispatch
│   ├── parser.sh         # Regex-based HTML tokenizer & semantic element extractor
│   ├── renderer.sh       # Terminal ANSI display engine
│   ├── network.sh        # HTTP client (curl wrapper with cookie & redirect handling)
│   ├── navigation.sh     # URL normalization, relative-path resolution & encoding
│   ├── input.sh          # Command parser and user input router
│   ├── history.sh        # Stack-based history navigation
│   └── bookmarks.sh      # File-backed bookmark storage
├── tests/               # Test suites and debugging verification scripts
├── data/                # Generated runtime data (cookies, bookmarks)
└── LICENSE              # MIT License
```

---

## 📋 Prerequisites

To run BashBrowser, ensure your environment has the following tools installed:

- **Bash** (version 4.0 or higher)
- **cURL** (`curl` with SSL/TLS support)
- **Perl** (used for fast regex-based HTML parsing)
- **Python 3** (optional, used as an alternative URL-encoding engine)
- Standard POSIX utilities: `grep`, `sed`, `head`, `cat`, `touch`

> **Note for Windows users**: BashBrowser runs seamlessly under [WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/) or Git Bash / MSYS2.

---

## 🚀 Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/HusseinMayla/BashBrowser.git
   cd BashBrowser
   ```

2. **Grant execution permissions**:
   ```bash
   chmod +x bashBrowser init/init.sh
   ```

3. **Launch the browser**:
   ```bash
   # Opens default homepage (https://example.com)
   ./bashBrowser

   # Or open a specific URL directly:
   ./bashBrowser https://news.ycombinator.com
   ```

---

## ⌨️ Command Reference

Enter commands into the prompt bar at the bottom of the interface:

### Navigation
| Command | Shortcut | Description |
| :--- | :--- | :--- |
| `open <url>` | `open <url>` | Navigate to an absolute or domain URL (e.g. `open github.com`) |
| `<n>` | `<n>` | Click link number `<n>` shown in brackets `[n]` |
| `click <n>` | — | Navigate to link number `<n>` |
| `back` | `b` | Return to previous page in history |
| `forward` | `f` | Move forward to next page in history |
| `reload` | `r` | Refresh the current web page |

### Forms & Interactive Elements
| Command | Description |
| :--- | :--- |
| `fill <id> <value>` | Fill an input field identified by its name/ID |
| `press` | Submit the active form using its target action & method |

### Search
| Command | Description |
| :--- | :--- |
| `search <query>` | Search DuckDuckGo Lite for the given query |

### Bookmarks
| Command | Shortcut | Description |
| :--- | :--- | :--- |
| `bm add` | `bookmark add` | Save the current URL as a bookmark |
| `bm` | `bm list` | Display saved bookmarks |
| `bm <n>` | `bookmark <n>` | Navigate directly to bookmark index `<n>` |
| `bm del <n>` | `bookmark del <n>` | Delete bookmark index `<n>` |

### History
| Command | Shortcut | Description |
| :--- | :--- | :--- |
| `history` | `h` | List all visited URLs in the current session |
| `history <n>` | `h <n>` | Jump directly to history entry `<n>` |

### General Controls
| Command | Shortcut | Description |
| :--- | :--- | :--- |
| `help` | `?` | Show in-browser command quick reference |
| `quit` | `q` / `exit` | Exit BashBrowser |

---

## 🧪 Testing

The repository includes automated and manual test scripts under the `tests/` directory:

```bash
# Run integration tests
bash tests/test_integration.sh

# Run backend engine test
bash tests/test_backend.sh

# Run form submission tests
bash tests/test_form_submit.sh
```

---

## 📄 License

This project is open-source and licensed under the [MIT License](LICENSE).
