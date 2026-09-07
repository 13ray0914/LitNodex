# LitNodex

[![CI](https://github.com/13ray0914/LitNodex/actions/workflows/ci.yml/badge.svg)](https://github.com/13ray0914/LitNodex/actions/workflows/ci.yml)
[![License: AGPL-3.0-or-later](https://img.shields.io/badge/License-AGPL--3.0--or--later-blue.svg)](LICENSE)
[![Version](https://img.shields.io/github/v/release/13ray0914/LitNodex?color=8b5cf6)](https://github.com/13ray0914/LitNodex/releases)

**LitNodex turns your scientific PDF library into a local, reviewable evidence base.** It extracts claims and measurements, links them to source sentences and visual evidence, and maps relationships across papers. Its focus is the combination of **source-level traceability, human curation, and configurable literature networks** in a reusable workspace.

| Tool | Main workflow | Main result |
|---|---|---|
| [ChatGPT Deep Research](https://help.openai.com/en/articles/10500283-deep-research-daq) | Investigate a question across the web, uploaded files, and connected sources | A synthesized report with citations or source links |
| [Connected Papers](https://www.connectedpapers.com/main/) | Explore similar papers around a starting paper and discover prior or derivative works | A visual map for literature discovery |
| **LitNodex** | Analyze and curate a chosen PDF collection using local models | Structured evidence, review records, and networks built from citations, semantics, claims, properties, and methods |

Use LitNodex when you need to inspect *which passage supports a claim*, correct extracted data, and regroup papers as your review develops. These tools can complement one another: discover literature, obtain the PDFs, then build and maintain the evidence base locally.

> [日本語README](README_JA.md) · [Detailed Japanese guide](README_V4_JA.md)

<img width="1919" height="1063" alt="LitNodex literature network and review workspace" src="https://github.com/user-attachments/assets/b617d53b-875e-4842-9350-18879b1823e9" />

## What you can do

- **Trace evidence:** stable IDs connect claims and measurements to sentences, figures, tables, equations, and the original PDF.
- **Review extractions:** inspect mechanical validation results, correct records, and record human approval or rejection.
- **Explore relationships:** combine seven network layers with Leiden clustering, or navigate the scientific knowledge graph.
- **Maintain a growing library:** projects share a canonical PDF library; hash-based processing detects duplicates and reuses unchanged stages.
- **Enrich and export:** resolve metadata and references through Crossref/OpenAlex, then export evidence reports and graph data.

```text
PDFs → text and visual extraction → claims and measurements
     → validation and human review → reports and graphs
```

## Requirements

- Windows 10/11 with WSL2 and Ubuntu, or a compatible Linux environment
- Python 3.10 or newer
- Docker for GROBID
- A llama.cpp-compatible local text model server; the default configuration expects an OpenAI-compatible endpoint at `http://127.0.0.1:8080/v1`
- Sufficient storage for source PDFs, intermediate data, and optional models

Optional components include SPECTER2, MinerU, and a separate multimodal llama.cpp server for visual interpretation.

<details>
<summary>Local Qwen hardware requirements and model paths</summary>

The default launcher uses **Qwen3.8-27B Q4_K_M**, a Q4_0 MTP draft model, full GPU offload, and a 65,536-token context. The model files total about 19 GB. See the [Qwen model card](https://huggingface.co/Qwen/Qwen3.8-27B) and [llama.cpp server options](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md).

| Resource | Practical minimum for the default | Recommended | Notes |
|---|---:|---:|---|
| GPU | NVIDIA CUDA-capable GPU | Recent NVIDIA GPU | CPU-only and partial-offload execution are possible in llama.cpp but are much slower for this workflow. |
| VRAM | 24 GB | 32 GB or more | The tested RTX 4090 run used about 23.3/24.0 GiB. Other llama.cpp builds and display use can require extra headroom. |
| System RAM | 32 GB | 64 GB or more | Use at least 64 GB when partially offloading to CPU, running other local models, or processing many large PDFs. |
| Free disk | 25 GB for llama.cpp and the two GGUF files | 40 GB or more plus PDF/output space | LitNodex research data, GROBID images, embeddings, and backups need additional space. |
| CPU | Modern x86-64 CPU with AVX2, 8 cores | 12+ cores | CPU is used for parsing, validation, graph construction, and any layers not offloaded to the GPU. |

Memory use varies with model, context, cache settings, and llama.cpp build. If 24 GB VRAM is insufficient, close other GPU applications or try `-c 32768` in `scripts/run_review_pipeline.sh`; shorter contexts may reject long extraction requests.

The launcher reads these environment variables, so custom locations do not require editing source files:

```bash
export QWEN_SERVER="$HOME/desktop/llm/llama.cpp/build/bin/llama-server"
export QWEN_MODEL="$HOME/models/Qwen3.8-27B/Qwen3.8-27B-Q4_K_M.gguf"
export QWEN_DRAFT_MODEL="$HOME/models/Qwen3.8-27B/mtp-Qwen3.8-27B-Q4_0.gguf"
```

The Qwen weights and llama.cpp binary are not installed by the LitNodex Python package.

</details>

## Download a release

Download a version from [GitHub Releases](https://github.com/13ray0914/LitNodex/releases):

- `LitNodex-vX.Y.Z-source.zip` and `LitNodex-vX.Y.Z-source.tar.gz` — source snapshots
- `litnodex-X.Y.Z-py3-none-any.whl` and `litnodex-X.Y.Z.tar.gz` — Python package files
- `LitNodex-X.Y.Z-setup.exe` — Windows/WSL installer
- `SHA256SUMS.txt` — checksums for every attached file

The Windows installer sets up the Python package inside an existing Ubuntu/WSL distribution and creates LitNodex shortcuts. Install WSL first with `wsl --install -d Ubuntu` if necessary. The installer preserves the WSL workspace, PDFs, results, and local configuration when LitNodex is upgraded or uninstalled. It does not install Docker/GROBID, Qwen, llama.cpp, GPU drivers, or model weights. The current installer is not code-signed, so Windows SmartScreen may require **More info → Run anyway** after you verify the SHA-256 checksum.

## Install with pip

LitNodex is installable directly from its Git repository. Use a dedicated virtual environment inside WSL/Linux; the Windows-native Python runtime is not supported because the service launchers use POSIX process and locking facilities.

Install the local OCR engine and English/Japanese language data if image-only PDFs must be processed:

```bash
sudo apt update
sudo apt install ocrmypdf tesseract-ocr-eng tesseract-ocr-jpn
```

The **Run OCR blocked papers** button creates derived searchable PDFs in `data/ocr_pdfs/`; canonical source PDFs are never overwritten. Only successfully OCR-processed papers are sent through the remaining resumable stages.

Create an [OpenAlex API key](https://openalex.org/settings/api) for metadata enrichment. See the [authentication and rate-limit guide](https://help.openalex.org/api/authentication/) if requests return `429 Too Many Requests`.

```bash
python3 -m venv ~/.venvs/litnodex
source ~/.venvs/litnodex/bin/activate
python -m pip install --upgrade pip
python -m pip install "litnodex @ git+https://github.com/13ray0914/LitNodex.git@main"

litnodex --version
litnodex init ~/desktop/review
cd ~/desktop/review
```

`litnodex init` creates the workspace and prompts for your OpenAlex API key. The key stays in the local, Git-ignored `config.json` and is never printed. After upgrading the package, run `litnodex init ~/desktop/review --force` to refresh application files while preserving research data and existing configuration.

For unattended installation, use `litnodex init PATH --no-openalex-prompt` and provide `OPENALEX_API_KEY` in the environment that runs `litnodex serve`.

Install the optional isolated graph environment and start GROBID:

```bash
./scripts/install_network_env.sh
docker compose -f docker-compose.grobid.yml up -d
```

After configuring/starting Qwen, verify and serve LitNodex:

```bash
litnodex check
litnodex serve
```

The server stays in the foreground and is available at [http://127.0.0.1:8766](http://127.0.0.1:8766). The `Analyze` button inherits the pip environment used by `litnodex serve`. The core stages can also be run directly with the compatibility command `litnodex pipeline --from-step 6 --to-step 11`.

### Install from a source checkout

For development, clone the repository and install it into an activated WSL/Linux virtual environment:

```bash
git clone https://github.com/13ray0914/LitNodex.git ~/desktop/litnodex
cd ~/desktop/litnodex
python -m pip install -e .
litnodex init ~/desktop/review
```

Then follow the graph-environment, GROBID, and server steps above from `~/desktop/review`. To create a Windows desktop shortcut, run `./scripts/install_windows_app.sh` there.

## Running the process

Add PDFs through the dashboard, select a project, and choose **Analyze / Update Selected Project**.

<img width="1919" height="1063" alt="LitNodex project analysis dashboard" src="https://github.com/user-attachments/assets/551e3632-60cc-4b6c-b98b-02439b320a18" />

For command-line processing:

```bash
./scripts/run_review_pipeline.sh
```

The core eleven-stage process can also be controlled directly:

```bash
python run_pipeline.py
python run_pipeline.py --ids P0002,P0005,P0008
python run_pipeline.py --from-step 6 --to-step 11
```

Completed stages are reused when their input, prompt, schema, model, and configuration hashes remain current.

## Graph interfaces

**Literature Network:** combine citation, semantic, claim, property, method, keyword, and bibliographic-coupling layers. Adjust the selected layers and Leiden resolution to explore communities. Display sparsification and search highlighting do not change clustering.

**Scientific Knowledge Graph:** explore connections among papers, claims, properties, methods, systems, measurements, and visual evidence. Progressive expansion and Fast/Balanced/Full modes control rendering without removing exported data.

A `review_required` flag means automatic validation found items to inspect. Use the Curation Editor to correct or reject them and record a human decision; the original validation report remains available for audit.

```bash
./scripts/open_network_gui.sh
./scripts/open_knowledge_gui.sh
```

## Main outputs

| Output | Purpose |
|---|---|
| `data/manifest.csv` | Stable paper registry |
| `data/paper_json/` | Sentence- and visual-ID-preserving paper JSON |
| `data/extracted/` | Inventories, measurements, claims, and validation |
| `data/visual_assets/` | Cropped figures, tables, and equations |
| `outputs/review_reports/` | Human-readable evidence reports |
| `outputs/projects/<project>/network_gui/` | Multiplex literature network |
| `outputs/projects/<project>/knowledge_graph/` | Scientific knowledge graph and tabular exports |

Generated research data, source PDFs, local configuration, caches, and model artifacts are intentionally excluded from Git by `.gitignore`.

## Security and privacy

- Application services bind to `127.0.0.1` by default.
- GROBID Docker ports are published only on the loopback interface.
- Browser-facing write endpoints validate request provenance and JSON content types.
- Uploaded PDFs and extracted scientific content remain local unless you explicitly configure an external service.
- Crossref and OpenAlex are used for metadata and citation enrichment, not for downloading paper PDFs.

LitNodex is research software, not an autonomous authority. Validate important claims, numerical values, units, and interpretations against the original papers before publication.

## Development

Run the regression suite:

```bash
python -m unittest discover -s tests -v
python -m compileall -q lib scripts run_pipeline.py check_environment.py
bash -n scripts/*.sh
docker compose -f docker-compose.grobid.yml config --quiet
```

CI runs the same security and smoke checks on pushes and pull requests.

## Documentation

- [Japanese setup and evidence-extraction guide](README_JA.md)
- [Japanese v4 architecture and migration guide](README_V4_JA.md)
- [Example configuration](config.example.json)
- [Default v4.1+ configuration overlay](config.v4_1.defaults.json)

## License

LitNodex is distributed under the [GNU Affero General Public License v3.0 or later](LICENSE) (`AGPL-3.0-or-later`). See the license section in [README_JA.md](README_JA.md#22-ライセンス) for dependency-specific notes.
