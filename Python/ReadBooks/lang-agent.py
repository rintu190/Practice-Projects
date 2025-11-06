from langchain_community.document_loaders import DirectoryLoader, PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Chroma
from langchain_community.llms import Ollama
from langchain.agents import initialize_agent, Tool
from langchain.chains import RetrievalQA

# -----------------------------
# 1. Load PDF Documents
# -----------------------------
print("Loading PDF files...")
loader = DirectoryLoader("./books", glob="*.pdf", loader_cls=PyPDFLoader)
docs = loader.load()

# -----------------------------
# 2. Split into Chunks
# -----------------------------
print("Splitting documents into chunks...")
splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=150)
chunks = splitter.split_documents(docs)

# -----------------------------
# 3. Embeddings Model
# -----------------------------
print("Creating embeddings...")
embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-mpnet-base-v2")

# -----------------------------
# 4. Vector Store (Chroma)
# -----------------------------
print("Indexing into Chroma vector database...")
vectordb = Chroma.from_documents(chunks, embeddings)

retriever = vectordb.as_retriever(search_kwargs={"k": 5})

# -----------------------------
# 5. Local LLaMA Model (Ollama)
# -----------------------------
llm = Ollama(model="llama3.2")

# -----------------------------
# 6. Create RAG QA Chain
# -----------------------------
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    retriever=retriever,
    chain_type="stuff"
)

# -----------------------------
# 7. Convert RAG into Agent Tool
# -----------------------------
tools = [
    Tool(
        name="SearchBooks",
        func=qa_chain.run,
        description="Use this tool to answer questions based on the loaded PDF books."
    )
]

agent = initialize_agent(
    tools=tools,
    llm=llm,
    agent="zero-shot-react-description",
    verbose=True
)

# -----------------------------
# 8. Chat Loop
# -----------------------------
print("\n✅ System ready. Ask anything from your books.")
print("Type 'exit' to quit.\n")

while True:
    query = input("Ask → ")
    if query.lower() in ["exit", "quit", "bye"]:
        print("Goodbye!")
        break

    result = agent.run(query)
    print("\nAnswer →\n", result, "\n")
