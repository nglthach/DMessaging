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

unit DMessaging.UIHelper;

interface

uses
  System.Classes,
  DMessaging,
  DMessaging.Channel;

type
  TMessageChannelHelper = class helper for TMessageChannel
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
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>); overload;
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
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>); overload;
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
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>); overload;
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
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>); overload;
  end;
  /// <summary>
  ///
  /// </summary>
  TMessagingHelper = record helper for TMessaging
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
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>); overload; static;
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
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>); overload; static;
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
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>); overload; static;
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
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>); overload; static;
  end;


implementation

{ TMessageChannelHelper }

procedure TMessageChannelHelper.SendInMainThread(
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

procedure TMessageChannelHelper.SendInMainThread(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>);
begin
  TThread.ForceQueue(nil,
    procedure
    begin
      Send(aMessageID, aData, aExceptedSubscribers);
    end
  );
end;

procedure TMessageChannelHelper.SendInMainThreadThenFree(
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

procedure TMessageChannelHelper.SendInMainThreadThenFree(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>);
begin
  TThread.ForceQueue(nil,
    procedure
    begin
      SendThenFree(aMessageID, aData, aExceptedSubscribers);
    end
  );
end;

procedure TMessageChannelHelper.SendInMainThreadSync(
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

procedure TMessageChannelHelper.SendInMainThreadSync(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      Send(aMessageID, aData, aExceptedSubscribers);
    end
  );
end;

procedure TMessageChannelHelper.SendInMainThreadThenFreeSync(
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

procedure TMessageChannelHelper.SendInMainThreadThenFreeSync(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      SendThenFree(aMessageID, aData, aExceptedSubscribers);
    end
  );
end;

{ TMessagingHelper }

class procedure TMessagingHelper.SendInMainThread(
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

class procedure TMessagingHelper.SendInMainThread(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>);
begin
  TThread.ForceQueue(nil,
    procedure
    begin
      Send(aMessageID, aData, aExceptedSubscribers);
    end
  );
end;

class procedure TMessagingHelper.SendInMainThreadThenFree(
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

class procedure TMessagingHelper.SendInMainThreadThenFree(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>);
begin
  TThread.ForceQueue(nil,
    procedure
    begin
      SendThenFree(aMessageID, aData, aExceptedSubscribers);
    end
  );
end;

class procedure TMessagingHelper.SendInMainThreadSync(
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

class procedure TMessagingHelper.SendInMainThreadSync(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      Send(aMessageID, aData, aExceptedSubscribers);
    end
  );
end;

class procedure TMessagingHelper.SendInMainThreadThenFreeSync(
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

class procedure TMessagingHelper.SendInMainThreadThenFreeSync(
        const aMessageID          : string;
        const aData               : TObject;
        const aExceptedSubscribers: TArray<TObject>);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      SendThenFree(aMessageID, aData, aExceptedSubscribers);
    end
  );
end;

end.
