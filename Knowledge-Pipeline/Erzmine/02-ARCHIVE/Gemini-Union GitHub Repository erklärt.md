# Union GitHub Repository erklärt

**Exported:** 3/8/2026 18:51:41  
**Link:** [https://gemini.google.com/app/02ac2ab074f95442](https://gemini.google.com/app/02ac2ab074f95442)

## Prompt:
was ist das ?

Skip to content

unionlabs

union

Repository navigation

Code

Issues

128

 (128)

Pull requests

57

 (57)

Actions

Projects

Wiki

Security

Insights

union

Public

unionlabs/union

t

Name

ehegnes

feat(ts-sdk-evm): provide packet metadata in prepareEip1193 (#5437)

c103ae9

 · 2 weeks ago

.changeset

feat(ts-sdk): behold the great migration

7 months ago

.github

fix(ci): do not assume binary

3 weeks ago

.helix

feat(docs): deployments and voyager docs cleanup

2 months ago

.vscode

chore: apply changes from #4539

10 months ago

.zed

chore(devshell): add package-version-server

3 months ago

11-cometbls

fix(audit): missing error handling for equal timestamps in cometbls l…

last year

app2

fix(app): testnet gas

3 weeks ago

aptos

chore: fix spelling and format

3 months ago

cairo

chore(voyager): return proper header data in voyager cometbls client …

2 months ago

ceremony

fix(app): make GraphQLError construction keep this context

2 months ago

cosmwasm

chore(nix): scripts cleanup

last month

deployments

feat(deployments): osmosis\<-\>base

3 weeks ago

devnet-compose

feat: prepare rust docs

5 months ago

docs

fix(docs): chains overview query

last month

drip

feat(rust): bump and clean up deps

3 months ago

e2e

feat(rust): bump and clean up deps

3 months ago

effect-svelte

fix(app): make GraphQLError construction keep this context

2 months ago

evm

chore(nix): scripts cleanup

last month

galoisd

chore(galoisd): use struct type

2 months ago

generated/rust

feat(rust): bump and clean up deps

3 months ago

lib

feat(voyager): support cosmos block events and make tx hash optional …

last month

mpc

feat(rust): bump and clean up deps

3 months ago

networks

chore: remove unused libraries

3 months ago

patches

feat(ts-sdk): behold the great migration

7 months ago

scripts

feat(ts-sdk-sui): add docgen

5 months ago

sentinel2

feat(docs): bootstrap voyager plugin and modules docs

2 months ago

site

feat(docs): bootstrap voyager plugin and modules docs

2 months ago

sui

chore(sui): new address for ibc

2 months ago

tools

deployments stuff (#5432)

3 weeks ago

ts-sdk-cosmos

refactor(app,ts-sdk,ts-sdk-evm,ts-sdk-cosmos): improve span tracing

2 months ago

ts-sdk-evm

chore(ts-sdk-evm): bump for release

2 weeks ago

ts-sdk-sui

feat(docs): bootstrap voyager plugin and modules docs

2 months ago

ts-sdk

feat(ts-sdk): add ZkgmClient tracing

2 months ago

typescript-sdk

feat(ts-sdk): update schema

5 months ago

uniond

chore(uniond): upgrade cometbls

2 months ago

unionvisor

chore: bump rust version to 1.93

3 months ago

versions

feat(uniond): v1.2 migration

8 months ago

voyager

feat(voyager): docker image (#5433)

3 weeks ago

zkgm-dev

fix(app): make GraphQLError construction keep this context

2 months ago

.envrc

feat: openvscode-server nix setup

2 years ago

.git-blame-ignore-revs

chore: ignore fd9caeb nix fmt in blame

11 months ago

.gitattributes

chore: update ts sdk

last year

.gitignore

feat(docs): bootstrap voyager plugin and modules docs

2 months ago

.ignore

chore: ignore vendor for search

3 years ago

ARCHITECTURE.md

feat(galois): rename from to

3 years ago

CODEOWNERS

chore: add @Swepool and @ehegnes codeowners

10 months ago

CONTRIBUTING.md

chore: apply changes from #4357

10 months ago

Cargo.lock

feat(voyager): otel

last month

Cargo.toml

feat(voyager): otel

last month

LICENSE-APACHE

docs: add dual MIT/Apache2 licenses

2 years ago

LICENSE-MIT

docs: add dual MIT/Apache2 licenses

2 years ago

README.md

chore(cosmwasm): remove cosmwasm/ibc-union subdirectory nesting

3 months ago

Scarb.lock

chore(cairo): cometbls groth16 verifier

2 months ago

Scarb.toml

chore(starknet): check pairing result

2 months ago

VERSIONING.md

feat: enable mdformat through treefmt-nix

2 years ago

biome.json

chore: migrate from biome to dprint

11 months ago

clippy.toml

refactor: move uint into unionlabs-primitives and split linea types

last year

dprint.json

chore: make vscode work with dprint

10 months ago

flake.lock

chore: update unionvisor bundle

2 months ago

flake.nix

chore: update unionvisor bundle

2 months ago

foundry.toml

chore(evm): more deterministic contracts

11 months ago

garnix.yaml

feat: prepare rust docs

5 months ago

package.json

fix(ts): package manager version

3 months ago

pnpm-lock.yaml

refactor(app,ts-sdk,ts-sdk-evm,ts-sdk-cosmos): improve span tracing

2 months ago

pnpm-workspace.yaml

refactor(app,ts-sdk,ts-sdk-evm,ts-sdk-cosmos): improve span tracing

2 months ago

rustfmt.toml

feat: bump rust version and edition

5 months ago

taplo.toml

feat: update deps, add taplo, and move deps to workspace

2 years ago

treefmt.nix

fix(app): type errors and formatting

3 months ago

tsconfig.base.json

chore: prune PNPM dependency FOD

5 months ago

tsconfig.build.json

fix(ts-sdk-sui): type errors

5 months ago

tstyche.config.json

feat(ts-sdk): behold the great migration

7 months ago

typos.toml

feat(deployments): osmosis\<-\>base

3 weeks ago

vercel.json

fix(site): pick up node version pls

5 months ago

vitest.setup.ts

fix: vitest w/ ts project references; hashes

11 months ago

vitest.shared.ts

feat(ts-sdk): behold the great migration

7 months ago

vitest.workspace.ts

feat(effect-svelte): init

4 months ago

Repository files navigation

README

Contributing

Apache-2.0 license

MIT license

Union is the hyper-efficient zero-knowledge infrastructure layer for general message passing, asset transfers, NFTs, and DeFi. Its based on Consensus Verification and has no dependencies on trusted third parties, oracles, multi-signatures or MPC. It implements IBC for compatibility with Cosmos chains and connects to EVM chains like Ethereum, Berachain (beacon-kit), Arbitrum, and more.

The upgradability of contracts on other chains, connections, token configurations, and evolution of the protocol will all be controlled by decentralized governance, aligning the priorities of Union with its users, validators, and operators.

Components

ComponentDescriptionLanguage(s)uniondThe Union node implementation, using CometBLSGogaloisdThe zero-knowledge prover implementationGo GnarkvoyagerModular hyper-performant cross-ecosystem relayerRustcosmwasmCosmWasm smart contract stackRustlight-clientsLight Clients for various ecosystemsRustunionvisorNode supervisor intended for production usageRustdripFaucet for Cosmos chains: app.union.build/faucetRustevmEVM smart contract stackSolidityappapp.union.buildTypeScript Sveltesiteunion.buildTypeScript AstroTypeScript SDKTypeScript SDK for interacting with UnionTypeScript

Quickstart

Install Nix to reproducibly build any component, and to enter a dev shell with all dependencies:

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

(Note that some components can only be built on Linux. If you are using macOS, we recommend using OrbStack to easily set up a NixOS VM within two minutes. Most Union developers use macOS with OrbStack, and there is no need to install Nix inside of the NixOS VM.)

You can now reproducibly build any of Union's components from source:

nix build .#uniond -L

nix build .#voyager -L

nix build .#app -L# to see all packages, run:

nix flake show

The result of whatever you build will be in result/

You can now also enter our dev shell, which has all of the dependencies (cargo, rustc, node, go, etc.) you need to work on any component: (Don't worry, this will not affect your system outside of this repo)

nix develop

Run the following to format the entire repo and check your spelling before each PR:

nix run .#pre-commit -L

Check the #developers channel on Union's discord if you need any help with this.

Supported Chains

NetworkMainnetsTestnetsArbitrumarbitrum.42161arbitrum.421614Babylonbabylon.bbn-1babylon.bbn-test-6Basebase.8453base.84532Berachainberachain.80094berachain.80069Bobbob.60808bob.808813BSCbsc.56bsc.97Corncorn.21000000corn.21000001Ethereumethereum.1ethereum.11155111, ethereum.560048Osmosisosmosis.osmosis-1osmosis.osmo-test-5Seisei.pacific-1, sei.1329sei.atlantic-2, sei.1328Sui-sui.4c78adacUnionunion.union-1union.union-testnet-10Xionxion.xion-mainnet-1xion.xion-testnet-2

For the full list see https://docs.union.build/ucs/04/

Docs

The official docs are hosted here. Each individual component also has accompanying developer documentation for contributors, which you can find in each README.md.

About

The trust-minimized, zero-knowledge bridging protocol, designed for censorship resistance, extremely high security, and usage in decentralized finance.

union.build

Topics

rust golang typescript nix ethereum blockchain svelte interoperability indexer astro solidity move cosmos evm prover typescipt zero-knowledge relayer cosmwasm

Resources

 Readme

License

 Apache-2.0, MIT licenses found

Contributing

 Contributing

 Activity

 Custom properties

Stars

 74.3k stars

Watchers

 1.6k watching

Forks

 3.8k forks

Report repository

Releases 107

bundle-union-1 v1.2.3

Latest

on Jan 26

\+ 106 releases

Deployments500+

 Preview

 Production 2 weeks ago

 app2-preview

\+ more deployments

Packages11

union/mpc-client

uniond

uniond-release

\+ 8 packages

Contributors29

\+ 15 contributors

Languages

Rust

76.9% 

TypeScript

6.3% 

Svelte

4.4% 

Move

3.8% 

Solidity

3.6% 

Cairo

1.8% 

Other

3.2%

Footer

© 2026 GitHub, Inc.

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
Bei dem von dir kopierten Text handelt es sich um die **GitHub-Repository-Seite von "Union"** (unionlabs/union).

**Union** ist eine Infrastruktur-Ebene für Blockchains, die auf **Zero-Knowledge-Technologie (ZK)** basiert. Ihr Hauptzweck ist es, verschiedene Blockchains sicher und ohne Vertrauen in Drittanbieter miteinander zu verbinden (Interoperabilität).

Hier sind die wichtigsten Details zusammengefasst:

### Was genau macht Union?

*   **Trustless Bridging:** Es ermöglicht den Transfer von Vermögenswerten (Assets), NFTs und Nachrichten zwischen verschiedenen Blockchains, ohne dass man Orakeln, Multi-Signatur-Wallets oder zentralen Zwischenhändlern vertrauen muss.
*   **IBC-Unterstützung:** Es nutzt das _Inter-Blockchain Communication_ (IBC) Protokoll, das ursprünglich aus dem Cosmos-Ökosystem stammt, und bringt dieses zu anderen Ketten wie **Ethereum**, **Arbitrum**, **Berachain** und **Sui**.
*   **Sicherheit:** Die Sicherheit wird durch mathematische Beweise (Zero-Knowledge Proofs) und Konsens-Verifizierung gewährleistet.

### Die technischen Komponenten

Das Projekt ist sehr modular aufgebaut und nutzt verschiedene Programmiersprachen:

| Komponente | Beschreibung | Sprache |
| --- | --- | --- |
| **uniond** | Der Haupt-Knoten (Node) des Netzwerks. | Go  |
| **galoisd** | Der ZK-Prover (erzeugt die kryptografischen Beweise). | Go  |
| **voyager** | Ein Relayer, der Daten zwischen den Ketten hin und her schickt. | Rust |
| **cosmwasm / evm** | Smart Contract Stacks für verschiedene Umgebungen. | Rust / Solidity |
| **ts-sdk** | Werkzeuge für Entwickler, um Anwendungen zu bauen. | TypeScript |

### Status des Projekts (Stand März 2026)

*   **Popularität:** Mit über **74.000 Sternen** auf GitHub ist es ein extrem beachtetes Projekt im Krypto-Sektor.
*   **Unterstützte Netze:** Es verbindet eine Vielzahl von Netzwerken, darunter Ethereum, Osmosis (Cosmos), Arbitrum, Base, Sei und Sui.
*   **Entwicklung:** Das Repository wird aktiv gepflegt (letzte Änderungen vor wenigen Wochen) und nutzt moderne Entwickler-Tools wie **Nix** für reproduzierbare Builds.

Das Projekt richtet sich primär an **Blockchain-Entwickler** und Betreiber von Infrastruktur, die eine hochsichere Verbindung zwischen unterschiedlichen Ökosystemen herstellen wollen.

Möchtest du wissen, wie man eine bestimmte Komponente davon installiert oder was "Zero-Knowledge" in diesem Zusammenhang genau bedeutet?

## Prompt:
wo und wie kann ich das hier nutzen ?Alejandra 💅

The Uncompromising Nix Code Formatter

Try it on your browser! here

Features

✔️ Fast

It's written in Rust and formats Nixpkgs in just a few seconds. 1

✔️ Powerful

We define a comprehensive style for all possible combinations of the Nix expression language.

✔️ Reliable

High coverage, battle tested.

From Nix's eyes, code is just the same. 2

✔️ Beautiful

Beauty is subjective, right?

We started from the original style of Nixpkgs, and then we applied the feedback of developers who have used Nix at scale for several years, producing a very well-grounded style guide. For everything else, some pieces of the style are configurable.

✔️ Transparent

You won't notice the formatter after a while.

Humans care about the content, machines about the style!

✔️ Native

We integrate with common code editors and workflows:

Visual Studio Code

Neovim

Vim

GNU Emacs

Doom Emacs

Pre-commit

Pre-commit-hooks.nix

Getting started

On the web editor

Please visit: kamadorueda.github.io/alejandra.

Prebuilt binaries

You can download a binary for your platform:

aarch64-unknown-linux-musl

x86\_64-unknown-linux-musl

Make it executable (\$ chmod +x) and run Alejandra with:

\$ ./alejandra --help

or:

\$ /path/to/alejandra --help

From Nixpkgs

Please visit: search.nixos.org/packages?query=alejandra.

Nix installation

Nix stable:

\$ nix-env -ivf https://github.com/kamadorueda/alejandra/tarball/4.0.0

Nix with Flakes:

\$ nix profile install github:kamadorueda/alejandra/4.0.0

Then run Alejandra with:

\$ alejandra --help

NixOS installation

Nix stable:

let

alejandra =

(import (builtins.fetchTarball {

url = "https://github.com/kamadorueda/alejandra/tarball/4.0.0";

sha256 = "0000000000000000000000000000000000000000000000000000";

}) {})

.outPath;in {

environment.systemPackages = \[alejandra\];}

Nix with Flakes:

{

inputs = {

nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

alejandra.url = "github:kamadorueda/alejandra/4.0.0";

alejandra.inputs.nixpkgs.follows = "nixpkgs";

};

outputs = {alejandra, nixpkgs, ...}: {

nixosConfigurations = {

example = nixpkgs.lib.nixosSystem rec {

\# We support: aarch64-darwin, aarch64-linux, i686-linux, x86\_64-darwin, x86\_64-linux

system = "x86\_64-linux";

modules = \[

{

environment.systemPackages = \[alejandra.defaultPackage.\${system}\];

}

\# Import your other modules here

\# ./path/to/my/module.nix

\# ...

\];

};

};

};}

From Homebrew

\$ brew install alejandra

(experimental) Configuration Options

You can configure Alejandra through a file named alejandra.toml. This file will be automatically detected if found in the same directory where Alejandra is being run from, or you can tell Alejandra to use a different location by using the --experimental-config ./path/to/alejandra.toml flag in the CLI.

You can find a full configuration file and the supported options here: alejandra.toml.

Cool libraries

NixEL

Santiago

rnix-parser

Alternatives

NixOS/nixfmt

serokell/nixfmt

nixpkgs-fmt

Versioning

We use semver to version Alejandra.

Our public API consists of:

The formatting rules (a.k.a. the style).

The CLI tool (\$ alejandra), command line flags, positional arguments, exit codes, and stdout.

With the exception of those explicitly marked as "experimental".

Changelog

Please read: CHANGELOG.

Contributors

The following people have helped improving Alejandra.

Thank you ❤️

Bobbe, Connor Baker, Daniel Bast, David Arnold, David Hauer, esf, Fabian Möller, Florian Finkernagel, Jamie Quigley, Joachim Ernst, Johannes Kirschbauer, Jörg Thalheim, Kevin Amado (Email, LinkedIn), Loïc Reynier, Matthew Kenigsberg, Michael Utz, Mr Hedgehog, Nathan Henrie, Norbert Melzer, Pablo Ovelleiro Corral, Patrick Stevens, Piegames, Rebecca Turner, Rehno Lindeque, Rok Garbas, Ryan Mulligan, Thomas Bereknyei, Tobias Bora, Tristan Maat, UserSv4, Victor Engmark, Vincent Ambo, Vladimir Fetisov, and Yorick van Pelt.

Footnotes

Footnotes

Running on a machine with:

CPU: 4 physical, 4 logical, 11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80GHz

MHz: from 400 to 4700 MHz

BogoMips: 5606.40

Cache L3: 12 MiB

Using:

\# x86\_64-unknown-linux-gnu

\$ time alejandra --threads \$threads /path/to/nixpkgs

Results:

\$threadsSeconds145225414

↩

The methodology to claim this is:

Checkout Nixpkgs and run:

\$ nix-env -qaf . --drv-path --xml \> before

Now format with Alejandra and run:

\$ nix-env -qaf . --drv-path --xml \> after

As of 2022-06-22, there are 41 differences in a set of 38109 derivations because of things like this:

goDeps = ./deps.nix;

Since ./deps.nix was also formatted you get a semantical difference.

This is something that should be solved on Nixpkgs and not a bug in Alejandra. For example:

https://github.com/NixOS/nixpkgs/pull/178378

https://github.com/NixOS/nixpkgs/pull/157760

 ↩

## Response:
**Alejandra** ist ein Werkzeug zum automatischen Formatieren von Nix-Code. Es sorgt dafür, dass dein Code sauber, einheitlich und gut lesbar bleibt, ohne dass du Leerzeichen oder Einrückungen manuell anpassen musst.

Hier sind die Möglichkeiten, wie und wo du es nutzen kannst:

### 1\. Im Browser (Ohne Installation)

Wenn du nur schnell ein paar Zeilen Code formatieren willst, kannst du den Web-Editor nutzen:

*   **URL:** 
    [kamadorueda.github.io/alejandra](https://www.google.com/search?q=https://kamadorueda.github.io/alejandra)

### 2\. Lokale Installation (Die "Wo"-Optionen)

Du kannst Alejandra auf verschiedene Arten auf deinem System installieren:

*   **Über Nix Flakes:** Ideal für moderne Nix-Setups.
*   **Über Nix-Env:** Für klassische Nix-Installationen.
*   **Über Homebrew:** Wenn du macOS nutzt.
*   **Direkt als Binärdatei:** Für Linux-Systeme ohne installiertes Nix.

### 3\. Integration in Editoren

Alejandra lässt sich in gängige Code-Editoren einbinden, damit dein Code beim Speichern automatisch formatiert wird:

*   **VS Code:** Über die entsprechende Nix-Erweiterung.
*   **Neovim / Vim:** Über Plugins wie `null-ls` oder `format.nvim`.
*   **Emacs:** Über `format-all-mode`.

* * *

### Installation und Anwendung (Die "Wie"-Optionen)

Gemäß deiner Vorgabe findest du hier alle relevanten Befehle für die Installation und die Nutzung in einem einzigen Block:

```
# --- INSTALLATION ---

# Option A: Installation mit Nix Flakes (empfohlen)
nix profile install github:kamadorueda/alejandra/4.0.0

# Option B: Installation mit klassischem Nix
nix-env -ivf https://github.com/kamadorueda/alejandra/tarball/4.0.0

# Option C: Installation unter macOS mit Homebrew
brew install alejandra

# --- NUTZUNG ---

# Hilfe anzeigen
alejandra --help

# Eine spezifische Datei formatieren
# Ersetze 'meine-datei.nix' durch deinen Dateinamen
alejandra meine-datei.nix

# Das gesamte aktuelle Verzeichnis (rekursiv) formatieren
alejandra .

# Überprüfung, ob Dateien formatiert sind (ohne sie zu ändern)
alejandra --check .
```

### Konfiguration (Optional)

Falls du vom Standard-Stil abweichen möchtest, kannst du eine Datei namens `alejandra.toml` im Projektverzeichnis erstellen. Alejandra erkennt diese automatisch und wendet deine spezifischen Regeln an.

Möchtest du, dass ich dir eine beispielhafte `alejandra.toml` erstelle oder dir zeige, wie du Alejandra direkt in deine `configuration.nix` für NixOS einbindest?

## Prompt:
was ist da sund wie geht das? https://github.com/DavHau/nix-portable

## Response:
**nix-portable** ist eine Version des Nix-Paketmanagers, die ohne Administratorrechte (root) und ohne eine klassische Installation auf fast jedem Linux-System funktioniert.

Normalerweise benötigt Nix zwingend das Verzeichnis `/nix` im Wurzelverzeichnis des Systems. Auf vielen Rechnern, wie zum Beispiel auf Firmenservern, HPC-Clustern oder Shared-Hosting-Angeboten, haben Nutzer jedoch keine Berechtigung, dieses Verzeichnis anzulegen. `nix-portable` löst dieses Problem.

### Funktionsweise

Das Programm nutzt Linux-Kernelfunktionen wie **User Namespaces** (oder alternativ Werkzeuge wie Bubblewrap oder proot). Damit erstellt es eine isolierte Umgebung für sich selbst. Innerhalb dieser Umgebung sieht es so aus, als gäbe es das Verzeichnis `/nix`, während die Daten in Wirklichkeit in deinem Benutzerverzeichnis (standardmäßig unter `~/.nix-portable`) gespeichert werden.

### Die wichtigsten Vorteile

*   **Kein Root-Zugriff:** Du musst kein Administrator sein, um Software zu installieren.
*   **Keine Installation:** Es ist eine einzige, statisch gelinkte Datei, die du einfach herunterlädst und ausführst.
*   **Portabilität:** Du kannst deine installierte Software und Konfiguration einfach mitnehmen oder auf Systemen nutzen, die Nix offiziell nicht unterstützen.

### So nutzt du es

Du lädst die Datei herunter, machst sie ausführbar und kannst dann sofort Nix-Befehle verwenden. Alle Befehle, die du normalerweise mit `nix` starten würdest, stellst du einfach `./nix-portable` voran.

Hier ist der gesamte Ablauf in einem Block:

```
# 1. Herunterladen der passenden Version für deine Prozessor-Architektur
curl -L https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-$(uname -m) > nix-portable

# 2. Die Datei ausführbar machen
chmod +x nix-portable

# 3. Beispiele für die Verwendung:

# Eine interaktive Shell mit einem Paket (z.B. 'hello') starten, ohne es dauerhaft zu installieren
./nix-portable nix-shell -p hello --run hello

# Ein Programm dauerhaft in deinem lokalen Profil installieren (z.B. den Prozessmonitor 'htop')
./nix-portable nix-env -iA nixpkgs.htop

# Das installierte Programm direkt über nix-portable aufrufen
./nix-portable htop
```

Falls dein System keine User Namespaces unterstützt (was bei sehr alten Kernel-Versionen vorkommen kann), versucht `nix-portable` automatisch, auf andere Methoden wie `proot` auszuweichen, um die Verzeichnisstruktur zu simulieren.



---
Powered by [Gemini Exporter](https://www.ai-chat-exporter.com)