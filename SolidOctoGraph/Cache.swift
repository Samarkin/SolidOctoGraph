private class Node<T> {
    let value: T
    var next: Node<T>?

    init(value: T) {
        self.value = value
    }
}

struct CacheGenerator<T>: GeneratorType {
    private var current: Node<T>?
    private init(node: Node<T>?) {
        current = node
    }

    mutating func next() -> T? {
        guard let c = current else {
            return nil
        }
        let v = c.value
        current = c.next
        return v
    }
}

class Cache<T>: SequenceType {
    private var root: Node<T>?
    private var count: Int = 0
    private let limit: Int

    init(limit: Int) {
        self.limit = limit
    }

    func push(value: T) {
        guard let r = root else {
            root = Node(value: value)
            count = 1
            return
        }

        root = Node(value: value)
        root!.next = r
        count++

        if count > limit {
            truncate()
        }
    }

    private func truncate() {
        guard let r = root else {
            return
        }
        guard limit > 0 else {
            root = nil
            return
        }
        var idx = 1
        var t = r
        while let q = t.next where idx < limit {
            t = q
            idx++
        }
        count = limit
        t.next = nil
    }

    func generate() -> CacheGenerator<T> {
        return CacheGenerator(node: root)
    }
}