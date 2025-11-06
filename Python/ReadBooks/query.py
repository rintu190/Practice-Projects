import subprocess
from sentence_transformers import SentenceTransformer
import chromadb

embedder = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

chroma_client = chromadb.PersistentClient(path="db")
collection = chroma_client.get_collection("library")

def ask_llama(prompt):
    result = subprocess.run(
        ["ollama", "run", "llama3:instruct"],
        text=True, input=prompt, capture_output=True
    )
    return result.stdout

while True:
    query = input("\n❓ Ask something : ")
    if query.lower() in ["exit", "quit"]:
        break

    q_vec = embedder.encode(query).tolist()
    results = collection.query(query_embeddings=[q_vec], n_results=5)

    context = "\n\n".join(results["documents"][0])

    prompt = f"""
Use the context below to answer the question accurately.
If the answer is not in the context, say "Not found in provided documents."

### Context:
{context}

### Question:
{query}

### Answer:
"""

    answer = ask_llama(prompt)
    print("\n💡 Answer:", answer)
