//
//  TreeHier.swift
//  Swift-Utilities
//
//  Created by tridiak on 26/01/19.
//  Copyright © 2019 tridiak. All rights reserved.
//

import Foundation

enum HierNodeEx :Error {
	case generic
	case nodeBounds
	case nodeInUse
	case hasAParent
}

// Used by GatherChildren(). Return an array of children for passed path.
typealias HierNodeChildBlock = (PathClass) -> [PathClass]

// Used by Iterate(). Called for each node.
typealias HierNodeItrBlock = (HierNode, Int) -> HierNode.IterateResult

// Is LHS < RHS. Used by SiblingSort().
typealias HierNodeSortBlock = (HierNode, HierNode) -> Bool

//-----------------------------------------------
#if DEBUG
fileprivate let IDs = AtomicInteger<UInt64>()
#endif

/*
Creates a hierarchy of linked nodes.

If a node has children, it will only store a reference to its first child.
Children are a linked list. First child's previous sibling should be nil.
All children have a reference to their parent.

To gather the children of a node, call GatherChildren() with a children retrieval block or
subclass HierNode and override Children().
The callback is called for every node.

------
The class is NOT thread safe or re-entrant.

------
**** Subclassing

Subclass these methods.
- CreateNode() : you MUST override this or any created children & siblings will not your subclass.
- Children() : return all children for the passed path.
- CountThis() : used by the counting methods. Return true if you want the node to be counted.
- IterationAction() : Called for every node by the Iterate() methods which do not use blocks.

-----
Ownership

These methods transfer ownership to you
 	DetachChildren() - node returned is the first sibling. You do not own any
		other sibling or children.
 	GoItAlone() - node returned by method only
 	SplitSiblings() - all nodes returned in array are yours. Their children are not yours.

*/

//----
class HierNode : CustomStringConvertible {
	let path : PathClass
	
#if DEBUG
	let ID : UInt64 = IDs.incrementAndGet()
#endif
	
	// Does not check for validity.
	init(path P: String) {
		path = PathClass(path: P)!
#if DEBUG
		print("Node \(ID) Init. Path = \(path)")
#endif
	}
	
	// Does not check for validity.
	init(path P: PathClass) {
		path = P
#if DEBUG
		print("Node \(ID) Init. Path = \(path)")
#endif
	}
	
	deinit {
#if DEBUG
		print("Node \(ID) deinit")
#endif
	}
	
	var description : String { return path.path }
	
	//**********************************************
	// If you subclass HierNode, you MUST implement this method calling your subclass's
	// constructor otherwise when new nodes are created, the subclass will not be created but this class.
	// It is called by GatherChildren() & GatherChildren_R() methods.
	func CreateNode(path: PathClass) -> HierNode {
		return HierNode(path: path)
	}
	
	//-----------------------
	// User flags are b8-15. b0-7 are reserved.
	private var flags = BitField(bitCount: 16)!
	
	func UserSet(flagBit: UInt8) { if flagBit >= 8 && flagBit <= 15 {flags[flagBit] = true } }
	func UserClear(flagBit: UInt8) { if flagBit >= 8 && flagBit <= 15 {flags[flagBit] = false } }
	func IsFlagSet(flagBit: UInt8) -> Bool { return flags[flagBit] }
	func UserFlags() -> UInt16 { return UInt16(flags.first & 0xFF00) }
	
	//--------------
	
	private(set) var parent : HierNode? = nil
	private(set) var firstChild : HierNode? = nil
	private(set) var prev : HierNode? = nil
	private(set) var next : HierNode? = nil
	
	//-----------------------------------------------------------------
	// MARK:- Gathering
	// Have node recursively gather all its children.
	// If the node has any existing children, the routine will be return immediately
	// and do nothing.
	// To force an update, you must either erase all children or
	// detach all children from the node.
	
	/// Override this and return all children for this node.
	/// The default returns an empty array.
	/// This is only used by GatherChildren(), not the block version.
	func Children() -> [PathClass] {
		return []
	}
	
