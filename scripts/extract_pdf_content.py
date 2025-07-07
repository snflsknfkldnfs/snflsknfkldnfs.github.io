#!/usr/bin/env python3
"""
Standardized PDF Content Extraction Script for Educational Repository
Author: Claude Code Assistant
Purpose: Extract text content from PDFs in repository for Claude MCP integration
"""

import os
import sys
import json
import argparse
import hashlib
import re
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Tuple, Dict

try:
    from PyPDF2 import PdfReader
    HAS_PYPDF2 = True
except ImportError:
    HAS_PYPDF2 = False

try:
    from pytesseract import image_to_string
    from PIL import Image
    import fitz  # PyMuPDF
    import io
    HAS_OCR = True
except ImportError:
    HAS_OCR = False

class PDFExtractor:
    """Standardized PDF content extractor for educational materials."""
    
    def __init__(self, max_pages: int = 10, languages: List[str] = None):
        self.max_pages = max_pages
        self.languages = languages or ['deu', 'eng']
        self.ocr_lang = '+'.join(self.languages)
        
        if not HAS_PYPDF2:
            raise ImportError("PyPDF2 not installed. Run: pip install PyPDF2")
    
    def is_scanned_pdf(self, pdf_path: str) -> bool:
        """Check if PDF contains only images (scanned document)."""
        try:
            reader = PdfReader(pdf_path)
            for page in reader.pages[:3]:  # Check first 3 pages
                text = page.extract_text().strip()
                if text and len(text) > 50:  # Reasonable text threshold
                    return False
            return True
        except Exception:
            return False
    
    def extract_text_from_scanned(self, pdf_path: str, pages: List[int]) -> str:
        """Extract text from scanned PDF using OCR."""
        if not HAS_OCR:
            return "OCR dependencies not available. Install: pip install pytesseract Pillow PyMuPDF"
        
        try:
            doc = fitz.open(pdf_path)
            extracted_text = []
            
            for page_num in pages:
                if page_num >= len(doc):
                    continue
                    
                page = doc.load_page(page_num)
                pix = page.get_pixmap(matrix=fitz.Matrix(2.0, 2.0))  # Higher resolution
                img = Image.open(io.BytesIO(pix.tobytes()))
                
                # OCR with specified languages
                text = image_to_string(img, lang=self.ocr_lang)
                if text.strip():
                    extracted_text.append(f"=== Seite {page_num + 1} (OCR) ===\n{text.strip()}")
            
            doc.close()
            return "\n\n".join(extracted_text)
            
        except Exception as e:
            return f"OCR-Extraktion fehlgeschlagen: {str(e)}"
    
    def extract_text_from_normal(self, pdf_path: str, pages: List[int]) -> str:
        """Extract text from normal PDF."""
        try:
            reader = PdfReader(pdf_path)
            extracted_text = []
            
            for page_num in pages:
                if page_num >= len(reader.pages):
                    continue
                    
                page = reader.pages[page_num]
                text = page.extract_text()
                if text.strip():
                    extracted_text.append(f"=== Seite {page_num + 1} ===\n{text.strip()}")
            
            return "\n\n".join(extracted_text)
            
        except Exception as e:
            return f"Text-Extraktion fehlgeschlagen: {str(e)}"
    
    def get_pdf_metadata(self, pdf_path: str) -> Dict:
        """Extract PDF metadata."""
        try:
            reader = PdfReader(pdf_path)
            metadata = {
                'total_pages': len(reader.pages),
                'title': None,
                'author': None,
                'subject': None,
                'creator': None
            }
            
            if reader.metadata:
                metadata.update({
                    'title': reader.metadata.get('/Title'),
                    'author': reader.metadata.get('/Author'),
                    'subject': reader.metadata.get('/Subject'),
                    'creator': reader.metadata.get('/Creator')
                })
            
            return metadata
            
        except Exception:
            return {'total_pages': 0}
    
    def extract_content(self, pdf_path: str, max_pages: Optional[int] = None) -> Tuple[str, Dict]:
        """Main extraction method returning content and metadata."""
        if not os.path.exists(pdf_path):
            raise FileNotFoundError(f"PDF nicht gefunden: {pdf_path}")
        
        max_pages = max_pages or self.max_pages
        pdf_metadata = self.get_pdf_metadata(pdf_path)
        total_pages = pdf_metadata.get('total_pages', 0)
        
        if total_pages == 0:
            raise ValueError("PDF konnte nicht gelesen werden")
        
        # Determine pages to extract
        pages_to_extract = list(range(min(max_pages, total_pages)))
        
        # Check if scanned
        is_scanned = self.is_scanned_pdf(pdf_path)
        
        # Extract content
        if is_scanned and HAS_OCR:
            content = self.extract_text_from_scanned(pdf_path, pages_to_extract)
            extraction_type = "OCR"
        else:
            content = self.extract_text_from_normal(pdf_path, pages_to_extract)
            extraction_type = "Direct" if not is_scanned else "Direct (OCR nicht verfügbar)"
        
        # Create metadata
        file_size = os.path.getsize(pdf_path)
        file_hash = hashlib.md5(open(pdf_path, 'rb').read()).hexdigest()[:8]
        
        metadata = {
            'source_file': pdf_path,
            'extracted_at': datetime.now().isoformat(),
            'extraction_type': extraction_type,
            'is_scanned': is_scanned,
            'total_pages': total_pages,
            'extracted_pages': len(pages_to_extract),
            'file_size': file_size,
            'content_length': len(content),
            'file_hash': file_hash,
            'pdf_metadata': pdf_metadata
        }
        
        return content, metadata

