unit DMessaging;

interface

uses
  System.Classes,
  System.SysUtils,
  DMessaging.Channel;

type
  TMessaging = record
  private
    class var DefaultChannel: TMessageChannel;
  public
    class constructor Create;
    class destructor Destroy;
    /// <summary>
    ///
    /// </summary>
    class function CreateChannel: TMessageChannel; static;
    /// <summary>
    ///
    /// </summary>
    class function RegisterAnonymousSubscriber<T>(
        aProc: TSubscribeMethod<T>): TObject; static;
    /// <summary>
    ///
    /// </summary>
    class procedure RegisterSubscriber(
        aSubscriber: TObject); static;
    /// <summary>
    ///
    /// </summary>
    class procedure UnregisterSubscriber(
        aSubscriber: TObject); static;
    /// <summary>
    ///
    /// </summary>
    class procedure FreeSubscriber(
        aSubscriber: TObject); static;
    /// <summary>
    ///
    /// </summary>
    class procedure Send(
        const aMessageID: string;
        const aData     : TObject); overload; static;
    /// <summary>
    ///
    /// </summary>
    class procedure Send(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>); overload; static;
    /// <summary>
    ///
    /// </summary>
    class procedure SendThenFree(
        const aMessageID: string;
        const aData     : TObject); overload; static;
    /// <summary>
    ///
    /// </summary>
    class procedure SendThenFree(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>); overload; static;
    /// <summary>
    ///
    /// </summary>
    class procedure SendInMainThread(
        const aMessageID: string;
        const aData     : TObject); overload; static;
    /// <summary>
    ///
    /// </summary>
    class procedure SendInMainThread(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>); overload; static;
    /// <summary>
    ///
    /// </summary>
    class procedure SendInMainThreadThenFree(
        const aMessageID: string;
        const aData     : TObject); overload; static;
    /// <summary>
    ///
    /// </summary>
    class procedure SendInMainThreadThenFree(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>); overload; static;
    /// <summary>
    ///
    /// </summary>
    class procedure SendInMainThreadSync(
        const aMessageID: string;
        const aData     : TObject); overload; static;
    /// <summary>
    ///
    /// </summary>
    class procedure SendInMainThreadSync(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>); overload; static;
    /// <summary>
    ///
    /// </summary>
    class procedure SendInMainThreadThenFreeSync(
        const aMessageID: string;
        const aData     : TObject); overload; static;
    /// <summary>
    ///
    /// </summary>
    class procedure SendInMainThreadThenFreeSync(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>); overload; static;
  end;
  /// <summary>
  ///
  /// </summary>
  TValueWrapper<T> = class
  private
    fValue: T;
  public
    constructor Create(AValue: T);
    property Value: T read fValue;
  end;

implementation

{ TMessaging }

class constructor TMessaging.Create;
begin
  DefaultChannel := TMessageChannel.Create;
end;

class destructor TMessaging.Destroy;
begin
  DefaultChannel.Free;
end;

class function TMessaging.CreateChannel: TMessageChannel;
begin
  Result := TMessageChannel.Create;
end;

class function TMessaging.RegisterAnonymousSubscriber<T>(
        aProc: TSubscribeMethod<T>): TObject;
begin
  DefaultChannel.RegisterAnonymousSubscriber<T>(aProc);
end;

class procedure TMessaging.RegisterSubscriber(
        aSubscriber: TObject);
begin
  DefaultChannel.RegisterSubscriber(aSubscriber);
end;

class procedure TMessaging.UnregisterSubscriber(
        aSubscriber: TObject);
begin
  DefaultChannel.UnregisterSubscriber(aSubscriber);
end;

class procedure TMessaging.FreeSubscriber(
        aSubscriber: TObject);
begin
  DefaultChannel.FreeSubscriber(aSubscriber);
end;

class procedure TMessaging.Send(
        const aMessageID: string;
        const aData     : TObject);
begin
  DefaultChannel.Send(aMessageID, aData);
end;

class procedure TMessaging.Send(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>);
begin
  DefaultChannel.Send(aMessageID, aData, aExcludeSubscribers);
end;

class procedure TMessaging.SendThenFree(
        const aMessageID: string;
        const aData     : TObject);
begin
  DefaultChannel.SendThenFree(aMessageID, aData);
end;

class procedure TMessaging.SendThenFree(
        const aMessageID             : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>);
begin
  DefaultChannel.SendThenFree(aMessageID, aData, aExcludeSubscribers);;
end;

class procedure TMessaging.SendInMainThread(
        const aMessageID: string;
        const aData     : TObject);
begin
  DefaultChannel.SendInMainThread(aMessageID, aData);
end;

class procedure TMessaging.SendInMainThread(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>);
begin
  DefaultChannel.SendInMainThread(aMessageID, aData, aExcludeSubscribers);
end;

class procedure TMessaging.SendInMainThreadThenFree(
        const aMessageID: string;
        const aData     : TObject);
begin
  DefaultChannel.SendInMainThreadThenFree(aMessageID, aData);
end;

class procedure TMessaging.SendInMainThreadThenFree(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>);
begin
  DefaultChannel.SendInMainThreadThenFree(aMessageID, aData, aExcludeSubscribers);
end;

class procedure TMessaging.SendInMainThreadSync(
        const aMessageID: string;
        const aData     : TObject);
begin
  DefaultChannel.SendInMainThreadSync(aMessageID, aData);
end;

class procedure TMessaging.SendInMainThreadSync(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>);
begin
  DefaultChannel.SendInMainThreadSync(aMessageID, aData, aExcludeSubscribers);
end;

class procedure TMessaging.SendInMainThreadThenFreeSync(
        const aMessageID: string;
        const aData     : TObject);
begin
  DefaultChannel.SendInMainThreadThenFreeSync(aMessageID, aData);
end;

class procedure TMessaging.SendInMainThreadThenFreeSync(
        const aMessageID         : string;
        const aData              : TObject;
        const aExcludeSubscribers: TArray<TObject>);
begin
  DefaultChannel.SendInMainThreadThenFreeSync(aMessageID, aData, aExcludeSubscribers);
end;

{ TValueWrapper<T> }

constructor TValueWrapper<T>.Create(AValue: T);
begin
  fValue := AValue;
end;

end.
