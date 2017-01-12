#if os(Linux)
    import RopeLinux
#else
    import RopeMacOS
#endif

public enum RopeError: Error {
    case connectionFailed(message: String)
}

public final class Rope {
    
    private(set) var conn: OpaquePointer!
    
    public var connected: Bool {
        guard let conn = conn, PQstatus(conn) == CONNECTION_OK else {
            return false
        }
        return true
    }
    
    public init(host:String, port:Int, dbName:String, user:String, password:String) throws {
        let conn = PQsetdbLogin(host, String(port), "", "", dbName, user, password)
        
        guard PQstatus(conn) == CONNECTION_OK else {
            try failWithError(conn); return
        }
        
        self.conn = conn
    }
    
    deinit {
        try? close()
    }
    
    public static func connect(host:String = "localhost", port:Int = 5432, dbName:String, user:String, password:String) throws -> Rope {
        return try Rope(host: host, port: port, dbName: dbName, user: user, password: password)
    }
    
    public func execute() {
        
    }
    
    public func close() throws {
        guard self.connected else {
            try failWithError(); return
        }
        
        PQfinish(conn)
        conn = nil
    }
    
    private func failWithError(_ conn: OpaquePointer? = nil) throws {
        let message = String(cString: PQerrorMessage(conn ?? self.conn))
        throw RopeError.connectionFailed(message: message)
    }
}