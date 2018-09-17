import Foundation


/// A lockable, thread-safe array.
/// It is a modification of Basem Emara's SynchronizedArray, see <http://basememara.com/creating-thread-safe-arrays-in-swift/>
/// It provides concurrent reads and serialized writes. A write is only executed after all reads have been completed.
/// If the LockableSynchronizedArray is locked, new writes are deferred until it is unlocked again, while new reads are executed normally.
class WriteLockableSynchronizedArray<Element> {
    
    typealias WriteOperation = ()->Void
    
    fileprivate var lockCounter = 0
    fileprivate let queue = DispatchQueue(label: "fi.flodin.tonemanager.WriteLockableSynchronizedArray", attributes: .concurrent)
    fileprivate var internalArray = [Element]()
    fileprivate var deferredWriteOperations: [WriteOperation] = []
    
    /// The internal array of the elements
    var array: [Element]? {
        var result: [Element]?
        queue.sync { result = self.internalArray }
        return result
    }
}

// MARK: - Properties
extension WriteLockableSynchronizedArray {
    
    /// The first element of the collection.
    var first: Element? {
        var result: Element?
        queue.sync { result = self.internalArray.first }
        return result
    }
    
    /// The last element of the collection.
    var last: Element? {
        var result: Element?
        queue.sync { result = self.internalArray.last }
        return result
    }
    
    /// The number of elements in the array.
    var count: Int {
        var result = 0
        queue.sync { result = self.internalArray.count }
        return result
    }
    
    /// A Boolean value indicating whether the collection is empty.
    var isEmpty: Bool {
        var result = false
        queue.sync { result = self.internalArray.isEmpty }
        return result
    }
    
    /// A textual representation of the array and its elements.
    var description: String {
        var result = ""
        queue.sync { result = self.internalArray.description }
        return result
    }
}

// MARK: - Init
extension WriteLockableSynchronizedArray {
    convenience init(with array: [Element]) {
        self.init()
        self.internalArray = array
    }
}

// MARK: - Lock - Unlock
extension WriteLockableSynchronizedArray {
    /// Locks the array for writes. Must be unlocked by unlockArray()
    func lockArray() {
        queue.async(flags: .barrier) {
            self.lockCounter += 1
        }
    }
    
    /// Unlocks the array after it has been locked by lockArray()
    func unlockArray() {
        queue.sync(flags: .barrier) {
            if self.lockCounter > 0 {
                self.lockCounter -= 1
            }
            if self.lockCounter == 0 {
                while self.deferredWriteOperations.count > 0 {
                    let nextOp = self.deferredWriteOperations.remove(at: 0)
                    self.queue.async(flags: .barrier) { nextOp() }
                    print("Enqueued deferred write op")
                }
            }
        }
    }
}

// MARK: - Immutable
extension WriteLockableSynchronizedArray {
    /// Returns the first element of the sequence that satisfies the given predicate or nil if no such element is found.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    /// - Returns: The first match or nil if there was no match.
    func first(where predicate: (Element) -> Bool) -> Element? {
        var result: Element?
        queue.sync { result = self.internalArray.first(where: predicate) }
        return result
    }
    
    /// Returns an array containing, in order, the elements of the sequence that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included in the returned array.
    /// - Returns: An array of the elements that includeElement allowed.
    func filter(_ isIncluded: (Element) -> Bool) -> [Element] {
        var result = [Element]()
        queue.sync { result = self.internalArray.filter(isIncluded) }
        return result
    }
    
    /// Returns the first index in which an element of the collection satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: The index of the first element for which predicate returns true. If no elements in the collection satisfy the given predicate, returns nil.
    func index(where predicate: (Element) -> Bool) -> Int? {
        var result: Int?
        queue.sync { result = self.internalArray.index(where: predicate) }
        return result
    }
    
    /// Returns the elements of the collection, sorted using the given predicate as the comparison between elements.
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns true if its first argument should be ordered before its second argument; otherwise, false.
    /// - Returns: A sorted array of the collection’s elements.
    func sorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> [Element] {
        var result = [Element]()
        queue.sync { result = self.internalArray.sorted(by: areInIncreasingOrder) }
        return result
    }
    
    /// Returns an array containing the non-nil results of calling the given transformation with each element of this sequence.
    ///
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: An array of the non-nil results of calling transform with each element of the sequence.
    func flatMap<ElementOfResult>(_ transform: (Element) -> ElementOfResult?) -> [ElementOfResult] {
        var result = [ElementOfResult]()
        queue.sync { result = self.internalArray.compactMap(transform) }
        return result
    }
    
    /// Calls the given closure on each element in the sequence in the same order as a for-in loop.
    ///
    /// - Parameter body: A closure that takes an element of the sequence as a parameter.
    func forEach(_ body: (Element) -> Void) {
        queue.sync { self.internalArray.forEach(body) }
    }
    
