This repository contains a project called "US Visa App for iPhone".

Technical notes
===============

Progress bar UI on iPhone 
------------------------- 

https://github.com/sakrist/UIDownloadBar 


Writing iOS 4 Code to Hide the iPhone Keyboard 
---------------------------------------------- 
 
http://www.techotopia.com/index.php/Writing_iOS_4_Code_to_Hide_the_iPhone_Keyboard 


NSDate formatting 
----------------- 
 
http://stackoverflow.com/questions/1349266/convert-an-nsdates-description-into-an-nsdate 
 
 
Save/restore context 
-------------------- 
 
http://www.servin.com/iphone/iPhone-Save-and-Restore-Mini-Course.html 
 
 
Getting application directory name 
---------------------------------- 
 
    NSString* docPath() { 
        NSArray* pathList =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        return [[pathList objectAtIndex:0] stringByAppendingPathComponent:@"data.dtd"]; 
    } 
 
    - (BOOL)application:(UIApplication *)applicationdidFinishLaunchingWithOptions:(NSDictionary *)launchOptions { 
        // Attempt to load an existing to-do dataset from an array stored to disk. 
        NSArray *plist = [NSArray arrayWithContentsOfFile:docPath()]; 
        if (plist) {
            // If there was a dataset available, copy it into our instance variable.
            tasks = [plist mutableCopy];
        } else {
            // Otherwise, just create an empty one to get us started.
            tasks = [[NSMutableArray alloc] init];
        }
    }

    - (void)applicationDidEnterBackground:(UIApplication *)application {
        // This method is only called in iOS 4.0+
        // Save our tasks array to disk
        [tasks writeToFile:docPath() atomically:YES];
    }

    NSString *pathInDocumentDirectory(NSString *fileName) {
        // Get list of document directories in sandbox
        NSArray *documentDirectories =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        // Get one and only document directory from that list
        NSString *documentDirectory = [documentDirectories objectAtIndex:0];
        // Append passed in file name to that directory, return it
        return [documentDirectory stringByAppendingPathComponent:fileName];
    }
