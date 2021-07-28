# MultiDex-for-Delphi

This addon brings MultiDex support to Delphi Android.

INSTALLATION.

You need to have JEDI JCL installed.

Run Targets.exe in the Targets\bin directory as administrator.
Load the addon in Delphi. Build and install.

USE.

You now have three new items in your project menu:
   
MultiDex: Check to turn on MultiDex for this project.
      
RunDex: Normally Delphi runs the Dex step on every compile. In non-MultiDex it doesn't take long, 
because pre-dexed libraries are used, but in multidex, you can't, and dexing takes longer. 
You only need to run the dex step, when you have added/removed/updated your libs. 
Check this item to run dex step. 
RunDex is reset to false on successfull compile.

D8: Check to use D8 dexer.

If you intend to support Android before version 5.0 (minSDK < 21), you need to do the following.

D8/Multidex is not supported with minsdk < 21.

Add the MultiDex.jar in the MultidexJarPas directory to your project libs.
Add the AndroidApi.JNI.MultiDex.pas in the MultidexJarPas directory to your mainform uses list.
Add 'android:name="androidx.multidex.MultiDexApplication"' to your <application entry in your AndroidManifest.template.xml file.
Add the following statements at the start of your main forms FormCreate procedure.

    if TJBuild_VERSION.JavaClass.SDK_INT < 21
    then
       TJMultiDex.javaclass.install(TAndroidHelper.Context);

