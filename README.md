# MultiDex-for-Delphi

This addon brings MultiDex support to Delphi Android.

Installation.

   You need to have JEDI JCL installed.

   Run Targets.exe in the bin directory as administrator.
   Load the addon in Delphi. Build and install.

Use.

   You now have two new items in your project menu:
   
      MultiDex: Check to turn on MultiDex for this project.
      
      RunDex: Normally Delphi runs the Dex step on every compile. In non-MultiDex it doesn't take long, because pre-dexed libraries are used, but in multidex, you can't, and
              dexing takes longer. You only need to run the dex step, when you have added/removed/updated your libs. Check this item to run dex step. 
              RunDex is reset to false on successfull compile.
              
