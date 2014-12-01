//
//  js.cpp
//  Demo
//
//  Created by Wolfgag on 11/30/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#include "js.h"

JSDisplay::JSDisplay()
{
    md_log = [NSMutableArray init];
}

void JSDisplay::logJS(std::string s_)
{
   [md_log addObject:[NSString stringWithUTF8String: s_.c_str()]];
}