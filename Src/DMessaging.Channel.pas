//  MIT License
//
//  Copyright © 2021 Ngô Thạch (https://www.smartmonkey.app)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

unit DMessaging.Channel;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.SyncObjs,
  System.SysUtils;

type
  /// <summary>
  ///
  /// </summary>
  TSubscribeAttribute = class(TCustomAttribute);
  /// <summary>
  ///
  /// </summary>
  TSubscribeMethod<T> = reference to procedure(const MessageID: string; Arg: T);
  /// <summary>
  ///
  /// </summary>
  TMessageChannel = class
  strict private type
    TMethodCache = record
      Method: TRttiMethod;
      MetaClass: TClass;
    end;
    /////////////////////////////////
    TMethodCacheList = class(TList<TMethodCache>)
    private
      fRttiContext: TRttiContext;
    public
      destructor Destroy; override;
    end;
    /////////////////////////////////
    TAnonymousSubscriber<T> = class
    private
      fChannel: TMessageChannel;
      fProc: TSubscribeMethod<T>;
    public
      /// <summary>
      ///
      /// </summary>
      constructor Create(
          aProc: TSubscribeMethod<T>);
      /// <summary>
      ///
      /// </summary>
      procedure BeforeDestruction; override;
      /// <summary>
      ///
      /// </summary>
      [TSubscribeAttribute]
      procedure ProcessEvent(
          const aEvent: string;
          const aData : T);
    end;
  private
    fCache: TDictionary<TObject, TMethodCacheList>;
    fSubscriberList: TList<TObject>;
    fAnonymousSubscriberList: TList<TObject>;
    fLock: TCriticalSection;
    /// <summary>
    ///
    /// </summary>
    function GetSubscribeMethodList(
        aSubscriber  : TObject;
        var CacheList: TMethodCacheList): Boolean;
    /// <summary>
    ///
    /// </summary>
    procedure Send(
        const aMessageID : string;
        const aData      : TObject;
        const aSubscriber: TObject); overload;
  public
    /// <summary>
    ///
    /// </summary>
    constructor Create;
    /// <summary>
    ///
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    ///
    /// </summary>
    function RegisterAnonymousSubscriber<T>(
        aProc: TSubscribeMethod<T>): TObject;
    /// <summary>
    ///
    /// </summary>
    procedure RegisterSubscriber(
        aSubscriber: TObject);
    /// <summary>
    ///
    /// </summary>
    procedure UnregisterSubscriber(
        aSubscriber: TObject); overload;
    /// <summary>
    ///
    /// </summary>
    procedure UnregisterSubscriber(
        aSubscribers: TArray<TObject>); overload;
    /// <summary>
    ///
    /// </summary>
    procedure FreeSubscriber(
        aSubscriber: TObject); overload;
    /// <summary>
    ///
    /// </summary>
    procedure FreeSubscriber(
        aSubscribers: TArray<TObject>); overload;
    /// <summary>
    ///
    /// </summary>
    procedure Send(
        const aMessageID: string;
        const aData     : TObject); overload;
    /// <summary>
    ///
    /// </summary>
    procedure Send(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>); overload;
    /// <summary>
    ///
    /// </summary>
    procedure SendThenFree(
        const aMessageID: string;
        const aData     : TObject); overload;
    /// <summary>
    ///
    /// </summary>
    procedure SendThenFree(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>); overload;
  end;

implementation

function InArray(
        const aObject: TObject;
        const aArray : array of TObject): Boolean; overload;
var
  lObj: TObject;
begin
  Result := False;
  for lObj in aArray do
    if lObj = aObject then
      Exit(True);
end;

{ TMessageChannel }

constructor TMessageChannel.Create;
begin
  fLock := TCriticalSection.Create;
  fCache :=   TObjectDictionary<TObject, TMethodCacheList>.Create([doOwnsValues]);
  fSubscriberList := TList<TObject>.Create;
  fAnonymousSubscriberList := TList<TObject>.Create;
end;

destructor TMessageChannel.Destroy;
begin
  // If anonymous list is not empty, free all the remain subscribers
  while FAnonymousSubscriberList.Count > 0 do
    FAnonymousSubscriberList[0].Free;
  //
  fLock.Free;
  fCache.Free;
  fSubscriberList.Free;
  fAnonymousSubscriberList.Free;
end;

function TMessageChannel.GetSubscribeMethodList(
        aSubscriber  : TObject;
        var CacheList: TMethodCacheList): Boolean;
var
  lContext: TRttiContext;
  lType: TRttiType;
  lMethod: TRttiMethod;
  lAttr: TCustomAttribute;
  lCacheItem: TMethodCache;
  lSubscribeMethodList: TMethodCacheList;
