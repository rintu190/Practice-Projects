import array
int_array = array.array('i',[1, 2, 3, 4])
print(int_array[0])

# Method        	Description
# append(x)	        Adds an item x to the end of the array.
# buffer_info()	    Returns a tuple (address, length) of the memory buffer.
# byteswap()	    Swaps the byte order (for endian conversion).
# count(x)	        Returns the number of times x occurs in the array.
# extend(iterable)	Extends the array by appending elements from an iterable.
# frombytes(bytes)	Appends elements from a byte object.
# fromlist(list)	Appends items from a list.
# fromunicode(str)	Extends array with unicode string (only for 'u' type — deprecated).
# index(x)	        Returns the first index of item x.
# insert(i, x)	    Inserts item x at position i.
# pop([i])	        Removes and returns item at index i (or last item if i not provided).
# remove(x)	        Removes the first occurrence of x.
# reverse()	        Reverses the items in the array in place.
# tolist()	        Returns a Python list with the same elements.
# tobytes()	        Converts the array to a bytes object.
# tofile(file)	    Writes array to a binary file.
# fromfile(file, n)	Reads n items from a binary file and appends to array.
# typecode (p)	    Returns the type code character ('i', 'f', etc.).
# itemsize (p)	    Size (in bytes) of one array item.
#---------------------------------------------------------------------------
from collections import deque

my_deque = deque()
my_deque.append(1)
my_deque.appendleft(2)

ele = my_deque.pop()
ele = my_deque.popleft()

# Method	            Description
# append(x)	            Add x to the right end of the deque.
# appendleft(x)	        Add x to the left end of the deque.
# pop()	                Remove and return an item from the right end.
# popleft()	            Remove and return an item from the left end.
# extend(iterable)	    Extend the right side by appending elements from the iterable.
# extendleft(iterable)	Extend the left side by appending elements from the iterable (in reverse order).
# clear()	            Remove all elements.
# copy()	            Create a shallow copy of the deque.
# count(x)	            Count the number of times x appears.
# index(x, start, end)	Return the index of x (optionally between start and end).
# insert(i, x)	        Insert x at position i.
# remove(x)	            Remove the first occurrence of x.
# reverse()	            Reverse the deque in place.
# rotate(n=1)	        Rotate the deque n steps to the right (left if n is negative).
# maxlen (property)	    The maximum size of the deque (or None if unlimited).
#---------------------------------------------------------------------------
from queue import Queue

myQueue = Queue()
myQueue.put(1)
ele = myQueue.get()
print(myQueue.empty())
print(myQueue.qsize())


# Class	                    Description
# queue.Queue	            FIFO Queue – First-In-First-Out.
# queue.LifoQueue	        LIFO Queue – Last-In-First-Out (like a stack).
# queue.PriorityQueue	    Items retrieved in priority order (lowest first).
# queue.SimpleQueue	        Unbounded FIFO queue – simpler and faster, but no task tracking. (Python 3.7+)


# Method	            Description
# put(item)	            Add item to queue. (Blocks if full)
# put_nowait(item)	    Add item without blocking. Raises queue.Full.
# get()	                Remove and return item. (Blocks if empty)
# get_nowait()	        Non-blocking get. Raises queue.Empty.
# empty()	            Returns True if queue is empty.
# full()	            Returns True if queue is full.
# qsize()	            Approximate size of the queue.
# task_done()	        Indicate a formerly enqueued task is complete.
# join()	            Blocks until all tasks are marked done.
#---------------------------------------------------------------------------
import heapq

li = [5, 7, 9, 1, 3]
heapq.heapify(li)
print ('The created heap is :',(list(li)))

# Function	                        Description
# heapq.heappush(heap, val)	        Push val onto the heap, maintaining heap order
# heapq.heappop(heap)	            Pop and return the smallest element
# heapq.heappushpop(heap, val)	    Push then pop in one atomic step
# heapq.heapreplace(heap, val)	    Pop and then push (more efficient if replacing)
# heapq.heapify(list)	            Transform a list into a valid heap in-place
# heapq.nlargest(n, iterable)	    Return n largest elements
# heapq.nsmallest(n, iterable)	    Return n smallest elements
#--------------------------------------------------------------
from collections import Counter
from collections import ChainMap 
from collections import defaultdict
from collections import OrderedDict

my_list = ['apple', 'banana', 'apple', 'orange', 'apple', 'banana']
my_counter = Counter(my_list)
print(my_counter)

    
d1 = {'a': 1, 'b': 2} 
d2 = {'c': 3, 'd': 4} 
d3 = {'e': 5, 'f': 6} 
c = ChainMap(d1, d2, d3) 

my_defaultdict = defaultdict(int)
my_ordered_dict = OrderedDict()

