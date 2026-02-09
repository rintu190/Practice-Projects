import random
import re
import json
import os

# -----------------------------
# 1️⃣ Neuron Class
# -----------------------------
class Neuron:
    def __init__(self, name):
        self.name = name
        self.connections = {}  # {Neuron: weight}

    def connect(self, neuron, weight=None):
        if weight is None:
            weight = random.uniform(0.5, 1.0)
        if neuron in self.connections:
            self.connections[neuron] = min(1.0, self.connections[neuron] + 0.1)
        else:
            self.connections[neuron] = weight

    def activate(self, activated=None, depth=2):
        if activated is None:
            activated = {}
        if self in activated or depth == 0:
            return activated
        activated[self] = activated.get(self, 0) + 1
        for neuron, weight in self.connections.items():
            if random.random() < weight:
                neuron.activate(activated, depth-1)
        return activated

# -----------------------------
# 2️⃣ Brain Class
# -----------------------------
class Brain:
    def __init__(self):
        self.neurons = {}  # concept string -> Neuron

    # Extract concepts from paragraph/text
    def extract_concepts(self, text):
        sentences = re.split(r'[.!?]', text)
        concepts = []
        for s in sentences:
            words = [w.lower() for w in re.findall(r'\b\w+\b', s)]
            if words:
                concepts.append(' '.join(words))
        return concepts

    # Learn text
    def learn_text(self, text):
        concepts = self.extract_concepts(text)
        for i, c in enumerate(concepts):
            if c not in self.neurons:
                self.neurons[c] = Neuron(c)
            for j in range(len(concepts)):
                if i != j:
                    if concepts[j] not in self.neurons:
                        self.neurons[concepts[j]] = Neuron(concepts[j])
                    self.neurons[c].connect(self.neurons[concepts[j]])
        print(f"Learned {len(concepts)} concepts from text.")

    # Reasoned recall
    def recall(self, query, depth=3, threshold=0.5):
        query = query.lower()
        matches = [c for c in self.neurons if query in c]
        if not matches:
            return f"Unknown concept: {query}"
        neuron = self.neurons[matches[0]]

        # Activate network
        activated = neuron.activate(depth=depth)

        # Score by connection strength
        scored = {}
        for n, score in activated.items():
            weight_sum = sum(n.connections.values())
            scored[n.name] = weight_sum * score

        high_relevance = [k for k, v in scored.items() if v >= threshold]
        if not high_relevance:
            high_relevance = sorted(scored, key=lambda x: -scored[x])[:5]

        # Synthesize short answer
        words = []
        for c in high_relevance:
            words.extend(c.split())
        words = list(dict.fromkeys(words))
        response = ' '.join(words[:min(20, len(words))])
        return response

    # -----------------------------
    # 3️⃣ JSON Persistence
    # -----------------------------
    def save_to_json(self, filename="brain_memory.json"):
        data = {}
        for concept, neuron in self.neurons.items():
            data[concept] = {n.name: w for n, w in neuron.connections.items()}
        with open(filename, "w") as f:
            json.dump(data, f)
        print(f"Memory saved to {filename}.")

    def load_from_json(self, filename="brain_memory.json"):
        if not os.path.exists(filename):
            print("No saved memory found. Starting fresh.")
            return
        with open(filename, "r") as f:
            data = json.load(f)
        for concept, connections in data.items():
            if concept not in self.neurons:
                self.neurons[concept] = Neuron(concept)
            for c_name, w in connections.items():
                if c_name not in self.neurons:
                    self.neurons[c_name] = Neuron(c_name)
                self.neurons[concept].connect(self.neurons[c_name], weight=w)
        print(f"Memory loaded from {filename}.")

# -----------------------------
# 4️⃣ Interactive AGI Loop
# -----------------------------
if __name__ == "__main__":
    brain = Brain()
    brain.load_from_json()

    print("=== Mini Brain AGI with Persistent Memory ===")
    print("Commands: learn / retrieve / exit")

    while True:
        cmd = input("\nCommand: ").strip().lower()
        if cmd == "learn":
            text = input("Enter paragraph/text to learn:\n").strip()
            brain.learn_text(text)
            brain.save_to_json()  # Auto-save after learning
        elif cmd == "retrieve":
            query = input("Enter query word/phrase:\n").strip()
            response = brain.recall(query)
            print(f"AGI Response: {response}")
        elif cmd == "exit":
            print("Exiting AGI...")
            brain.save_to_json()
            break
        else:
            print("Unknown command. Use learn/retrieve/exit.")
