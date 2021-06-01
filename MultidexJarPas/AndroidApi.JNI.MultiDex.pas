
unit AndroidApi.JNI.MultiDex;

interface

uses
  Androidapi.JNIBridge,
  Androidapi.JNI.App,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Util;

type
// ===== Forward declarations =====

  JMultiDex = interface;//androidx.multidex.MultiDex

// ===== Interface declarations =====

  JMultiDexClass = interface(JObjectClass)
    ['{C4B51236-C451-4483-96D1-C5918E2943C3}']
    {class} procedure install(context: JContext); cdecl;
    {class} procedure installInstrumentation(context: JContext; context1: JContext); cdecl;
  end;

  [JavaSignature('androidx/multidex/MultiDex')]
  JMultiDex = interface(JObject)
    ['{A37C8D01-4EC9-4353-8F39-7B9C1EADD657}']
  end;
  TJMultiDex = class(TJavaGenericImport<JMultiDexClass, JMultiDex>) end;

implementation

procedure RegisterTypes;
begin
  TRegTypes.RegisterType('AndroidApi.JNI.MultiDex.JMultiDex', TypeInfo(AndroidApi.JNI.MultiDex.JMultiDex));
end;

initialization
  RegisterTypes;
end.

