import Vapor
import Foundation

let drop = Droplet()

drop.get("/") { request in
    return try drop.view.make("main")
}

drop.post("/match") { request in
    
    var regex = (request.data["regex"]?.string)!
    var text = (request.data["text"]?.string)!
    
    // unescape
    regex = regex.unescaped
    text = text.unescaped
    
    let ranges = text.matches(for: regex).map { range -> Node in
        let location = Node.number(Node.Number(range.location))
        let length = Node.number(Node.Number(range.length))
        return .object(["location": location, "length": length])
    }
        
    let node = Node.object(["ranges": .array(ranges), "text": .string(text)])
    
    return try JSON(node: node)
}

drop.run()
