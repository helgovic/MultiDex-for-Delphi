# MultiDex-for-Delphi

This addon brings MultiDex support to Delphi Android.

INSTALLATION.

You need to have JEDI JCL installed.

Run Targets.exe in the Targets\bin directory as administrator.
Load the addon in Delphi. Build and install.

USE.

You now have two new items in your project menu:
   
MultiDex: Check to turn on MultiDex for this project.
      
RunDex: Normally Delphi runs the Dex step on every compile. In non-MultiDex it doesn't take long, 
because pre-dexed libraries are used, but in multidex, you can't, and dexing takes longer. 
You only need to run the dex step, when you have added/removed/updated your libs. 
Check this item to run dex step. 
RunDex is reset to false on successfull compile.

If you intend to support Android before version 5.0 (minSDK < 21), you need to do the following.

Add the MultiDex.jar in the MultidexJarPas directory to your project libs.
Add the AndroidApi.JNI.MultiDex.pas in the MultidexJarPas directory to your mainform uses list.
Add the following statements at the start of your main forms FormCreate procedure.

    if TJBuild_VERSION.JavaClass.SDK_INT < 21
    then
       TJMultiDex.javaclass.install(TAndroidHelper.Context);

