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
    var total: Double!
    var destination: Vertex
    var previous: Path!
    
    
    
    init(){
        destination = Vertex()
        ActualPath  = Array<Vertex>()
        
    }
    
    
    func getVertex(start: CLLocationCoordinate2D)-> Vertex{
        var NewStart = Vertex();
        var smallestLatDifference : Double  = 10000;
        for ver in canvas{
            var value1 = abs(abs(ver.location.longitude) - abs(start.longitude)) + abs(ver.location.latitude-start.latitude)
            
            if(ver.location.latitude == start.latitude){
                return Vertex(key: ver.key,loc: ver.location,visited: false,neighbors: ver.neighbors)
            }
            //var value2 = (ver.long-start.long)
            if (value1 < smallestLatDifference){
                smallestLatDifference = value1
                NewStart = Vertex(key: ver.key,loc: ver.location,visited: false,neighbors: ver.neighbors)
            }
        }
        
        return  NewStart
    }
    
    
    func getVertexElevator(start: CLLocationCoordinate2D, floor: FloorData)-> CLLocationCoordinate2D{
        var NewStart = CLLocationCoordinate2D();
        var smallestLatDifference : Double  = 10000;
        var AllElevatorsInFloor : [RoomData]
        AllElevatorsInFloor = floor.getElevatorsInFloor()
        for elv in AllElevatorsInFloor{
            var ver = elv.GetroomCenter()
            var value1 = abs(abs(ver.longitude) - abs(start.longitude)) + abs(ver.latitude-start.latitude)
            
            if(ver.latitude == start.latitude){
                NewStart = CLLocationCoordinate2D(latitude: ver.latitude,longitude: ver.longitude)
                return NewStart
            }
            //var value2 = (ver.long-start.long)
            if (value1 < smallestLatDifference){
                smallestLatDifference = value1
                NewStart = CLLocationCoordinate2D(latitude: ver.latitude,longitude: ver.longitude)
            }
        }
        
        return  NewStart
    }
    
    
    func getVertex(Id:Vertex)-> Vertex{
        
        for ver in canvas{
            
            if(ver.key==Id.key){
                return ver
            }
        }
        return Id
    }
    
    
    func traverseGraphBFSFinalPath(start: CLLocationCoordinate2D, end : CLLocationCoordinate2D,SameFloor : Bool,StartingFloor : FloorData, EndingFloor: FloorData)-> Path?{
        self.BuildGraph();
        var myPaths = Path?()
        var StartingNav = self.getVertex(end)
        StartingNav.visited = false
        var EndingNav = self.getVertex(start)
        EndingNav.visited = false
        myPaths = self.processDijkstra(StartingNav,destination: EndingNav)
        myPaths?.ActualPath.append(EndingNav)
        while(myPaths?.previous != nil){
            myPaths?.ActualPath.append(self.getVertex((myPaths?.previous.destination)!))
            myPaths?.previous =  myPaths?.previous.previous
            
        }
        myPaths?.ActualPath.append(StartingNav)
        
        
        return  myPaths
        
    }

    
    
    func traverseGraphBFS(start: CLLocationCoordinate2D, end : CLLocationCoordinate2D,SameFloor : Bool,StartingFloor : FloorData, EndingFloor: FloorData)-> Path?{
        
        self.BuildGraph();
        var myPaths = Path?()
        
        if(SameFloor){
            var StartingNav = self.getVertex(start)
            StartingNav.visited = false
            var EndingNav = self.getVertex(end)
            EndingNav.visited = false
            myPaths = self.processDijkstra(StartingNav,destination: EndingNav)
        
        myPaths?.ActualPath.append(EndingNav)
        while(myPaths?.previous != nil){
            myPaths?.ActualPath.append(self.getVertex((myPaths?.previous.destination)!))
            myPaths?.previous =  myPaths?.previous.previous
            
        }
        myPaths?.ActualPath.append(StartingNav)
            
             return  myPaths
            
            
        }else{
            var StartingNav = self.getVertex(start)
            StartingNav.visited = false
            var EndingElevator = self.getVertexElevator(end,floor: StartingFloor)
            var EndingNav = self.getVertex(EndingElevator)
            EndingNav.visited = false
            myPaths = self.processDijkstra(StartingNav,destination: EndingNav)
            myPaths?.ActualPath.append(EndingNav)
            while(myPaths?.previous != nil){
                myPaths?.ActualPath.append(self.getVertex((myPaths?.previous.destination)!))
                myPaths?.previous =  myPaths?.previous.previous
                
            }
            myPaths?.ActualPath.append(StartingNav)
            
            return  myPaths
            
        }
        
        
        
        
        return  myPaths
        
    }
    
    
    func processDijkstra(source: Vertex, destination: Vertex) -> Path? {
        var frontier: Array = [Path]()
        var finalPaths: Array = [Path]()
        //use source edges to create the frontier
        for e in source.neighbors {
            
            var newPath: Path = Path()
            newPath.destination = e.neighbor
            newPath.previous = nil
            newPath.total = e.weight
            //add the new path to the frontier
            frontier.append(newPath)
            
            
        }
        
        //obtain the best path
        var bestPath: Path = Path()
        while((frontier.count != 0)&&(frontier.count < 6000)) {
            //support path changes using the greedy approach
            bestPath = Path()
            var x: Int = 0
            var pathIndex: Int = 0
            for (x = 0; x < frontier.count; x++) {
                var itemPath: Path = frontier[x] as Path
                if (bestPath.total == nil) || (itemPath.total < bestPath.total) {
                    bestPath = itemPath
                    pathIndex = x
                }
            }
            
            for e in bestPath.destination.neighbors {
                
                var newPath: Path = Path()
                newPath.destination = e.neighbor
                newPath.previous = bestPath
                newPath.total = bestPath.total + e.weight
                //add the new path to the frontier
                frontier.append(newPath)
                
            }
            
            //preserve the bestPath
            finalPaths.append(bestPath)
            //remove the bestPath from the frontier
            frontier.removeAtIndex(pathIndex)
        }
        for p in finalPaths {
            let path = p as Path
            if (path.total < bestPath.total) && (path.destination.key == destination.key){
                bestPath = path
            }
        }
        return bestPath
    }
    
    
    
    func BuildGraph(){
        
        for i in canvas{
            i.visited = false
            for k in i.neighbors {
                k.neighbor = self.getVertex(k.neighbor)
                k.weight = self.distanceInMetersFrom(i, EndVertex: k.neighbor)
            }
        }
        
    }
    
    
    
    internal  func distanceInMetersFrom(stratVertex : Vertex,EndVertex : Vertex) -> CLLocationDistance {
        let firstLoc = CLLocation(latitude: stratVertex.location.latitude, longitude: stratVertex.location.longitude)
        let secondLoc = CLLocation(latitude: EndVertex.location.latitude, longitude: EndVertex.location.longitude)
        return firstLoc.distanceFromLocation(secondLoc)
    }
    
}