	// Calls Children(). true implies failure or all stop.
	// false implies no issues.
	// If the node already possesses children, false will be returned.
	// You will have to delete/detach all children.
	@discardableResult func GatherChildren() -> Bool {
		print("Gather children start")
		
		if firstChild != nil { return false }
		
		let children = Children()
		
		for chd in children {
			let node = CreateNode(path: chd)
			AddChild(newChild: node)
			if node.GatherChildren_R() { return true }
		}
		
		firstChild!.DebugShowSiblings()
		
		print("Gather children end")
		return false
	}
	
	// Recursive.
	private func GatherChildren_R() -> Bool {
		print("Gather children: \(path.path)")
		let children = Children()
		
		for chd in children {
			let node = CreateNode(path: chd)
			AddChild(newChild: node)
			if node.GatherChildren_R() { return true }
		}
		
		return false
	}
	
	// Block method. block is expected to return an array of children.
	
	// Block returns an array of all children for this node.
	// If the node already possesses children, false will be returned.
	// You will have to delete/detach all children.
	@discardableResult func GatherChildren(block: HierNodeChildBlock) -> Bool {
		print("Gather children start : block")
		
		if firstChild != nil { return false }
		
		let children = block(path)
		
		for chd in children {
			let node = CreateNode(path: chd)
			AddChild(newChild: node)
			if node.GatherChildren_R(block: block) { return true }
		}
		
		print("Gather children end : block")
		return false
	}
	
	// Recursive
	private func GatherChildren_R(block: HierNodeChildBlock) -> Bool {
		print("Gather children block: \(path.path)")
		let children = block(path)
		
		for chd in children {
			let node = CreateNode(path: chd)
			AddChild(newChild: node)
			if node.GatherChildren_R(block: block) { return true }
		}
		
		return false
	}
	
	//-------------------------
	// Adds a sibling at a position relative to this node.
	// If the position extends beyond the before and after child count, the new sibling
	// is added at the beginning or end.
	// Currently false can only be returned if position is 0.
	@discardableResult private func AddSibling(newSibling: HierNode, where pos: Int) -> Bool {
		var nodePos : HierNode? = nil
		// newSibling.GoItAlone()
		
		if pos == 0 { return false }
		
		newSibling.GoItAlone()
		newSibling.parent = parent
		
		if pos < 0 && prev == nil {
			newSibling.next = self
			prev = newSibling
			parent?.firstChild = newSibling
			
			return true
		}
		
		if pos > 0 && next == nil {
			newSibling.prev = self
			next = newSibling
			
			return true
		}
		
		nodePos = self[pos]
		if nodePos == nil {
			if pos < 0 { nodePos = FirstSibling() }
			else { nodePos = LastSibling() }
		}
		
		if pos < 0 { // before
			let afterNode = nodePos!.next
			newSibling.next = afterNode
			newSibling.prev = nodePos
			if afterNode != nil { afterNode!.prev = newSibling }
			
			nodePos!.next = newSibling
			if newSibling.prev == nil && newSibling.parent != nil {
				newSibling.parent = newSibling
			}
		}
		else { // after
			let beforeNode = nodePos!.prev
			newSibling.prev = beforeNode
			newSibling.next = nodePos
			if beforeNode != nil { beforeNode!.next = newSibling }
			
			nodePos!.prev = newSibling
		}
		
		return true
	} // AddSibling()
	
	//--
	// Adds a new child to end of children list.
	private func AddChild(newChild: HierNode) {
		newChild.parent = self
		
		if firstChild == nil { firstChild = newChild }
		else {
			firstChild!.AddSibling(newSibling: newChild, where: Int.max)
		}
	}
	
	//-----------------------------------------------------------------
	// MARK:- Deletions
	// Recursive
	func DeleteAllChildren() {
		if firstChild == nil { return }
		
		Delete_R(node: firstChild!)
		firstChild = nil
	}
	
