//
//  GameScene.swift
//  Minesweeper
//
//  Created by Jonathan Pappas on 1/4/22.
//

import SpriteKit
import GameplayKit


class MineSweeperTile: SKSpriteNode {
    var bomb: Bool = false
    var revealed = false
    var x = 0
    var y = 0
}

class GameScene: SKScene {
    var dimensions: (x: Int, y: Int) = (20, 20)
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        let boardNode = SKNode()
        for x in 1...dimensions.x {
            for y in 1...dimensions.y {
                let tile = MineSweeperTile.init(color: .black, size: .init(width: 100, height: 100))
                tile.position = CGPoint(x: x * 110, y: y * 110)
                tile.name = "\(x) \(y)"
                if Int.random(in: 1...8) == 1{//
                    tile.bomb = true
                }
                tile.x = x
                tile.y = y
                boardNode.addChild(tile)
            }
        }
        addChild(boardNode)
        
        let perfect = boardNode.calculateAccumulatedFrame()
        let maximum = max(perfect.width, perfect.height)
        boardNode.setScale(850 / maximum)
        
        boardNode.position.x += -50 * boardNode.xScale //(((1000 - 850) / 2) - 50) * boardNode.xScale
        boardNode.position.y += -50 * boardNode.xScale //(((1000 - 850) / 2) - 50) * boardNode.xScale
        boardNode.position.x += 66
        boardNode.position.y += 66
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let nodesTapped = nodes(at: location)
        if let minesweeper = nodesTapped.first as? MineSweeperTile {
            reveal(tile: minesweeper)
        }
    }
    
    
    func tileAt(x: Int, y: Int) -> MineSweeperTile? {
        return (children.first?.childNode(withName: "\(x) \(y)") as? MineSweeperTile)
    }
    func isBomb(x: Int, y: Int) -> Bool {
        return tileAt(x: x, y: y)?.bomb == true
    }
    
    func neighborsAreBombs(tile: MineSweeperTile, slowed: Double = 0.0) -> Int {
        var bombsNearby = 0
        
        for dx in [-1, 0, 1] {
            for dy in [-1, 0, 1] {
                if dx == 0, dy == 0 { continue }
                
                if isBomb(x: tile.x + dx, y: tile.y + dy) {
                    bombsNearby += 1
                }
            }
        }
        
        if bombsNearby == 0 {
            
            let foo = DispatchQueue.init(label: "foo")
            foo.async {
                for dx in [-1, 0, 1] {
                    for dy in [-1, 0, 1] {
                        if dx == 0, dy == 0 { continue }
                        print(tile.x + dx, tile.y + dy)
                        if let tileo = self.tileAt(x: tile.x + dx, y: tile.y + dy) {
                            self.reveal(tile: tileo, slowed: slowed + 0.00)
                        }
                    }
                }
            }
            
        }
        
        return bombsNearby
    }
    
    // When you tap for the first time, the location of the tap plus neighbors are all unbombed
    func firstRevealed(tile: MineSweeperTile) {
        firstReveal = false
        tile.bomb = false
        
        for dx in [-1, 0, 1] {
            for dy in [-1, 0, 1] {
                if dx == 0, dy == 0 { continue }
                tileAt(x: tile.x + dx, y: tile.y + dy)?.bomb = false
            }
        }
    }
    
    var firstReveal = true
    func reveal(tile: MineSweeperTile, slowed: Double = 0.0) {
        if tile.revealed {
            return
        }
        
        tile.revealed = true
        
        if firstReveal {
            firstRevealed(tile: tile)
        }
        
        if tile.bomb {
            tile.color = .gray
            
        } else {
            tile.run(.customAction(withDuration: slowed + 0.1, actionBlock: { i, foo in
                tile.color = .init(white: foo * 10.0, alpha: 1.0)
            }))
            //tile.color = .white
            
            let count = neighborsAreBombs(tile: tile, slowed: slowed)
            let label = SKLabelNode.init(text: "\(count)")
            label.fontColor = .black
            label.fontName = ""
            label.setScale(80 / label.frame.height)
            label.fontSize *= label.xScale
            label.setScale(1)
            label.verticalAlignmentMode = .center
            tile.addChild(label)
        }
        
        
    }
    
    
}