public class Vertex {
    var key   =  -1
    var location  = CLLocationCoordinate2D(latitude: 0,longitude: 0)
    var visited : Bool = false
    var neighbors: Array<Edge>
    
    init() {
        self.key   =  -1
        self.location  = CLLocationCoordinate2D(latitude: 0,longitude: 0)
        self.visited  = false
        self.neighbors = Array<Edge>()
    }
    
    init(key:Int,loc:CLLocationCoordinate2D,visited:Bool,neighbors:Array<Edge>) {
        self.key = key
        self.location = loc
        self.visited = visited
        self.neighbors = neighbors
    }
}



public class Edge {
    var neighbor: Vertex
    var weight :CLLocationDistance
    init(neighbor :Vertex , weight : CLLocationDistance) {
        self.neighbor = neighbor
        self.weight = weight
    }
}



public class SwiftGraph {
    
    public var isDirected: Bool
    
    init() {
        canvas = Array<Vertex>()
        isDirected = true
    }
    
    
    
    
    public func readFromFile(filename : String){
          //clean data Stucture
            canvas.removeAll()
        
        let file = filename
        
        if let filepath = NSBundle.mainBundle().pathForResource(file, ofType: "txt") {
            do {
                var contents = try NSString(contentsOfFile: filepath, usedEncoding: nil) as String
                contents = contents.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                contents = contents.stringByReplacingOccurrencesOfString("]", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let stringArray : Array<String> = contents.componentsSeparatedByString("\n")
                for e in stringArray{
                    var str : Array<String> = e.componentsSeparatedByString(",")
                    //convert the array from string to double
                    let doubleArray = str.map{NSString(string: $0).doubleValue}
                    var chiled   : Vertex = Vertex()
                    var count = doubleArray.count-1
                    var key  = Int(doubleArray[0])
                    var loc = CLLocationCoordinate2D( latitude: doubleArray[1], longitude: doubleArray[2])
                    var neighbors : Array = Array<Int>()
                    for i in 3...count{
                        let element : Int = Int(doubleArray[i])
                        if(element != Int()){
                            neighbors.append(element)
                        }
                        
                    }
                    chiled =  self.addVertex(key,loc: loc)
                    for nei in neighbors{
                        var neigh  : Vertex = Vertex()
                        neigh.key =  nei
                        self.addEdge(chiled, neighbor:  neigh)
                    }
                    
                }
                
            } catch {
                print(" contents could not be loaded")
            }
        } else {
            print(" File  not found!")
        }
    }
    
    
    
    
    
    
    
    func addVertex(key: Int, loc: CLLocationCoordinate2D) -> Vertex {
        let childVertex: Vertex = Vertex()
        childVertex.key = key
        childVertex.location = loc
        canvas.append(childVertex)
        return childVertex
    }
    
    
    
    func addEdge(source: Vertex, neighbor: Vertex)
    {
        // var weight = self.distanceInMetersFrom(source,EndVertex: neighbor)
        let weight = 0.0
        let newEdge = Edge(neighbor: neighbor,weight: weight)
        source.neighbors.append(newEdge)
        if (isDirected == false) {
            let reverseEdge = Edge(neighbor: neighbor,weight: weight)
            reverseEdge.neighbor = source
            neighbor.neighbors.append(reverseEdge)
        }
    }
}