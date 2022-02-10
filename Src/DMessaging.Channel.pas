﻿unit DMessaging.Channel;

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
    procedure ClearCacheList;
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
    destructor Destroy;
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
        aSubscriber: TObject);
    /// <summary>
    ///
    /// </summary>
    procedure FreeSubscriber(
        aSubscriber: TObject);
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
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>); overload;
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
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>); overload;
    /// <summary>
    ///
    /// </summary>
    procedure SendInMainThread(
        const aMessageID: string;
        const aData     : TObject); overload;
    /// <summary>
    ///
    /// </summary>
    procedure SendInMainThread(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>); overload;
    /// <summary>
    ///
    /// </summary>
    procedure SendInMainThreadThenFree(
        const aMessageID: string;
        const aData     : TObject); overload;
    /// <summary>
    ///
    /// </summary>
    procedure SendInMainThreadThenFree(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>); overload;
    /// <summary>
    ///
    /// </summary>
    procedure SendInMainThreadSync(
        const aMessageID: string;
        const aData     : TObject); overload;
    /// <summary>
    ///
    /// </summary>
    procedure SendInMainThreadSync(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>); overload;
    /// <summary>
    ///
    /// </summary>
    procedure SendInMainThreadThenFreeSync(
        const aMessageID: string;
        const aData     : TObject); overload;
    /// <summary>
    ///
    /// </summary>
    procedure SendInMainThreadThenFreeSync(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>); overload;
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

procedure TMessageChannel.ClearCacheList;
var
  lKey: TObject;
begin
  for lKey in fCache.Keys.ToArray do
  begin
    fCache.Items[lKey].Free;
    fCache.Remove(lKey);
  end;
end;

constructor TMessageChannel.Create;
begin
  fLock := TCriticalSection.Create;
  fCache := TDictionary<TObject, TMethodCacheList>.Create;
  fSubscriberList := TList<TObject>.Create;
  fAnonymousSubscriberList := TObjectList<TObject>.Create;
end;

destructor TMessageChannel.Destroy;
begin
  ClearCacheList;
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
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>);
var
  lSubscriber: TObject;
begin
  fLock.Acquire;
  try
    for lSubscriber in fSubscriberList do
      if not InArray(lSubscriber, aExcludeSubscribers) then
        Send(aMessageID, aData, lSubscriber);
  finally
    fLock.Release;
  end;
end;

procedure TMessageChannel.SendThenFree(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>);
begin
  Send(aMessageID, aData, aExcludeSubscribers);
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

procedure TMessageChannel.SendInMainThread(
        const aMessageID: string;
        const aData     : TObject);
begin
  TThread.ForceQueue(nil,
    procedure
    begin
      Send(aMessageID, aData);
    end
  );
end;

procedure TMessageChannel.SendInMainThread(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>);
begin
  TThread.ForceQueue(nil,
    procedure
    begin
      Send(aMessageID, aData, aExcludeSubscribers);
    end
  );
end;

procedure TMessageChannel.SendInMainThreadThenFree(
        const aMessageID: string;
        const aData     : TObject);
begin
  TThread.ForceQueue(nil,
    procedure
    begin
      SendThenFree(aMessageID, aData);
    end
  );
end;

procedure TMessageChannel.SendInMainThreadThenFree(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>);
begin
  TThread.ForceQueue(nil,
    procedure
    begin
      SendThenFree(aMessageID, aData, aExcludeSubscribers);
    end
  );
end;

procedure TMessageChannel.SendInMainThreadSync(
        const aMessageID: string;
        const aData     : TObject);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      Send(aMessageID, aData);
    end
  );
end;

procedure TMessageChannel.SendInMainThreadSync(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      Send(aMessageID, aData, aExcludeSubscribers);
    end
  );
end;

procedure TMessageChannel.SendInMainThreadThenFreeSync(
        const aMessageID: string;
        const aData     : TObject);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      SendThenFree(aMessageID, aData);
    end
  );
end;

procedure TMessageChannel.SendInMainThreadThenFreeSync(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      SendThenFree(aMessageID, aData, aExcludeSubscribers);
    end
  );
end;

procedure TMessageChannel.UnregisterSubscriber(
        aSubscriber: TObject);
var
  lCacheList: TMethodCacheList;
begin
  fLock.Acquire;
  try
    if fSubscriberList.Contains(aSubscriber) then
    begin
      lCacheList := fCache.Items[aSubscriber];
      lCacheList.Free;
      fCache.Remove(aSubscriber);
      fSubscriberList.Remove(aSubscriber);
    end;
    if fAnonymousSubscriberList.Contains(aSubscriber) then
      fAnonymousSubscriberList.Remove(aSubscriber);
  finally
    fLock.Release;
  end;
end;

procedure TMessageChannel.FreeSubscriber(
        aSubscriber: TObject);
begin
  UnregisterSubscriber(aSubscriber);
  aSubscriber.Free;
end;

{ TMessageChannel.TAnonymousSubscriber<T> }

procedure TMessageChannel.TAnonymousSubscriber<T>.BeforeDestruction;
begin
  if fChannel.fAnonymousSubscriberList.Contains(Self) then
    fChannel.fAnonymousSubscriberList.Remove(Self);

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