    /// Returns a Boolean value indicating whether the sequence contains an element that satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: true if the sequence contains an element that satisfies predicate; otherwise, false.
    func contains(where predicate: (Element) -> Bool) -> Bool {
        var result = false
        queue.sync { result = self.internalArray.contains(where: predicate) }
        return result
    }
}

// MARK: - Mutable
extension WriteLockableSynchronizedArray {
    
    /// Adds a new element at the end of the array.
    ///
    /// - Parameter element: The element to append to the array.
    func append( _ element: Element) {
        let op = { self.internalArray.append(element) }
        handleWriteOperation(op)
    }
    
    /// Adds a new element at the end of the array.
    ///
    /// - Parameter element: The element to append to the array.
    func append( _ elements: [Element]) {
        let op = { self.internalArray += elements }
        handleWriteOperation(op)
    }
    
    /// Inserts a new element at the specified position.
    ///
    /// - Parameters:
    ///   - element: The new element to insert into the array.
    ///   - index: The position at which to insert the new element.
    func insert( _ element: Element, at index: Int) {
        let op = { self.internalArray.insert(element, at: index) }
        handleWriteOperation(op)
    }
    
    /// Removes and returns the element at the specified position.
    ///
    /// - Parameters:
    ///   - index: The position of the element to remove.
    ///   - completion: The handler with the removed element.
    func remove(at index: Int, completion: ((Element) -> Void)? = nil) {
        let op = {
            let element = self.internalArray.remove(at: index)
            DispatchQueue.main.async {
                completion?(element)
            }
        }
        handleWriteOperation(op)
    }
    
    /// Removes and returns the element at the specified position.
    ///
    /// - Parameters:
    ///   - predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    ///   - completion: The handler with the removed element.
    func remove(where predicate: @escaping (Element) -> Bool, completion: ((Element) -> Void)? = nil) {
        let op = {
            guard let index = self.internalArray.index(where: predicate) else { return }
            let element = self.internalArray.remove(at: index)
            DispatchQueue.main.async {
                completion?(element)
            }
        }
        handleWriteOperation(op)
    }
    
    /// Removes all elements from the array.
    ///
    /// - Parameter completion: The handler with the removed elements.
    func removeAll(completion: (([Element]) -> Void)? = nil) {
        let op = {
            let elements = self.internalArray
            self.internalArray.removeAll()
            DispatchQueue.main.async {
                completion?(elements)
            }
        }
        handleWriteOperation(op)
    }
}

extension WriteLockableSynchronizedArray {
    
    /// Accesses the element at the specified position if it exists.
    ///
    /// - Parameter index: The position of the element to access.
    /// - Returns: optional element if it exists.
    subscript(index: Int) -> Element? {
        get {
            var result: Element?
            
            queue.sync {
                guard self.internalArray.startIndex..<self.internalArray.endIndex ~= index else { return }
                result = self.internalArray[index]
            }
            
            return result
        }
        set {
            guard let newValue = newValue else { return }
            
            let op = { self.internalArray[index] = newValue }
            handleWriteOperation(op)
        }
    }
}


// MARK: - Equatable
extension WriteLockableSynchronizedArray where Element: Equatable {
    
    /// Returns a Boolean value indicating whether the sequence contains the given element.
    ///
    /// - Parameter element: The element to find in the sequence.
    /// - Returns: true if the element was found in the sequence; otherwise, false.
    func contains(_ element: Element) -> Bool {
        var result = false
        queue.sync { result = self.internalArray.contains(element) }
        return result
    }
}

// MARK: - Infix operators
extension WriteLockableSynchronizedArray {
    
    static func +=(left: inout WriteLockableSynchronizedArray, right: Element) {
        left.append(right)
    }
    
    static func +=(left: inout WriteLockableSynchronizedArray, right: [Element]) {
        left.append(right)
    }
}

// MARK: - Protocol Sequence
extension WriteLockableSynchronizedArray: Sequence {
    
    public func makeIterator() -> Iterator {
        return Iterator(self.array)
    }
    
    public struct Iterator: IteratorProtocol {
        private var index: Int
        private var arr: [Element]?
        
        init(_ array: [Element]?) {
            self.arr = array
            index = 0
        }
        
        mutating public func next() -> Element? {
            guard let arr = self.arr, arr.count > index else { return nil }
            let returnValue = arr[index]
            index += 1
            return returnValue
        }
    }
}

// MARK: - Private helper
fileprivate extension WriteLockableSynchronizedArray {
    func handleWriteOperation(_ op: @escaping WriteLockableSynchronizedArray.WriteOperation) {
        queue.sync {
            if self.lockCounter > 0 {
                self.deferredWriteOperations.append { op() }
            } else {
                queue.async(flags: .barrier) {
                    op()
                }
            }
        }
    }
    
}
