---
name: document-research
description: Document processing and knowledge extraction combining PDF OCR, DOCX/XLSX parsing, table extraction, document merging, and structured knowledge conversion
---

# Document Research & Extraction - Enhanced Edition

Comprehensive document handling combining **PDF OCR** (including handwriting), **DOCX/XLSX parsing**, **table extraction**, **document merging/splitting**, and **knowledge extraction** for converting unstructured documents into structured reports.

## When to Use

- ✅ Extracting text and data from **PDFs** (including scanned documents)
- ✅ Parsing **Word documents** with complex formatting
- ✅ Extracting **tables** from PDFs and images
- ✅ Converting documents to **structured formats** (JSON, markdown)
- ✅ **Batch processing** multiple documents
- ✅ **OCR for handwritten** documents
- ✅ **Document merging** and report generation
- ✅ **Knowledge extraction** from research papers/reports

## Core Patterns

### 1. PDF Text Extraction with OCR

```python
import PyPDF2
from pdf2image import convert_from_path
import pytesseract
from PIL import Image

# Simple PDF text extraction
def extract_pdf_text(pdf_path):
    with open(pdf_path, 'rb') as file:
        reader = PyPDF2.PdfReader(file)
        text = ""
        for page in reader.pages:
            text += page.extract_text()
    return text

# OCR for scanned documents
def extract_ocr_text(pdf_path):
    images = convert_from_path(pdf_path)
    full_text = ""
    for image in images:
        text = pytesseract.image_to_string(image)
        full_text += text + "\n"
    return full_text

# Handwriting recognition
def extract_handwriting(image_path):
    image = Image.open(image_path)
    text = pytesseract.image_to_string(image, config='--psm 6')
    return text
```

### 2. Table Extraction

```python
import pdfplumber
import pandas as pd

# Extract tables from PDF
def extract_tables_from_pdf(pdf_path):
    tables = []
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            page_tables = page.extract_tables()
            for table in page_tables:
                df = pd.DataFrame(table[1:], columns=table[0])
                tables.append(df)
    return tables

# Save to CSV
def save_tables_to_csv(pdf_path, output_dir):
    tables = extract_tables_from_pdf(pdf_path)
    for i, df in enumerate(tables):
        df.to_csv(f'{output_dir}/table_{i}.csv', index=False)

# Convert to JSON
def tables_to_json(tables):
    json_tables = []
    for table in tables:
        json_tables.append(table.to_dict(orient='records'))
    return json_tables
```

### 3. Word Document Parsing

```python
from docx import Document
from docx.shared import Pt, RGBColor

# Read DOCX
def extract_docx_content(docx_path):
    doc = Document(docx_path)
    content = {
        'paragraphs': [],
        'tables': [],
        'images': []
    }

    for para in doc.paragraphs:
        content['paragraphs'].append({
            'text': para.text,
            'style': para.style.name,
            'level': para.level
        })

    for table in doc.tables:
        table_data = []
        for row in table.rows:
            row_data = [cell.text for cell in row.cells]
            table_data.append(row_data)
        content['tables'].append(table_data)

    return content

# Generate DOCX report
def create_report(title, sections, output_path):
    doc = Document()
    doc.add_heading(title, 0)

    for section_title, section_content in sections.items():
        doc.add_heading(section_title, 1)
        doc.add_paragraph(section_content)

    doc.save(output_path)
```

### 4. Excel Data Extraction

```python
import pandas as pd
import openpyxl

# Read Excel with multiple sheets
def extract_excel_sheets(xlsx_path):
    sheets = {}
    excel_file = pd.ExcelFile(xlsx_path)

    for sheet_name in excel_file.sheet_names:
        df = pd.read_excel(xlsx_path, sheet_name=sheet_name)
        sheets[sheet_name] = df

    return sheets

# Extract specific data and transform
def extract_and_transform(xlsx_path, sheet_name):
    df = pd.read_excel(xlsx_path, sheet_name=sheet_name)

    # Clean data
    df = df.dropna()
    df.columns = df.columns.str.lower().str.replace(' ', '_')

    # Transform
    df['date'] = pd.to_datetime(df['date'])
    df['amount'] = pd.to_numeric(df['amount'])

    return df.to_dict(orient='records')
```

