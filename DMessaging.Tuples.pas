{****************************************************}
{                                                    }
{  Generics.Tuples                                   }
{                                                    }
{  Copyright (C) 2014 Malcolm Groves                 }
{                                                    }
{  https://github.com/malcolmgroves/generics.tuples  }
{                                                    }
{****************************************************}
{                                                    }
{  This Source Code Form is subject to the terms of  }
{  the Mozilla Public License, v. 2.0. If a copy of  }
{  the MPL was not distributed with this file, You   }
{  can obtain one at                                 }
{                                                    }
{  http://mozilla.org/MPL/2.0/                       }
{                                                    }
{****************************************************}

unit DMessaging.Tuples;

interface

type
  /// <summary>
  ///
  /// </summary>
  TTupleOwnerships = set of (
      toOwnsAll,
      toOwnsValue1,
      toOwnsValue2,
      toOwnsValue3,
      toOwnsValue4,
      toOwnsValue5
  );
  /// <summary>
  ///
  /// </summary>
  ITuple<T1, T2> = interface
    procedure SetValue1(Value : T1);
    function GetValue1 : T1;
    procedure SetValue2(Value : T2);
    function GetValue2 : T2;
    property Value1 : T1 read GetValue1 write SetValue1;
    property Value2 : T2 read GetValue2 write SetValue2;
  end;
  /// <summary>
  ///
  /// </summary>
  ITuple<T1, T2, T3> = interface(ITuple<T1, T2>)
    procedure SetValue3(Value : T3);
    function GetValue3 : T3;
    property Value3 : T3 read GetValue3 write SetValue3;
  end;
  /// <summary>
  ///
  /// </summary>
  ITuple<T1, T2, T3, T4> = interface(ITuple<T1, T2, T3>)
    procedure SetValue4(Value : T4);
    function GetValue4 : T4;
    property Value4 : T4 read GetValue4 write SetValue4;
  end;
  /// <summary>
  ///
  /// </summary>
  ITuple<T1, T2, T3, T4, T5> = interface(ITuple<T1, T2, T3, T4>)
    procedure SetValue5(Value : T5);
    function GetValue5 : T5;
    property Value5 : T5 read GetValue5 write SetValue5;
  end;
  /// <summary>
  ///
  /// </summary>
  TTuple<T1, T2> = class(TInterfacedObject, ITuple<T1, T2>)
  protected
    FOwnerships: TTupleOwnerships;
    FValue1 : T1;
    FValue2 : T2;
    /// <summary>
    ///
    /// </summary>
    procedure SetValue1(Value : T1);
    /// <summary>
    ///
    /// </summary>
    function GetValue1 : T1;
    /// <summary>
    ///
    /// </summary>
    procedure SetValue2(Value : T2);
    /// <summary>
    ///
    /// </summary>
    function GetValue2 : T2;
  public
    /// <summary>
    ///
    /// </summary>
    constructor Create(Value1 : T1; Value2 : T2; Ownerships: TTupleOwnerships = []); virtual;
    /// <summary>
    ///
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    ///
    /// </summary>
    property Value1 : T1 read FValue1 write FValue1;
    /// <summary>
    ///
    /// </summary>
    property Value2 : T2
        read  FValue2
        write FValue2;
  end;
  /// <summary>
  ///
  /// </summary>
  TTuple<T1, T2, T3> = class(TTuple<T1, T2>, ITuple<T1, T2, T3>)
  protected
    FValue3 : T3;
    /// <summary>
    ///
    /// </summary>
    procedure SetValue3(Value : T3);
    /// <summary>
    ///
    /// </summary>
    function GetValue3 : T3;
  public
    /// <summary>
    ///
    /// </summary>
    constructor Create(Value1 : T1; Value2 : T2; Value3 : T3; Ownerships: TTupleOwnerships = []); reintroduce;
    /// <summary>
    ///
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    ///
    /// </summary>
    property Value3 : T3
        read  GetValue3
        write SetValue3;
  end;
  /// <summary>
  ///
  /// </summary>
  TTuple<T1, T2, T3, T4> = class(TTuple<T1, T2, T3>, ITuple<T1, T2, T3, T4>)
  protected
    FValue4 : T4;
    /// <summary>
    ///
    /// </summary>
    procedure SetValue4(Value : T4);
    /// <summary>
    ///
    /// </summary>
    function GetValue4 : T4;
  public
    /// <summary>
    ///
    /// </summary>
    constructor Create(Value1 : T1; Value2 : T2; Value3 : T3; Value4: T4; Ownerships: TTupleOwnerships = []); reintroduce;
    /// <summary>
    ///
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    ///
    /// </summary>
    property Value4 : T4
        read  GetValue4
        write SetValue4;
  end;
  /// <summary>
  ///
  /// </summary>
  TTuple<T1, T2, T3, T4, T5> = class(TTuple<T1, T2, T3, T4>, ITuple<T1, T2, T3, T4, T5>)
  protected
    FValue5 : T5;
    /// <summary>
    ///
    /// </summary>
    procedure SetValue5(Value : T5);
    /// <summary>
    ///
    /// </summary>
    function GetValue5 : T5;
  public
    /// <summary>
    ///
    /// </summary>
    constructor Create(
        Value1 : T1; Value2 : T2; Value3 : T3; Value4: T4; Value5: T5;
        Ownerships: TTupleOwnerships = []); reintroduce;
    /// <summary>
    ///
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    ///
    /// </summary>
    property Value5 : T5
        read  GetValue5
        write SetValue5;
  end;

implementation

uses
  System.RTTI;

{ TPair<T1, T2> }

constructor TTuple<T1, T2>.Create(Value1: T1; Value2: T2; Ownerships: TTupleOwnerships);
begin
  FOwnerships := Ownerships;
  FValue1 := Value1;
  FValue2 := Value2;
end;

destructor TTuple<T1, T2>.Destroy;
{$IFNDEF AUTOREFCOUNT}
var
  LValue1Holder, LValue2Holder : TValue;
{$ENDIF}
begin
{$IFNDEF AUTOREFCOUNT}
  LValue1Holder := TValue.From<T1>(FValue1);
  if ((toOwnsAll in FOwnerships) or (toOwnsValue1 in FOwnerships)) and LValue1Holder.IsObject then
    LValue1Holder.AsObject.Free;

  LValue2Holder := TValue.From<T2>(FValue2);
  if ((toOwnsAll in FOwnerships) or (toOwnsValue2 in FOwnerships)) and LValue2Holder.IsObject then
    LValue2Holder.AsObject.Free;
  inherited;
{$ENDIF}
end;

function TTuple<T1, T2>.GetValue1: T1;
begin
  Result := FValue1;
end;

function TTuple<T1, T2>.GetValue2: T2;
begin
  Result := FValue2;
end;

procedure TTuple<T1, T2>.SetValue1(Value: T1);
begin
  FValue1 := Value;
end;

procedure TTuple<T1, T2>.SetValue2(Value: T2);
begin
  FValue2 := Value;
end;

{ TTuple3<T1, T2, T3> }

constructor TTuple<T1, T2, T3>.Create(Value1: T1; Value2: T2; Value3: T3; Ownerships: TTupleOwnerships);
begin
  inherited Create(Value1, Value2, Ownerships);
  Self.Value3 := Value3;
end;

destructor TTuple<T1, T2, T3>.Destroy;
{$IFNDEF AUTOREFCOUNT}
var
  LValue3Holder : TValue;
{$ENDIF}
begin
{$IFNDEF AUTOREFCOUNT}
  LValue3Holder := TValue.From<T3>(FValue3);
  if ((toOwnsAll in FOwnerships) or (toOwnsValue3 in FOwnerships)) and LValue3Holder.IsObject then
    LValue3Holder.AsObject.Free;
{$ENDIF}
  inherited;
end;

function TTuple<T1, T2, T3>.GetValue3: T3;
begin
  Result := FValue3;
end;

procedure TTuple<T1, T2, T3>.SetValue3(Value: T3);
begin
  FValue3 := Value;
end;

{ TTuple<T1, T2, T3, T4> }

constructor TTuple<T1, T2, T3, T4>.Create(Value1: T1; Value2: T2; Value3: T3; Value4: T4; Ownerships: TTupleOwnerships);
begin
  inherited Create(Value1, Value2, Value3, Ownerships);
  Self.Value4 := Value4;
end;

destructor TTuple<T1, T2, T3, T4>.Destroy;
{$IFNDEF AUTOREFCOUNT}
var
  LValue4Holder : TValue;
{$ENDIF}
begin
{$IFNDEF AUTOREFCOUNT}
  LValue4Holder := TValue.From<T4>(FValue4);
  if ((toOwnsAll in FOwnerships) or (toOwnsValue4 in FOwnerships)) and LValue4Holder.IsObject then
    LValue4Holder.AsObject.Free;
{$ENDIF}
  inherited;
end;

function TTuple<T1, T2, T3, T4>.GetValue4: T4;
begin
  Result := FValue4;
end;

procedure TTuple<T1, T2, T3, T4>.SetValue4(Value: T4);
begin
  FValue4 := Value;
end;

{ TTuple<T1, T2, T3, T4, T5> }

constructor TTuple<T1, T2, T3, T4, T5>.Create(Value1: T1; Value2: T2; Value3: T3; Value4: T4; Value5: T5; Ownerships: TTupleOwnerships);
begin
  inherited Create(Value1, Value2, Value3, Value4, Ownerships);
  Self.Value5 := Value5;
end;

destructor TTuple<T1, T2, T3, T4, T5>.Destroy;
{$IFNDEF AUTOREFCOUNT}
var
  LValue5Holder : TValue;
{$ENDIF}
begin
{$IFNDEF AUTOREFCOUNT}
  LValue5Holder := TValue.From<T4>(FValue4);
  if ((toOwnsAll in FOwnerships) or (toOwnsValue5 in FOwnerships)) and LValue5Holder.IsObject then
    LValue5Holder.AsObject.Free;
{$ENDIF}
  inherited;
end;

function TTuple<T1, T2, T3, T4, T5>.GetValue5: T5;
begin
  Result := FValue5;
end;

procedure TTuple<T1, T2, T3, T4, T5>.SetValue5(Value: T5);
begin
  FValue5 := Value;
end;

end.