	// Recursive
	private func Delete_R(node: HierNode) {
		if let ref = node.next {
			ref.DeleteAllChildren()
			Delete_R(node: ref)
		}
		
	}
	
	// Recursively delete this and all its siblings.
	// Calls DeleteAllChildren().
	func SiblingDelete() {
		if parent != nil { parent?.DetachChildren()}
		
		do { try HierNode.SplitSiblings(node: self) }
		catch {}
		// should delete automatically if no references exist.
		
	}
	
	// Detach children from parent.
	// Caller is the new owner of this node, its sibling and their children.
	@discardableResult func DetachChildren() -> HierNode? {
		
		if firstChild == nil { return nil }
		var ptr = firstChild
		while ptr != nil {
			ptr!.parent = nil
			ptr = ptr!.next
		}
		
		ptr = firstChild
		firstChild = nil
		
		return ptr
	}
	
	/// Separate the siblings into individual trees.
	/// All must be detached from parent, otherwise an exception will be thrown.
	@discardableResult static func SplitSiblings(node: HierNode) throws -> [HierNode] {
		var array : [HierNode] = []
		
		if node.parent != nil { throw HierNodeEx.hasAParent }
		
		var n : HierNode? = node.FirstSibling()
		var n2 = n
		while n != nil {
			if n!.parent != nil { throw HierNodeEx.hasAParent }
			array.append(n!)
			n = n!.next
		}
		
		while n2 != nil {
			n = n2!.next
			n2!.prev = nil
			n2!.next = nil
			n2 = n
		}
		
		return array
	}
	
	//
	@discardableResult func GoItAlone() -> HierNode {
		
		if let C = parent?.firstChild {
			if C.path == self.path { // Risky. May need unique node ID.
				parent!.firstChild = next
			}
		}
		
		parent = nil
		if prev != nil { prev!.next = next }
		if next != nil { next!.prev = prev }
		
		prev = nil
		next = nil
		
		return self
	}
	
	//-----------------------------------------------------------------
	// MARK:- Counts
	// Count of immed. children
	func ChildCount() -> UInt {
		var count : UInt = 0
		var ptr = firstChild
		while ptr != nil {
			if CountThis() { count += 1 }
			ptr = next
		}
		
		return count
	}
	
	// Count of siblings
	func SiblingCount() -> UInt {
		var count : UInt = 0
		var ptr : HierNode? = FirstSibling()
		while ptr != nil {
			if CountThis()  { count += 1 }
			ptr = next
		}
		
		return count
	}
	
	// Count of all children
	func DeepChildCount() -> UInt {
		var count : UInt = 0
		FirstSibling().DeepChildCount_R(count: &count)
		
		return count
	}
	
	private func DeepChildCount_R(count: inout UInt) {
		if CountThis() { count += 1 }
		if next != nil {
			next?.DeepChildCount_R(count: &count)
		}
		
		if firstChild != nil {
			firstChild!.DeepChildCount_R(count: &count)
		}
	}
	
	/// Count of siblings before and after this node.
	func SiblingCount() -> (beforeMe: UInt, afterMe: UInt) {
		var beforeMe : UInt = 0
		var afterMe : UInt = 0
		
		var node : HierNode? = prev
		while node != nil {
			beforeMe += 1
			node = prev
		}
		
		node = next
		while node != nil {
			afterMe += 1
			node = next
		}
		
		return (beforeMe, afterMe)
	}
	
	// Override method.
	func CountThis() -> Bool { return true }
	
	// Widths for all rows.
	func WidthForRow() -> [UInt] {
		let depth = GreatestDepth()
		if depth == 0 { return [] }
		
		var widthForRow : [UInt] = Array(repeating: 0, count: Int(depth + 1) )
		var ptr : HierNode? = FirstSibling()
		
		while ptr != nil {
			let res = Iterate(mode: .breadthFirst) { (node, depth) -> HierNode.IterateResult in
				widthForRow[depth] += 1
				return .rContinue
			}
			
			if res != .rContinue { break }
			
			ptr = next
		}
		
		return widthForRow
	}
	
