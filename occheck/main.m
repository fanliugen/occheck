//
//  main.m
//  occheck
//
//  Created by 启亮 谌 on 12-2-24.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCManager.h"
NSCharacterSet *OCNameCharacterSet;
int verbose = 0;

int hasDangerousFunction = 0;

BOOL isArc = NO;

int main (int argc, const char * argv[])
{
    int ret = 0;
    @autoreleasepool {
        // insert code here...
        NSMutableCharacterSet *set = [[[NSMutableCharacterSet alloc] init] autorelease];
        [set addCharactersInRange:NSMakeRange('A', 'Z'-'A'+1)];
        [set addCharactersInRange:NSMakeRange('a', 'z'-'a'+1)];
        [set addCharactersInRange:NSMakeRange('0', '9'-'0'+1)];
        [set addCharactersInString:@"_"];
        OCNameCharacterSet = [set copy]; 
        
        if (argc>1) {
            for (int i = 1; i < argc; i++) {
                NSString *param = [NSString stringWithUTF8String:argv[i]];
                if ([param hasPrefix:@"-"]) {
                    if ([param isEqualToString:@"-v"]) {
                        verbose = 1;
                    }
                    if ([param isEqualToString:@"-vv"]) {
                        verbose = 2;
                    }
                    if ([param isEqualToString:@"-vvv"]) {
                        verbose = 3;
                    }
                    if ([param isEqualToString:@"-arc"]) {
                        isArc = YES;
                    }
                }
                else{
                    setpriority(PRIO_PROCESS, getpid(), PRIO_DARWIN_BG);
                    OCManager *manager = [[OCManager alloc] initWithDirectory:param];
                    if (![manager checkError]) {
                        printf("给力! 在 %s 中没有发现内存泄露问题。\n",[param UTF8String]);
                    }
                    else{
                        ret = -1;
                    }
                    if(hasDangerousFunction==0){
                        printf("给力! 在 %s 中没有发现高危函数。\n",[param UTF8String]);
                    }
                    else{
                        ret = -1;
                    }
                    [manager release];
                }
            }
        }
        else{
            printf("检查一个目录下的源代码是否存在问题\n");
            printf("使用方法：\n");
            printf("occheck [-arc] [文件夹路径] ...\n");
            printf("-arc 使用ARC的工程，不会检查内存泄漏，仍会检查高危函数。");
        }
    }
    return ret;
}

