//
//  SCNActionViewController.m
//  SceneKitRoationDemo
//
//  Created by tianpengfei on 16/5/8.
//  Copyright © 2016年 tianpengfei. All rights reserved.
//

#import "SCNActionViewController.h"

@interface SCNActionViewController ()
@property(strong,nonatomic)SCNNode *sunNode,*earthNode,*moonNode,*earthGroupNode,*sunHaloNode;
@end

@implementation SCNActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillLayoutSubviews{

    if(!_scnView){
        
        _scnView = [[SCNView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
        [self.view insertSubview:_scnView belowSubview:_closeButton];
        
        [self initScene];
    }

}
-(void)initScene{

    // create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 50,250);
    cameraNode.camera.zFar = 2000;
    cameraNode.rotation =  SCNVector4Make(1, 0, 0,-M_PI_4/4);
    
    // set the scene to the view
    _scnView.scene = scene;
    
    // configure the view
    _scnView.backgroundColor = [UIColor blackColor];
    
//    _scnView.allowsCameraControl = YES;
    
    [self initNode];

}
-(void)initNode{
    
    _sunNode = [SCNNode new];
    _earthNode = [SCNNode new];
    _moonNode = [SCNNode new];
    _earthGroupNode = [SCNNode new];
    
    _sunNode.geometry = [SCNSphere sphereWithRadius:34.0];
    _earthNode.geometry = [SCNSphere sphereWithRadius:14.0];
    _moonNode.geometry = [SCNSphere sphereWithRadius:7.0];
    
    _moonNode.position = SCNVector3Make(42, 0, 0);
    [_earthGroupNode addChildNode:_earthNode];
//    [_earthGroupNode addChildNode:_moonNode];
    
    _earthGroupNode.position = SCNVector3Make(140,0, 0);
    
    [_scnView.scene.rootNode addChildNode:_sunNode];
//    [_sunNode addChildNode:_earthGroupNode];
    
    
    
    // Add materials to the planets
    _earthNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/earth-diffuse-mini.jpg";
    _earthNode.geometry.firstMaterial.emission.contents = @"art.scnassets/earth/earth-emissive-mini.jpg";
    _earthNode.geometry.firstMaterial.specular.contents = @"art.scnassets/earth/earth-specular-mini.jpg";
    _moonNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/moon.jpg";
    _sunNode.geometry.firstMaterial.multiply.contents = @"art.scnassets/earth/sun.jpg";
    _sunNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun.jpg";
    _sunNode.geometry.firstMaterial.multiply.intensity = 0.5;
    _sunNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    _sunNode.geometry.firstMaterial.multiply.wrapS =
    _sunNode.geometry.firstMaterial.diffuse.wrapS  =
    _sunNode.geometry.firstMaterial.multiply.wrapT =
    _sunNode.geometry.firstMaterial.diffuse.wrapT  = SCNWrapModeRepeat;
    
    _earthNode.geometry.firstMaterial.locksAmbientWithDiffuse =
    _moonNode.geometry.firstMaterial.locksAmbientWithDiffuse  =
    _sunNode.geometry.firstMaterial.locksAmbientWithDiffuse   = YES;
    
    _earthNode.geometry.firstMaterial.shininess = 0.1;
    _earthNode.geometry.firstMaterial.specular.intensity = 0.5;
    _moonNode.geometry.firstMaterial.specular.contents = [UIColor grayColor];
    
    
    [self roationNode];
    [self addOtherNode];
    [self addLight];
}
-(void)roationNode{
    
    [_earthNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:2]]];   //地球自转
    [_moonNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:4 z:0 duration:1]]];   //月球自转
   
    // Moon-rotation (center of rotation of the Moon around the Earth)
    SCNNode *moonRotationNode = [SCNNode node];
    [moonRotationNode addChildNode:_moonNode];
    [moonRotationNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:3 z:0 duration:1]]];   //月球公转

    [_earthGroupNode addChildNode:moonRotationNode];
   
    // Earth-rotation (center of rotation of the Earth around the Sun)
    SCNNode *earthRotationNode = [SCNNode node];
    [_sunNode addChildNode:earthRotationNode];
    
    // Earth-group (will contain the Earth, and the Moon)
    [earthRotationNode addChildNode:_earthGroupNode];
    [earthRotationNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:1 z:0 duration:1]]];   //地月系统绕着太阳转

    // 添加飞船
    SCNNode *ship = [_scnView.scene.rootNode childNodeWithName:@"ship" recursively:YES];
    ship.scale = SCNVector3Make(2, 2, 2);
    ship.position = SCNVector3Make(70,70, 0);
    
    ship.eulerAngles = SCNVector3Make(0,0, -M_PI/4);
    ship.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    SCNNode *shipRotationNode = [SCNNode node];
    shipRotationNode.position = SCNVector3Make(-210, -210, 0);
    [_sunNode addChildNode:shipRotationNode];
    
    [shipRotationNode addChildNode:ship];

    SCNAction *shipMoveAction = [SCNAction moveTo:SCNVector3Make(0,0, 0) duration:4];
    shipMoveAction.timingMode = SCNActionTimingModeEaseOut;   //越来越慢
    
    
    SCNAction *shipRotationAction =[SCNAction repeatActionForever:[SCNAction rotateByAngle:-2 aroundAxis:SCNVector3Make(-5, 5, 0) duration:4]];
    
    SCNAction *sequenceAction = [SCNAction sequence:@[shipMoveAction,shipRotationAction]];  //顺序执行Action
    
    [shipRotationNode runAction:sequenceAction];
    
    [self addAnimationToSun];
    [self addParticleSystem];
}
-(void)addParticleSystem{

    SCNNode *ship = [_scnView.scene.rootNode childNodeWithName:@"ship" recursively:YES];
    SCNNode *shipMesh = [ship childNodeWithName:@"shipMesh" recursively:YES];

    SCNNode *emitter = [shipMesh childNodeWithName:@"emitter" recursively:YES];
    SCNParticleSystem *ps = [SCNParticleSystem particleSystemNamed:@"reactor.scnp" inDirectory:@"art.scnassets/particles"];
    [emitter addParticleSystem:ps];
    
}
-(void)addAnimationToSun{
    
    // Achieve a lava effect by animating textures
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    animation.duration = 10.0;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animation.repeatCount = FLT_MAX;
    [_sunNode.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
    
    animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    animation.duration = 30.0;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(5, 5, 5))];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5))];
    animation.repeatCount = FLT_MAX;
    [_sunNode.geometry.firstMaterial.multiply addAnimation:animation forKey:@"sun-texture2"];
    
}
-(void)addOtherNode{
    
    
    SCNNode *cloudsNode = [SCNNode node];
    cloudsNode.geometry = [SCNSphere sphereWithRadius:16.0];
    
    [_earthNode addChildNode:cloudsNode];
    
    cloudsNode.opacity = 0.5;
    // This effect can also be achieved with an image with some transparency set as the contents of the 'diffuse' property
    cloudsNode.geometry.firstMaterial.transparent.contents = @"art.scnassets/earth/cloudsTransparency.png";
    cloudsNode.geometry.firstMaterial.transparencyMode = SCNTransparencyModeRGBZero;
    
    // Add a halo to the Sun (a simple textured plane that does not write to depth)
    _sunHaloNode = [SCNNode node];
    _sunHaloNode.geometry = [SCNPlane planeWithWidth:300 height:300];
    _sunHaloNode.rotation = SCNVector4Make(1, 0, 0, 0 * M_PI / 180.0);
    _sunHaloNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun-halo.png";
    _sunHaloNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    _sunHaloNode.geometry.firstMaterial.writesToDepthBuffer = NO; // do not write to depth
    _sunHaloNode.opacity = 0.2;
    [_sunNode addChildNode:_sunHaloNode];
    
    
    // Add a textured plane to represent Earth's orbit
    SCNNode *earthOrbit = [SCNNode node];
    earthOrbit.opacity = 0.4;
    earthOrbit.geometry = [SCNPlane planeWithWidth:280 height:280];
    earthOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    earthOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    earthOrbit.rotation = SCNVector4Make(1, 0, 0,-M_PI_2);
    earthOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    [_sunNode addChildNode:earthOrbit];
    
    
//    // Add a textured plane to represent ship's orbit
//    SCNNode *shipOrbit = [SCNNode node];
//    shipOrbit.opacity = 0.4;
//    shipOrbit.geometry = [SCNPlane planeWithWidth:140 height:140];
//    shipOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
////    shipOrbit.geometry.firstMaterial.diffuse.contents = [UIColor redColor];
//    shipOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
//    shipOrbit.eulerAngles = SCNVector3Make(M_PI_4, M_PI_2, shipOrbit.eulerAngles.z);
//    shipOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
//    [_sunNode addChildNode:shipOrbit];
    
    
}

-(void)addLight{
    
    // We will turn off all the lights in the scene and add a new light
    // to give the impression that the Sun lights the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.color = [UIColor blackColor]; // initially switched off
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.light.zFar = 200;
    [_sunNode addChildNode:lightNode];
    
    // Configure attenuation distances because we don't want to light the floor
    lightNode.light.attenuationEndDistance = 2000.0;
    lightNode.light.attenuationStartDistance = 19.5;
    
    // Animation
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1];
    {
        
        lightNode.light.color = [UIColor whiteColor]; // switch on
        //[presentationViewController updateLightingWithIntensities:@[@0.0]]; //switch off all the other lights
        _sunHaloNode.opacity = 0.5; // make the halo stronger
    }
    [SCNTransaction commit];
    
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^(){}];
}
@end