	/// Widest row in the hierarchy.
	func WidestRow() -> (row:UInt, count:UInt) {
		var row : UInt = 0
		var count : UInt = 0
		let rows = WidthForRow()
		var idx : UInt = 0
		for V in rows {
			if V > count {
				count = V
				row = idx
			}
			idx += 1
		}
		return (row, count)
	}
	
	/// Greatest depth from this node.
	/// This node is not necessarily the root node.
	func GreatestDepth() -> UInt {
		var depth : UInt = 0
		Iterate(mode: .depthFirst) { (node, D) -> HierNode.IterateResult in
			if D > depth { depth = UInt(D) }
			return .rContinue
		}
		
		return depth
	}
	
	//-----------------------------------------------------------------
	// MARK:- Siblings
	
	/// First sibling ("eldest")
	func FirstSibling() -> HierNode {
		var ref : HierNode? = self
		while ref!.prev != nil { ref = ref!.prev }
		return ref!
	}
	
	/// Last sibling ("youngest")
	func LastSibling() -> HierNode {
		var ref : HierNode? = self
		while ref!.next != nil { ref = ref!.next }
		return ref!
	}
	
	// Get SIBLING at index idx RELATIVE to this node.
	// Will return nil if idx exceeds sibling range.
	subscript(idx : Int) -> HierNode? {
		if idx == 0 { return self }
		var index = 0
		let dx = idx < 0 ? -1 : 1
		let back = idx < 0
		var ref : HierNode? = back ? prev : next
		
		while ref != nil {
			if index == idx { return ref }
			ref = back ? ref!.prev : ref!.next
			index += dx
		}
		return nil
	}
	
	// Return all nodes of depth N that are only direct descendants of this node.
	// Ignore siblings and other possible branches of ancestors.
	func AllAtDepthDown(depth: Int) -> [HierNode] {
		if depth < 0 { return [] }
		if depth == 0 { return [self] }
		
		var array : [HierNode] = []
		Iterate(mode: .depthFirst) { (node, D) -> HierNode.IterateResult in
			if D == depth { array.append(node) }
			return .rContinue
		}
		
		return array
	}
	
	// Return all nodes of depth N, incl. siblings and ancestor branches.
	func AllAt(depth: Int) -> [HierNode] {
		
		if depth == 0 { return SiblingArray(setSortFlag: false) }
		
		var delta = 0
		let root = GetRoot(delta: &delta)
		let trueDepth = depth - delta
		
		if trueDepth < 0 { return [] }
		let siblings = root.SiblingArray(setSortFlag: false)
		
		if trueDepth == 0 { return siblings }
		
		var nodes : [HierNode] = []
		var allNodes : [HierNode] = []
		
		for node in siblings {
			nodes.removeAll()
			nodes = node.AllAt(depth: trueDepth)
			allNodes.append(contentsOf: nodes)
		}
		
		return allNodes
	}
	
	/// Find ancestor with no parent.
	/// If the top row has siblings, it will be the first sibling.
	/// delta is how many rows above root is relative to this node.
	/// delta will always be <= 0.
	func GetRoot(delta: inout Int) -> HierNode {
		delta = 0
		var root : HierNode! = self
		while root.parent != nil {
			delta -= 1
			root = parent
		}
		
		root = root.FirstSibling()
		
		return root
	}
	
#if DEBUG
	func DebugShowSiblings() {
		print("Debug: siblings")
		var node : HierNode! = FirstSibling()
		while node != nil {
			print(node.path.path)
			node = node.next
		}
	}
#endif
	
	//-----------------------------------------------------------------
	// MARK:- Iteration
	
	enum IterationMode {
		// Depth first, first -> last child
		case depthFirst
		// Depth first, last -> first child
		case depthFirstEnd
		// Breadth first, first -> last child
		case breadthFirst
		// Breadth first, last -> first child
		case breadthFirstEnd
	}
	
