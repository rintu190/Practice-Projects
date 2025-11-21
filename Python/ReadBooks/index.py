import fitz  # pymupdf
import os
from sentence_transformers import SentenceTransformer
from langchain_text_splitters import RecursiveCharacterTextSplitter

import chromadb

# Load embedding model (local, no internet)
embedder = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

# Local Vector DB
chroma_client = chromadb.PersistentClient(path="db")
collection = chroma_client.get_or_create_collection("library")

def extract_text(pdf_path):
    doc = fitz.open(pdf_path)
    return "\n".join(page.get_text() for page in doc)

splitter = RecursiveCharacterTextSplitter(chunk_size=800, chunk_overlap=100)

for file in os.listdir("books"):
    if file.endswith(".pdf"):
        print(f"Processing: {file}")
        text = extract_text(os.path.join("books", file))
        chunks = splitter.split_text(text)

        for i, chunk in enumerate(chunks):
            vec = embedder.encode(chunk).tolist()
            collection.add(
                documents=[chunk],
                embeddings=[vec],
                ids=[f"{file}-{i}"]
            )

print("✅ Indexing Complete. All PDFs processed and stored locally!")