### 5. Knowledge Extraction Pipeline

```python
import json
import re

def extract_knowledge_structure(content):
    """Convert document to structured knowledge"""

    knowledge = {
        'summary': extract_summary(content),
        'key_points': extract_key_points(content),
        'references': extract_references(content),
        'metadata': extract_metadata(content),
        'structured_data': extract_structured_data(content)
    }

    return knowledge

def extract_key_points(content):
    """Extract bullet points and numbered lists"""
    key_points = []

    # Match bullet points
    bullets = re.findall(r'[•\-\*]\s*(.+?)(?=\n|$)', content)
    key_points.extend(bullets)

    # Match numbered lists
    numbered = re.findall(r'\d+\.\s*(.+?)(?=\n|$)', content)
    key_points.extend(numbered)

    return key_points

def extract_references(content):
    """Extract citations and links"""
    references = []

    # URLs
    urls = re.findall(r'https?://[^\s]+', content)
    references.extend(urls)

    # Citations (Author, Year)
    citations = re.findall(r'(\w+\s*(?:et al\.)?,\s*\d{4})', content)
    references.extend(citations)

    return references

def extract_metadata(content):
    """Extract document metadata"""
    return {
        'word_count': len(content.split()),
        'sentence_count': len(re.split(r'[.!?]+', content)),
        'has_tables': '|' in content or '─' in content,
        'has_citations': bool(re.search(r'(\w+,\s*\d{4})', content))
    }

def extract_structured_data(content):
    """Convert key-value pairs to structured JSON"""
    data = {}

    # Pattern: Key: Value
    patterns = re.findall(r'(\w+[\w\s]*?):\s*([^\n]+)', content)
    for key, value in patterns:
        data[key.strip().lower()] = value.strip()

    return data
```

### 6. Batch Document Processing

```python
import os
from pathlib import Path

def batch_process_documents(input_dir, output_dir):
    """Process all documents in a directory"""

    Path(output_dir).mkdir(exist_ok=True)
    results = []

    for file_path in os.listdir(input_dir):
        full_path = os.path.join(input_dir, file_path)

        try:
            if file_path.endswith('.pdf'):
                content = extract_pdf_text(full_path)
                processed = extract_knowledge_structure(content)

            elif file_path.endswith('.docx'):
                content = extract_docx_content(full_path)
                processed = content

            elif file_path.endswith('.xlsx'):
                processed = extract_excel_sheets(full_path)

            # Save results
            output_file = f"{output_dir}/{Path(file_path).stem}.json"
            with open(output_file, 'w') as f:
                json.dump(processed, f, indent=2)

            results.append({
                'file': file_path,
                'status': 'success',
                'output': output_file
            })

        except Exception as e:
            results.append({
                'file': file_path,
                'status': 'error',
                'error': str(e)
            })

    return results
```

## Tool References

- **PyPDF2:** Text extraction from PDFs
- **pdfplumber:** Table extraction and precise location
- **python-docx:** Word document handling
- **pandas:** Excel and data manipulation
- **pytesseract:** OCR (requires Tesseract installation)
- **pdf2image:** PDF to image conversion
- **OpenAI Vision:** For complex document layout understanding

## Common Use Cases

1. **Research Paper Analysis** → Extract key findings and citations
2. **Financial Reports** → Extract tables and metrics
3. **Compliance Documents** → Convert to structured formats
4. **Meeting Minutes** → Convert handwritten notes to digital
5. **Knowledge Bases** → Build searchable indexes from documents
6. **Batch Processing** → Convert 100s of documents at once

---

**Enhanced version combining PDF OCR, DOCX/XLSX parsing, table extraction, document merging, and knowledge extraction.**
