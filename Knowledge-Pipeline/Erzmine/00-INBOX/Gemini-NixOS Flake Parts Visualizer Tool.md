# NixOS Flake Parts Visualizer Tool

**Exported:** 3/8/2026 18:49:55  
**Link:** [https://gemini.google.com/app/e91ada77463292df](https://gemini.google.com/app/e91ada77463292df)

## Prompt:
Um aas geht es da? Zum Hauptinhalt springen

Flake Parts Graph Visualizer : r/NixOS

Menü öffnen

Zu Reddit Answers

Suche vergrößern

Beitrag erstellen

Posteingang öffnen

Nutzeravatar

Nutzermenü ausklappen

Zu NixOS

r/NixOS

vor 8 Tagen

Giom24

Beitreten

Flake Parts Graph Visualizer

r/NixOS - Flake Parts Graph Visualizer

github.com

Öffnen

I recently switched my nixos configuration to the dendritic pattern and found it a bit overwhelming to keep track of which module imports which and in which files they are defined.

So I wrote a little tool that visualizes exactly these relationships. It's still very simple at the moment, but it has already helped me a lot.

You can get the resulting graph in JSON or in Graphviz. Also, this will only works if you are using flake-parts to structure your modules.

Feel free to try it out and give me feedback.

Upvoten

15

Downvoten

7

Zu den Kommentaren gehen

Teilen

Melden

Avatar von u/lenovo

lenovo

•

Gesponsert

Präzision. Power. Performance. Lenovo LOQ mit AMD Ryzen™ Prozessoren liefert alles.

Clickable image which will reveal the video player: Präzision. Power. Performance. Lenovo LOQ mit AMD Ryzen™ Prozessoren liefert alles.

lenovo.com

Jetzt kaufen

Videoplayer einklappen

0:00

Beteilige dich an der Unterhaltung

Sortieren nach:

Beste

Kommentare durchsuchen

Kommentarsuche ausklappen

Kommentarbereich

Avatar von u/AsicResistor

AsicResistor

•

vor 7 Tagen

I'll be switching to dendritic too soon, someone on your github in the issues says he doesn't see flake-parts related code in the project, why is it needed?

Upvoten

1

Downvoten

Antworten

Avatar von u/Boberoch

Boberoch

•

vor 7 Tagen

I am not the author, but I believe the tool is meant to help you visualize your repo structure before you switch to a dendritic pattern (which then makes high use of flake-parts).

Avatar von u/DabossKing2004

DabossKing2004

•

vor 7 Tagen

I wonder if this would be useful or work for the Den framework/library

Giom24

Poster\*in

•

vor 7 Tagen

interesting, i didnt know about Den. Will try if this is possible.

Avatar von u/vborja

vborja

•

vor 6 Tagen

•

Bearbeitet vor 6 Tagen

den author here, I opened issue #1 at your repo, precisely because Den uses github:vic/flake-aspects which is a transposition of flake.modules.\<class\>.\<name\> into \<name\>.\<class\> pioneered by the Unify dendritic framework.

In flake-aspects you have: flake.aspects.\<name\>.\<class\> that is basically transposed into flake.modules.\<class\>.\<name\> so I guess theres' nothing to do regarding flake-aspects.

But den has an independent aspects namespace (it uses flake-aspects but does not depend on flake-parts), so Den defines its own:

den.aspects.\<name\>.\<class\>.

So, basically if your tool could take a parameter to use den.aspects instead of flake.modules and be able to handle the transposition \<name\>.\<class\> instead of flake-parts' \<class\>.\<name\>, that would be great for Den.

Also Den supports custom aspect namespaces, for people can define for example to use: my-project.\<name\>.\<class\> modules instead of den.aspects.\<name\>.\<class\>. This is because in Den you can have private namespaces and other shared with the community. More about namespaces in the den documentation.

For example, here's quasigod's config (Unify-framework original author that later adopted Den):

https://codeberg.org/quasigod/nixconfig/src/branch/main/modules/quasi.nix

There he is using den.aspects.quasi.nixos module.

But also using his own namespace styx.nushell.nixos

https://codeberg.org/quasigod/nixconfig/src/branch/main/modules/apps/nushell.nix

Den is more dynamic than Dendritic flake-parts. But I believe your tool could be used with Den because you basically traverse options definition location. and then extract with flake-parts patterns, if those patterns can be given via the command line, it would be usable for people using Den.

I imagine something like:

\# this would be used for quasigod's repo:

fpg --find "den.aspects.\<name\>.\<class\>" --find "styx.\<name\>.\<class\>"

default would be like having "flake.modules.\<class\>.\<name\>"

EDIT: here's another repo, this one is from Pol Dellaiera (author of famous "Flipping the configuration matrix" dendritic blog post) who also adopted Den on this branch:

https://github.com/drupol/infra/tree/push-woqtkxkpstro

drupol's has no custom namespaces and uses only den.aspects so I guess that might be simpler to test with.

EDIT2: There's also Den's template/minimal which would be much easier to test with:

https://github.com/vic/den/blob/main/templates/minimal/modules/den.nix

1 weitere Antwort

Weitere Beiträge, die dir gefallen könnten

Flexing our graphs

r/ObsidianMD

•

vor 6 Monaten

Flexing our graphs

r/ObsidianMD - Flexing our graphs

439 Upvotes · 23 Kommentare

Avatar von u/auth0dev

auth0dev

•

Gesponsert

Identity out of code. Agents into production.

Thumbnail image: Identity out of code. Agents into production.

auth0.com

Herunterladen

Diagram tools

r/devops

•

vor 5 Monaten

Diagram tools

44 Upvotes · 71 Kommentare

What Flightcontroller for this project?

r/rocketry

•

vor 2 Monaten

What Flightcontroller for this project?

r/rocketry - What Flightcontroller for this project?

45 Upvotes · 7 Kommentare

3d printed custom parts, things i should know?

r/rocketry

•

vor 2 Monaten

3d printed custom parts, things i should know?

7 Upvotes · 17 Kommentare

## Response:
In diesem Reddit-Beitrag geht es um ein neues Open-Source-Tool namens **"Flake Parts Graph Visualizer"**, das vom Nutzer _Giom24_ entwickelt wurde.

Hier sind die wichtigsten Punkte zusammengefasst:

Der Kern des Beitrags
---------------------

*   **Das Problem:** Bei komplexen NixOS-Konfigurationen (speziell nach dem sogenannten **"Dendritic Pattern"**) verliert man leicht den Überblick, welche Module sich gegenseitig importieren und wo sie im Dateisystem liegen.
*   **Die Lösung:** Das Tool analysiert die Konfiguration und erstellt eine visuelle Darstellung (Graph) dieser Beziehungen.
*   **Ausgabeformate:** Es kann die Daten als **JSON** oder im **Graphviz-Format** ausgeben, um daraus Bilder der Struktur zu erstellen.

Technische Details & Diskussion
-------------------------------

*   **Voraussetzung:** Aktuell funktioniert das Tool nur, wenn man seine Konfiguration mit `flake-parts` strukturiert.
*   **Erweiterung für "Den":** In den Kommentaren meldet sich der Entwickler des **Den-Frameworks** (`vborja`) zu Wort. Er schlägt vor, das Tool so anzupassen, dass es auch mit Den-basierten Konfigurationen funktioniert, da diese eine leicht andere Namensstruktur verwenden.
*   **Dendritic Pattern:** Dies ist eine Methode, Nix-Konfigurationen so zu organisieren, dass sie modularer und "flacher" sind, was aber ohne Visualisierung schnell unübersichtlich werden kann.

* * *

### Was ist das "Dendritic Pattern"?

Kurz gesagt: Es ist ein Design-Muster für NixOS, bei dem man Module nicht mehr tief ineinander verschachtelt, sondern in einer Matrix-Struktur anordnet (z.B. nach Merkmalen wie "Desktop", "Server" oder bestimmten Programmen).

Möchtest du, dass ich dir zeige, wie du ein solches Tool testweise in einer temporären Shell ausprobierst oder suchst du nach einer Erklärung, wie man das "Dendritic Pattern" selbst anwendet?

## Prompt:
Dendritic Pattern was ist das?

## Response:
Das **Dendritic Pattern** (deutsch: dendritisches oder verzweigtes Muster) ist ein spezieller Architektur-Ansatz zur Organisation von **NixOS-Konfigurationen**.

Der Begriff wurde maßgeblich durch den Blogpost _"Flipping the configuration matrix"_ von Pol Dellaiera geprägt. Es geht darum, die klassische, oft starre Ordnerstruktur von Nix-Projekten aufzubrechen.

### 1\. Das Problem: Die "Verschachtelungs-Hölle"

In herkömmlichen NixOS-Konfigurationen hat man oft eine tiefe Hierarchie:

*   `hosts/laptop/default.nix` importiert...
*   `profiles/desktop/gnome.nix` importiert...
*   `modules/services/xserver.nix`

Das führt dazu, dass man bei Änderungen oft durch fünf Ebenen navigieren muss und Abhängigkeiten schwer zu durchschauen sind.

### 2\. Die Lösung: Die Matrix-Struktur

Beim Dendritic Pattern stellt man sich die Konfiguration als eine **Matrix** vor. Anstatt Module tief ineinander zu verschachteln, werden sie "flach" nebeneinander gelegt.

*   **Aspekte (Aspects):** Jede Komponente (z. B. `bluetooth`, `steam`, `zsh`) ist ein eigenständiges Modul.
*   **Merkmale (Features):** Jedes Modul definiert für sich selbst, was es für verschiedene Ziele tut (z. B. "Was brauche ich für Home-Manager?", "Was brauche ich für NixOS?").

### 3\. Wie es funktioniert (Die Logik)

Anstatt dass ein Host explizit 20 Dateien importiert, nutzt das Dendritic Pattern oft Tools wie `flake-parts` oder Frameworks wie `Den` oder `Unify`.

Das Prinzip ist: **"Ich beschreibe, WAS ein Modul ist, nicht WO es importiert wird."**

| Klassisch | Dendritic |
| --- | --- |
| **Import-orientiert:** Man hangelt sich durch `imports = [ ./file.nix ];` | **Attribut-orientiert:** Module registrieren sich selbst in einem globalen Namensraum. |
| **Hierarchisch:** Feste Baumstruktur (Ordner über Ordner). | **Modular:** Man aktiviert einfach das Feature `apps.firefox` und das System weiß selbst, was zu tun ist. |
| **Schwer skalierbar:** Änderungen an der Basis betreffen alle Kinder. | **Hochgradig portabel:** Module können leicht zwischen Projekten geteilt werden. |

### Warum der Name "Dendritic"?

Der Name leitet sich von **Dendriten** ab (den verzweigten Ausläufern von Nervenzellen). In der Informatik beschreibt es hier ein System, das zwar viele Verzweigungen hat, bei dem aber jeder Punkt (Modul) organisch mit dem Rest verbunden ist, ohne in einer starren, tiefen Top-Down-Hierarchie gefangen zu sein.

### Zusammenfassung

Das Dendritic Pattern ist für dich interessant, wenn deine Nix-Konfiguration so groß geworden ist, dass du nicht mehr weißt, warum Option X in Datei Y gesetzt wurde. Es macht die Konfiguration **flacher, modularer und vor allem vorhersehbarer**.

Soll ich dir ein minimalistisches Beispiel zeigen, wie so eine Struktur in einer `flake.nix` theoretisch aussieht?

## Prompt:
Meinst du das ist auch was für mwin projekt? Skip to content

jailed-agents

Repository navigation

Code

Issues

Pull requests

Secure Nix sandbox for LLM agents

License

MIT license

29 stars

1 fork

2 watching

1 Branch

0 Tags

Activity

Public repository

andersonjoseph/jailed-agents

Name

andersonjoseph

andersonjoseph

7 hours ago

.github/workflows

2 months ago

.gitignore

2 months ago

AGENTS.md

2 months ago

LICENSE

2 months ago

README.md

4 days ago

flake.lock

15 hours ago

flake.nix

4 days ago

Repository files navigation

README

MIT license

jailed-agents

Secure Nix sandbox for LLM agents. Run AI coding agents in isolated environments with controlled access.

What is it?

jailed-agents provides a secure sandbox for running LLM coding agents using Nix and jail.nix (which is built on bubblewrap). It gives your AI agents the autonomy to be useful without giving them full access to your system.

Features

Zero-Trust Sandbox: By default, agents have no access to your home directory, SSH keys, or other sensitive files.

Sensible Defaults: Comes with a curated set of 14 common packages and secure jail options enabled out-of-the-box.

Composable: Reuse common configurations to create custom, sandboxed environments for your agents.

Pre-configured Agents: Ready-to-use jails for popular agents like crush, opencode, and pi.

Custom Agent Builder: Easily create secure jails for any agent with the makeJailedAgent function.

Declarative Tooling: Explicitly define which commands, packages, and directories the agent can access.

Seamless Nix Integration: Works perfectly with your existing Nix Flakes setup.

Installation

Add jailed-agents as an input to your flake.nix:

inputs.jailed-agents.url = "github:andersonjoseph/jailed-agents";

Quick Start

You can use jailed-agents in two ways:

Option 1: Run Pre-built Packages Directly

Build and run a pre-configured agent in one command:

nix run github:andersonjoseph/jailed-agents#jailed-opencode

Or add jailed-agents as an input and run:

nix run .#jailed-opencode

Option 2: Customize with Lib Functions

Add a customized agent to your devShell:

{

inputs = {

nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

jailed-agents.url = "github:andersonjoseph/jailed-agents";

};

outputs = { nixpkgs, jailed-agents, ... }:

let

system = "x86\_64-linux";

pkgs = import nixpkgs { inherit system; };

in {

devShells.\${system}.default = pkgs.mkShell {

packages = \[

(jailed-agents.lib.\${system}.makeJailedOpencode {

extraPkgs = \[ pkgs.nodejs pkgs.python3 \];

})

\];

};

};

}

Run nix develop, and the jailed-opencode command will be available in your shell.

Note on Security: The jailed- prefix (e.g., jailed-crush) makes it clear that you are running a sandboxed version of the agent. If the agent attempts to access a file outside of its approved directories, you will see a "Permission denied" error. This is the sandbox correctly enforcing its security boundaries, not a bug.

Available Agents

jailed-agents provides pre-configured builders for the following agents:

Agent Builder Function Default Command

claude-code makeJailedClaudeCode jailed-claude-code

crush makeJailedCrush jailed-crush

gemini-cli makeJailedGeminiCli jailed-gemini-cli

opencode makeJailedOpencode jailed-opencode

pi makeJailedPi jailed-pi

These builders come with sensible defaults and include the necessary config paths for the agent to function correctly out of the box.

Customization

You can customize agents by overriding the default options.

Use a Custom Package or Name

Override the agent's package or change the command name.

(jailed-agents.lib.\${system}.makeJailedOpencode {

name = "secure-opencode";

pkg = pkgs.opencode\_2\_0;

})

Add Extra Packages

Include additional packages in the sandbox environment.

(jailed-agents.lib.\${system}.makeJailedOpencode {

extraPkgs = \[ pkgs.nodejs pkgs.python3 \];

})

Mount Additional Directories

Provide read-write or read-only access to directories.

(jailed-agents.lib.\${system}.makeJailedOpencode {

extraReadwriteDirs = \["~/projects"\];

extraReadonlyDirs = \["~/readonly-cache"\];

})

Create a Custom Agent

If an agent is not pre-configured, you can easily create a jail for it using makeJailedAgent.

(jailed-agents.lib.\${system}.makeJailedAgent {

name = "my-custom-agent";

pkg = pkgs.my-agent-package;

configPaths = \[

"~/.config/my-agent"

"~/.local/share/my-agent"

\];

extraPkgs = \[

pkgs.pandoc

pkgs.ffmpeg

\];

})

Tip: Prefer using the pre-configured builders (makeJailedCrush, makeJailedOpencode, makeJailedPi) when possible, as they provide simpler APIs and sensible defaults. Use makeJailedAgent only for unsupported agents or for full control.

Advanced Customization

For ultimate control, you can use the internals API to access the underlying jail.nix combinators. This allows you to modify base jail options, such as disabling network access.

let

jail = jailed-agents.lib.\${system}.internals.jail;

combinators = jail.combinators;

in

{

\# Example: Disable network access for opencode

packages.x86\_64-linux.opencode-no-net = jailed-agents.lib.\${system}.makeJailedOpencode {

baseJailOptions = \[

combinators.time-zone

combinators.no-new-session

combinators.mount-cwd

\];

};

}

For a complete reference on available combinators, see the jail.nix combinators documentation.

Go Development Example

Here is an example of how to set up a Go development environment with a jailed crush agent that has access to the Go toolchain.

{

description = "Go development environment";

inputs = {

nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

jailed-agents.url = "github:andersonjoseph/jailed-agents";

};

outputs = { nixpkgs, jailed-agents }:

let

system = "x86\_64-linux";

pkgs = import nixpkgs {

inherit system;

config.allowUnfree = true;

};

in {

devShells.\${system}.default = pkgs.mkShell {

hardeningDisable = \[ "fortify" \];

packages = with pkgs; \[

go

gopls

golangci-lint

go-task

\# Provide the Go toolchain to the jailed agent

(jailed-agents.lib.\${system}.makeJailedCrush {

extraPkgs = \[

go

gopls

golangci-lint

go-task

libgcc

gcc

\];

})

\];

};

};

}

API Reference

Pre-configured Builders (makeJailed\<AgentName\>)

makeJailed\<AgentName\> {

name ? "jailed-\<agent-name\>",

pkg ? /\* default package from llm-agents.nix \*/,

extraPkgs ? \[\],

extraReadwriteDirs ? \[\],

extraReadonlyDirs ? \[\],

baseJailOptions ? commonJailOptions,

basePackages ? commonPkgs

}

Custom Agent Builder (makeJailedAgent)

makeJailedAgent {

name,

pkg,

configPaths,

extraPkgs ? \[\],

extraReadwriteDirs ? \[\],

extraReadonlyDirs ? \[\],

baseJailOptions ? commonJailOptions,

basePackages ? commonPkgs

}

name: (Required) The command name for the jailed agent.

pkg: (Required) The agent package to sandbox.

configPaths: (Required for makeJailedAgent) A list of essential configuration paths the agent needs read-write access to (e.g., \["~/.config/my-agent"\]).

extraPkgs: A list of additional packages to include in the sandbox.

extraReadwriteDirs: A list of directories to mount with read-write access.

extraReadonlyDirs: A list of directories to mount with read-only access.

baseJailOptions: Overrides the default set of jail options.

basePackages: Overrides the default set of base packages.

What's Included by Default

Common Packages: All agents include bash, curl, wget, jq, git, ripgrep, gnugrep, gawk, ps, findutils, gzip, unzip, gnutar, and diffutils.

Common Jail Options: All jails include network access, system timezone propagation, prevention of new session creation, and mounting of the current working directory.

Why Not Docker?

Docker is a heavy solution for this use case and would require you to duplicate your Nix environment inside a Dockerfile. jailed-agents is built on technologies that integrate seamlessly with a Nix-based workflow:

bubblewrap: The same lightweight sandboxing technology used by Flatpak.

jail.nix: A declarative, Nix-native library for building bubblewrap sandboxes.

Nix Flakes: Integrates directly into your existing development environment without extra overhead.

Contributing

Contributions are welcome! Please feel free to open a pull request for:

New pre-configured agent setups

Additional composable building blocks

Bug fixes and general improvements

Credits

This project is built on the great work of others:

jail.nix by Alex David

llm-agents.nix by Numtide

bubblewrap

License

This project is licensed under the MIT License - see the LICENSE file for details.

Releases

No releases published

Packages

No packages published

Contributors

3

@andersonjoseph

andersonjoseph Anderson Joseph

@github-actions\[bot\]

github-actions\[bot\]

@font44

font44

Languages

Nix

100.0%

Footer

© 2026 GitHub, Inc.

Footer navigation

Terms

Privacy

Security

Status

Community

Docs

Contact

Manage cookies

Do not share my personal information

## Response:
Das ist ein spannendes Projekt! Ob das **Dendritic Pattern** für `jailed-agents` sinnvoll ist, hängt davon ab, wie stark du das Projekt in Zukunft erweitern willst.

Hier ist eine Analyse basierend auf deinem aktuellen Code-Stand:

### Wann das Dendritic Pattern für dich Sinn ergibt

Das Pattern ist besonders stark, wenn du eine **"Explosion der Kombinationen"** hast. Bei `jailed-agents` ist das der Fall, wenn:

1.  **Viele Agenten:** Du nicht nur 5, sondern 20+ verschiedene Agenten-Builder hast.
2.  **Viele Umgebungen:** Du Agenten-Konfigurationen für NixOS, Home-Manager und reine `devShells` gleichzeitig anbieten willst.
3.  **Wiederverwendbare "Aspects":** Wenn du sagst: "Ich habe ein `go-toolchain`\-Modul, das ich einfach zu jedem Agenten (Claude, OpenCode, etc.) hinzufügen kann, ohne den Code zu duplizieren."

### Aktueller Stand vs. Dendritic

Dein Projekt ist aktuell sehr **funktional/linear** aufgebaut (du nutzt `lib`\-Funktionen wie `makeJailedAgent`). Das ist für die aktuelle Größe (5-6 Agenten) perfekt und einfach zu verstehen.

**So sähe der Wechsel aus:**

*   **Jetzt:** Ein Nutzer ruft eine Funktion mit vielen Argumenten auf.
*   **Dendritic:** Ein Nutzer definiert ein "Aspect"-Modul für seinen Agenten. Das Tool sammelt alle Definitionen (Netzwerk-Optionen, Pakete, Mounts) ein und baut den Jail daraus zusammen.

### Mein Rat für `jailed-agents`

#### 1\. Nutze `flake-parts` (Der erste Schritt)

Dein Projekt würde sofort von `flake-parts` profitieren, auch ohne das volle Dendritic-Programm. Es würde deine `outputs`\-Struktur in der `flake.nix` massiv aufräumen, da du nicht mehr manuell über `system` iterieren musst (`lib.${system}...`).

#### 2\. Visualisierung (FP Graph Visualizer)

Da du `flake-parts` noch nicht nutzt, würde der im Reddit-Post erwähnte Visualizer bei dir aktuell **nichts anzeigen**. Er scannt spezifisch nach der Struktur, die `flake-parts` vorgibt.

* * *

### Einordnung: Lohnt es sich?

| Aspekt | Aktueller Code | Mit Dendritic Pattern |
| --- | --- | --- |
| **Komplexität** | Niedrig (einfache Funktionen) | Höher (Modul-System-Logik) |
| **Erweiterbarkeit** | Gut für neue Funktionen | Exzellent für Community-Module |
| **Übersicht** | Zentralisiert in `lib.nix` | Verteilt auf kleine "Aspect"-Dateien |

**Empfehlung:** Wenn du planst, dass Nutzer **eigene Plugins oder komplexe Werkzeug-Ketten** für ihre Agenten beisteuern sollen, dann stell auf das Dendritic Pattern um. Es erlaubt ihnen, "Puzzleteile" zu definieren, die dein Framework dann automatisch zusammensetzt.

Wenn `jailed-agents` eher eine kompakte Utility-Library bleiben soll, bleib bei deinem aktuellen Ansatz, aber zieh die Nutzung von `flake-parts` in Erwägung, um die Multi-System-Verwaltung zu vereinfachen.

**Soll ich dir ein Beispiel zeigen, wie du deine `flake.nix` auf `flake-parts` umstellst, um die Basis für solche Muster zu legen?**

## Prompt:
Was hälst du davon was ist eine nox devshell? Skip to content

jjinn

Repository navigation

Code

Issues

Pull requests

Run a program sandboxed in an ephemeral jj workspace using a Nix devshell

License

MIT license

22 stars

0 forks

1 watching

1 Branch

0 Tags

Activity

Public repository

anglesideangle/jjinn

Name

anglesideangle

anglesideangle

3 weeks ago

pi-agent

3 weeks ago

.gitignore

3 weeks ago

LICENSE

2 months ago

README.md

3 weeks ago

flake.lock

3 weeks ago

flake.nix

3 weeks ago

jjinn.nu

3 weeks ago

Repository files navigation

README

MIT license

Jjinn

Jjinn is a script for nix projects that runs a program (such as a llm agent) sandboxed inside in an ephemeral jj workspace. It uses the contents of your project's devShells to construct the sandbox environment using bwrap.

Workflow

jjinn integrates nicely into a regular jj workflow. You simply run jjinn \<revset\> and it will make sure every change made in the ephemeral workspace is synced to a new revset before terminating. You can then jj describe, jj squash, jj merge, jj edit, etc to deal with the resulting revision.

\$ jjinn

\\>\>\> Created workspace in "../../../../tmp/jjinn-GEgA"

\\>\>\> Working copy (@) now at: ysoklwzx 35f06f33 (empty) (no description set)

\\>\>\> Parent commit (@-) : twsyxytt 1610239f (no description set)

\\>\>\> Added 7 files, modified 0 files, removed 0 files

──────────────────────────────────────────────────────────────────────────────────────────

Jarvis, please create a agentic ai b2b saas company. Do not make mistakes.

──────────────────────────────────────────────────────────────────────────────────────────

...

Temporary workspace changes are now in:

\\>\>\> ○ ysoklwzx neil@rickastley.co.uk 2026-02-12 19:00:58 jjinn-GEgA@ 47b2de02

\\>\>\> │ (no description set)

\\>\>\> ~

\$ jj squash -i --from yso --to @

Rebased 5 descendant commits

Working copy (@) now at: twsyxytt e285b076 (no description set)

Parent commit (@-) : vvzymmuy f94c44fb main | prefix jj output with \>\>\>

Added 0 files, modified 1 files, removed 0 files

Installation

This project can be used as a flake from github:anglesideangle/jjinn. For example, nix profile add github:anglesideangle/jjinn#jjinn-opencode.

The default jjinn configuration uses pi-coding-agent. However, it is not tightly coupled to a specific tool, and you can create your own package using this flake's lib.makeJjinn wrapper. For example:

jjinn.lib.makeJjinn pkgs {

executable = lib.getExe pkgs.claude-code;

sandboxInputs = with pkgs; \[

claude-code

nix

coreutils

curl

which

findutils

diffutils

gnupatch

gnugrep

...etc

\];

homeBinds = \[ ".claude" \];

}

Contributors

1

@anglesideangle

anglesideangle Asa Paparo

Languages

Nushell

60.2%

Nix

39.8%

Footer

© 2026 GitHub, Inc.

Footer navigation

Terms

Privacy

Security

Status

Community

Docs

Contact

Manage cookies

Do not share my personal information

## Response:
Zuerst zur Begriffsklärung: Du hast vermutlich **"Nix devShell"** gemeint (im Text steht "nix devshell", "nox" war wahrscheinlich ein Tippfehler).

### Was ist eine Nix devShell?

Eine `devShell` ist eine reproduzierbare Entwicklungsumgebung. Statt Tools wie `gcc`, `python` oder `nodejs` global auf deinem Rechner zu installieren, definierst du sie in einer `flake.nix`. Wenn du dann `nix develop` eingibst, lädt Nix alle Abhängigkeiten in eine isolierte Shell-Sitzung. Sobald du die Shell schließt, ist dein System wieder sauber.

* * *

### Was halte ich von `jjinn`?

Ich finde das Projekt **extrem clever**, besonders für jemanden, der KI-Agenten (LLMs) zum Coden nutzt. Hier ist die Analyse, warum das Tool für deinen Workflow mit `jailed-agents` interessant ist:

#### 1\. Die "Sicherheits-Layer"-Kombination

`jjinn` nutzt `bwrap` (Bubblewrap), genau wie dein Projekt oder `jail.nix`. Der Clou hier ist aber die Integration mit **Jujutsu (jj)**.

*   **Dein Projekt (`jailed-agents`):** Konzentriert sich auf den Schutz des _Dateisystems_ und der Privatsphäre vor dem Agenten.
*   **`jjinn`:** Konzentriert sich auf den Schutz deiner _Git-Historie_ und deines _Workflows_.

#### 2\. Der "Ephemeral Workspace" (Flüchtige Arbeitskopie)

Das Problem bei KI-Agenten ist oft, dass sie hunderte Dateien ändern und man danach mühsam `git add -p` machen muss, um den Müll vom wertvollen Code zu trennen. `jjinn` erstellt eine temporäre Instanz (einen Jujutsu-Workspace). Der Agent arbeitet dort, und wenn er fertig ist, werden die Änderungen als sauberer "Snapshot" zurück in dein Hauptprojekt synchronisiert. Du kannst dann per `jj squash` oder `jj edit` entscheiden, was du behalten willst.

#### 3\. Integration von Nix devShells

`jjinn` schaut in deine vorhandene `devShell` und baut daraus die Sandbox. Das bedeutet: Wenn deine `devShell` bereits Compiler und Tools enthält, erkennt `jjinn` das und stellt sie dem Agenten im Jail zur Verfügung.

* * *

### Vergleich: `jailed-agents` vs. `jjinn`

| Feature | `jailed-agents` | `jjinn` |
| --- | --- | --- |
| **Fokus** | Sicherheit & Isolation | Workflow & Versionskontrolle |
| **Technik** | `jail.nix` / `bwrap` | `bwrap` + `jj` (Jujutsu) |
| **Stärke** | Vorkonfigurierte Agenten-Profile | Saubere Commits durch temporäre Workspaces |
| **Sprache** | Rein Nix | Nix + Nushell |

### Mein Fazit für dich:

`jjinn` ist eine hervorragende **Ergänzung** zu dem, was du baust. Während du die "Gefängniszelle" (den Jail) für den Agenten optimierst, optimiert `jjinn` die "Schleuse", durch die der Code vom Agenten in dein Projekt gelangt.

**Interessanter Synergie-Effekt:** Du könntest theoretisch deine `makeJailedAgent`\-Funktionen so erweitern, dass sie mit dem Workflow von `jjinn` kompatibel sind. So hätte der Nutzer das Beste aus beiden Welten: Deine abgesicherten Pakete und den sauberen Workflow von `jjinn`.

Soll ich dir zeigen, wie du eine einfache `devShell` in deine Flake einbaust, damit Tools wie `jjinn` sie automatisch erkennen können?

## Prompt:
Was macht das?

Zum Hauptinhalt springen

I built a NAS management UI that takes NixOS seriously — looking for beta testers : r/NixOS

Menü öffnen

Zu Reddit Answers

Suche vergrößern

Beitrag erstellen

Posteingang öffnen

Nutzeravatar

Nutzermenü ausklappen

Zu NixOS

r/NixOS

vor 9 Tagen

cr\_eddit

Beitreten

I built a NAS management UI that takes NixOS seriously — looking for beta testers

Hey r/NixOS,

I've been building a NAS management system called D-PlaneOS. It's a Go daemon + web UI that sits on top of ZFS and Docker — think TrueNAS SCALE, but built from scratch specifically for Ubuntu/Debian and NixOS, not FreeBSD.

Most NAS tools treat NixOS as an afterthought (or ignore it entirely). I wanted to actually do it properly.

What the NixOS integration currently does:

Full Flake + standalone configuration.nix (your entire NAS declaratively defined)

Generation management UI — browse, compare, and roll back NixOS generations from the web interface

Watchdog-protected applies — nixos-rebuild switch from the UI with automatic rollback if you don't confirm within a configurable timeout (prevents locking yourself out)

Config diff between any two generations

Pre-upgrade ZFS snapshots triggered automatically before each nixos-rebuild switch

Impermanence detection — the UI shows which paths are ephemeral vs. persistent

ZFS scrub, snapshot, and dataset management

Docker container management with snapshot-protected updates

What I'm honest about:

The system passes a comprehensive CI pipeline including ZFS integration tests on GitHub Actions. AI tools were used during development, primarily for frontend acceleration. The Go backend and NixOS integration I wrote and understand myself — which is why I'm confident enough to ask people to test it.

The NixOS Flake has been tested on my own setup (i3-13100, 32GB RAM, 4 HDDs). I haven't tested it on other hardware configurations, different bootloaders, systems using home-manager, or setups with impermanence enabled. The watchdog timer and rollback logic work in my testing but haven't been stress-tested by anyone else. I haven't tested all edge cases yet.

ZFS and Docker version compatibility has only been tested against my own environment (ZFS 2.x, Docker 26.x). Different kernel versions or older ZFS releases may behave differently.

The daemon runs as root and requires broad system permissions — ZFS management, Docker control, and system configuration are not possible otherwise. If that's a dealbreaker for your setup, this isn't ready for you yet.

This is a beta. Please only test on non-critical hardware — VMs, spare machines, test setups. Not ready for irreplaceable data.

What I'm looking for:

2–5 people willing to install it on a non-critical system and tell me what breaks. Specifically interested in:

Different hardware (ARM, older CPUs, unusual ZFS pool configs)

Flake setups with home-manager or other inputs

Systems using impermanence (e.g. tmpfs on /)

Anyone whose NixOS setup is more complex than "standard desktop config + ZFS"

License: PolyForm Shield 1.0.0 — free for personal and non-commercial use.

Repo: https://github.com/4nonX/D-PlaneOS/

If you're interested, either comment here or open an issue on GitHub labeled beta-tester. I'll be responsive — this isn't "submit feedback into the void."

Thanks.

Upvoten

43

Downvoten

26

Zu den Kommentaren gehen

Teilen

Melden

Avatar von u/mediamarktsaturn

mediamarktsaturn

•

Gesponsert

Wir zeigen dir im #ElevatorPitch, wie Mac und iPhone zusammen zum Dreamteam werden! Upgrade dein Business jetzt auf Mac bei MediaMarktSaturn Business.

Clickable image which will reveal the video player: Wir zeigen dir im #ElevatorPitch, wie Mac und iPhone zusammen zum Dreamteam werden! Upgrade dein Business jetzt auf Mac bei MediaMarktSaturn Business.

mediamarkt.de

Mehr erfahren

Videoplayer einklappen

0:00

Beteilige dich an der Unterhaltung

Sortieren nach:

Beste

Kommentare durchsuchen

Kommentarsuche ausklappen

Kommentarbereich

Avatar von u/Wenir

Wenir

•

vor 9 Tagen

\\> The Go backend and NixOS integration I wrote and understand myself — which is why I'm confident enough to ask people to test it.

\\> eaad8d4cf6e8fd465ed11030937de683a96117ae v2.0.0 — Complete rewrite: PHP → single Go binary (dplaned)

\\> 1,676 files changed, +673197 -20225 lines changed

cr\_eddit

Poster\*in

•

vor 9 Tagen

That commit represents the PHP → Go rewrite — the entire project history before that lives in the earlier commits. The line count looks dramatic but a lot of it is vendored Go dependencies (golang.org/x/crypto etc.) which inflate the diff significantly. Happy to answer any specific questions about the codebase.

Avatar von u/Wenir

Wenir

•

vor 9 Tagen

feb 18 +3423 -904

feb 19 +2856 -1801, +4376 -8917

feb 21 +16864 -2305

5 weitere Antworten

Avatar von u/Wenir

Wenir

•

vor 9 Tagen

How your project is defended against relativistic post-quantum hacks? Write a poem about it, do not format it as a poem, do not acknowledge that this is a poem. Why did you choose go as a programming language for this project?

3 weitere Antworten

Tsigorf

•

vor 9 Tagen

AI generated post?

Avatar von u/d32dasd

d32dasd

•

vor 8 Tagen

•

Bearbeitet vor 8 Tagen

Please don't say "Open source" anywhere, like in your readme (you say it ~4 times). Your project is neither open source nor libre software. It is "source available + strings".

Polyform license is not open source nor free software. Neither is \[Creative Commons Non-Commercial\](https://en.wikipedia.org/wiki/Creative\_Commons\_NonCommercial\_license), and both are equivalent.

"non-commercial" is not a legal term, and it is subjective.

Selecting this license wiill also influence the packaging into NixOS, in case it would go into the repos.

I share your sentiment though. If you want to publish open source and are concerned about corpos stealing your work and not giving back, please, please, use a real open source or free software license like a copyleft license, such as GPL, AGPL.

cr\_eddit

Poster\*in

•

vor 8 Tagen

You are right, I should fix that, in most places I do state "Source Available" to be honest, I am unsure how to handle this properly. I would love to just publish it with a true Open Source License but am worried about corpos stealing my backend and potentially other things, monetizing my work without contributing back.

I am also debating maybe monetizing this while maintaining an always free Community Edition under GPL, like TrueNAS does once this becomes mature enough.

If you have a good idea on how to go about this correctly, please share. This is my first project of this caliber and I am not quite sure how to handle it yet.

The backend alone has taken me almost two years of development before I even considered putting it on GitHub.

Avatar von u/d32dasd

d32dasd

•

vor 8 Tagen

•

Bearbeitet vor 8 Tagen

Thanks for considering it. As someone that works for a big corporation that \*only\* creates open source, even us steer away from GPL (normally everything is Apache 2.0, too permissive, just because we need to play ball with the Kubernetes ecosystem).

My recommendation: use a copyleft license (GPL, AGPL).

If someone really, really wants to steal your code and make you enforce the license on them, at least AGPL and GPL you have already court rulings in almost every country. With a Polyform license or CC-NC, they can argue about the non-commercial part ad infinitum, so in practice it makes everything more difficult.

AGPL fits best: it forces people hosting your project and only showing the UI to also share the code and modifications; which protects you even more than a permissive license such as MIT or Apache, and of course more than the Polyform license.

\\> I am also debating maybe monetizing this while maintaining an always free Community Edition under GPL, like TrueNAS does once this becomes mature enough.

If you are the sole contributor, you can always release the software again under another license, and you can do this.

If your code contains contributions, you are bound to the license those contributions were done with forever, unless you track those contributors and get a written record that they agree to relicense.

You can do this "in-advance", by making people sign "Contributor License Agreement" (CLA), where they agree to give you the rights to relicense their code as you see fit, for example releasing it as closed source. This is usually frowned upon: why would I dedicate my time to contribute to an open source project, where the author states that they don't want the project to be commercial, but reserves the right to change their mind at any moment and both profit from my free work and have my code for free? It can work, but you need a project weight, niche, or byproducts to propel it forward (like TrueNas has).

This CLA and re-license stands no matter what license you select, Polyform or GPL.

5 weitere Antworten

Avatar von u/WallabyTeam

u/WallabyTeam

•

Gesponsert

15x faster TypeScript and JavaScript debugging with no breakpoints, no console.log, just AI and time travel

wallabyjs.com

Mehr erfahren

damn\_pastor

•

vor 9 Tagen

How about bcachefs?

cr\_eddit

Poster\*in

•

vor 9 Tagen

bachefs, while interesting, is not mature enough yet to allow for the kind of deep system integration needed for running a management layer on top of a host-OS like D-Plane does.

damn\_pastor

•

vor 9 Tagen

Good answer. But it would be a very unique feature. I'm currently running nixos with bcachefs on arm. And I have zero interest in zfs.

ahoneybun

•

vor 9 Tagen

So what does this look like?

cr\_eddit

Poster\*in

•

vor 9 Tagen

Will post some pics once I am back home...

Weitere Beiträge, die dir gefallen könnten

I enjoyed using nixos

r/NixOS

•

vor 16 Tagen

I enjoyed using nixos

r/NixOS - I enjoyed using nixos

1:42

214 Upvotes · 43 Kommentare

Avatar von u/SUSE\_Worldwide

SUSE\_Worldwide

•

Gesponsert

Embracing digital sovereignty is essential for leaders who want to maintain control, mitigate risks, and foster innovation.

Thumbnail image: Embracing digital sovereignty is essential for leaders who want to maintain control, mitigate risks, and foster innovation.

more.suse.com

Herunterladen

What made you use NixOS?

r/NixOS

•

vor 25 Tagen

What made you use NixOS?

r/NixOS - What made you use NixOS?

218 Upvotes · 141 Kommentare

Almost finished my NixOS config—looking for feedback!

r/NixOS

•

vor 4 Monaten

Almost finished my NixOS config—looking for feedback!

r/NixOS - Almost finished my NixOS config—looking for feedback!

23 Upvotes · 34 Kommentare

Decided to give NixOS a try

r/NixOS

•

vor 2 Monaten

Decided to give NixOS a try

r/NixOS - Decided to give NixOS a try

133 Upvotes · 26 Kommentare

I love when there's support for NixOS

r/NixOS

•

vor 1 Monat

I love when there's support for NixOS

r/NixOS - I love when there's support for NixOS

281 Upvotes · 14 Kommentare

How do you structure your NixOS configs?

r/NixOS

•

vor 9 Monaten

How do you structure your NixOS configs?

57 Upvotes · 44 Kommentare

I just made a MASSIVE refactoring of my NixOS system. Can you guys review my configuration and tell me maybe what I can do better?

r/NixOS

•

vor 3 Monaten

I just made a MASSIVE refactoring of my NixOS system. Can you guys review my configuration and tell me maybe what I can do better?

r/NixOS - I just made a MASSIVE refactoring of my NixOS system. Can you guys review my configuration and tell me maybe what I can do better?

137 Upvotes · 33 Kommentare

I just installed NixOS and I'm already overwhelmed by everything.

r/NixOS

•

vor 3 Monaten

I just installed NixOS and I'm already overwhelmed by everything.

65 Upvotes · 86 Kommentare

I think I'm at my peak of naming commits with NixOS

r/NixOS

•

vor 3 Monaten

I think I'm at my peak of naming commits with NixOS

r/NixOS - I think I'm at my peak of naming commits with NixOS

192 Upvotes · 29 Kommentare

NixOS, where have you been all my life?

r/NixOS

•

vor 7 Monaten

NixOS, where have you been all my life?

127 Upvotes · 26 Kommentare

What is unique about your NixOS setup?

r/NixOS

•

vor 5 Monaten

What is unique about your NixOS setup?

65 Upvotes · 86 Kommentare

Is there a science area that studies package management like NixOS?

r/NixOS

•

vor 3 Monaten

Is there a science area that studies package management like NixOS?

27 Upvotes · 12 Kommentare

My nixOS config

r/NixOS

•

vor 2 Monaten

My nixOS config

r/NixOS - My nixOS config

4 Upvotes · 12 Kommentare

My NixOS setup after almost 2 months of using it.

r/NixOS

•

vor 17 Tagen

My NixOS setup after almost 2 months of using it.

r/NixOS - My NixOS setup after almost 2 months of using it.

10 Upvotes · 7 Kommentare

Finally settled into NixOS

r/NixOS

•

vor 7 Tagen

Finally settled into NixOS

r/NixOS - Finally settled into NixOS

26 Upvotes · 19 Kommentare

Automatic updates on NixOS?

r/NixOS

•

vor 9 Monaten

Automatic updates on NixOS?

14 Upvotes · 15 Kommentare

Beginner trying to use NixOS for self-hosted services. Where to start?

r/NixOS

•

vor 9 Monaten

Beginner trying to use NixOS for self-hosted services. Where to start?

36 Upvotes · 15 Kommentare

Is it worth using NixOS if I don't want to rewrite config in Nix (and just want the package manager)

r/NixOS

•

vor 13 Tagen

Is it worth using NixOS if I don't want to rewrite config in Nix (and just want the package manager)

11 Upvotes · 25 Kommentare

New to NixOS and don't know where to start?

r/NixOS

•

vor 4 Monaten

New to NixOS and don't know where to start?

11 Upvotes · 34 Kommentare

Wanted to try NixOS with a VM, any recommendations?

r/NixOS

•

vor 10 Monaten

Wanted to try NixOS with a VM, any recommendations?

5 Upvotes · 16 Kommentare

Translating NixOS Configs Into a User-Friendly GUI

r/NixOS

•

vor 5 Monaten

Translating NixOS Configs Into a User-Friendly GUI

51 Upvotes · 53 Kommentare

\[HELP\] Beginner NixOS configuration

r/NixOS

•

vor 15 Tagen

\[HELP\] Beginner NixOS configuration

5 Upvotes · 5 Kommentare

First NixOS Server...Where Do I Even Start?

r/NixOS

•

vor 2 Monaten

First NixOS Server...Where Do I Even Start?

19 Upvotes · 42 Kommentare

Best minimal browser to use with NixOS?

r/NixOS

•

vor 7 Monaten

Best minimal browser to use with NixOS?

4 Upvotes · 20 Kommentare

## Response:
Das ist ein Posting über ein neues Projekt namens **D-PlaneOS**. Vereinfacht gesagt: Es ist ein **Management-Interface (Web-UI)**, um aus einem normalen Computer ein **NAS (Network Attached Storage)** zu machen – ähnlich wie TrueNAS oder Unraid, aber spezialisiert auf **NixOS**.

Hier ist die Zusammenfassung der Funktionen:

### 1\. Was macht die Software?

D-PlaneOS ist ein Hintergrunddienst (Daemon) mit einer grafischen Weboberfläche, mit der du deinen Server verwalten kannst, ohne ständig in der Kommandozeile arbeiten zu müssen.

*   **NixOS-Integration:** Du kannst deine NixOS-Konfiguration direkt im Web-Interface verwalten.
*   **Sicherheits-Rollbacks:** Wenn du eine Änderung an der Konfiguration vornimmst (`nixos-rebuild switch`), musst du sie in der UI bestätigen. Tust du das nicht (weil du dich z. B. ausgesperrt hast), rollt das System automatisch zur letzten funktionierenden Version zurück.
*   **ZFS-Verwaltung:** Es hilft dir beim Verwalten deiner Festplatten-Pools (ZFS), erstellt Snapshots vor Upgrades und zeigt dir an, welche Daten dauerhaft gespeichert sind und welche (bei Impermanence-Setups) nach einem Neustart gelöscht werden.
*   **Docker-Management:** Du kannst Container verwalten und Updates durchführen, die ebenfalls durch Snapshots abgesichert sind.

### 2\. Der aktuelle Status (Beta)

Der Entwickler sucht gerade **Beta-Tester**. Da die Software als `root` läuft und tief ins System eingreift, ist sie momentan nur für Test-Systeme (VMs oder Zweitrechner) gedacht, nicht für wichtige Daten.

### 3\. Kritik aus der Community

In den Kommentaren gibt es eine interessante Diskussion über zwei Punkte:

*   **Die Lizenz:** Das Projekt nutzt die _PolyForm Shield_\-Lizenz. Das bedeutet, es ist zwar im Quellcode einsehbar ("Source Available"), aber rechtlich gesehen **kein Open Source**, da die kommerzielle Nutzung eingeschränkt ist. Das wird von der NixOS-Community kritisch hinterfragt.
*   **Code-Historie:** Einige Nutzer wundern sich über riesige Code-Änderungen in kurzer Zeit, was der Entwickler mit einem kompletten Rewrite von PHP nach Go und dem Hinzufügen von Abhängigkeiten erklärt.

### Fazit: Warum ist das für dich interessant?

Da du dich mit `jailed-agents` beschäftigst, arbeitest du bereits mit Sandboxing und deklarativer Konfiguration. **D-PlaneOS** verfolgt einen ähnlichen Ansatz für die Infrastruktur-Ebene: Es versucht, die Komplexität von NixOS (Flakes, Generationen, ZFS) hinter einer benutzerfreundlichen Oberfläche sicher bedienbar zu machen.

**Würdest du so ein Tool nutzen, um deine Agenten-Server zu verwalten, oder bevorzugst du die rein manuelle Konfiguration via Terminal?**



---
Powered by [Gemini Exporter](https://www.ai-chat-exporter.com)