	// Iteration
	enum IterateResult : Int {
		case rContinue = 0
		case allStop = -1
		case badParam = 1
	}
	
	// Iterate hierarchy passing each node to passed block.
	@discardableResult func Iterate(mode: IterationMode, block: HierNodeItrBlock) -> IterateResult {
		
		switch mode {
			case .depthFirst:
				return Iterate_Depth_R(block: block, depth: 0)
			case .depthFirstEnd:
				return LastSibling().Iterate_Depth_End_R(block: block, depth: 0)
			case .breadthFirst:
				return Iterate_Breadth_R(block: block, depth: 0)
			case .breadthFirstEnd:
				return LastSibling().Iterate_Breadth_End_R(block: block, depth: 0)
		}
	}
	
	// Iterate depth first, first child.
	private func Iterate_Depth_R(block: HierNodeItrBlock, depth : Int) -> IterateResult {
		if block(self, depth) != .rContinue { return .allStop }
		
		if let F = firstChild {
			if F.Iterate_Depth_R(block: block, depth: depth + 1) != .rContinue { return .allStop }
		}
		
		if let N = next {
			if N.Iterate_Depth_R(block: block, depth: depth) != .rContinue { return .allStop }
		}
		
		return .rContinue
	}
	
	// Iterate depth first, last child.
	private func Iterate_Depth_End_R(block: HierNodeItrBlock, depth : Int) -> IterateResult {
		if block(self, depth) != .rContinue { return .allStop }
		
		if let F = firstChild {
			if F.LastSibling().Iterate_Depth_End_R(block: block, depth: depth + 1) != .rContinue { return .allStop }
		}
		
		if let P = prev {
			if P.Iterate_Depth_End_R(block: block, depth: depth) != .rContinue { return .allStop }
		}
		
		return .rContinue
	}
	
	// Iterate breadth first, first child.
	private func Iterate_Breadth_R(block: HierNodeItrBlock, depth : Int) -> IterateResult {
		let ary = SiblingArray(setSortFlag: false)
		
		for n in ary {
			if block(n, depth) != .rContinue { return .allStop }
		}
		
		for n in ary {
			if let F = n.firstChild {
				if F.Iterate_Breadth_R(block: block, depth: depth + 1) != .rContinue { return .allStop }
			}
		}
		
		return .rContinue
	}
	
	// Iterate breadth first, last child.
	private func Iterate_Breadth_End_R(block: HierNodeItrBlock, depth : Int) -> IterateResult {
		if block(self, depth) != .rContinue { return .allStop }
		
		if prev != nil {
			if prev!.Iterate_Breadth_End_R(block: block, depth: depth) != .rContinue { return .allStop }
		}
		
		if firstChild != nil {
			if firstChild!.LastSibling().Iterate_Breadth_End_R(block: block, depth: depth + 1) != .rContinue {
				return .allStop
			}
		}
		
		return .rContinue
	}
	
	/// Iterate hierarchy using the overridden IterationAction() method.
	@discardableResult func Iterate(mode: IterationMode) -> IterateResult {
		
		switch mode {
			case .depthFirst:
				return Iterate_Depth_R(depth: 0)
			case .depthFirstEnd:
				return LastSibling().Iterate_Depth_End_R(depth: 0)
			case .breadthFirst:
				return Iterate_Breadth_R(depth: 0)
			case .breadthFirstEnd:
				return LastSibling().Iterate_Breadth_End_R(depth: 0)
		}
	}
	
	/// Override this. Default does nothing.
	func IterationAction(depth: Int) -> IterateResult {
		return .rContinue
	}
	
	// Dpeth first iteration from from first child
	private func Iterate_Depth_R(depth : Int) -> IterateResult {
		if IterationAction(depth:depth) != .rContinue { return .allStop }
		
		if let F = firstChild {
			if F.Iterate_Depth_R(depth: depth + 1) != .rContinue { return .allStop }
		}
		
		if let N = next {
			if N.Iterate_Depth_R(depth: depth) != .rContinue { return .allStop }
		}
		
		return .rContinue
	}
	
