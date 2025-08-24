# PDF Reader AI with Ollama

A Python application that allows you to ask questions about the content of your PDF documents using local AI models via Ollama.

## Features

- Extract text from PDF documents
- Ask questions about the PDF content
- Uses local AI models (gemma:2b by default)
- Works entirely offline after setup
- Simple command-line interface

## Prerequisites

- Windows 10 (64-bit)
- Python 3.11 (recommended)
- Ollama installed and running
- At least 8GB RAM (16GB+ recommended for larger models)

## Installation

1. **Install Ollama**
   - Download and install from [ollama.com](https://ollama.com)
   - After installation, start the Ollama service

2. **Download a model** (if not already done):
   ```bash
   ollama pull gemma:2b
   ```
   Or for a more powerful model (requires more RAM):
   ```bash
   ollama pull llama3.1:8b
   ```

3. **Clone this repository**
   ```bash
   git clone <repository-url>
   cd pdf_reader
   ```

4. **Create and activate a virtual environment**
   ```bash
   python -m venv venv
   .\\venv\\Scripts\\activate
   ```

5. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

## Usage

### Basic Usage

```bash
python pdf_reader.py path/to/your/document.pdf
```

### Ask a specific question

```bash
python pdf_reader.py path/to/your/document.pdf -q "What is the main topic of this document?"
```

### Specify a different model

```bash
python pdf_reader.py path/to/your/document.pdf -m llama3.1:8b
```

## Interactive Mode

If you run the script without the `-q` option, it will start in interactive mode where you can ask multiple questions:

```
Loading PDF: example.pdf
PDF loaded successfully!

Enter your questions about the PDF (type 'exit' to quit):

Question: What is the main topic of this document?

Searching for answer...

Answer: The main topic of this document is...
```

## Troubleshooting

### Common Issues

1. **Ollama service not running**
   - Make sure the Ollama service is running
   - Try restarting the service: `ollama serve`

2. **Model not found**
   - Make sure you've downloaded the model: `ollama pull gemma:2b`
   - Check available models: `ollama list`

3. **PDF text extraction issues**
   - Ensure the PDF is not scanned (must be text-based)
   - Try with a different PDF to verify

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgements

- [Ollama](https://ollama.com) for providing the local LLM infrastructure
- [pdfplumber](https://github.com/jsvine/pdfplumber) for PDF text extraction
