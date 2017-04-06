//
//  CCParticleSystem+NodeInfo.m
//  CocosBuilder
//
//  Created by Plus on 2017/4/5.
//
//

#import "CCParticleSystem+NodeInfo.h"
#import "CCNode+NodeInfo.h"
#import "SequencerKeyframe.h"
#import "PlugInNode.h"
#import "SequencerNodeProperty.h"

@implementation CCParticleSystem (NodeInfo)
- (void) updateProperty:(NSString*) propName time:(float)time sequenceId:(int)seqId{
    int type = [SequencerKeyframe keyframeTypeFromPropertyType:[self.plugIn propertyTypeForProperty:propName]];
    if (!type) return;
    
    id value = [self valueForProperty:propName atTime:time sequenceId:seqId];
    if (type == kCCBKeyframeTypeToggle && [propName isEqualToString:@"particleActive"]){
        [self setValue:value forKey:propName];
        SequencerNodeProperty* seqNodeProp = [self sequenceNodeProperty:propName sequenceId:seqId];
        if (seqNodeProp == 0 && time == 0) {
            [self resetSystem];
        }
    } else {
        [super updateProperty:propName time:time sequenceId:seqId];
    }
}
@end
