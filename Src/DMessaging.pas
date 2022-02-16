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

unit DMessaging;

interface

uses
  System.Classes,
  System.SysUtils,
  DMessaging.Channel;

type
  TMessaging = record
  private
    class var CommonChannel: TMessageChannel;
  public
    class constructor Create;
    class destructor Destroy;
    /// <summary>
    ///
    /// </summary>
    class function CreatePrivateChannel: TMessageChannel; static;
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
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>); overload; static;
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
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>); overload; static;
  end;
  /// <summary>
  ///
  /// </summary>
  TValueWrapper<T> = class
  private
    fValue: T;
  public
    /// <summary>
    ///
    /// </summary>
    constructor Create(
        aValue: T);
    /// <summary>
    ///
    /// </summary>
    property Value: T
        read  fValue
        write fValue;
  end;

implementation

{ TMessaging }

class constructor TMessaging.Create;
begin
  CommonChannel := TMessageChannel.Create;
end;

class destructor TMessaging.Destroy;
begin
  CommonChannel.Free;
end;

class function TMessaging.CreatePrivateChannel: TMessageChannel;
begin
  Result := TMessageChannel.Create;
end;

class function TMessaging.RegisterAnonymousSubscriber<T>(
        aProc: TSubscribeMethod<T>): TObject;
begin
  Result := CommonChannel.RegisterAnonymousSubscriber<T>(aProc);
end;

class procedure TMessaging.RegisterSubscriber(
        aSubscriber: TObject);
begin
  CommonChannel.RegisterSubscriber(aSubscriber);
end;

class procedure TMessaging.UnregisterSubscriber(
        aSubscriber: TObject);
begin
  CommonChannel.UnregisterSubscriber(aSubscriber);
end;

class procedure TMessaging.FreeSubscriber(
        aSubscriber: TObject);
begin
  CommonChannel.FreeSubscriber(aSubscriber);
end;

class procedure TMessaging.Send(
        const aMessageID: string;
        const aData     : TObject);
begin
  CommonChannel.Send(aMessageID, aData);
end;

class procedure TMessaging.Send(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>);
begin
  CommonChannel.Send(aMessageID, aData, aExceptedSubscribers);
end;

class procedure TMessaging.SendThenFree(
        const aMessageID: string;
        const aData     : TObject);
begin
  CommonChannel.SendThenFree(aMessageID, aData);
end;

class procedure TMessaging.SendThenFree(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>);
begin
  CommonChannel.SendThenFree(aMessageID, aData, aExceptedSubscribers);;
end;

{ TValueWrapper<T> }

constructor TValueWrapper<T>.Create(
        aValue: T);
begin
  fValue := aValue;
end;

end.
