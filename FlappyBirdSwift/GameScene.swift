//
//  GameScene.swift
//  FlappyBirdSwift
//
//  Created by 周椿杰 on 16/3/3.
//  Copyright (c) 2016年 周椿杰. All rights reserved.
//

import SpriteKit

class GameScene: SKScene ,SKPhysicsContactDelegate{
    
    var skyColor:SKColor!
    var moving:SKNode!
    var pipeTextureUp:SKTexture!
    var pipeTextureDown:SKTexture!
    var movePipesAndRemove:SKAction!
    var bird:SKSpriteNode!
    var pipes:SKNode!
    
    var score = NSInteger()
    
    let birdCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
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
        // 设置bird大小，以及处罚未知
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(2.0)
        bird.position = CGPoint(x: self.frame.size.width*0.35, y: self.frame.size.height*0.6)
        bird.runAction(flap)
        self.addChild(bird)
        
        //小鸟自由落体
        //定制游戏世界的重力方向
        self.physicsWorld.gravity = CGVectorMake(0.0, -5)
        //设置小鸟遵循物理守则
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2.0)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.physicsBody?.contactTestBitMask = worldCategory | pipeCategory
        
        let ground = SKNode()
        ground.position = CGPointMake(0, groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height*2.0))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
        
        pipes = SKNode()
        moving.addChild(pipes)
        
        pipeTextureUp = SKTexture(imageNamed: "PipeUp")
        pipeTextureUp.filteringMode = SKTextureFilteringMode.Nearest
        pipeTextureDown = SKTexture(imageNamed: "PipeDown")
        pipeTextureDown.filteringMode = SKTextureFilteringMode.Nearest
        
        //每个管道的位移距离
        let distanceToMove = CGFloat(self.frame.size.width+2.0*pipeTextureUp.size().width)
        //定义移动管道的动作
        let movePipes = SKAction.moveByX(-distanceToMove, y: 0.0, duration: NSTimeInterval(0.01*distanceToMove))
        //定义将管道从屏幕移除的动作
        let removePipes = SKAction.removeFromParent()
        //将两个动作组合
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
        
        //创建一个生成管道的闭包
        let spawn = SKAction.runBlock({() in self.spawnPipes()})
        //定义一个延迟时间
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        //组合后为一个调用必报内容后延迟2秒的操作
        let spawnThenDelay = SKAction.sequence([spawn,delay])
        //无限次重复上面生成的组合内容
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        //启动定时器
        self.runAction(spawnThenDelayForever)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        //通过点击让小鸟上升
        if moving.speed > 0{
            for touch:AnyObject in touches{
                let location = touch.locationInNode(self)
                //将小鸟的速度设置为0
                bird.physicsBody?.velocity = CGVectorMake(0, 0)
                //给小鸟一个向上的瞬时速度
                bird.physicsBody?.applyImpulse(CGVectorMake(0, 30))
            }
        }
    }
    
    func clamp(min:CGFloat, max: CGFloat, value:CGFloat)->CGFloat{
        if value > max{
            return max
        } else if value < min {
            return min
        }else{
            return value
        }
    }
    
    func spawnPipes(){
        //生成一个节点用于管理一对管道
        let pipePair = SKNode()
        //设置这个管道的起始位置在屏幕最右侧
        pipePair.position = CGPointMake(self.frame.size.width+pipeTextureUp.size().width*2, 0)
        //设置这个节点在陆地和小鸟的后面，在背景（-20）之前
        pipePair.zPosition = -10
        
        //通过随机方法创建一个随机的管道高度
        let height = UInt32(self.frame.size.height/4)
        let y = arc4random()%height + height
        
        //创建下管道并指定位置
        let pipeDown = SKSpriteNode(texture: pipeTextureDown)
        pipeDown.setScale(2.0)
        pipeDown.position = CGPointMake(0.0, CGFloat(y)+pipeDown.size.height+150.0)
        
        //指定下管道的物理属性，并指定碰撞属性和与什么类型精灵发生碰撞时调用委托（contactTestBitMake）
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody?.dynamic=false
        pipeDown.physicsBody?.categoryBitMask = pipeCategory
        pipeDown.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipeDown)
        
        //创建上管道并指定位置
        let pipeUp = SKSpriteNode(texture: pipeTextureUp)
        pipeUp.setScale(2.0)
        pipeUp.position = CGPointMake(0.0, CGFloat(y))
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody?.dynamic = false
        pipeUp.physicsBody?.categoryBitMask = pipeCategory
        pipeUp.physicsBody?.contactTestBitMask = pipeCategory
        pipePair.addChild(pipeUp)
        
        //常见一个用于检测小鸟是否通过该组管道的节点
        let contactNode = SKNode()
        contactNode.position = CGPointMake(pipeDown.size.width + bird.size.width/2, CGRectGetMidY(self.frame))
        contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeUp.size.width, self.frame.size.height))
        contactNode.physicsBody?.dynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(contactNode)
        
        //执行预设的动画将管道添加到屏幕
        pipePair.runAction(movePipesAndRemove)
        pipes.addChild(pipePair)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if bird.physicsBody!.velocity.dy<0{
            bird.zRotation = self.clamp(-1, max: 0.5, value: bird.physicsBody!.velocity.dy*0.003)
        }else{
            bird.zRotation = self.clamp(-1, max: 0.5, value: bird.physicsBody!.velocity.dy*0.001)
        }
//        bird.zRotation = self.clamp(-1, max: 0.5, value: bird.physicsBody!.velocity.dy*(bird.physicsBody!.velocity.dy<0?0.003:0.001))
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if moving.speed>0{
            if(contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
                //当两个碰撞物体的其中一个掩码为scoreCategory时，即可确定是小鸟通过了管道间的空隙
                
            }else{
                //否则可以确定小鸟撞到了地面或者管道，游戏结束
                moving.speed = 0
            }
        }
    }
}