	// Depth first iteration from last child
	private func Iterate_Depth_End_R(depth : Int) -> IterateResult {
		if IterationAction(depth:depth) != .rContinue { return .allStop }
		
		if let F = firstChild {
			if F.LastSibling().Iterate_Depth_End_R(depth: depth + 1) != .rContinue { return .allStop }
		}
		
		if let P = prev {
			if P.Iterate_Depth_End_R(depth: depth) != .rContinue { return .allStop }
		}
		
		return .rContinue
	}
	
	// Breadth first iteration from first child
	private func Iterate_Breadth_R(depth : Int) -> IterateResult {
		
		if IterationAction(depth:depth) != .rContinue { return .allStop }
		
		if let N = next {
			if N.Iterate_Breadth_R(depth: depth) != .rContinue { return .allStop }
		}
		
		if let F = firstChild {
			if F.Iterate_Breadth_R(depth: depth + 1) != .rContinue { return .allStop }
		}
		
		return .rContinue
	}
	
	// Breadth first iteration from last child
	private func Iterate_Breadth_End_R(depth : Int) -> IterateResult {
		if IterationAction(depth:depth) != .rContinue { return .allStop }
		
		if prev != nil {
			if prev!.Iterate_Breadth_End_R(depth: depth) != .rContinue { return .allStop }
		}
		
		if firstChild != nil {
			if firstChild!.LastSibling().Iterate_Breadth_End_R(depth: depth + 1) != .rContinue {
				return .allStop
			}
		}
		
		return .rContinue
	}
	
	//-----------------------------------------------------------------
	// MARK:- Sorting
	
	// Because all the nodes have been sorted, their prev & next fields need to be changed.
	fileprivate static func RelinkSorted(nodes: inout [HierNode]) {
		var node : HierNode! = nodes[0]
		if node.parent != nil {
			node.parent!.firstChild = node
		}
		
		node!.prev = nil
		
		var nodeB : HierNode! = nil
		var idx = 1
		while idx < nodes.count {
			nodeB = nodes[idx]
			node.next = nodeB
			nodeB.prev = node
			nodeB.next = nil
			
			node = nodeB
			idx += 1
		}
	}
	
	/// Sort siblings using path string comparison.
	static func SiblingSort(startNode: HierNode) {
		var nodeArray = startNode.SiblingArray(setSortFlag: false)
		
		if nodeArray.count == 1 { return }
		if nodeArray.count == 2 {
			if nodeArray[1].path < nodeArray[0].path {
				nodeArray.swapAt(0, 1)
				RelinkSorted(nodes: &nodeArray)
				return
			}
		}
		
		nodeArray.sort { (N1, N2) -> Bool in
			return N1.path < N2.path
		}
		
		RelinkSorted(nodes: &nodeArray)
	}
	
	/// Sorts sibling using a passed sorting block.
	static func SiblingSort(startNode: HierNode, block: HierNodeSortBlock) {
		var nodeArray = startNode.SiblingArray(setSortFlag: false)
		
		if nodeArray.count == 1 { return }
		if nodeArray.count == 2 {
			if !block(nodeArray[0], nodeArray[1]) {
				nodeArray.swapAt(0, 1)
				RelinkSorted(nodes: &nodeArray)
				return
			}
		}
		
		nodeArray.sort { (N1, N2) -> Bool in
			return block(N1, N2)
		}
		
		RelinkSorted(nodes: &nodeArray)
	}
	
	/// Return array of all siblings.
	func SiblingArray(setSortFlag: Bool) -> [HierNode] {
		var array : [HierNode] = []
		
		var node : HierNode! = FirstSibling()
		while node != nil {
			array.append(node)
			node = node.next
		}
		
		return array
	}
	
}
