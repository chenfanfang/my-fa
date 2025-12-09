#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import ConvoUI;

NS_ASSUME_NONNULL_BEGIN

@interface FAComposerToolsExample : NSObject

+ (NSArray<FinConvoComposerTool *> *)createExampleTools;
+ (void)handleComposerToolSelected:(FinConvoComposerTool *)tool;

@end

NS_ASSUME_NONNULL_END