begin
  Result := False;
  lSubscribeMethodList := TMethodCacheList.Create;
  lContext := TRttiContext.Create;
  lType := lContext.GetType(aSubscriber.ClassType);
  for lMethod in lType.GetMethods do
    for lAttr in lMethod.GetAttributes do
      if lAttr is TSubscribeAttribute then
        if (Length(lMethod.GetParameters) = 2) then
          if (lMethod.GetParameters[0].ParamType.TypeKind in [tkUnicodeString]) and lMethod.GetParameters[1].ParamType.IsInstance then
          begin
            Result := True;
            lCacheItem.Method := lMethod;
            lCacheItem.MetaClass := lMethod.GetParameters[1].ParamType.AsInstance.MetaclassType;
            lSubscribeMethodList.Add(lCacheItem);
          end;

  if Result then
  begin
    CacheList := lSubscribeMethodList;
    CacheList.fRttiContext := lContext;
  end
  else
    lSubscribeMethodList.Free;
end;

procedure TMessageChannel.Send(
        const aMessageID: string;
        const aData     : TObject);
begin
  Send(aMessageID, aData, []);
end;

procedure TMessageChannel.Send(
        const aMessageID : string;
        const aData      : TObject;
        const aSubscriber: TObject);
var
  lMethod: TRttiMethod;
  lCacheItem: TMethodCache;
begin
  for lCacheItem in fCache.Items[aSubscriber] do
    if (aData = nil) // NIL is passed to all subscribers
        or (aData.ClassType = lCacheItem.MetaClass)
        or aData.InheritsFrom(lCacheItem.MetaClass) then
    begin
      lMethod := lCacheItem.Method;
      lMethod.Invoke(aSubscriber, [aMessageID, aData]);
    end;
end;

procedure TMessageChannel.Send(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>);
var
  lSubscriber: TObject;
begin
  fLock.Acquire;
  try
    for lSubscriber in fSubscriberList do
      if not InArray(lSubscriber, aExceptedSubscribers) then
        Send(aMessageID, aData, lSubscriber);
  finally
    fLock.Release;
  end;
end;

procedure TMessageChannel.SendThenFree(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>);
begin
  Send(aMessageID, aData, aExceptedSubscribers);
  aData.Free;
end;

procedure TMessageChannel.SendThenFree(
        const aMessageID: string;
        const aData     : TObject);
begin
  Send(aMessageID, aData);
  aData.Free;
end;

function TMessageChannel.RegisterAnonymousSubscriber<T>(
        aProc: TSubscribeMethod<T>): TObject;
begin
  fLock.Acquire;
  try
    Result := TAnonymousSubscriber<T>.Create(aProc);
    RegisterSubscriber(Result);
    fAnonymousSubscriberList.Add(Result);
    TAnonymousSubscriber<T>(Result).fChannel := Self;
  finally
    fLock.Release;
  end;
end;

procedure TMessageChannel.RegisterSubscriber(
        aSubscriber: TObject);
var
  lSubscribeMethodList: TMethodCacheList;
begin
  fLock.Acquire;
  try
    if not fSubscriberList.Contains(aSubscriber)
        and GetSubscribeMethodList(aSubscriber, lSubscribeMethodList) then
    begin
      fSubscriberList.Add(aSubscriber);
      fCache.Add(aSubscriber, lSubscribeMethodList);
    end;
  finally
    fLock.Release;
  end;
end;

procedure TMessageChannel.UnregisterSubscriber(
        aSubscriber: TObject);
begin
  fLock.Acquire;
  try
    if fSubscriberList.Contains(aSubscriber) then
    begin
      fCache.Remove(aSubscriber);
      fSubscriberList.Remove(aSubscriber);
    end;
    if fAnonymousSubscriberList.Contains(aSubscriber) then
      fAnonymousSubscriberList.Remove(aSubscriber);
  finally
    fLock.Release;
  end;
end;

procedure TMessageChannel.UnregisterSubscriber(
        aSubscribers: TArray<TObject>);
var
  lSubscriber: TObject;
begin
  for lSubscriber in aSubscribers do
    UnregisterSubscriber(lSubscriber);
end;

procedure TMessageChannel.FreeSubscriber(
        aSubscriber: TObject);
begin
  UnregisterSubscriber(aSubscriber);
  aSubscriber.Free;
end;

procedure TMessageChannel.FreeSubscriber(
        aSubscribers: TArray<TObject>);
var
  lSubscriber: TObject;
begin
  for lSubscriber in aSubscribers do
    FreeSubscriber(lSubscriber);
end;

{ TMessageChannel.TAnonymousSubscriber<T> }

procedure TMessageChannel.TAnonymousSubscriber<T>.BeforeDestruction;
begin
  fChannel.UnregisterSubscriber(Self);
  inherited;
end;

constructor TMessageChannel.TAnonymousSubscriber<T>.Create(
        aProc: TSubscribeMethod<T>);
begin
  fProc := aProc;
end;

procedure TMessageChannel.TAnonymousSubscriber<T>.ProcessEvent(
        const aEvent: string;
        const aData : T);
begin
  if Assigned(fProc) then
    fProc(aEvent, aData);
end;

{ TMessageChannel.TMethodCacheList }

destructor TMessageChannel.TMethodCacheList.Destroy;
begin
  fRttiContext.Free;
  inherited;
end;

end.