def sanitize_filename(filename: str) -> str:
    """Create filesystem-safe filename."""
    base = Path(filename).stem
    safe = re.sub(r'[^\w\-_.]', '_', base)
    return safe[:100]

def create_extraction_summary(extracted_files: List[Dict]) -> Dict:
    """Create summary of extraction process."""
    successful = [f for f in extracted_files if f['status'] == 'success']
    failed = [f for f in extracted_files if f['status'] == 'failed']
    
    return {
        'extraction_date': datetime.now().isoformat(),
        'total_files': len(extracted_files),
        'successful_extractions': len(successful),
        'failed_extractions': len(failed),
        'total_content_length': sum(f.get('content_length', 0) for f in successful),
        'extraction_tool': 'standardized_pdf_extractor_v1.0',
        'files': extracted_files
    }

def main():
    parser = argparse.ArgumentParser(description='Extract PDF content for Claude MCP integration')
    parser.add_argument('paths', nargs='*', help='PDF files or directories to process')
    parser.add_argument('--output-dir', '-o', default='extracted_content', 
                       help='Output directory for extracted content')
    parser.add_argument('--max-pages', '-p', type=int, default=10,
                       help='Maximum pages to extract per PDF')
    parser.add_argument('--force', '-f', action='store_true',
                       help='Force re-extraction of existing files')
    parser.add_argument('--recursive', '-r', action='store_true',
                       help='Search directories recursively')
    parser.add_argument('--languages', '-l', nargs='+', default=['deu', 'eng'],
                       help='OCR languages (default: deu eng)')
    
    args = parser.parse_args()
    
    # Create output directories
    output_dir = Path(args.output_dir)
    metadata_dir = output_dir / 'metadata'
    output_dir.mkdir(exist_ok=True)
    metadata_dir.mkdir(exist_ok=True)
    
    # Find PDF files
    pdf_files = []
    
    if not args.paths:
        # Default: search current directory
        search_paths = ['.']
    else:
        search_paths = args.paths
    
    for path in search_paths:
        path_obj = Path(path)
        if path_obj.is_file() and path_obj.suffix.lower() == '.pdf':
            pdf_files.append(path_obj)
        elif path_obj.is_dir():
            if args.recursive:
                pdf_files.extend(path_obj.rglob('*.pdf'))
            else:
                pdf_files.extend(path_obj.glob('*.pdf'))
    
    if not pdf_files:
        print("Keine PDF-Dateien gefunden.")
        return
    
    print(f"Gefunden: {len(pdf_files)} PDF-Dateien")
    
    # Initialize extractor
    extractor = PDFExtractor(max_pages=args.max_pages, languages=args.languages)
    
    # Process files
    extracted_files = []
    
    for pdf_file in pdf_files:
        safe_name = sanitize_filename(str(pdf_file))
        output_file = output_dir / f"{safe_name}.txt"
        metadata_file = metadata_dir / f"{safe_name}.json"
        
        # Skip if already exists and not forcing
        if output_file.exists() and not args.force:
            print(f"Übersprungen (existiert bereits): {pdf_file}")
            continue
        
        print(f"Verarbeite: {pdf_file}")
        
        try:
            content, metadata = extractor.extract_content(str(pdf_file), args.max_pages)
            
            # Write content file
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(f"# Extrahiert aus: {pdf_file}\n")
                f.write(f"# Extraktionsdatum: {metadata['extracted_at']}\n")
                f.write(f"# Seiten: {metadata['extracted_pages']}/{metadata['total_pages']}\n")
                f.write(f"# Typ: {metadata['extraction_type']}\n\n")
                f.write(content)
            
            # Write metadata file
            with open(metadata_file, 'w', encoding='utf-8') as f:
                json.dump(metadata, f, indent=2, ensure_ascii=False)
            
            extracted_files.append({
                'source': str(pdf_file),
                'output_file': str(output_file),
                'metadata_file': str(metadata_file),
                'status': 'success',
                'content_length': len(content),
                'extraction_type': metadata['extraction_type']
            })
            
            print(f"  ✓ Erfolgreich: {len(content)} Zeichen extrahiert")
            
        except Exception as e:
            print(f"  ✗ Fehler: {e}")
            
            # Create error file
            error_file = output_dir / f"{safe_name}_ERROR.txt"
            with open(error_file, 'w', encoding='utf-8') as f:
                f.write(f"# FEHLER bei Extraktion aus: {pdf_file}\n")
                f.write(f"# Fehlerdatum: {datetime.now().isoformat()}\n")
                f.write(f"# Fehler: {str(e)}\n")
            
            extracted_files.append({
                'source': str(pdf_file),
                'output_file': str(error_file),
                'status': 'failed',
                'error': str(e)
            })
    
    # Create summary
    summary = create_extraction_summary(extracted_files)
    summary_file = output_dir / 'extraction_summary.json'
    
    with open(summary_file, 'w', encoding='utf-8') as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)
    
    # Print summary
    print(f"\n=== Zusammenfassung ===")
    print(f"Verarbeitet: {summary['total_files']}")
    print(f"Erfolgreich: {summary['successful_extractions']}")
    print(f"Fehlgeschlagen: {summary['failed_extractions']}")
    print(f"Gesamter Textinhalt: {summary['total_content_length']} Zeichen")
    print(f"Ausgabe: {output_dir}")

if __name__ == "__main__":
    main()