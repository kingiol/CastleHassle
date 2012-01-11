//
//  ButtonItem.m
//  Rev5
//
//  Created by Bryce Redd on 3/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PurchaseItem.h"
#import "ButtonItem.h"
#import "Battlefield.h"
#import "HUDActionController.h"
#import "Piece.h"
#import "Weapon.h"

@implementation PurchaseItem

@synthesize selectedPiece, price;

-(id) initWithPiece:(Piece*)p {
	if( (self=[super init])) {
		self.selectedPiece = p;
		
        isObservingSelected = YES;
		[selectedPiece addObserver:self 
						forKeyPath:@"isChanged" 
						   options:NSKeyValueObservingOptionNew
						   context:nil];
		
		AtlasSpriteManager* mgr = [[Battlefield instance].managers objectForKey:@"coins"];
		
		coin = [AtlasSprite spriteWithRect:CGRectMake(0, 21, 14, 14) 
										   spriteManager:mgr];
		
		[mgr addChild:coin];
		
	}
	return self;
}

-(void) postInitWithText:(NSString *)text {
	self.buttonText = [Label labelWithString:text fontName:@"Arial" fontSize:14.0];
	self.price = [Label labelWithString:[NSString stringWithFormat:@"%d", 50] fontName:@"Arial" fontSize:14.0];
	[[Battlefield instance] addChild:price z:PIECE_Z_INDEX];
	[[Battlefield instance] addChild:buttonText z:PIECE_Z_INDEX];
	
	if([text compare:@"Repair"] == NSOrderedSame)
		type = repair;
	else 
		type = upgrade;

	[self updatePrice];
}

-(BOOL) handleInitialTouch:(CGPoint)p {
	
	if(buttonText.visible) { return [super handleInitialTouch:p]; } 
	
	return NO;
}

-(BOOL) handleDragExit:(CGPoint)p {
	return YES;
}

-(void) move:(CGPoint)p {
	[super move:p];
	
	float xLeft = img.position.x - img.textureRect.size.width/2;
	float xRight = img.position.x + img.textureRect.size.width/2;
	
	buttonText.position = ccp((xLeft+xRight-40)/2, buttonText.position.y);
	
	//buttonText.position = CGPointMake(img.position.x, buttonText.position.y);
	coin.position = ccp(xRight-40, img.position.y);
	price.position = ccp(xRight-20, img.position.y);
}

-(void) hide {
	[super hide];
    
    [buttonText runAction:[FadeOut actionWithDuration:.25]];
    [coin runAction:[FadeOut actionWithDuration:.25]];
    [price runAction:[FadeOut actionWithDuration:.25]];
    
}

-(void) show {
	[super show];

	[buttonText runAction:[FadeIn actionWithDuration:.25]];
    [coin runAction:[FadeIn actionWithDuration:.25]];
    [price runAction:[FadeIn actionWithDuration:.25]];
    
	[self move:ccp(0,0)];
	[self updatePrice];
}

-(void) updatePrice {
	if(type == repair) {

		[price setString:[NSString stringWithFormat:@"%d", [selectedPiece getCurrentRepairPrice]]];
	} 
	
	if(type == upgrade) {
		Weapon* w = (Weapon*)selectedPiece;
		[price setString:[NSString stringWithFormat:@"%d", [w getUpgradePrice]]];
		[buttonText setString:[NSString stringWithFormat:@"Upgrade Lv%d", w.weaponLevel]];
		if(w.weaponLevel >= MAX_WEAPON_LEVEL) { [self hide]; }
	}
	
	
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self updatePrice];
}

-(void) dealloc {
    if(isObservingSelected)
        [selectedPiece removeObserver:self forKeyPath:@"isChanged"];
        
    [selectedPiece release];
    [price release];
	
	[super dealloc];
}

@end