# Method	                    Description
# Counter(iterable)	            Count items from list/string
# c.most_common(n)	            Return top n most common elements
# c.elements()	                Iterator over elements repeating as per count
# c.update(iterable)	        Add counts from iterable or another Counter
# c.subtract(iterable)	        Subtract counts using iterable or another Counter
# c.total() (Python 3.10+)	    Total of all counts
# c.clear()	                    Remove all counts
# c.fromkeys(iterable, value)   Class method that creates a new Counter object from an iterable
#---------------------------------------------------------------

# Data Structures & Algorithms Modules in Python
# ├── Built-in Types
# │   ├── list          → Dynamic arrays
# │   ├── tuple         → Immutable sequences
# │   ├── set           → Unordered unique elements
# │   └── dict          → Hash maps (key-value pairs)
# │
# ├── collections (High-performance alternatives)
# │   ├── deque         → Doubly-ended queue
# │   ├── defaultdict   → Dict with default factory
# │   ├── OrderedDict   → Dict that remembers order (Python < 3.7)
# │   ├── Counter       → Frequency counter
# │   └── namedtuple    → Lightweight object types
# │
# ├── array
# │   └── array         → Typed array (more memory-efficient than list)
# │
# ├── heapq
# │   ├── heappush      → Push item onto heap
# │   ├── heappop       → Pop smallest item
# │   └── heapify       → Convert list into heap
# │
# ├── queue
# │   ├── Queue         → Thread-safe FIFO
# │   ├── LifoQueue     → Thread-safe LIFO (stack)
# │   └── PriorityQueue → Thread-safe priority queue
# │
# ├── bisect
# │   ├── bisect_left   → Binary search insert position
# │   ├── bisect_right  → Same as above but right-most
# │   └── insort        → Insert while maintaining order
# │
# ├── itertools
# │   ├── combinations
# │   ├── permutations
# │   ├── product
# │   ├── cycle, count, repeat
# │   └── islice, chain, groupby
# │
# ├── functools
# │   ├── lru_cache     → Memoization
# │   └── reduce        → Apply function cumulatively
# │
# ├── math
# │   ├── gcd, lcm, factorial
# │   ├── isqrt, pow, sqrt
# │   └── comb, perm    → Combinatorics
# │
# ├── statistics
# │   ├── mean, median, mode
# │   └── stdev, variance
# │
# └── External Libraries (Optional but powerful)
#     ├── numpy         → Arrays, matrices, number crunching
#     ├── pandas        → DataFrames, Series
#     ├── networkx      → Graph algorithms
#     ├── sympy         → Symbolic math
#     └── sortedcontainers → Fast sorted data structures
#---------------------------------------------------------------
# Data Structures
# Library	            Description
# treelib	            Tree data structures (N-ary, binary trees)
# sortedcontainers	    Fast and pure-Python implementations of sorted list, dict, and set
# BTrees	            Scalable tree structures with O(log n) performance
# blist (archived)	    List-like structure with better slicing and insert performance
# intervaltree	        Interval (range-based) search trees

# 📊 Math, Number Theory & Algorithms
# Library	            Description
# sympy	                Symbolic math (GCD, primes, simplification, etc.)
# numpy	                Fast numerical arrays and vectorized operations
# gmpy2	                Fast arithmetic for large numbers (GCD, primes, etc.)
# mpmath	            Arbitrary-precision arithmetic
# scipy	                Scientific computing algorithms (graphs, optimization, etc.)

# 📉 Graphs & Trees
# Library	            Description
# networkx	            Graph data structures, traversal, shortest path, etc.
# igraph	            Fast graph algorithms (C-based)
# graph-tool	        High-performance graph library (C++ backend)
# pygraphviz	        Python wrapper for Graphviz for visualizing graphs

# 🔍 Search, Text, Compression
# Library	            Description
# whoosh	            Pure Python search engine for text indexing
# marisa-trie	        Fast trie (prefix tree) implementation
# pytrie	            Simple trie for dictionary-like access
# lzma, zlib	        Compression algorithms (built-in and external)

# 🔗 Parallelism / Performance
# Library	            Description
# numba	                JIT compilation for Python (use decorators to accelerate functions)
# cython	            Compile Python to C for performance gains
# multiprocessing	    Built-in, but often extended for parallel DSA problems
# concurrent.futures	Thread/Process pools
# joblib	            Parallel processing made easy (common in ML pipelines)

# 📦 Other Tools for DSA Practice
# Tool	                            Description
# PyRextester, OnlineGDB	        Run multi-language code online (great for DSA practice)
# Leetcode                          API Wrappers	Some wrappers help run/test Leetcode problems locally
# competitive-programming-helper    Automate input/output test cases in contests
# kattis-cli, cf-tool	             Command-line tools to run and submit problems on Kattis, Codeforces, etc.