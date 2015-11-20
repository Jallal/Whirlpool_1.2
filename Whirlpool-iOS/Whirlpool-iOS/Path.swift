//
//  Path.swift
//  Whirlpool-iOS
//
//  Created by Jallal Elhazzat on 11/15/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import CoreData


 public var canvas: Array = Array<Vertex>()

class Path {
    
    var ActualPath  : Array<Vertex>
  
    var total: Int!
    var destination: Vertex
    var previous: Path!
    

 init(){
    destination = Vertex()
    ActualPath  = Array<Vertex>()
    
    }
    
    
    
    func getVertex(inout start: Vertex,can:Bool )-> Vertex{
        print("***********************************")
        print(start.lat)
        print(start.long)
        var smallestLatDifference : Double  = 1000;
        var smallestLongDifference : Double = 1000
        for ver in canvas{
            var value1 = (ver.lat-start.lat)
             var value2 = (ver.long-start.long)
            if ((value1 < smallestLatDifference)&&(value2 < smallestLongDifference) ){
              start  = ver;
            }
        }
        
      return  start
    }
    
      func getVertex(inout Id:Vertex)-> Vertex{
        
        for ver in canvas{
            
            if(ver.key==Id.key){
                Id.key = ver.key
                Id.lat = ver.lat
                Id.long = ver.long
                return Id
            }
        }
        return Id
    }
    
    
    func traverseGraphBFS(start: CLLocationCoordinate2D, end : CLLocationCoordinate2D,startingFloor: Int, EndingFloor: Int)-> Array<Vertex> {
        
        var st = Vertex(key: -1,lat: start.latitude,long: start.longitude,visited: false)
        var ed  = Vertex(key: -1,lat: end.latitude,long: end.longitude,visited: false)
        
   var StartingNav : Vertex = self.getVertex(&st,can: true)
        var EndingNav : Vertex = self.getVertex(&ed,can:true)
        
        var myPath = Array<Vertex> ()
    
    //establish a new queue 
    var graphQueue: Queue<Vertex> = Queue<Vertex>()
    //queue a starting vertex 
    graphQueue.enQueue(StartingNav)
   myPath.append(self.getVertex(&StartingNav))
    while(!graphQueue.isEmpty()) {
        //traverse the next queued vertex 
        var vitem = graphQueue.deQueue() as Vertex!
        //add unvisited vertices to the queue 
        for e in vitem.neighbors {
            var v = self.getVertex(&e.neighbor)
            if v.visited == false {
                 v.visited = true
                print("adding vertex: \(e.neighbor.key)")
                if(v.key==EndingNav.key){
                    return myPath
                }
                graphQueue.enQueue(v)
                myPath.append(v)
            }
        }
        //vitem.visited = true
        print("traversed vertex: \(vitem.key)")
    }
    //end while
    print("graph traversal complete..")
        return myPath
    }
    
}


public class Vertex {
    var key   =  -1
    var lat   = 0.0
    var long  = 0.0
    var visited : Bool = false
    var neighbors: Array<Edge>
    
    init() {
        self.neighbors = Array<Edge>()
    }
    
    init(key:Int,lat:Double,long:Double,visited:Bool) {
        self.key = key
        self.lat = lat
        self.long = long
        self.visited = visited
        self.neighbors = Array<Edge>()
    }
}



public class Edge {
    var neighbor: Vertex
    var weight: Int
    init() {
        weight = 0
        self.neighbor = Vertex()
    }
    init(weight : Int, neighbor :Vertex ) {
        self.weight = weight
        self.neighbor = neighbor
    }
}



public class SwiftGraph {
  
    public var isDirected: Bool
    
    init() {
        canvas = Array<Vertex>()
        isDirected = true
}
    
    
    
    
    public func readFromFile(){
        
        
        let file = "ghq_nw_f4_nav"
        
        if let filepath = NSBundle.mainBundle().pathForResource(file, ofType: "txt") {
            do {
                var contents = try NSString(contentsOfFile: filepath, usedEncoding: nil) as String
               contents = contents.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                contents = contents.stringByReplacingOccurrencesOfString("]", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let stringArray : Array<String> = contents.componentsSeparatedByString("\n")
                for e in stringArray{
                    var str : Array<String> = e.componentsSeparatedByString(",")
                    var count = 0
                     var chiled   : Vertex = Vertex()
                    var key : Int = Int()
                    var latitude : Double =  Double ()
                    var longitude : Double  =  Double()
                    var neighbors : Array = Array<Int>()
                   
                        for ee in str {
                            
                            if(count==0){
                                var val =  NSNumberFormatter().numberFromString(ee)
                                 key = val!.integerValue
                                count = count+1
                                
                            }
                            else if(count==1){
                                var val =  NSNumberFormatter().numberFromString(ee)
                                latitude = val!.doubleValue
                               count = count+1
                               
                            }
                            else if(count==2){
                                var val =  NSNumberFormatter().numberFromString(ee)
                                 longitude = val!.doubleValue
                             count = count+1
                                
                            }
                            else{
                                var val =  NSNumberFormatter().numberFromString(ee)
                                if(val != nil){
                                var nan = val!.integerValue
                              neighbors.append(nan)
                                }
                            count = count+1
                            }

                      }
                    chiled =  self.addVertex(key, lat: latitude, long: longitude)
                    for nei in neighbors{
                     var neigh  : Vertex = Vertex()
                        neigh.key =  nei
                        self.addEdge(chiled, neighbor:  neigh, weight: 0)
                    }
                    
             
                }
                
              
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
    }
    
    
    
    
    
    func addVertex(key: Int, lat: Double, long :Double) -> Vertex {
        var childVertex: Vertex = Vertex()
        childVertex.key = key
        childVertex.lat = lat
        childVertex.long = long
        canvas.append(childVertex)
        return childVertex
    }


 
    func addEdge(source: Vertex, neighbor: Vertex, weight: Int)
    {
        
        var newEdge = Edge(weight: weight,neighbor: neighbor)
        //newEdge.neighbor = neighbor
        //newEdge.weight = weight
        source.neighbors.append(newEdge)
        if (isDirected == false) {
            var reverseEdge = Edge()
           
            reverseEdge.neighbor = source
            reverseEdge.weight = weight
            neighbor.neighbors.append(reverseEdge)
        }
    }


}

public class Queue<T> {
    private var top: QNode<T>! = QNode<T>()
//enqueue the specified object 
    func enQueue(var key: T) {
//check for the instance 
        if (top == nil) {
            top = QNode<T>()
} //establish the top node 
        if (top.key == nil) {
            top.key = key; return
        }
        var childToUse: QNode<T> = QNode<T>()
        var current: QNode = top
//cycle through the list of items to get to the end. 
        while (current.next != nil) {
            current = current.next! }
//append a new item 
        childToUse.key = key; current.next = childToUse;
    }
    
    
    
    func deQueue() -> T? {
        //determine if the key or instance exists 
        let topitem: T? = self.top?.key
        if (topitem == nil) {
            return nil
        }
        //retrieve and queue the next item 
        var queueitem: T? = top.key!
        //use optional binding 
        if let nextitem = top.next {
            top = nextitem
        } else {
            top = nil
        }
        return queueitem
    }
    
    func isEmpty() -> Bool {
        //determine if the key or instance exist
        if let topitem: T = self.top?.key {
            return false }
        else {
            return true
        }
    }
    //retrieve the top most item
    func peek() -> T? {
        return top.key!
    }
}

class QNode<T> {
    var key: T?
    var next: QNode?
}









