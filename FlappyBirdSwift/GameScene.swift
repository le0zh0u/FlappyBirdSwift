//
//  GameScene.swift
//  FlappyBirdSwift
//
//  Created by 周椿杰 on 16/3/3.
//  Copyright (c) 2016年 周椿杰. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var skyColor:SKColor!
    var moving:SKNode!
    var pipeTextureUp:SKTexture!
    var pipeTextureDown:SKTexture!
    var movePipesAndRemove:SKAction!
    var bird:SKSpriteNode!
    
    var score = NSInteger()
    
    override func didMoveToView(view: SKView) {
        //设置背景颜色
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        
        //创建一个移动节点
        moving = SKNode()
        self.addChild(moving)
        
        //创建一个地面的纹理
        let groundTexture = SKTexture(imageNamed: "land")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        //创建一个平移地面精灵的动作
        let moveGroundSprite = SKAction.moveByX(-groundTexture.size().width*2.0, y: 0, duration: NSTimeInterval(0.02*groundTexture.size().width*2.0))
        
        //创建一个将地面精灵位置还原的动作
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width*2.0, y: 0, duration: 0.0)
        
        //创建一个无限循环的动作，组合上面的两个动作达到不断移动的效果
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        
        for var i:CGFloat=0; i<2.0+self.frame.size.width/(groundTexture.size().width*2.0);++i {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            //设置地面精灵的位置，注意在SpriteKit中坐标系远点在屏幕左下角
            sprite.setScale(2.0)
            sprite.position = CGPointMake(i*sprite.size.width, sprite.size.height/2.0)
            
            //将精灵设置为我们已经创建好的循环动作
            sprite.runAction(moveGroundSpritesForever)
            //对应屏幕的宽度生成n个地面精灵用于填充屏幕下方区域
            moving.addChild(sprite)
        }
        
        //创建一个天空的纹理
        let skyTexture = SKTexture(imageNamed: "sky")
        skyTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        //创建一个平移天空精灵的动作
        let moveSkySprite = SKAction.moveByX(-skyTexture.size().width*2.0, y: 0, duration: NSTimeInterval(0.1*skyTexture.size().width*2.0))
        
        //创建一个平移天空精灵的动作
        let resetSkySprite = SKAction.moveByX(skyTexture.size().width*2.0, y: 0, duration: 0.0)
        
        //创建一个无限循环的动作，组合上面的两个动作达到不断移动的效果
        let moveSkySpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveSkySprite,resetSkySprite]))
        
        for var i:CGFloat=0; i<2.0+self.frame.size.width/(skyTexture.size().width*2.0);++i {
            let sprite = SKSpriteNode(texture: skyTexture)
            sprite.setScale(2.0)
            //因为我们期望天空座位远一层的背景， 所以我们将天空精灵的坐标后移20
            sprite.zPosition = -20
            sprite.position = CGPointMake(i*sprite.size.width, sprite.size.height/2.0+groundTexture.size().height*2.0)
            sprite.runAction(moveSkySpritesForever)
            moving.addChild(sprite)
            
        }
    
        // init bird picture animate
        let birdTexture1 = SKTexture(imageNamed: "bird-1")
        birdTexture1.filteringMode = SKTextureFilteringMode.Nearest
        let birdTexture2 = SKTexture(imageNamed: "bird-2")
        birdTexture2.filteringMode = SKTextureFilteringMode.Nearest
        // init animate
        let anim = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.2)
        let flap = SKAction.repeatActionForever(anim)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(2.0)
        bird.position = CGPoint(x: self.frame.size.width*0.35, y: self.frame.size.height*0.6)
        bird.runAction(flap)
        self.addChild(bird)
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -0.5)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2.0)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.allowsRotation = false
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
