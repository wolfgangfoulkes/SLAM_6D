//
//  js.h
//  Demo
//
//  Created by Wolfgag on 11/30/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#ifndef __Demo__js__
#define __Demo__js__

#include <stdio.h>

class JSDisplay
{
    public:
    NSMutableArray * md_log;
    JSDisplay();
    void logJS(std::string s_);
    void printLog();
    
};

#endif /* defined(__Demo__js__) */
