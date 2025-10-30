from treelib import Node, Tree

tree = Tree()
tree.create_node("root","root")
tree.create_node("left child","left",parent="root")
tree.create_node("right child","right",parent="root")
tree.create_node("left grandchild","left_grand",parent = "left")
tree.create_node("right grandchild","right_grand",parent = "left")

tree.show()

print("pre-order traversal")
for node in tree.all_nodes():
    print(node.tag)
tree.show(line_type = "ascii-em")

# create_node(tag, node_id=None, parent=None): Creates a new node with the specified tag and optional data. Optionally specifies the node identifier (node_id) and parent node (parent).
# remove_node(node_id): Removes the node with the specified identifier from the tree.
# get_node(node_id): Retrieves the node with the specified identifier from the tree.
# update_node(node_id, tag=None, data=None): Updates the tag and/or data of the node with the specified identifier.
# contains(node_id): Checks if the tree contains a node with the specified identifier.
# parent(node_id): Returns the parent node identifier of the node with the specified identifier.
# children(node_id): Returns a list of identifiers of the children nodes of the node with the specified identifier.
# depth(node_id): Calculates the depth of the node with the specified identifier in the tree.
# size(node_id=None): Calculates the size (number of nodes) of the subtree rooted at the node with the specified identifier. If no identifier is provided, calculates the size of the entire tree.
# height(node_id=None): Calculates the height (maximum depth) of the subtree rooted at the node with the specified identifier. If no identifier is provided, calculates the height of the entire tree.
# show(line_type="ascii"): Prints a textual representation of the tree

#------------------Binary search Tree--------------------------------------
import bisect
sortedList = [1,3,4,5,9]
newElement = 6
insertionPoint = bisect.bisect_left(sortedList, newElement)
sortedList.insert(insertionPoint, newElement)
print("Sorted list after insertion: ",sortedList)
print("new element inserted at index: ",insertionPoint)

# bisect(list, num, beg, end): This function returns the position in the sorted list.
# bisect.bisect_left()
# bisect.bisect_right()
# bisect.insort_left()
# bisect.insort_right()
# bisect.insort()
#---------------------Interval Tree-----------------------------------------
from intervaltree import IntervalTree, Interval

tree = IntervalTree()
tree.add(Interval(1,5))
tree.add(Interval(3,8))
tree.add(Interval(5,10))
tree.add(Interval(12,15))

queryRange = (4,7)
resultInterval = tree.overlap(*queryRange)
print("interval that overlap with query rnage", resultInterval)
for interval in resultInterval:
    print("start: ",interval.begin," end: ",interval.end)

# add(interval): Adds an interval to the interval tree.
# remove(interval): Removes an interval from the interval tree.
# search(begin): Searches for intervals that overlap with the given range defined by begin and end (inclusive).
# overlap(begin): Alias for search(). Searches for intervals that overlap with the given range defined by begin and end.
# at(begin): Searches for intervals that contain the specified point begin. Returns a set of intervals that contain the point.
# clear(): Clears all intervals from the interval tree, making it empty.
# copy(): Creates a shallow copy of the interval tree, including all intervals.
# discard(interval): Removes an interval from the interval tree if it exists, similar to the remove() method.
# items(): Returns a generator that yields all intervals stored in the interval tree.
# size(): Returns the number of intervals stored in the interval tree.
# empty(): Returns True if the interval tree is empty, False otherwise.

#---------------------Trie-----------------------------------------
from trie import Trie
# import pygtrie

trie = Trie()
trie.insert("apple")
trie.insert("banana")
trie.insert("app")
trie.insert("bat")
trie.insert("ball")

print("Search result")
print("does apple exist? ",trie.search("apple"))

print("starts with results")
print("any word starts with ap", trie.startswith("ap"))
print("autocomplete", trie.autocomplete("ba"))

trie.delete("apple")
print(trie.words())

print("total words: ",trie.count_words())
print("number of words with prefix ba", trie.count_prefixes("ba"))

# Trie(): Constructor method to create a new Trie object.
# insert(str) -> None: Inserts a word into the trie.
# search(str): Searches for a word in the trie. Returns True if the word is found, otherwise False.
# startswith(prefix: str): Checks if any word in the trie starts with the given prefix. Returns True if a word starts with the prefix, otherwise False.
# delete(word: str): Deletes a word from the trie.
# words(prefix: str = ''): Returns a list .of words in the trie that start with the given prefix.
